/*
 * Copyright (c) 2023, WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.stdlib.persist.sql.compiler.codemodifier;

import io.ballerina.compiler.syntax.tree.ChildNodeEntry;
import io.ballerina.compiler.syntax.tree.ClientResourceAccessActionNode;
import io.ballerina.compiler.syntax.tree.ExpressionNode;
import io.ballerina.compiler.syntax.tree.FromClauseNode;
import io.ballerina.compiler.syntax.tree.FunctionArgumentNode;
import io.ballerina.compiler.syntax.tree.GroupByClauseNode;
import io.ballerina.compiler.syntax.tree.IntermediateClauseNode;
import io.ballerina.compiler.syntax.tree.LimitClauseNode;
import io.ballerina.compiler.syntax.tree.NamedArgumentNode;
import io.ballerina.compiler.syntax.tree.Node;
import io.ballerina.compiler.syntax.tree.NodeList;
import io.ballerina.compiler.syntax.tree.NodeLocation;
import io.ballerina.compiler.syntax.tree.OrderByClauseNode;
import io.ballerina.compiler.syntax.tree.ParenthesizedArgList;
import io.ballerina.compiler.syntax.tree.PositionalArgumentNode;
import io.ballerina.compiler.syntax.tree.QueryPipelineNode;
import io.ballerina.compiler.syntax.tree.SeparatedNodeList;
import io.ballerina.compiler.syntax.tree.SimpleNameReferenceNode;
import io.ballerina.compiler.syntax.tree.SyntaxKind;
import io.ballerina.compiler.syntax.tree.TemplateExpressionNode;
import io.ballerina.compiler.syntax.tree.WhereClauseNode;
import io.ballerina.projects.plugins.AnalysisTask;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.stdlib.persist.sql.compiler.Constants;
import io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes;
import io.ballerina.stdlib.persist.sql.compiler.model.Query;
import io.ballerina.stdlib.persist.sql.compiler.utils.Utils;
import io.ballerina.tools.diagnostics.Diagnostic;
import io.ballerina.tools.diagnostics.DiagnosticFactory;
import io.ballerina.tools.diagnostics.DiagnosticInfo;

import java.text.MessageFormat;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Analysis task to validate queries.
 */
public class PersistQueryValidator implements AnalysisTask<SyntaxNodeAnalysisContext> {

    private final Map<String, String> entities;
    private final List<String> persistClientNames;
    private final List<String> persistClientVariableNames;
    private final Map<String, String> variables;
    private final Map<QueryPipelineNode, Query> queries;
    private final Map<QueryPipelineNode, Query> validatedQueries;

    public PersistQueryValidator(Map<String, String> entities, List<String> persistClientNames,
                                 Map<String, String> variables, Map<QueryPipelineNode, Query> queries,
                                 Map<QueryPipelineNode, Query> validatedQueries,
                                 List<String> persistClientVariableNames) {
        this.entities = entities;
        this.persistClientNames = persistClientNames;
        this.variables = variables;
        this.queries = queries;
        this.validatedQueries = validatedQueries;
        this.persistClientVariableNames = persistClientVariableNames;
    }

