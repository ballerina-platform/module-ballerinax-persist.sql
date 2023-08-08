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

package io.ballerina.stdlib.persist.sql.compiler.expression;

import io.ballerina.compiler.syntax.tree.BasicLiteralNode;
import io.ballerina.compiler.syntax.tree.BinaryExpressionNode;
import io.ballerina.compiler.syntax.tree.BindingPatternNode;
import io.ballerina.compiler.syntax.tree.BracedExpressionNode;
import io.ballerina.compiler.syntax.tree.CaptureBindingPatternNode;
import io.ballerina.compiler.syntax.tree.ChildNodeList;
import io.ballerina.compiler.syntax.tree.ExpressionNode;
import io.ballerina.compiler.syntax.tree.FieldAccessExpressionNode;
import io.ballerina.compiler.syntax.tree.FieldBindingPatternVarnameNode;
import io.ballerina.compiler.syntax.tree.FunctionCallExpressionNode;
import io.ballerina.compiler.syntax.tree.IndexedExpressionNode;
import io.ballerina.compiler.syntax.tree.LiteralValueToken;
import io.ballerina.compiler.syntax.tree.MappingBindingPatternNode;
import io.ballerina.compiler.syntax.tree.OptionalFieldAccessExpressionNode;
import io.ballerina.compiler.syntax.tree.SeparatedNodeList;
import io.ballerina.compiler.syntax.tree.SimpleNameReferenceNode;
import io.ballerina.compiler.syntax.tree.SyntaxKind;
import io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes;
import io.ballerina.stdlib.persist.sql.compiler.exception.NotSupportedExpressionException;
import io.ballerina.stdlib.persist.sql.compiler.model.Query;
import io.ballerina.stdlib.persist.sql.compiler.utils.Utils;
import io.ballerina.tools.diagnostics.Diagnostic;
import io.ballerina.tools.diagnostics.DiagnosticFactory;
import io.ballerina.tools.diagnostics.DiagnosticInfo;

import java.util.ArrayList;
import java.util.List;

/**
 * Builder class to process where clause.
 */
public class ExpressionBuilder {
    private final ExpressionNode expressionNode;
    private boolean isCaptureBindingPattern = false;
    private String bindingVariableName = "";
    private final List<String> fieldNames = new ArrayList<>();

