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

import io.ballerina.compiler.syntax.tree.AbstractNodeFactory;
import io.ballerina.compiler.syntax.tree.BasicLiteralNode;
import io.ballerina.compiler.syntax.tree.BindingPatternNode;
import io.ballerina.compiler.syntax.tree.CaptureBindingPatternNode;
import io.ballerina.compiler.syntax.tree.ChildNodeEntry;
import io.ballerina.compiler.syntax.tree.ClientResourceAccessActionNode;
import io.ballerina.compiler.syntax.tree.ExpressionNode;
import io.ballerina.compiler.syntax.tree.FieldAccessExpressionNode;
import io.ballerina.compiler.syntax.tree.FieldBindingPatternVarnameNode;
import io.ballerina.compiler.syntax.tree.FromClauseNode;
import io.ballerina.compiler.syntax.tree.FunctionArgumentNode;
import io.ballerina.compiler.syntax.tree.FunctionCallExpressionNode;
import io.ballerina.compiler.syntax.tree.GroupByClauseNode;
import io.ballerina.compiler.syntax.tree.GroupingKeyVarDeclarationNode;
import io.ballerina.compiler.syntax.tree.IntermediateClauseNode;
import io.ballerina.compiler.syntax.tree.LimitClauseNode;
import io.ballerina.compiler.syntax.tree.MappingBindingPatternNode;
import io.ballerina.compiler.syntax.tree.ModulePartNode;
import io.ballerina.compiler.syntax.tree.NameReferenceNode;
import io.ballerina.compiler.syntax.tree.NamedArgumentNode;
import io.ballerina.compiler.syntax.tree.Node;
import io.ballerina.compiler.syntax.tree.NodeFactory;
import io.ballerina.compiler.syntax.tree.NodeList;
import io.ballerina.compiler.syntax.tree.OrderByClauseNode;
import io.ballerina.compiler.syntax.tree.OrderKeyNode;
import io.ballerina.compiler.syntax.tree.ParenthesizedArgList;
import io.ballerina.compiler.syntax.tree.PositionalArgumentNode;
import io.ballerina.compiler.syntax.tree.QueryPipelineNode;
import io.ballerina.compiler.syntax.tree.SeparatedNodeList;
import io.ballerina.compiler.syntax.tree.SimpleNameReferenceNode;
import io.ballerina.compiler.syntax.tree.SyntaxKind;
import io.ballerina.compiler.syntax.tree.SyntaxTree;
import io.ballerina.compiler.syntax.tree.Token;
import io.ballerina.compiler.syntax.tree.TreeModifier;
import io.ballerina.compiler.syntax.tree.WhereClauseNode;
import io.ballerina.projects.Document;
import io.ballerina.projects.DocumentId;
import io.ballerina.projects.Module;
import io.ballerina.projects.ModuleId;
import io.ballerina.projects.Package;
import io.ballerina.projects.plugins.ModifierTask;
import io.ballerina.projects.plugins.SourceModifierContext;
import io.ballerina.stdlib.persist.sql.compiler.Constants;
import io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes;
import io.ballerina.stdlib.persist.sql.compiler.exception.NotSupportedExpressionException;
import io.ballerina.stdlib.persist.sql.compiler.expression.ExpressionBuilder;
import io.ballerina.stdlib.persist.sql.compiler.expression.ExpressionVisitor;
import io.ballerina.stdlib.persist.sql.compiler.utils.Utils;
import io.ballerina.tools.diagnostics.Diagnostic;
import io.ballerina.tools.diagnostics.DiagnosticFactory;
import io.ballerina.tools.diagnostics.DiagnosticInfo;
import org.ballerinalang.formatter.core.Formatter;
import org.ballerinalang.formatter.core.FormatterException;

import java.io.PrintStream;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Code modifier for query expression.
 */
public class QueryCodeModifierTask implements ModifierTask<SourceModifierContext> {

    private final Map<String, String> variables;
    private final List<String> entities;
    private final List<String> persistClientNames;
    private final List<String> persistClientVariables = new ArrayList<>();
    private boolean isClientVariablesProcessed = false;

    public QueryCodeModifierTask(List<String> persistClientNames, List<String> entities,
                                 Map<String, String> variables) {
        this.entities = entities;
        this.variables = variables;
        this.persistClientNames = persistClientNames;
    }

