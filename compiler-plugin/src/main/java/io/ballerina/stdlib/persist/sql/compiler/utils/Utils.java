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
package io.ballerina.stdlib.persist.sql.compiler.utils;

import io.ballerina.compiler.syntax.tree.FieldAccessExpressionNode;
import io.ballerina.compiler.syntax.tree.FunctionArgumentNode;
import io.ballerina.compiler.syntax.tree.FunctionCallExpressionNode;
import io.ballerina.compiler.syntax.tree.LiteralValueToken;
import io.ballerina.compiler.syntax.tree.NameReferenceNode;
import io.ballerina.compiler.syntax.tree.NodeFactory;
import io.ballerina.compiler.syntax.tree.OptionalFieldAccessExpressionNode;
import io.ballerina.compiler.syntax.tree.SeparatedNodeList;
import io.ballerina.compiler.syntax.tree.SyntaxKind;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.tools.diagnostics.Diagnostic;
import io.ballerina.tools.diagnostics.DiagnosticSeverity;

import static io.ballerina.compiler.syntax.tree.AbstractNodeFactory.createEmptyMinutiaeList;

/**
 * Class containing util functions.
 */
public class Utils {

    private Utils() {}

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
                SyntaxKind.STRING_LITERAL, value, createEmptyMinutiaeList(), createEmptyMinutiaeList());
    }

    public static String stripEscapeCharacter(String name) {
        return name.startsWith("'") ? name.substring(1) : name;
    }

//    public static String findRelationalTableName(String fieldName, Map<String, TypeDefinitionNode> entities,
//                                                 String targetType, List<String> tables) {
//        String fieldType = getFieldType(fieldName, entities, targetType);
//        for (String value : tables) {
//            if (fieldType != null && (fieldType.startsWith(value) || fieldType.startsWith(value + "Optionalized") ||
//                    fieldType.startsWith(value + "WithRelations") || fieldType.startsWith(value + "TargetType") ||
//                    fieldType.startsWith(value + "Insert") || fieldType.startsWith(value + "Update"))) {
//                return value.substring(0, 1).toLowerCase(Locale.ROOT) + value.substring(1);
//            }
//        }
//        return null;
//    }
//
//    private static String getFieldType(String fieldName, Map<String, TypeDefinitionNode> entities,
//                                       String targetType) {
//        TypeDefinitionNode typeDefinitionNode = entities.get(targetType);
//        TypeDescriptorNode typeDescriptorNode = (TypeDescriptorNode) typeDefinitionNode.typeDescriptor();
//        for (Node fieldNode : ((RecordTypeDescriptorNode) typeDescriptorNode).fields()) {
//            if (fieldNode instanceof RecordFieldNode) {
//                RecordFieldNode recordFieldNode = (RecordFieldNode) fieldNode;
//                if (Utils.stripEscapeCharacter(recordFieldNode.fieldName().text().trim()).equals(fieldName)) {
//                    return Utils.stripEscapeCharacter(recordFieldNode.typeName().toSourceCode().trim());
//                }
//            } else if (fieldNode instanceof RecordFieldWithDefaultValueNode) {
//                RecordFieldWithDefaultValueNode defaultField = (RecordFieldWithDefaultValueNode) fieldNode;
//                if (Utils.stripEscapeCharacter(defaultField.fieldName().text().trim()).equals(fieldName)) {
//                    return Utils.stripEscapeCharacter(defaultField.typeName().toSourceCode().trim());
//                }
//
//            } else if (fieldNode instanceof TypeReferenceNode) {
//                TypeReferenceNode typeReferenceNode = (TypeReferenceNode) fieldNode;
//                String fieldType =  getFieldType(fieldName, entities, Utils.stripEscapeCharacter(typeReferenceNode.
//                        typeName().toSourceCode().trim()));
//                if (fieldType != null) {
//                    return fieldType;
//                }
//            }
//        }
//        return null;
//    }

    public static String getReferenceTableName(FunctionCallExpressionNode expression) {
        NameReferenceNode functionName = expression.functionName();
        SeparatedNodeList<FunctionArgumentNode> arguments = expression.arguments();
        return functionName.toSourceCode().trim() + expression.openParenToken().text() +
                arguments.get(0).toSourceCode() + expression.closeParenToken().text();
    }

    public static String getReferenceTableName(OptionalFieldAccessExpressionNode expression) {
        return Utils.stripEscapeCharacter(((FieldAccessExpressionNode) expression.
                expression()).fieldName().toSourceCode().trim());
//        return Utils.findRelationalTableName(relationalTableName, entities, query.getTargetType(), tables);
    }
}
