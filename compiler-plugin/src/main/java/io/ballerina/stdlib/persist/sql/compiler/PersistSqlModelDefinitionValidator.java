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

package io.ballerina.stdlib.persist.sql.compiler;

import io.ballerina.compiler.syntax.tree.AnnotationNode;
import io.ballerina.compiler.syntax.tree.ArrayTypeDescriptorNode;
import io.ballerina.compiler.syntax.tree.BuiltinSimpleNameReferenceNode;
import io.ballerina.compiler.syntax.tree.EnumDeclarationNode;
import io.ballerina.compiler.syntax.tree.ImportPrefixNode;
import io.ballerina.compiler.syntax.tree.ModuleMemberDeclarationNode;
import io.ballerina.compiler.syntax.tree.ModulePartNode;
import io.ballerina.compiler.syntax.tree.Node;
import io.ballerina.compiler.syntax.tree.NodeList;
import io.ballerina.compiler.syntax.tree.OptionalTypeDescriptorNode;
import io.ballerina.compiler.syntax.tree.QualifiedNameReferenceNode;
import io.ballerina.compiler.syntax.tree.RecordFieldNode;
import io.ballerina.compiler.syntax.tree.RecordTypeDescriptorNode;
import io.ballerina.compiler.syntax.tree.SimpleNameReferenceNode;
import io.ballerina.compiler.syntax.tree.TypeDefinitionNode;
import io.ballerina.compiler.syntax.tree.TypeDescriptorNode;
import io.ballerina.projects.ProjectKind;
import io.ballerina.projects.plugins.AnalysisTask;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.projects.util.ProjectConstants;
import io.ballerina.stdlib.persist.sql.compiler.model.Entity;
import io.ballerina.stdlib.persist.sql.compiler.model.IdentityField;
import io.ballerina.stdlib.persist.sql.compiler.model.RelationField;
import io.ballerina.stdlib.persist.sql.compiler.model.SimpleTypeField;

import java.io.File;
import java.nio.file.Path;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import static io.ballerina.stdlib.persist.sql.compiler.Constants.ANNOTATION_LENGTH_FIELD;
import static io.ballerina.stdlib.persist.sql.compiler.Constants.ANNOTATION_NAMES_FIELD;
import static io.ballerina.stdlib.persist.sql.compiler.Constants.ANNOTATION_NAME_FIELD;
import static io.ballerina.stdlib.persist.sql.compiler.Constants.ANNOTATION_PRECISION_FIELD;
import static io.ballerina.stdlib.persist.sql.compiler.Constants.ANNOTATION_REFS_FIELD;
import static io.ballerina.stdlib.persist.sql.compiler.Constants.BallerinaTypes.DECIMAL;
import static io.ballerina.stdlib.persist.sql.compiler.Constants.BallerinaTypes.INT;
import static io.ballerina.stdlib.persist.sql.compiler.Constants.BallerinaTypes.STRING;
import static io.ballerina.stdlib.persist.sql.compiler.Constants.PERSIST_DIRECTORY;
import static io.ballerina.stdlib.persist.sql.compiler.Constants.SQL_CHAR_MAPPING_ANNOTATION_NAME;
import static io.ballerina.stdlib.persist.sql.compiler.Constants.SQL_DB_MAPPING_ANNOTATION_NAME;
import static io.ballerina.stdlib.persist.sql.compiler.Constants.SQL_DECIMAL_MAPPING_ANNOTATION_NAME;
import static io.ballerina.stdlib.persist.sql.compiler.Constants.SQL_GENERATED_ANNOTATION_NAME;
import static io.ballerina.stdlib.persist.sql.compiler.Constants.SQL_INDEX_MAPPING_ANNOTATION_NAME;
import static io.ballerina.stdlib.persist.sql.compiler.Constants.SQL_RELATION_MAPPING_ANNOTATION_NAME;
import static io.ballerina.stdlib.persist.sql.compiler.Constants.SQL_UNIQUE_INDEX_MAPPING_ANNOTATION_NAME;
import static io.ballerina.stdlib.persist.sql.compiler.Constants.SQL_VARCHAR_MAPPING_ANNOTATION_NAME;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_423;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_424;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_426;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_427;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_428;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_429;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_430;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_600;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_601;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_602;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_604;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_605;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_606;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_607;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_608;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_609;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_610;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_611;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_612;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_613;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_614;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_615;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_616;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_617;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_618;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_619;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_620;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_621;
import static io.ballerina.stdlib.persist.sql.compiler.utils.Utils.getTypeName;
import static io.ballerina.stdlib.persist.sql.compiler.utils.Utils.hasCompilationErrors;
import static io.ballerina.stdlib.persist.sql.compiler.utils.Utils.isAnnotationPresent;
import static io.ballerina.stdlib.persist.sql.compiler.utils.Utils.readStringArrayValueFromAnnotation;
import static io.ballerina.stdlib.persist.sql.compiler.utils.Utils.readStringValueFromAnnotation;
import static io.ballerina.stdlib.persist.sql.compiler.utils.Utils.stripEscapeCharacter;