    public ExpressionBuilder(ExpressionNode expression, BindingPatternNode bindingPatternNode) {
        this.expressionNode = expression;
        if (bindingPatternNode instanceof CaptureBindingPatternNode) {
            this.isCaptureBindingPattern = true;
            this.bindingVariableName = ((CaptureBindingPatternNode) bindingPatternNode).variableName().text();
        } else if (bindingPatternNode instanceof MappingBindingPatternNode) {
            SeparatedNodeList<BindingPatternNode> bindingPatternNodes =
                    ((MappingBindingPatternNode) bindingPatternNode).fieldBindingPatterns();
            for (BindingPatternNode patternNode : bindingPatternNodes) {
                String field = ((FieldBindingPatternVarnameNode) patternNode).variableName().name().text();
                fieldNames.add(field);
            }
        }
    }
    public void build(ExpressionVisitor expressionVisitor, Query query) throws NotSupportedExpressionException {
        buildVariableExecutors(expressionNode, expressionVisitor, query);
    }
    private void buildVariableExecutors(ExpressionNode expressionNode, ExpressionVisitor expressionVisitor,
                                        Query query)
            throws NotSupportedExpressionException {
        try {
            String tableName = query.getTableName();
            if (expressionNode instanceof BinaryExpressionNode) {
                // Simple Compare
                ChildNodeList expressionChildren = expressionNode.children();
                SyntaxKind tokenKind = expressionChildren.get(1).kind();
                if (tokenKind == SyntaxKind.LOGICAL_AND_TOKEN) {
                    expressionVisitor.beginVisitAnd();
                    expressionVisitor.beginVisitAndLeftOperand();
                    buildVariableExecutors((ExpressionNode) expressionChildren.get(0), expressionVisitor, query);
                    expressionVisitor.endVisitAndLeftOperand();
                    expressionVisitor.beginVisitAndRightOperand();
                    buildVariableExecutors((ExpressionNode) expressionChildren.get(2), expressionVisitor, query);
                    expressionVisitor.endVisitAndRightOperand();
                    expressionVisitor.endVisitAnd();
                } else if (tokenKind == SyntaxKind.LOGICAL_OR_TOKEN) {
                    expressionVisitor.beginVisitOr();
                    expressionVisitor.beginVisitOrLeftOperand();
                    buildVariableExecutors((ExpressionNode) expressionChildren.get(0), expressionVisitor, query);
                    expressionVisitor.endVisitOrLeftOperand();
                    expressionVisitor.beginVisitOrRightOperand();
                    buildVariableExecutors((ExpressionNode) expressionChildren.get(2), expressionVisitor, query);
                    expressionVisitor.endVisitOrRightOperand();
                    expressionVisitor.endVisitOr();
                } else {
                    expressionVisitor.beginVisitCompare(tokenKind);
                    expressionVisitor.beginVisitCompareLeftOperand(tokenKind);
                    buildVariableExecutors((ExpressionNode) expressionChildren.get(0), expressionVisitor, query);
                    expressionVisitor.endVisitCompareLeftOperand(tokenKind);
                    expressionVisitor.beginVisitCompareRightOperand(tokenKind);
                    buildVariableExecutors((ExpressionNode) expressionChildren.get(2), expressionVisitor, query);
                    expressionVisitor.endVisitCompareRightOperand(tokenKind);
                    expressionVisitor.endVisitCompare(tokenKind);
                }
            } else if (expressionNode instanceof BracedExpressionNode) {
                expressionVisitor.beginVisitBraces();
                buildVariableExecutors(((BracedExpressionNode) expressionNode).expression(), expressionVisitor, query);
                expressionVisitor.endVisitBraces();
            } else if (expressionNode instanceof FieldAccessExpressionNode) {
                FieldAccessExpressionNode exp = (FieldAccessExpressionNode) expressionNode;
                String fieldName = Utils.stripEscapeCharacter(exp.fieldName().toSourceCode().trim());
                ExpressionNode fieldAccessName = exp.expression();
                if (this.isCaptureBindingPattern && bindingVariableName.equals(fieldAccessName.toSourceCode().trim())) {
                    updateExpressionVisitor(tableName + "." + fieldName, expressionVisitor);
                } else {
                    if (fieldAccessName instanceof FieldAccessExpressionNode) {
                        tableName = Utils.stripEscapeCharacter(((FieldAccessExpressionNode) fieldAccessName).
                                fieldName().toSourceCode().trim());
                        updateExpressionVisitor(tableName + "." + fieldName, expressionVisitor);
                    } else if (fieldAccessName instanceof IndexedExpressionNode) {
                        IndexedExpressionNode indexedExpressionNode = (IndexedExpressionNode) fieldAccessName;
                        tableName = Utils.stripEscapeCharacter(((FieldAccessExpressionNode) indexedExpressionNode.
                                containerExpression()).fieldName().toSourceCode().trim());
                        updateExpressionVisitor(tableName + "." + fieldName, expressionVisitor);
                    } else {
                        throw new NotSupportedExpressionException("Unsupported field access in where clause");
                    }
                }
            } else if (expressionNode instanceof OptionalFieldAccessExpressionNode) {
                OptionalFieldAccessExpressionNode fieldNode = (OptionalFieldAccessExpressionNode) expressionNode;
                updateExpressionVisitor(Utils.getReferenceTableName(fieldNode) + "." +
                        Utils.stripEscapeCharacter(fieldNode.fieldName().toSourceCode().trim()), expressionVisitor);
            } else if (expressionNode instanceof SimpleNameReferenceNode) {
                String referencedName = Utils.stripEscapeCharacter(
                        ((SimpleNameReferenceNode) expressionNode).name().text());
                if (this.isCaptureBindingPattern) {
                    expressionVisitor.beginVisitBalVariable(referencedName);
                    expressionVisitor.endVisitBalVariable(referencedName);
                } else {
                    // Mapping constructor
                    if (fieldNames.contains(referencedName)) {
                        expressionVisitor.beginVisitStoreVariable(referencedName);
                        expressionVisitor.endVisitStoreVariable(referencedName);
                    } else {
                        // todo Here wrong reference name cannot be identified as error
                        updateExpressionVisitor(referencedName, expressionVisitor);
                    }
                }
            } else if (expressionNode instanceof BasicLiteralNode) {
                LiteralValueToken literalValueToken = (LiteralValueToken) expressionNode.children().get(0);
                expressionVisitor.beginVisitConstant(literalValueToken.text(), literalValueToken.kind());
                expressionVisitor.endVisitConstant(literalValueToken.text(), literalValueToken.kind());
            } else if (expressionNode instanceof FunctionCallExpressionNode) {
                String referencedName = Utils.getReferenceTableName((FunctionCallExpressionNode) expressionNode);
                expressionVisitor.beginVisitBalVariable(referencedName);
                expressionVisitor.endVisitBalVariable(referencedName);
            } else {
                throw new NotSupportedExpressionException("Unsupported expression.");
            }
        } catch (NotSupportedExpressionException e) {
            if (e.getDiagnostic() == null) {
                DiagnosticInfo diagnosticInfo = new DiagnosticInfo(DiagnosticsCodes.PERSIST_SQL_201.getCode(),
                        DiagnosticsCodes.PERSIST_SQL_201.getMessage(), DiagnosticsCodes.PERSIST_SQL_201.getSeverity());
                Diagnostic diagnostic = DiagnosticFactory.createDiagnostic(diagnosticInfo, expressionNode.location());
                throw new NotSupportedExpressionException("Unsupported expression.", diagnostic);
            } else {
                throw e;
            }
        }
    }

    private void updateExpressionVisitor(String fieldName, ExpressionVisitor expressionVisitor) {
        expressionVisitor.beginVisitStoreVariable(fieldName);
        expressionVisitor.endVisitStoreVariable(fieldName);
    }
}