    @Override
    public void modify(SourceModifierContext sourceModifierContext) {
        if (persistClientNames.isEmpty()) {
            return;
        }
        if (!isClientVariablesProcessed) {
            processPersistClientVariables();
        }

        if (this.persistClientVariables.isEmpty()) {
            return;
        }

        Package pkg = sourceModifierContext.currentPackage();
        for (ModuleId moduleId : pkg.moduleIds()) {
            Module module = pkg.module(moduleId);
            for (DocumentId documentId : module.documentIds()) {
                SyntaxTree syntaxTree = getUpdatedSyntaxTree(module, documentId, sourceModifierContext);
                if (syntaxTree != null) {
                    sourceModifierContext.modifySourceFile(syntaxTree.textDocument(), documentId);
                }
            }
            for (DocumentId documentId : module.testDocumentIds()) {
                SyntaxTree syntaxTree = getUpdatedSyntaxTree(module, documentId, sourceModifierContext);
                if (syntaxTree != null) {
                    sourceModifierContext.modifyTestSourceFile(syntaxTree.textDocument(), documentId);
                }
            }
        }
    }

    private SyntaxTree getUpdatedSyntaxTree(Module module, DocumentId documentId, SourceModifierContext ctx) {
        Document document = module.document(documentId);
        ModulePartNode rootNode = document.syntaxTree().rootNode();
        QueryConstructModifier queryConstructModifier = new QueryConstructModifier(entities,
                persistClientVariables, ctx);
        ModulePartNode newRoot = (ModulePartNode) rootNode.apply(queryConstructModifier);
        if (queryConstructModifier.isSourceCodeModified()) {
            SyntaxTree syntaxTree = document.syntaxTree().modifyWith(newRoot);
            try {
                Formatter.format(syntaxTree);
            } catch (FormatterException e) {
                // throw new RuntimeException("Syntax tree formatting failed for the file: " + document.name());
            }
            return syntaxTree;
        }
        return null;
    }

    private void processPersistClientVariables() {
        for (Map.Entry<String, String> entry : this.variables.entrySet()) {
            String[] strings = entry.getValue().split(":");
            if (persistClientNames.contains(strings[strings.length - 1])) {
                persistClientVariables.add(entry.getKey());
            }
        }
        isClientVariablesProcessed = true;
    }

    private static class QueryConstructModifier extends TreeModifier {
        private final List<String> persistClientVariables;
        private final List<String> entities;
        private boolean isSourceCodeModified = false;
        private SourceModifierContext ctx;

        public QueryConstructModifier(List<String> entities, List<String> persistClientVariables,
                                      SourceModifierContext ctx) {
            this.entities = entities;
            this.persistClientVariables = persistClientVariables;
            this.ctx = ctx;
        }