/**
 * Persist model definition validator.
 */
public class PersistSqlModelDefinitionValidator implements AnalysisTask<SyntaxNodeAnalysisContext> {
    private final Map<String, Entity> entities = new HashMap<>();
    private final List<String> entityNames = new ArrayList<>();
    private final List<String> enumTypes = new ArrayList<>();

    @Override
    public void perform(SyntaxNodeAnalysisContext ctx) {
        if (!isPersistModelDefinitionDocument(ctx)) {
            return;
        }

        if (hasCompilationErrors(ctx)) {
            return;
        }

        if (ctx.node() instanceof ImportPrefixNode) {
            return;
        }

        ModulePartNode rootNode = (ModulePartNode) ctx.node();
        List<TypeDefinitionNode> foundEntities = new ArrayList<>();
        for (ModuleMemberDeclarationNode member : rootNode.members()) {
            if (member instanceof TypeDefinitionNode typeDefinitionNode) {
                TypeDescriptorNode typeDescriptorNode = (TypeDescriptorNode) typeDefinitionNode.typeDescriptor();
                if (typeDescriptorNode instanceof RecordTypeDescriptorNode) {
                    String entityName = stripEscapeCharacter(typeDefinitionNode.typeName().text().trim());
                    foundEntities.add(typeDefinitionNode);
                    entityNames.add(entityName.toLowerCase(Locale.ROOT));
                    this.entityNames.add(entityName);
                }
            } else if (member instanceof EnumDeclarationNode) {
                String enumTypeName = stripEscapeCharacter(((EnumDeclarationNode) member).identifier().text().trim());
                enumTypes.add(enumTypeName);
            }
        }

        for (TypeDefinitionNode typeDefinitionNode : foundEntities) {
            String entityName = stripEscapeCharacter(typeDefinitionNode.typeName().text().trim());
            TypeDescriptorNode typeDescriptorNode = (TypeDescriptorNode) typeDefinitionNode.typeDescriptor();
            List<AnnotationNode> annotations = typeDefinitionNode.metadata().map(
                    metadata -> metadata.annotations().stream().toList()).orElse(Collections.emptyList());
            Entity entity = new Entity(entityName, typeDefinitionNode.typeName().location(),
                    ((RecordTypeDescriptorNode) typeDescriptorNode), annotations);
            processEntityFields(entity);
            this.entities.put(entityName, entity);
        }

        //validate annotations
        List<String> tableMappings = new ArrayList<>();
        for (Entity entity : this.entities.values()) {
            //relation annotations
            List<String> refs = new ArrayList<>();
            entity.getRelationFields().values().forEach(field -> validateRelationField(entity, field, refs));
            entity.getGroupedRelationFields().values()
                    .forEach(groupedRelationField -> groupedRelationField.getRelationFields()
                            .forEach(field -> validateRelationField(entity, field, refs)));
            //table mapping annotations
            if (isAnnotationPresent(entity.getAnnotations(), SQL_DB_MAPPING_ANNOTATION_NAME)) {
                String tableName = readStringValueFromAnnotation
                        (entity.getAnnotations(), SQL_DB_MAPPING_ANNOTATION_NAME, ANNOTATION_NAME_FIELD);
                if (tableName.isEmpty()) {
                    entity.reportDiagnostic(PERSIST_SQL_600.getCode(), PERSIST_SQL_600.getMessage(),
                            PERSIST_SQL_600.getSeverity(), entity.getEntityNameLocation());
                }
                if (tableName.equals(entity.getEntityName())) {
                    entity.reportDiagnostic(PERSIST_SQL_601.getCode(), PERSIST_SQL_601.getMessage(),
                            PERSIST_SQL_601.getSeverity(), entity.getEntityNameLocation());
                } else if (entities.containsKey(tableName)) {
                    entity.reportDiagnostic(PERSIST_SQL_620.getCode(), PERSIST_SQL_620.getMessage(),
                            PERSIST_SQL_620.getSeverity(), entity.getEntityNameLocation());
                }
                if (tableMappings.contains(tableName)) {
                    entity.reportDiagnostic(PERSIST_SQL_610.getCode(), PERSIST_SQL_610.getMessage(),
                            PERSIST_SQL_610.getSeverity(), entity.getEntityNameLocation());
                } else {
                    tableMappings.add(tableName);
                }
            }
            // column mapping, char, varchar, decimal, index, unique index annotations
            List<String> columnMappings = new ArrayList<>();
            for (SimpleTypeField field : entity.getNonRelationFields()) {
                if (isAnnotationPresent(field.getAnnotations(), SQL_DB_MAPPING_ANNOTATION_NAME)) {
                    String mappingName = readStringValueFromAnnotation(field.getAnnotations(),
                            SQL_DB_MAPPING_ANNOTATION_NAME, ANNOTATION_NAME_FIELD);
                    if (mappingName.isEmpty()) {
                        entity.reportDiagnostic(PERSIST_SQL_600.getCode(), PERSIST_SQL_600.getMessage(),
                                PERSIST_SQL_600.getSeverity(), field.getNodeLocation());
                    }
                    if (mappingName.equals(field.getName())) {
                        entity.reportDiagnostic(PERSIST_SQL_601.getCode(), PERSIST_SQL_601.getMessage(),
                                PERSIST_SQL_601.getSeverity(), field.getNodeLocation());
                    }
                    if (columnMappings.contains(mappingName)) {
                        entity.reportDiagnostic(PERSIST_SQL_610.getCode(), PERSIST_SQL_610.getMessage(),
                                PERSIST_SQL_610.getSeverity(), field.getNodeLocation());
                    } else {
                        columnMappings.add(mappingName);
                    }
                    if (entity.getNonRelationFields().stream().anyMatch(f -> f.getName().equals(mappingName)
                            && f != field)) {
                        entity.reportDiagnostic(PERSIST_SQL_621.getCode(), PERSIST_SQL_621.getMessage(),
                                PERSIST_SQL_621.getSeverity(), field.getNodeLocation());
                    }
                }
                boolean isCharPresent =
                        isAnnotationPresent(field.getAnnotations(), SQL_CHAR_MAPPING_ANNOTATION_NAME);
                boolean isVarCharPresent =
                        isAnnotationPresent(field.getAnnotations(), SQL_VARCHAR_MAPPING_ANNOTATION_NAME);
                boolean isDecimalPresent =
                        isAnnotationPresent(field.getAnnotations(), SQL_DECIMAL_MAPPING_ANNOTATION_NAME);
                if (field.getType().equals(STRING)) {
                    if (isCharPresent && isVarCharPresent) {
                        entity.reportDiagnostic(PERSIST_SQL_605.getCode(), PERSIST_SQL_605.getMessage(),
                                PERSIST_SQL_605.getSeverity(), field.getNodeLocation());
                    } else if (isCharPresent) {
                        String length = readStringValueFromAnnotation(field.getAnnotations(),
                                SQL_CHAR_MAPPING_ANNOTATION_NAME, ANNOTATION_LENGTH_FIELD);
                        if (length.equals("0")) {
                            entity.reportDiagnostic(PERSIST_SQL_607.getCode(),
                                    MessageFormat.format(PERSIST_SQL_607.getMessage(), "Char"),
                                    PERSIST_SQL_607.getSeverity(), field.getNodeLocation());
                        }
                    } else if (isVarCharPresent) {
                        String length = readStringValueFromAnnotation(field.getAnnotations(),
                                SQL_VARCHAR_MAPPING_ANNOTATION_NAME, ANNOTATION_LENGTH_FIELD);
                        if (length.equals("0")) {
                            entity.reportDiagnostic(PERSIST_SQL_607.getCode(),
                                    MessageFormat.format(PERSIST_SQL_607.getMessage(), "VarChar"),
                                    PERSIST_SQL_607.getSeverity(), field.getNodeLocation());
                        }
                    }
                } else {
                    if (isCharPresent) {
                        entity.reportDiagnostic(PERSIST_SQL_604.getCode(),
                                MessageFormat.format(PERSIST_SQL_604.getMessage(), "Char"),
                                PERSIST_SQL_604.getSeverity(), field.getNodeLocation());
                    } else if (isVarCharPresent) {
                        entity.reportDiagnostic(PERSIST_SQL_604.getCode(),
                                MessageFormat.format(PERSIST_SQL_604.getMessage(), "VarChar"),
                                PERSIST_SQL_604.getSeverity(), field.getNodeLocation());
                    }
                }
                if (isDecimalPresent) {
                    if (field.getType().equals(DECIMAL)) {
                        List<Integer> decimal = readStringArrayValueFromAnnotation(field.getAnnotations(),
                                SQL_DECIMAL_MAPPING_ANNOTATION_NAME, ANNOTATION_PRECISION_FIELD)
                                .stream().map(Integer::parseInt).toList();
                        if (decimal.get(0) == 0) {
                            entity.reportDiagnostic(PERSIST_SQL_608.getCode(),
                                    PERSIST_SQL_608.getMessage(), PERSIST_SQL_608.getSeverity(),
                                    field.getNodeLocation());
                        }
                        if (decimal.get(0) < decimal.get(1)) {
                            entity.reportDiagnostic(PERSIST_SQL_609.getCode(),
                                    PERSIST_SQL_609.getMessage(), PERSIST_SQL_609.getSeverity(),
                                    field.getNodeLocation());
                        }
                    } else {
                        entity.reportDiagnostic(PERSIST_SQL_606.getCode(),
                                PERSIST_SQL_606.getMessage(), PERSIST_SQL_606.getSeverity(), field.getNodeLocation());
                    }
                }
                if (isAnnotationPresent(field.getAnnotations(), SQL_INDEX_MAPPING_ANNOTATION_NAME)) {
                    List<String> indexNames = readStringArrayValueFromAnnotation(field.getAnnotations(),
                            SQL_INDEX_MAPPING_ANNOTATION_NAME, ANNOTATION_NAMES_FIELD);
                    if (indexNames != null && !indexNames.isEmpty()) {
                        List<String> distinctIndexes = indexNames.stream().distinct().toList();
                        if (indexNames.size() != distinctIndexes.size()) {
                            entity.reportDiagnostic(PERSIST_SQL_613.getCode(), PERSIST_SQL_613.getMessage(),
                                    PERSIST_SQL_613.getSeverity(), field.getNodeLocation());
                        }
                        if (indexNames.contains("")) {
                            entity.reportDiagnostic(PERSIST_SQL_615.getCode(), PERSIST_SQL_615.getMessage(),
                                    PERSIST_SQL_615.getSeverity(), field.getNodeLocation());
                        }
                    }
                }
                if (isAnnotationPresent(field.getAnnotations(), SQL_UNIQUE_INDEX_MAPPING_ANNOTATION_NAME)) {
                    List<String> indexNames = readStringArrayValueFromAnnotation(field.getAnnotations(),
                            SQL_UNIQUE_INDEX_MAPPING_ANNOTATION_NAME, ANNOTATION_NAMES_FIELD);
                    if (indexNames != null && !indexNames.isEmpty()) {
                        List<String> distinctIndexes = indexNames.stream().distinct().toList();
                        if (indexNames.size() != distinctIndexes.size()) {
                            entity.reportDiagnostic(PERSIST_SQL_614.getCode(), PERSIST_SQL_614.getMessage(),
                                    PERSIST_SQL_614.getSeverity(), field.getNodeLocation());
                        }
                        if (indexNames.contains("")) {
                            entity.reportDiagnostic(PERSIST_SQL_616.getCode(), PERSIST_SQL_616.getMessage(),
                                    PERSIST_SQL_616.getSeverity(), field.getNodeLocation());
                        }
                    }
                }
                if (isAnnotationPresent(field.getAnnotations(), SQL_GENERATED_ANNOTATION_NAME)) {
                    if (!entity.getIdentityFieldNames().contains(field.getName())) {
                        entity.reportDiagnostic(PERSIST_SQL_617.getCode(), PERSIST_SQL_617.getMessage(),
                                PERSIST_SQL_617.getSeverity(), field.getNodeLocation());
                    } else if (entity.getIdentityFieldNames().size() > 1) {
                        entity.reportDiagnostic(PERSIST_SQL_618.getCode(), PERSIST_SQL_618.getMessage(),
                                PERSIST_SQL_618.getSeverity(), field.getNodeLocation());
                    } else if (!field.getType().equals(INT)) {
                        entity.reportDiagnostic(PERSIST_SQL_619.getCode(), PERSIST_SQL_619.getMessage(),
                                PERSIST_SQL_619.getSeverity(), field.getNodeLocation());
                    }
                }
            }
            entity.getDiagnostics().forEach(ctx::reportDiagnostic);
        }
    }
    private void validateRelationField(Entity entity, RelationField relationField, List<String> refs) {
        validateRelationAnnotation(
                relationField, this.entities.get(relationField.getContainingEntity()),
                this.entities.get(relationField.getType()), refs);
        if (isAnnotationPresent(relationField.getAnnotations(), SQL_DB_MAPPING_ANNOTATION_NAME)) {
            entity.reportDiagnostic(PERSIST_SQL_602.getCode(), PERSIST_SQL_602.getMessage(),
                    PERSIST_SQL_602.getSeverity(), relationField.getLocation());
        }
        if (isAnnotationPresent(relationField.getAnnotations(), SQL_INDEX_MAPPING_ANNOTATION_NAME)) {
            entity.reportDiagnostic(PERSIST_SQL_611.getCode(), PERSIST_SQL_611.getMessage(),
                    PERSIST_SQL_611.getSeverity(), relationField.getLocation());
        }
        if (isAnnotationPresent(relationField.getAnnotations(), SQL_UNIQUE_INDEX_MAPPING_ANNOTATION_NAME)) {
            entity.reportDiagnostic(PERSIST_SQL_612.getCode(), PERSIST_SQL_612.getMessage(),
                    PERSIST_SQL_612.getSeverity(), relationField.getLocation());
        }
        if (isAnnotationPresent(relationField.getAnnotations(), SQL_GENERATED_ANNOTATION_NAME)) {
            entity.reportDiagnostic(PERSIST_SQL_617.getCode(), PERSIST_SQL_617.getMessage(),
                    PERSIST_SQL_617.getSeverity(), relationField.getLocation());
        }
    }

