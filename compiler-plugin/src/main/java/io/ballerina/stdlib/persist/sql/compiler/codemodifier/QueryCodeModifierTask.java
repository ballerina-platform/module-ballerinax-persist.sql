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
import io.ballerina.compiler.syntax.tree.ClientResourceAccessActionNode;
import io.ballerina.compiler.syntax.tree.ExpressionNode;
import io.ballerina.compiler.syntax.tree.FieldAccessExpressionNode;
import io.ballerina.compiler.syntax.tree.FromClauseNode;
import io.ballerina.compiler.syntax.tree.FunctionArgumentNode;
import io.ballerina.compiler.syntax.tree.FunctionCallExpressionNode;
import io.ballerina.compiler.syntax.tree.GroupByClauseNode;
import io.ballerina.compiler.syntax.tree.GroupingKeyVarDeclarationNode;
import io.ballerina.compiler.syntax.tree.IntermediateClauseNode;
import io.ballerina.compiler.syntax.tree.LimitClauseNode;
import io.ballerina.compiler.syntax.tree.LiteralValueToken;
import io.ballerina.compiler.syntax.tree.ModulePartNode;
import io.ballerina.compiler.syntax.tree.NameReferenceNode;
import io.ballerina.compiler.syntax.tree.Node;
import io.ballerina.compiler.syntax.tree.NodeFactory;
import io.ballerina.compiler.syntax.tree.NodeList;
import io.ballerina.compiler.syntax.tree.OptionalFieldAccessExpressionNode;
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
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.stdlib.persist.sql.compiler.Constants;
import io.ballerina.stdlib.persist.sql.compiler.exception.NotSupportedExpressionException;
import io.ballerina.stdlib.persist.sql.compiler.expression.ExpressionBuilder;
import io.ballerina.stdlib.persist.sql.compiler.expression.ExpressionVisitor;
import io.ballerina.stdlib.persist.sql.compiler.model.Query;
import io.ballerina.tools.diagnostics.Diagnostic;
import io.ballerina.tools.diagnostics.DiagnosticSeverity;
import org.ballerinalang.formatter.core.Formatter;
import org.ballerinalang.formatter.core.FormatterException;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Code modifier for query expression.
 */
public class QueryCodeModifierTask implements ModifierTask<SourceModifierContext> {

    private final Map<QueryPipelineNode, Query> validatedQueries;

    public QueryCodeModifierTask(Map<QueryPipelineNode, Query> validatedQueries) {
        this.validatedQueries = validatedQueries;
    }

    @Override
    public void modify(SourceModifierContext sourceModifierContext) {
        Package pkg = sourceModifierContext.currentPackage();
        for (ModuleId moduleId : pkg.moduleIds()) {
            Module module = pkg.module(moduleId);
            for (DocumentId documentId : module.documentIds()) {
                SyntaxTree syntaxTree = getUpdatedSyntaxTree(module, documentId, this.validatedQueries);
                if (syntaxTree != null) {
                    sourceModifierContext.modifySourceFile(syntaxTree.textDocument(), documentId);
                }
            }
            for (DocumentId documentId : module.testDocumentIds()) {
                SyntaxTree syntaxTree = getUpdatedSyntaxTree(module, documentId, this.validatedQueries);
                if (syntaxTree != null) {
                    sourceModifierContext.modifyTestSourceFile(syntaxTree.textDocument(), documentId);
                }
            }
        }
    }

    private SyntaxTree getUpdatedSyntaxTree(Module module, DocumentId documentId,
                                            Map<QueryPipelineNode, Query> validatedQueries) {
        Document document = module.document(documentId);
        ModulePartNode rootNode = document.syntaxTree().rootNode();
        QueryConstructModifier queryConstructModifier = new QueryConstructModifier(validatedQueries);
        ModulePartNode newRoot = (ModulePartNode) rootNode.apply(queryConstructModifier);
        if (queryConstructModifier.isSourceCodeModified()) {
            SyntaxTree syntaxTree = document.syntaxTree().modifyWith(newRoot);
            try {
                Formatter.format(syntaxTree);
            } catch (FormatterException e) {
                // ignore
            }
            return syntaxTree;
        }
        return null;
    }

    private static class QueryConstructModifier extends TreeModifier {
        private boolean isSourceCodeModified = false;
        private final Map<QueryPipelineNode, Query> validatedQueries;