    @Override
    public void perform(SyntaxNodeAnalysisContext ctx) {
        if (Utils.hasCompilationErrors(ctx)) {
            return;
        }

        QueryPipelineNode queryPipelineNode = (QueryPipelineNode) ctx.node();
        FromClauseNode fromClauseNode = queryPipelineNode.fromClause();
        Query query = isQueryUsingPersistentClient(fromClauseNode);
        if (query == null) {
            return;
        }

        NodeList<IntermediateClauseNode> intermediateClauseNodes = queryPipelineNode.intermediateClauses();
        List<IntermediateClauseNode> whereClauseNodes = intermediateClauseNodes.stream()
                .filter((node) -> node instanceof WhereClauseNode)
                .collect(Collectors.toList());

        List<IntermediateClauseNode> orderByClauseNode = intermediateClauseNodes.stream()
                .filter((node) -> node instanceof OrderByClauseNode)
                .collect(Collectors.toList());

        List<IntermediateClauseNode> limitClauseNode = intermediateClauseNodes.stream()
                .filter((node) -> node instanceof LimitClauseNode)
                .collect(Collectors.toList());

        List<IntermediateClauseNode> groupByClauseNode = intermediateClauseNodes.stream()
                .filter((node) -> node instanceof GroupByClauseNode)
                .collect(Collectors.toList());

        boolean isWhereClauseUsed = whereClauseNodes.size() != 0;
        boolean isOrderByClauseUsed = orderByClauseNode.size() != 0;
        boolean isLimitClauseUsed = limitClauseNode.size() != 0;
        boolean groupByClauseUsed = groupByClauseNode.size() != 0;

        if (!isWhereClauseUsed && !isOrderByClauseUsed && !isLimitClauseUsed && !groupByClauseUsed) {
            return;
        }

        List<IntermediateClauseNode> letClauseNodes = intermediateClauseNodes.stream()
                .filter((node) -> node.kind().equals(SyntaxKind.LET_CLAUSE))
                .collect(Collectors.toList());

        if (groupByClauseUsed) {
            NodeLocation groupByClauseLocation = groupByClauseNode.get(0).location();
            int groupByClauseEndLine = groupByClauseLocation.lineRange().startLine().line();
            if (isWhereClauseUsed) {
                if (groupByClauseEndLine < whereClauseNodes.get(0).location().lineRange().startLine().line()) {
                    DiagnosticInfo diagnosticInfo = new DiagnosticInfo(DiagnosticsCodes.
                            PERSIST_SQL_204.getCode(), MessageFormat.format(
                            DiagnosticsCodes.PERSIST_SQL_204.getMessage(), Constants.WHERE),
                            DiagnosticsCodes.PERSIST_SQL_204.getSeverity());
                    Diagnostic diagnostic = DiagnosticFactory.createDiagnostic(diagnosticInfo, groupByClauseLocation);
                    ctx.reportDiagnostic(diagnostic);
                    return;
                }
            }
            if (isOrderByClauseUsed) {
                if (groupByClauseEndLine < orderByClauseNode.get(0).location().lineRange().startLine().line()) {
                    DiagnosticInfo diagnosticInfo = new DiagnosticInfo(DiagnosticsCodes.
                            PERSIST_SQL_204.getCode(), MessageFormat.format(
                            DiagnosticsCodes.PERSIST_SQL_204.getMessage(), Constants.ORDER_BY),
                            DiagnosticsCodes.PERSIST_SQL_204.getSeverity());
                    Diagnostic diagnostic = DiagnosticFactory.createDiagnostic(diagnosticInfo, groupByClauseLocation);
                    ctx.reportDiagnostic(diagnostic);
                    return;
                }
            }
        }
        query.addWhereClause(whereClauseNodes);
        query.addLimitClauses(limitClauseNode);
        query.addGroupByClauses(groupByClauseNode);
        query.addOrderByClause(orderByClauseNode);
        query.addLetClauseNodes(letClauseNodes);
        this.queries.put(queryPipelineNode, query);
        validateQuery(ctx);
    }

    private Query isQueryUsingPersistentClient(FromClauseNode fromClauseNode) {
        if (fromClauseNode.expression() instanceof ClientResourceAccessActionNode) {
            ClientResourceAccessActionNode remoteCall =
                    (ClientResourceAccessActionNode) fromClauseNode.expression();
            SimpleNameReferenceNode clientName = (SimpleNameReferenceNode) remoteCall.expression();
            Collection<ChildNodeEntry> clientResourceChildEntries = remoteCall.childEntries();
            if (clientResourceChildEntries.size() == 5 || clientResourceChildEntries.size() == 7) {
                SeparatedNodeList<FunctionArgumentNode> argumentsList = null;
                Optional<ParenthesizedArgList> arguments = remoteCall.arguments();
                Optional<SimpleNameReferenceNode> methodNameNode = remoteCall.methodName();
                SimpleNameReferenceNode methodName;
                if (methodNameNode.isPresent()) {
                    methodName = methodNameNode.get();
                    if (!methodName.toSourceCode().trim().equals(Constants.GET)) {
                        return null;
                    }
                }
                if (arguments.isPresent()) {
                    argumentsList = arguments.get().arguments();
                }
                return new Query(clientName.toSourceCode().trim(), argumentsList, remoteCall.resourceAccessPath());
            }
        }
        return null;
    }