    private void processEntityFields(Entity entity) {
        RecordTypeDescriptorNode typeDescriptorNode = entity.getTypeDescriptorNode();

        NodeList<Node> fields = typeDescriptorNode.fields();
        for (Node fieldNode : fields) {
            IdentityField identityField = null;
            boolean isIdentityField = false;
            int readonlyTextRangeStartOffset = 0;
            RecordFieldNode recordFieldNode;
            String fieldName;
            if (fieldNode instanceof RecordFieldNode) {
                recordFieldNode = (RecordFieldNode) fieldNode;
                fieldName = stripEscapeCharacter(recordFieldNode.fieldName().text().trim());
                if (recordFieldNode.readonlyKeyword().isPresent()) {
                    isIdentityField = true;
                    readonlyTextRangeStartOffset = recordFieldNode.readonlyKeyword().get().textRange().startOffset();
                    identityField = new IdentityField(fieldName);
                }
            } else {
                continue;
            }

            List<AnnotationNode> annotations =
                    recordFieldNode.metadata().map(metadata ->
                            metadata.annotations().stream().toList()).orElse(Collections.emptyList());

            Node typeNode = recordFieldNode.typeName();
            Node processedTypeNode = typeNode;
            boolean isArrayType = false;
            int arrayStartOffset = 0;
            int arrayLength = 0;
            boolean isOptionalType = false;
            boolean isSimpleType = false;
            int nullableStartOffset = 0;
            String fieldType;
            if (processedTypeNode instanceof OptionalTypeDescriptorNode optionalTypeNode) {
                isOptionalType = true;
                processedTypeNode = optionalTypeNode.typeDescriptor();
                nullableStartOffset = optionalTypeNode.questionMarkToken().textRange().startOffset();
            }
            if (processedTypeNode instanceof ArrayTypeDescriptorNode arrayTypeDescriptorNode) {
                isArrayType = true;
                arrayStartOffset = arrayTypeDescriptorNode.dimensions().get(0).openBracket().textRange().startOffset();
                arrayLength = arrayTypeDescriptorNode.dimensions().get(0).closeBracket().textRange().endOffset() -
                        arrayStartOffset;
                processedTypeNode = arrayTypeDescriptorNode.memberTypeDesc();
            }

            if (processedTypeNode instanceof BuiltinSimpleNameReferenceNode) {
                fieldType = ((BuiltinSimpleNameReferenceNode) processedTypeNode).name().text();
                isSimpleType = true;
            } else if (processedTypeNode instanceof QualifiedNameReferenceNode qualifiedName) {
                // Support only time constructs
                String modulePrefix = stripEscapeCharacter(qualifiedName.modulePrefix().text());
                String identifier = stripEscapeCharacter(qualifiedName.identifier().text());
                fieldType = modulePrefix + ":" + identifier;
                isSimpleType = true;
            } else if (processedTypeNode instanceof SimpleNameReferenceNode) {
                String typeName = stripEscapeCharacter(
                        ((SimpleNameReferenceNode) processedTypeNode).name().text().trim());
                fieldType = typeName;
                if (this.entityNames.contains(typeName)) {
                    entity.setContainsRelations(true);
                    entity.addRelationField(new RelationField(fieldName, typeName,
                            typeNode.location().textRange().endOffset(), isOptionalType, nullableStartOffset,
                            isArrayType, arrayStartOffset, arrayLength, recordFieldNode.location(),
                            entity.getEntityName(), annotations));
                } else {
                    isSimpleType = true;
                }
            } else {
                fieldType = getTypeName(processedTypeNode);
            }

            if (isIdentityField) {
                identityField.setType(fieldType);
                identityField.setValidType(true);
                identityField.setNullable(isOptionalType);
                identityField.setNullableStartOffset(nullableStartOffset);
                identityField.setReadonlyTextRangeStartOffset(readonlyTextRangeStartOffset);
                identityField.setTypeLocation(typeNode.location());
                entity.addIdentityField(identityField);
            }

            if (isSimpleType) {
                entity.addNonRelationField(new SimpleTypeField(fieldName, fieldType, true,
                        isOptionalType, isArrayType, fieldNode.location(), typeNode.location(), annotations));
            }
        }
    }