        @Override
        public QueryPipelineNode transform(QueryPipelineNode queryPipelineNode) {
            FromClauseNode fromClauseNode = queryPipelineNode.fromClause();
            if (!isQueryUsingPersistentClient(fromClauseNode)) {
                return queryPipelineNode;
            }

            NodeList<IntermediateClauseNode> intermediateClauseNodes = queryPipelineNode.intermediateClauses();
            List<IntermediateClauseNode> letClauseNodes = intermediateClauseNodes.stream()
                    .filter((node) -> node.kind().equals(SyntaxKind.LET_CLAUSE))
                    .collect(Collectors.toList());
            boolean isLetClauseNodesUsed = letClauseNodes.size() != 0;
            if (isLetClauseNodesUsed) {
                return queryPipelineNode;
            }

            List<IntermediateClauseNode> whereClauseNode = intermediateClauseNodes.stream()
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

            boolean isWhereClauseUsed = whereClauseNode.size() != 0;
            boolean isOrderByClauseUsed = orderByClauseNode.size() != 0;
            boolean isLimitClauseUsed = limitClauseNode.size() != 0;
            boolean isGroupByClauseUsed = groupByClauseNode.size() != 0;

            if (!isWhereClauseUsed && !isOrderByClauseUsed && !isLimitClauseUsed && !isGroupByClauseUsed) {
                return queryPipelineNode;
            }

            ClientResourceAccessActionNode clientResourceAccessActionNode =
                    (ClientResourceAccessActionNode) fromClauseNode.expression();
            Optional<ParenthesizedArgList> argument = clientResourceAccessActionNode.arguments();
            if (argument.isEmpty()) {
                return queryPipelineNode;
            }
            List<Node> arguments = new ArrayList<>();
            arguments.add(argument.get().arguments().get(0));
            if (isWhereClauseUsed) {
                List<Node> whereClauseParameterizedQuery = new ArrayList<>();
                whereClauseParameterizedQuery.add(Utils.getStringLiteralToken(Constants.SPACE));

                try {
                    List<Node> whereClause = processWhereClause(((WhereClauseNode) whereClauseNode.get(0)),
                            fromClauseNode.typedBindingPattern().bindingPattern());
                    whereClauseParameterizedQuery.addAll(whereClause);
                } catch (NotSupportedExpressionException e) {
                    // Need to
                    return queryPipelineNode;
                }

                PositionalArgumentNode parameterizedQueryForWhere = NodeFactory.createPositionalArgumentNode(
                        NodeFactory.createTemplateExpressionNode(
                                SyntaxKind.RAW_TEMPLATE_EXPRESSION, null,
                                Constants.TokenNodes.BACKTICK_TOKEN,
                                AbstractNodeFactory.createSeparatedNodeList(whereClauseParameterizedQuery),
                                Constants.TokenNodes.BACKTICK_TOKEN
                        )
                );
                arguments.add(NodeFactory.createNamedArgumentNode(NodeFactory.createSimpleNameReferenceNode(
                        Constants.TokenNodes.WHERE_CLAUSE_NAME), Constants.TokenNodes.EQUAL_TOKEN,
                        parameterizedQueryForWhere.expression()));
            }

            if (isOrderByClauseUsed) {
                List<Node> orderByClauseParameterizedQuery = new ArrayList<>();
                orderByClauseParameterizedQuery.add(Utils.getStringLiteralToken(Constants.SPACE));

                Node orderByClause = processOrderByClause(((OrderByClauseNode) orderByClauseNode.get(0)),
                        fromClauseNode.typedBindingPattern().bindingPattern());
                orderByClauseParameterizedQuery.add(orderByClause);

                PositionalArgumentNode parameterizedQueryForOrder = NodeFactory.createPositionalArgumentNode(
                        NodeFactory.createTemplateExpressionNode(
                                SyntaxKind.RAW_TEMPLATE_EXPRESSION, null,
                                Constants.TokenNodes.BACKTICK_TOKEN,
                                AbstractNodeFactory.createSeparatedNodeList(orderByClauseParameterizedQuery),
                                Constants.TokenNodes.BACKTICK_TOKEN
                        )
                );
                arguments.add(NodeFactory.createNamedArgumentNode(
                        NodeFactory.createSimpleNameReferenceNode(
                                Constants.TokenNodes.ORDER_BY_CLAUSE_NAME), Constants.TokenNodes.EQUAL_TOKEN,
                        parameterizedQueryForOrder.expression()));
            }

            if (isGroupByClauseUsed) {
                List<Node> groupByClauseParameterizedQuery = new ArrayList<>();
                groupByClauseParameterizedQuery.add(Utils.getStringLiteralToken(Constants.SPACE));

                Node groupByClause = processGroupByClause(((GroupByClauseNode) groupByClauseNode.get(0)),
                        fromClauseNode.typedBindingPattern().bindingPattern());
                groupByClauseParameterizedQuery.add(groupByClause);

                PositionalArgumentNode parameterizedQueryForGroupBy = NodeFactory.createPositionalArgumentNode(
                        NodeFactory.createTemplateExpressionNode(
                                SyntaxKind.RAW_TEMPLATE_EXPRESSION, null,
                                Constants.TokenNodes.BACKTICK_TOKEN,
                                AbstractNodeFactory.createSeparatedNodeList(groupByClauseParameterizedQuery),
                                Constants.TokenNodes.BACKTICK_TOKEN
                        )
                );
                arguments.add(NodeFactory.createNamedArgumentNode(
                        NodeFactory.createSimpleNameReferenceNode(
                                Constants.TokenNodes.GROUP_BY_CLAUSE_NAME), Constants.TokenNodes.EQUAL_TOKEN,
                        parameterizedQueryForGroupBy.expression()));
            }
            if (isLimitClauseUsed) {
                List<Node> limitClauseParameterizedQuery = new ArrayList<>();
                limitClauseParameterizedQuery.add(Utils.getStringLiteralToken(Constants.SPACE));
                Node limitClause = processLimitClause(((LimitClauseNode) limitClauseNode.get(0)));
                limitClauseParameterizedQuery.add(limitClause);

                PositionalArgumentNode parameterizedQueryForOrder = NodeFactory.createPositionalArgumentNode(
                        NodeFactory.createTemplateExpressionNode(
                                SyntaxKind.RAW_TEMPLATE_EXPRESSION, null,
                                Constants.TokenNodes.BACKTICK_TOKEN,
                                AbstractNodeFactory.createSeparatedNodeList(limitClauseParameterizedQuery),
                                Constants.TokenNodes.BACKTICK_TOKEN
                        )
                );
                arguments.add(NodeFactory.createNamedArgumentNode(NodeFactory.createSimpleNameReferenceNode(
                                Constants.TokenNodes.LIMIT_CLAUSE_NAME), Constants.TokenNodes.EQUAL_TOKEN,
                        parameterizedQueryForOrder.expression()));
            }
            int argumentSize = arguments.size();
            // todo: need to handle more than 4 arguments
            SeparatedNodeList<FunctionArgumentNode> separatedNodeList;
            if (argumentSize == 2) {
                separatedNodeList = NodeFactory.createSeparatedNodeList(arguments.get(0),
                        Constants.TokenNodes.COMMA_TOKEN, arguments.get(1));
            } else if (argumentSize == 3) {
                separatedNodeList = NodeFactory.createSeparatedNodeList(arguments.get(0),
                        Constants.TokenNodes.COMMA_TOKEN, arguments.get(1), Constants.TokenNodes.COMMA_TOKEN,
                        arguments.get(2));
            } else if (argumentSize == 4) {
                separatedNodeList = NodeFactory.createSeparatedNodeList(arguments.get(0),
                        Constants.TokenNodes.COMMA_TOKEN, arguments.get(1), Constants.TokenNodes.COMMA_TOKEN,
                        arguments.get(2), Constants.TokenNodes.COMMA_TOKEN, arguments.get(3));
            }  else {
                separatedNodeList = NodeFactory.createSeparatedNodeList(arguments.get(0),
                        Constants.TokenNodes.COMMA_TOKEN, arguments.get(1), Constants.TokenNodes.COMMA_TOKEN,
                        arguments.get(2), Constants.TokenNodes.COMMA_TOKEN, arguments.get(3),
                        Constants.TokenNodes.COMMA_TOKEN, arguments.get(4));
            }

            ParenthesizedArgList parenthesizedArgList = NodeFactory.createParenthesizedArgList(
                    Constants.TokenNodes.OPEN_PAREN_TOKEN,
                    separatedNodeList,
                    Constants.TokenNodes.CLOSE_PAREN_WITH_NEW_LINE_TOKEN
            );

            FromClauseNode modifiedFromClause = fromClauseNode.modify(
                    fromClauseNode.fromKeyword(),
                    fromClauseNode.typedBindingPattern(),
                    fromClauseNode.inKeyword(),
                    NodeFactory.createClientResourceAccessActionNode(
                            clientResourceAccessActionNode.expression(),
                            clientResourceAccessActionNode.rightArrowToken(),
                            clientResourceAccessActionNode.slashToken(),
                            clientResourceAccessActionNode.resourceAccessPath(),
                            null,
                            null,
                            parenthesizedArgList
                    )
            );
            this.isSourceCodeModified = true;
            return queryPipelineNode.modify(
                    modifiedFromClause,
                    intermediateClauseNodes
            );
        }