    public void validateQuery(SyntaxNodeAnalysisContext ctx) {
        if (!this.persistClientNames.isEmpty() && !this.entities.isEmpty()) {
            processPersistClientVariables();
            Map<QueryPipelineNode, Query> temp = this.queries;
            for (Map.Entry<QueryPipelineNode, Query> entry : temp.entrySet()) {
                Query query = entry.getValue();
                if (query.isValidated()) {
                    continue;
                }
                // Validate whether the client name is a persist client or not
                if (!this.persistClientVariableNames.contains(query.getClientName())) {
                    query.validated = true;
                    continue;
                }
                // Validate the resource path
                SeparatedNodeList<Node> resourcePath = query.getPath();
                if (resourcePath.size() == 0) {
                    query.validated = true;
                    continue;
                }
                String path = resourcePath.get(0).toString().trim();
                if (!this.entities.containsKey(path)) {
                    query.validated = true;
                    continue;
                }
                query.addTableName(this.entities.get(path));
                // Validate arguments
                SeparatedNodeList<FunctionArgumentNode> argumentNodes = query.getArguments();
                if (argumentNodes.size() == 0) {
                    query.validated = true;
                    continue;
                }
                boolean hasTargetType = false;
                boolean hasClauseVariable = false;
                for (FunctionArgumentNode functionArgumentNode : argumentNodes) {
                    if (functionArgumentNode instanceof NamedArgumentNode) {
                        NamedArgumentNode namedArgumentNode = (NamedArgumentNode) functionArgumentNode;
                        String argumentsName = namedArgumentNode.argumentName().toString().trim();
                        if (namedArgumentNode.argumentName().toString().trim().equals(Constants.TARGET_TYPE)) {
//                            query.addTargetType(Utils.stripEscapeCharacter(
//                                    ((QualifiedNameReferenceNode) namedArgumentNode.expression()).identifier().
//                                            text().trim()));
                            hasTargetType = true;
                        } else {
                            hasClauseVariable = true;
                            DiagnosticInfo diagnosticInfo = new DiagnosticInfo(DiagnosticsCodes.
                                    PERSIST_SQL_202.getCode(), MessageFormat.format(
                                    DiagnosticsCodes.PERSIST_SQL_202.getMessage(), argumentsName),
                                    DiagnosticsCodes.PERSIST_SQL_202.getSeverity());
                            Diagnostic diagnostic = DiagnosticFactory.createDiagnostic(diagnosticInfo,
                                    functionArgumentNode.location());
                            ctx.reportDiagnostic(diagnostic);
                        }
                    } else if (functionArgumentNode instanceof PositionalArgumentNode) {
                        PositionalArgumentNode positionalArgumentNode = (PositionalArgumentNode) functionArgumentNode;
                        ExpressionNode expression = positionalArgumentNode.expression();
                        if (expression instanceof SimpleNameReferenceNode) {
//                            query.addTargetType(Utils.stripEscapeCharacter(
//                                    ((SimpleNameReferenceNode) expression).name().text()));
                            hasTargetType = true;
                        } else if (expression instanceof TemplateExpressionNode) {
                            hasClauseVariable = true;
                            DiagnosticInfo diagnosticInfo = new DiagnosticInfo(DiagnosticsCodes.
                                    PERSIST_SQL_203.getCode(), DiagnosticsCodes.PERSIST_SQL_203.getMessage(),
                                    DiagnosticsCodes.PERSIST_SQL_203.getSeverity());
                            Diagnostic diagnostic = DiagnosticFactory.createDiagnostic(diagnosticInfo,
                                    expression.location());
                            ctx.reportDiagnostic(diagnostic);
                        }

                    }
                }
                query.validated = true;
                if (hasTargetType && !hasClauseVariable) {
                    this.validatedQueries.put(entry.getKey(), entry.getValue());
                }
            }
        }
    }

    private void processPersistClientVariables() {
        for (Map.Entry<String, String> entry : variables.entrySet()) {
            String[] strings = entry.getValue().split(Constants.COLON);
            if (this.persistClientNames.size() != 0 && this.persistClientNames.contains(strings[strings.length - 1])) {
                this.persistClientVariableNames.add(entry.getKey());
            }
        }
    }
}