    private void validateRelationAnnotation(RelationField relationField, Entity ownerEntity, Entity referredEntity,
                                            List<String> refs) {
        boolean isRelationAnnotationPresent = isAnnotationPresent
                (relationField.getAnnotations(), SQL_RELATION_MAPPING_ANNOTATION_NAME);
        if (!isRelationAnnotationPresent) {
            return;
        }
        if (relationField.isArrayType()) {
            ownerEntity.reportDiagnostic(
                    PERSIST_SQL_426.getCode(),
                    MessageFormat.format(PERSIST_SQL_426.getMessage(), relationField.getName()),
                    PERSIST_SQL_426.getSeverity(),
                    relationField.getLocation()
            );
            return;
        }
        if (relationField.isOptionalType()) {
            ownerEntity.reportDiagnostic(
                    PERSIST_SQL_427.getCode(),
                    MessageFormat.format(PERSIST_SQL_427.getMessage(), relationField.getName()),
                    PERSIST_SQL_427.getSeverity(),
                    relationField.getLocation()
            );
            return;
        }
        //annotation present, relationField is the owner
        List<String> referenceFields = readStringArrayValueFromAnnotation(relationField.getAnnotations(),
                SQL_RELATION_MAPPING_ANNOTATION_NAME, ANNOTATION_REFS_FIELD);
        List<String> referredIdFieldTypes = referredEntity.getIdentityFields().stream()
                .map(IdentityField::getType).toList();
        List<String> distinctReferenceFields = referenceFields.stream()
                .distinct()
                .toList();
        if (distinctReferenceFields.size() != referenceFields.size()) {
            ownerEntity.reportDiagnostic(PERSIST_SQL_429.getCode(),
                    PERSIST_SQL_429.getMessage(),
                    PERSIST_SQL_429.getSeverity(), relationField.getLocation());
            return;
        }
        for (String referenceField : referenceFields) {
            boolean doesFieldExist = ownerEntity.getNonRelationFields().stream().anyMatch
                    (f -> f.getName().equals(referenceField));
            if (!doesFieldExist) {
                ownerEntity.reportDiagnostic(PERSIST_SQL_428.getCode(),
                        MessageFormat.format(PERSIST_SQL_428.getMessage(), referenceField, ownerEntity.getEntityName()),
                        PERSIST_SQL_428.getSeverity(), relationField.getLocation());
                return;
            }
        }
        if (referenceFields.size() != referredIdFieldTypes.size()) {
            ownerEntity.reportDiagnostic(PERSIST_SQL_423.getCode(),
                    MessageFormat.format(PERSIST_SQL_423.getMessage(), relationField.getType(),
                            ownerEntity.getEntityName(), referredIdFieldTypes.size(), referenceFields.size()),
                    PERSIST_SQL_423.getSeverity(),
                    relationField.getLocation());
            return;
        }
        for (int i = 0; i < referenceFields.size(); i++) {
            int finalI = i;
            SimpleTypeField ownerField = ownerEntity.getNonRelationFields().stream()
                    .filter(f -> f.getName().equals(referenceFields.get(finalI))).findFirst().orElse(null);
            if (ownerField != null) {
                if (!ownerField.getType().equals(referredIdFieldTypes.get(finalI))) {
                    ownerEntity.reportDiagnostic(PERSIST_SQL_424.getCode(),
                            MessageFormat.format(PERSIST_SQL_424.getMessage(), referredEntity.getEntityName()),
                            PERSIST_SQL_424.getSeverity(), relationField.getLocation());
                    return;
                }
            }
        }
        if (new HashSet<>(refs).containsAll(referenceFields)) {
            ownerEntity.reportDiagnostic(PERSIST_SQL_430.getCode(), PERSIST_SQL_430.getMessage(),
                    PERSIST_SQL_430.getSeverity(), relationField.getLocation());
            return;
        }
        refs.addAll(referenceFields);
    }

    private boolean isPersistModelDefinitionDocument(SyntaxNodeAnalysisContext ctx) {
        try {
            if (ctx.currentPackage().project().kind().equals(ProjectKind.SINGLE_FILE_PROJECT)) {
                Path balFilePath = ctx.currentPackage().project().sourceRoot().toAbsolutePath();
                Path balFileContainingFolder = balFilePath.getParent();
                if (balFileContainingFolder != null && balFileContainingFolder.endsWith(PERSIST_DIRECTORY)) {
                    Path balProjectDir = balFileContainingFolder.getParent();
                    if (balProjectDir != null) {
                        File balProject = balProjectDir.toFile();
                        if (balProject.isDirectory()) {
                            File tomlFile = balProjectDir.resolve(ProjectConstants.BALLERINA_TOML).toFile();
                            return tomlFile.exists();
                        }
                    }
                }
            }
        } catch (UnsupportedOperationException e) {
            //todo log properly This is to identify any issues in resolving path
        }
        return false;
    }
}
