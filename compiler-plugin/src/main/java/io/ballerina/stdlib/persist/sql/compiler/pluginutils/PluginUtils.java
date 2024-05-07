/*
 * Copyright (c) 2024, WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
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

package io.ballerina.stdlib.persist.sql.compiler.pluginutils;

import io.ballerina.compiler.syntax.tree.AnnotationNode;
import io.ballerina.compiler.syntax.tree.ExpressionNode;
import io.ballerina.compiler.syntax.tree.MappingConstructorExpressionNode;
import io.ballerina.compiler.syntax.tree.MappingFieldNode;
import io.ballerina.compiler.syntax.tree.SpecificFieldNode;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.tools.diagnostics.Diagnostic;
import io.ballerina.tools.diagnostics.DiagnosticSeverity;

import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.stream.Stream;

/**
 * Class containing util functions.
 */
public final class PluginUtils {

    private PluginUtils() {
    }

    public record AnnotationUtilRecord(List<AnnotationNode> annotationNodes, String annotation, String field) {
        public AnnotationUtilRecord (List<AnnotationNode> annotationNodes, String annotation, String field) {
            this.annotationNodes = Collections.unmodifiableList(annotationNodes);
            this.annotation = annotation;
            this.field = field;
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

    public static String stripEscapeCharacter(String name) {
        return name.startsWith("'") ? name.substring(1) : name;
    }

    public static String readStringValueFromAnnotation(AnnotationUtilRecord annotationMethodRecord) {
        for (AnnotationNode annotationNode : annotationMethodRecord.annotationNodes) {
            String annotationName = annotationNode.annotReference().toSourceCode().trim();
            if (annotationName.equals(annotationMethodRecord.annotation)) {
                Optional<MappingConstructorExpressionNode> annotationFieldNode = annotationNode.annotValue();
                if (annotationFieldNode.isPresent()) {
                    for (MappingFieldNode mappingFieldNode : annotationFieldNode.get().fields()) {
                        SpecificFieldNode specificFieldNode = (SpecificFieldNode) mappingFieldNode;
                        String fieldName = specificFieldNode.fieldName().toSourceCode().trim();
                        if (!fieldName.equals(annotationMethodRecord.field)) {
                            return "";
                        }
                        Optional<ExpressionNode> valueExpr = specificFieldNode.valueExpr();
                        if (valueExpr.isPresent()) {
                            return valueExpr.get().toSourceCode().trim().replace("\"", "").trim();
                        }
                    }
                }
            }
        }
        return "";
    }
    public static boolean isAnnotationPresent
            (List<AnnotationNode> annotationNodes, String annotation) {
        for (AnnotationNode annotationNode : annotationNodes) {
            String annotationName = annotationNode.annotReference().toSourceCode().trim();
            if (annotationName.equals(annotation)) {
                return true;
            }
        }
        return false;
    }

    public static boolean isAnnotationFieldStringType(AnnotationUtilRecord annotationMethodRecord) {
        for (AnnotationNode annotationNode : annotationMethodRecord.annotationNodes) {
            String annotationName = annotationNode.annotReference().toSourceCode().trim();
            if (annotationName.equals(annotationMethodRecord.annotation)) {
                Optional<MappingConstructorExpressionNode> annotationFieldNode = annotationNode.annotValue();
                if (annotationFieldNode.isPresent()) {
                    for (MappingFieldNode mappingFieldNode : annotationFieldNode.get().fields()) {
                        SpecificFieldNode specificFieldNode = (SpecificFieldNode) mappingFieldNode;
                        String fieldName = specificFieldNode.fieldName().toSourceCode().trim();
                        if (!fieldName.equals(annotationMethodRecord.field)) {
                            return false;
                        }
                        Optional<ExpressionNode> valueExpr = specificFieldNode.valueExpr();
                        if (valueExpr.isPresent()) {
                            return valueExpr.get().toSourceCode().trim().startsWith("\"") &&
                                    valueExpr.get().toSourceCode().trim().endsWith("\"");
                        }
                    }
                }
            }
        }
        return false;
    }

    public static boolean isAnnotationFieldArrayType(AnnotationUtilRecord annotationMethodRecord) {
        for (AnnotationNode annotationNode : annotationMethodRecord.annotationNodes) {
            String annotationName = annotationNode.annotReference().toSourceCode().trim();
            if (annotationName.equals(annotationMethodRecord.annotation)) {
                Optional<MappingConstructorExpressionNode> annotationFieldNode = annotationNode.annotValue();
                if (annotationFieldNode.isPresent()) {
                    for (MappingFieldNode mappingFieldNode : annotationFieldNode.get().fields()) {
                        SpecificFieldNode specificFieldNode = (SpecificFieldNode) mappingFieldNode;
                        String fieldName = specificFieldNode.fieldName().toSourceCode().trim();
                        if (!fieldName.equals(annotationMethodRecord.field)) {
                            return false;
                        }
                        Optional<ExpressionNode> valueExpr = specificFieldNode.valueExpr();
                        if (valueExpr.isPresent()) {
                            return valueExpr.get().toSourceCode().trim().startsWith("[") &&
                                    valueExpr.get().toSourceCode().trim().endsWith("]");
                        }
                    }
                }
            }
        }
        return false;
    }

    public static List<String> readStringArrayValueFromAnnotation(AnnotationUtilRecord annotationUtilRecord) {
        for (AnnotationNode annotationNode : annotationUtilRecord.annotationNodes) {
            String annotationName = annotationNode.annotReference().toSourceCode().trim();
            if (annotationName.equals(annotationUtilRecord.annotation)) {
                Optional<MappingConstructorExpressionNode> annotationFieldNode = annotationNode.annotValue();
                if (annotationFieldNode.isPresent()) {
                    for (MappingFieldNode mappingFieldNode : annotationFieldNode.get().fields()) {
                        SpecificFieldNode specificFieldNode = (SpecificFieldNode) mappingFieldNode;
                        String fieldName = specificFieldNode.fieldName().toSourceCode().trim();
                        if (!fieldName.equals(annotationUtilRecord.field)) {
                            return Collections.emptyList();
                        }
                        Optional<ExpressionNode> valueExpr = specificFieldNode.valueExpr();
                        if (valueExpr.isPresent()) {
                            String strings = valueExpr.get().toSourceCode().trim()
                                    .replace("[", "")
                                    .replace("]", "");
                            if (strings.trim().isEmpty()) {
                                return Collections.emptyList();
                            }
                            return Stream.of(strings.replace("\"", "").split(","))
                                    .map(String::trim).toList();
                        }
                    }
                }
            }
        }
        return Collections.emptyList();
    }
}