        public QueryConstructModifier(Map<QueryPipelineNode, Query> validatedQueries) {
            this.validatedQueries = validatedQueries;
        }

        @Override
        public QueryPipelineNode transform(QueryPipelineNode queryPipelineNode) {
            if (!validatedQueries.containsKey(queryPipelineNode)) {
                return queryPipelineNode;
            }
            Query query = validatedQueries.get(queryPipelineNode);

            if (query.getLetClauseNodes().size() > 0) {
                return queryPipelineNode;
            }
            FromClauseNode fromClauseNode = queryPipelineNode.fromClause();
            NodeList<IntermediateClauseNode> intermediateClauseNodes = queryPipelineNode.intermediateClauses();

            List<IntermediateClauseNode> whereClauseNode = query.getWhereClause();

            List<IntermediateClauseNode> orderByClauseNode = query.getOrderByClause();

            List<IntermediateClauseNode> limitClauseNode = query.getLimitClauses();

            List<IntermediateClauseNode> groupByClauseNode = query.getGroupByClauses();

            boolean isWhereClauseUsed = whereClauseNode.size() != 0;
            boolean isOrderByClauseUsed = orderByClauseNode.size() != 0;
            boolean isLimitClauseUsed = limitClauseNode.size() != 0;
            boolean isGroupByClauseUsed = groupByClauseNode.size() != 0;

            if (!isWhereClauseUsed && !isOrderByClauseUsed && !isLimitClauseUsed && !isGroupByClauseUsed) {
                return queryPipelineNode;
            }

            ClientResourceAccessActionNode clientResourceAccessActionNode =
                    (ClientResourceAccessActionNode) fromClauseNode.expression();
            SeparatedNodeList<FunctionArgumentNode> queryArguments = query.getArguments();
            List<Node> arguments = new ArrayList<>();
            arguments.add(queryArguments.get(0));
            if (isWhereClauseUsed) {
                List<Node> whereClauseParameterizedQuery = new ArrayList<>();
                whereClauseParameterizedQuery.add(getStringLiteralToken(Constants.SPACE));

                try {
                    List<Node> whereClause = processWhereClause(((WhereClauseNode) whereClauseNode.get(0)),
                            fromClauseNode.typedBindingPattern().bindingPattern(), query);
                    whereClauseParameterizedQuery.addAll(whereClause);
                } catch (NotSupportedExpressionException e) {
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
                orderByClauseParameterizedQuery.add(getStringLiteralToken(Constants.SPACE));

                Node orderByClause = processOrderByClause(((OrderByClauseNode) orderByClauseNode.get(0)),
                        fromClauseNode.typedBindingPattern().bindingPattern(), query);
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
                groupByClauseParameterizedQuery.add(getStringLiteralToken(Constants.SPACE));

                Node groupByClause = processGroupByClause(((GroupByClauseNode) groupByClauseNode.get(0)),
                        fromClauseNode.typedBindingPattern().bindingPattern(), query);
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
                limitClauseParameterizedQuery.add(getStringLiteralToken(Constants.SPACE));
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

        private List<Node> processWhereClause(WhereClauseNode whereClauseNode, BindingPatternNode bindingPatternNode,
                                              Query query) throws NotSupportedExpressionException {
            ExpressionBuilder expressionBuilder = new ExpressionBuilder(whereClauseNode.expression(),
                    bindingPatternNode);
            ExpressionVisitor expressionVisitor = new ExpressionVisitor();
            expressionBuilder.build(expressionVisitor, query);
            return expressionVisitor.getExpression();
        }

        private Node processOrderByClause(OrderByClauseNode orderByClauseNode,
                                          BindingPatternNode bindingPatternNode, Query query) {
            StringBuilder orderByClause = new StringBuilder();
            SeparatedNodeList<OrderKeyNode> orderKeyNodes = orderByClauseNode.orderKey();
            String tableName = query.getTableName();
            for (int i = 0; i < orderKeyNodes.size(); i++) {
                if (i != 0) {
                    orderByClause.append(Constants.COMMA_WITH_SPACE);
                }
                ExpressionNode expression = orderKeyNodes.get(i).expression();
                if (expression instanceof FieldAccessExpressionNode fieldAccessNode) {
                    if (!(bindingPatternNode instanceof CaptureBindingPatternNode)) {
                        // If this is not capture pattern there is compilation error
                        return null;
                    }
                    String bindingVariableName = ((CaptureBindingPatternNode) bindingPatternNode).
                            variableName().text();
                    Node node = fieldAccessNode.expression();
                    if (node instanceof FieldAccessExpressionNode accessExpressionNode) {
                        if (!bindingVariableName.equals(accessExpressionNode.expression().toSourceCode().trim())) {
                            return null;
                        }
                        String relationalTableName = stripEscapeCharacter(accessExpressionNode.fieldName().
                                toSourceCode().trim());
                        orderByClause.append(relationalTableName).append(".").
                                append(stripEscapeCharacter(((FieldAccessExpressionNode) expression).fieldName().
                                        toSourceCode().trim()));
                    } else {
                        String recordName = stripEscapeCharacter(((SimpleNameReferenceNode) fieldAccessNode.
                                expression()).name().text());
                        if (!bindingVariableName.equals(recordName)) {
                            return null;
                        }
                        orderByClause.append(tableName).append(".").append(
                                stripEscapeCharacter(((SimpleNameReferenceNode) fieldAccessNode.fieldName()).
                                        name().text()));
                    }
                } else if (expression instanceof SimpleNameReferenceNode) {
                    orderByClause.append(Constants.INTERPOLATION_START_TOKEN).append(
                                    ((SimpleNameReferenceNode) expression).name().text()).
                            append(Constants.INTERPOLATION_END_TOKEN);
                } else if (expression instanceof OptionalFieldAccessExpressionNode fieldNode) {
                    orderByClause.append(getReferenceTableName(fieldNode)).append(".").
                            append(stripEscapeCharacter(fieldNode.fieldName().toSourceCode().trim()));
                } else if (expression instanceof FunctionCallExpressionNode) {
                    orderByClause.append(Constants.INTERPOLATION_START_TOKEN).append(getReferenceTableName(
                            (FunctionCallExpressionNode) expression)).append(Constants.INTERPOLATION_END_TOKEN);
                } else {
                    // Persistent client does not support order by using parameters
                    return null;
                }
                if (orderKeyNodes.get(i).orderDirection().isPresent()) {
                    Token orderDirection = orderKeyNodes.get(i).orderDirection().get();
                    if (orderDirection.text().equals(Constants.DESCENDING)) {
                        orderByClause.append(Constants.SPACE).append(Constants.SQLKeyWords.ORDER_BY_DESCENDING);
                    } else {
                        orderByClause.append(Constants.SPACE).append(Constants.SQLKeyWords.ORDER_BY_ASCENDING);
                    }
                } else {
                    orderByClause.append(Constants.SPACE).append(Constants.SQLKeyWords.ORDER_BY_ASCENDING);
                }
                orderByClause.append(Constants.SPACE);
            }
            return getStringLiteralToken(orderByClause.toString());
        }

        private Node processGroupByClause(GroupByClauseNode groupByClauseNode,
                                          BindingPatternNode bindingPatternNode, Query query) {
            StringBuilder groupByClause = new StringBuilder();
            SeparatedNodeList<Node> groupingKey = groupByClauseNode.groupingKey();
            String tableName = query.getTableName();
            for (int i = 0; i < groupingKey.size(); i++) {
                if (i != 0) {
                    groupByClause.append(Constants.COMMA_WITH_SPACE);
                }
                ExpressionNode expression = ((GroupingKeyVarDeclarationNode) groupingKey.get(i)).expression();
                if (expression instanceof FieldAccessExpressionNode fieldAccessNode) {
                    if (!(bindingPatternNode instanceof CaptureBindingPatternNode)) {
                        // If this is not capture pattern there is compilation error
                        return null;
                    }
                    String bindingVariableName = ((CaptureBindingPatternNode) bindingPatternNode).variableName().text();
                    Node node = fieldAccessNode.expression();
                    if (node instanceof FieldAccessExpressionNode accessExpressionNode) {
                        if (!bindingVariableName.equals(accessExpressionNode.expression().toSourceCode().trim())) {
                            return null;
                        }
                        String relationalTableName = stripEscapeCharacter(accessExpressionNode.fieldName().
                                toSourceCode().trim());
                        groupByClause.append(relationalTableName).append(".").
                                append(stripEscapeCharacter(((FieldAccessExpressionNode) expression).fieldName().
                                        toSourceCode().trim()));
                    } else {
                        if (!bindingVariableName.equals(((SimpleNameReferenceNode) fieldAccessNode.
                                expression()).name().text())) {
                            return null;
                        }
                        String fieldName = stripEscapeCharacter(((SimpleNameReferenceNode) fieldAccessNode.
                                fieldName()).name().text());
                        groupByClause.append(tableName).append(".").append(fieldName);
                    }
                } else if (expression instanceof OptionalFieldAccessExpressionNode fieldNode) {
                    groupByClause.append(getReferenceTableName(fieldNode)).append(".").
                            append(stripEscapeCharacter(fieldNode.fieldName().toSourceCode().trim()));
                } else if (expression instanceof FunctionCallExpressionNode) {
                    groupByClause.append(Constants.INTERPOLATION_START_TOKEN).append(getReferenceTableName(
                            (FunctionCallExpressionNode) expression)).append(Constants.INTERPOLATION_END_TOKEN);
                } else if (expression instanceof SimpleNameReferenceNode) {
                    groupByClause.append(Constants.INTERPOLATION_START_TOKEN).append(
                            ((SimpleNameReferenceNode) expression).name().text()).
                            append(Constants.INTERPOLATION_END_TOKEN);
                } else {
                    // Persistent client does not support group by using parameters
                    return null;
                }
            }
            return getStringLiteralToken(groupByClause.toString());
        }

        private Node processLimitClause(LimitClauseNode limitClauseNode) {
            ExpressionNode limitByExpression = limitClauseNode.expression();
            if (limitByExpression instanceof BasicLiteralNode &&
                    limitByExpression.kind() == SyntaxKind.NUMERIC_LITERAL) {
                return getStringLiteralToken(Constants.SPACE + ((BasicLiteralNode) limitByExpression).
                        literalToken().text());
            } else if (limitByExpression instanceof SimpleNameReferenceNode) {
                return getStringLiteralToken(Constants.INTERPOLATION_START_TOKEN +
                        ((SimpleNameReferenceNode) limitByExpression).name().text().trim() +
                        Constants.INTERPOLATION_END_TOKEN);
            } else if (limitByExpression instanceof FunctionCallExpressionNode functionCallExpressionNode) {
                NameReferenceNode fun = functionCallExpressionNode.functionName();
                SeparatedNodeList<FunctionArgumentNode> arguments = functionCallExpressionNode.arguments();
                return getStringLiteralToken(Constants.INTERPOLATION_START_TOKEN +
                        fun.toSourceCode().trim() + functionCallExpressionNode.openParenToken().text() +
                        arguments.get(0).toSourceCode() + functionCallExpressionNode.closeParenToken().text() +
                        Constants.INTERPOLATION_END_TOKEN);
            } else {
                return null;
            }
        }
    }

    public static boolean hasCompilationErrors(SyntaxNodeAnalysisContext context) {
        for (Diagnostic diagnostic : context.compilation().diagnosticResult().diagnostics()) {
            if (diagnostic.diagnosticInfo().severity() == DiagnosticSeverity.ERROR) {
                return true;
            }
        }
        return false;
    }

    public static LiteralValueToken getStringLiteralToken(String value) {
        return NodeFactory.createLiteralValueToken(
                SyntaxKind.STRING_LITERAL, value, AbstractNodeFactory.createEmptyMinutiaeList(), 
                AbstractNodeFactory.createEmptyMinutiaeList());
    }

    public static String stripEscapeCharacter(String name) {
        return name.startsWith("'") ? name.substring(1) : name;
    }

    public static String getReferenceTableName(FunctionCallExpressionNode expression) {
        NameReferenceNode functionName = expression.functionName();
        SeparatedNodeList<FunctionArgumentNode> arguments = expression.arguments();
        return functionName.toSourceCode().trim() + expression.openParenToken().text() +
                arguments.get(0).toSourceCode() + expression.closeParenToken().text();
    }

    public static String getReferenceTableName(OptionalFieldAccessExpressionNode expression) {
        return stripEscapeCharacter(((FieldAccessExpressionNode) expression.
                expression()).fieldName().toSourceCode().trim());
    }
}