        public boolean isSourceCodeModified() {
            return this.isSourceCodeModified;
        }

        private boolean isQueryUsingPersistentClient(FromClauseNode fromClauseNode) {
            // From clause should contain resource call invocation
            if (fromClauseNode.expression() instanceof ClientResourceAccessActionNode) {
                ClientResourceAccessActionNode remoteCall =
                        (ClientResourceAccessActionNode) fromClauseNode.expression();
                Collection<ChildNodeEntry> clientResourceChildEntries = remoteCall.childEntries();
                int size = clientResourceChildEntries.size();
                PrintStream asd = System.out;
                asd.println("size: " + size);
                if (size != 5 && size != 7) {
                    return false;
                }
                if (remoteCall.expression() instanceof SimpleNameReferenceNode) {
                    SimpleNameReferenceNode clientName = (SimpleNameReferenceNode) remoteCall.expression();
                    if (!this.persistClientVariables.contains(clientName.name().text().trim())) {
                        return false;
                    }
                    Object[] childEntries = clientResourceChildEntries.toArray();
                    boolean validResourcePath = false;
                    Optional<Node> resourcePath = ((ChildNodeEntry) childEntries[3]).node();
                    if (resourcePath.isPresent() && this.entities.contains(resourcePath.get().toString().trim())) {
                        validResourcePath = true;
                        if (clientResourceChildEntries.size() == 7) {
                            resourcePath = ((ChildNodeEntry) childEntries[5]).node();
                            validResourcePath = resourcePath.isPresent() &&
                                    resourcePath.get().toString().trim().equals("get");
                        }
                    }
                    boolean hasTargetType = false;
                    boolean hasClauseVariable = false;
                    if (validResourcePath) {
                        Optional<ParenthesizedArgList> arguments = remoteCall.arguments();
                        if (arguments.isPresent()) {
                            SeparatedNodeList<FunctionArgumentNode> argumentNodes = arguments.get().arguments();
                            for (FunctionArgumentNode functionArgumentNode: argumentNodes) {
                                if (functionArgumentNode instanceof NamedArgumentNode) {
                                    NamedArgumentNode namedArgumentNode = (NamedArgumentNode) functionArgumentNode;
                                    String argumentsName = namedArgumentNode.argumentName().toString().trim();
                                    if (namedArgumentNode.argumentName().toString().trim().equals("targetType")) {
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
                                }
                            }
                            return hasTargetType && !hasClauseVariable;
                        }
                    }
                    return validResourcePath;
                }
            }
            return false;
        }

        private List<Node> processWhereClause(WhereClauseNode whereClauseNode, BindingPatternNode bindingPatternNode)
                throws NotSupportedExpressionException {
            ExpressionBuilder expressionBuilder = new ExpressionBuilder(whereClauseNode.expression(),
                    bindingPatternNode);
            ExpressionVisitor expressionVisitor = new ExpressionVisitor();
            expressionBuilder.build(expressionVisitor);
            return expressionVisitor.getExpression();
        }

        private Node processOrderByClause(OrderByClauseNode orderByClauseNode,
                                          BindingPatternNode bindingPatternNode) {
            StringBuilder orderByClause = new StringBuilder();
            SeparatedNodeList<OrderKeyNode> orderKeyNodes = orderByClauseNode.orderKey();
            for (int i = 0; i < orderKeyNodes.size(); i++) {
                if (i != 0) {
                    orderByClause.append(Constants.COMMA_WITH_SPACE);
                }
                ExpressionNode expression = orderKeyNodes.get(i).expression();
                if (expression instanceof FieldAccessExpressionNode) {
                    FieldAccessExpressionNode fieldAccessNode = (FieldAccessExpressionNode) expression;
                    if (!(bindingPatternNode instanceof CaptureBindingPatternNode)) {
                        // If this is not capture pattern there is compilation error
                        return null;
                    }
                    String bindingVariableName = ((CaptureBindingPatternNode) bindingPatternNode).variableName().text();
                    String recordName = ((SimpleNameReferenceNode) fieldAccessNode.expression()).name().text();
                    if (!bindingVariableName.equals(recordName)) {
                        return null;
                    }
                    String fieldName = ((SimpleNameReferenceNode) fieldAccessNode.fieldName()).name().text();
                    orderByClause.append(fieldName);
                } else if (expression instanceof SimpleNameReferenceNode) {
                    String fieldName = ((SimpleNameReferenceNode) expression).name().text();

                    if (!(bindingPatternNode instanceof MappingBindingPatternNode)) {
                        // If this is not mapping pattern there is compilation error
                        return null;
                    }
                    boolean isCorrectField = false;
                    SeparatedNodeList<BindingPatternNode> bindingPatternNodes =
                            ((MappingBindingPatternNode) bindingPatternNode).fieldBindingPatterns();
                    for (BindingPatternNode patternNode : bindingPatternNodes) {
                        String field = ((FieldBindingPatternVarnameNode) patternNode).variableName().name().text();
                        if (fieldName.equals(field)) {
                            isCorrectField = true;
                        }
                    }
                    if (!isCorrectField) {
                        return null;
                    }
                    orderByClause.append(fieldName);
                } else if (expression instanceof FunctionCallExpressionNode) {
                    FunctionCallExpressionNode functionCallExpressionNode = (FunctionCallExpressionNode) expression;
                    NameReferenceNode fun = functionCallExpressionNode.functionName();
                    SeparatedNodeList<FunctionArgumentNode> arguments = functionCallExpressionNode.arguments();
                    String referencedName =  Constants.INTERPOLATION_START_TOKEN + fun.toSourceCode().trim() +
                            functionCallExpressionNode.openParenToken().text() +  arguments.get(0).toSourceCode() +
                            functionCallExpressionNode.closeParenToken().text() +  Constants.INTERPOLATION_END_TOKEN;
                    orderByClause.append(referencedName);
                } else {
                    // Persistent client does not support order by using parameters
                    return null;
                }
                if (orderKeyNodes.get(i).orderDirection().isPresent()) {
                    Token orderDirection = orderKeyNodes.get(i).orderDirection().get();
                    if (orderDirection.text().equals(Constants.ASCENDING)) {
                        orderByClause.append(Constants.SPACE).append(Constants.SQLKeyWords.ORDER_BY_ASCENDING);
                    } else {
                        orderByClause.append(Constants.SPACE).append(Constants.SQLKeyWords.ORDER_BY_DECENDING);
                    }
                    // Any typos are recognised as order by direction missing
                }
                orderByClause.append(Constants.SPACE);
            }
            return Utils.getStringLiteralToken(orderByClause.toString());
        }

        private Node processGroupByClause(GroupByClauseNode groupByClauseNode,
                                          BindingPatternNode bindingPatternNode) {
            StringBuilder groupByClause = new StringBuilder();
            SeparatedNodeList<Node> groupingKey = groupByClauseNode.groupingKey();
            for (int i = 0; i < groupingKey.size(); i++) {
                if (i != 0) {
                    groupByClause.append(Constants.COMMA_WITH_SPACE);
                }
                ExpressionNode expression = ((GroupingKeyVarDeclarationNode) groupingKey.get(i)).expression();
                if (expression instanceof FieldAccessExpressionNode) {
                    FieldAccessExpressionNode fieldAccessNode = (FieldAccessExpressionNode) expression;
                    if (!(bindingPatternNode instanceof CaptureBindingPatternNode)) {
                        // If this is not capture pattern there is compilation error
                        return null;
                    }
                    String bindingVariableName = ((CaptureBindingPatternNode) bindingPatternNode).variableName().text();
                    String recordName = ((SimpleNameReferenceNode) fieldAccessNode.expression()).name().text();
                    if (!bindingVariableName.equals(recordName)) {
                        return null;
                    }
                    String fieldName = ((SimpleNameReferenceNode) fieldAccessNode.fieldName()).name().text();
                    groupByClause.append(fieldName);
                } else if (expression instanceof FunctionCallExpressionNode) {
                    FunctionCallExpressionNode functionCallExpressionNode = (FunctionCallExpressionNode) expression;
                    NameReferenceNode fun = functionCallExpressionNode.functionName();
                    SeparatedNodeList<FunctionArgumentNode> arguments = functionCallExpressionNode.arguments();
                    String referencedName = Constants.INTERPOLATION_START_TOKEN + fun.toSourceCode().trim() +
                            functionCallExpressionNode.openParenToken().text() +  arguments.get(0).toSourceCode() +
                            functionCallExpressionNode.closeParenToken().text() + Constants.INTERPOLATION_END_TOKEN;
                    groupByClause.append(referencedName);
                } else {
                    // Persistent client does not support group by using parameters
                    return null;
                }
            }
            return Utils.getStringLiteralToken(groupByClause.toString());
        }

        private Node processLimitClause(LimitClauseNode limitClauseNode) {
            ExpressionNode limitByExpression = limitClauseNode.expression();
            if (limitByExpression instanceof BasicLiteralNode &&
                    limitByExpression.kind() == SyntaxKind.NUMERIC_LITERAL) {
                return Utils.getStringLiteralToken(Constants.SPACE + ((BasicLiteralNode) limitByExpression).
                        literalToken().text());
            } else if (limitByExpression instanceof SimpleNameReferenceNode) {
                return Utils.getStringLiteralToken(Constants.INTERPOLATION_START_TOKEN +
                        ((SimpleNameReferenceNode) limitByExpression).name().text().trim() +
                        Constants.INTERPOLATION_END_TOKEN);
            } else if (limitByExpression instanceof FunctionCallExpressionNode) {
                FunctionCallExpressionNode functionCallExpressionNode = (FunctionCallExpressionNode) limitByExpression;
                NameReferenceNode fun = functionCallExpressionNode.functionName();
                SeparatedNodeList<FunctionArgumentNode> arguments = functionCallExpressionNode.arguments();
                return Utils.getStringLiteralToken(Constants.INTERPOLATION_START_TOKEN +
                        fun.toSourceCode().trim() + functionCallExpressionNode.openParenToken().text() +
                        arguments.get(0).toSourceCode() + functionCallExpressionNode.closeParenToken().text() +
                        Constants.INTERPOLATION_END_TOKEN);
            } else {
                return null;
            }
        }
    }
}