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

import io.ballerina.compiler.syntax.tree.EnumDeclarationNode;
import io.ballerina.compiler.syntax.tree.ModuleMemberDeclarationNode;
import io.ballerina.compiler.syntax.tree.ModulePartNode;
import io.ballerina.compiler.syntax.tree.RecordTypeDescriptorNode;
import io.ballerina.compiler.syntax.tree.TypeDefinitionNode;
import io.ballerina.compiler.syntax.tree.TypeDescriptorNode;
import io.ballerina.projects.plugins.AnalysisTask;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.stdlib.persist.compiler.model.Entity;
import io.ballerina.stdlib.persist.compiler.model.RelationField;
import io.ballerina.tools.diagnostics.DiagnosticFactory;
import io.ballerina.tools.diagnostics.DiagnosticInfo;

import java.io.PrintStream;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import static io.ballerina.stdlib.persist.compiler.DiagnosticsCodes.PERSIST_101;
import static io.ballerina.stdlib.persist.compiler.DiagnosticsCodes.PERSIST_202;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_207;
import static io.ballerina.stdlib.persist.sql.compiler.utils.Utils.stripEscapeCharacter;


public class PersistSqlModelDefinitionValidator implements AnalysisTask<SyntaxNodeAnalysisContext> {
    private final Map<String, Entity> entities = new HashMap<>();
    private final List<String> entityNames = new ArrayList<>();
    private final List<String> enumTypes = new ArrayList<>();

    @Override
    public void perform(SyntaxNodeAnalysisContext ctx) {
        PrintStream out = System.out;
        out.println("HI FROM PERSIST SQL MODEL DEFINITION VALIDATOR");
        ModulePartNode rootNode = (ModulePartNode) ctx.node();
        // Names in lowercase to check for duplicate entity names
        List<String> entityNames = new ArrayList<>();
        List<TypeDefinitionNode> foundEntities = new ArrayList<>();
        for (ModuleMemberDeclarationNode member : rootNode.members()) {
            if (member instanceof TypeDefinitionNode) {
                TypeDefinitionNode typeDefinitionNode = (TypeDefinitionNode) member;
                TypeDescriptorNode typeDescriptorNode = (TypeDescriptorNode) typeDefinitionNode.typeDescriptor();
                if (typeDescriptorNode instanceof RecordTypeDescriptorNode) {
                    String entityName = stripEscapeCharacter(typeDefinitionNode.typeName().text().trim());
                    ctx.reportDiagnostic(DiagnosticFactory.createDiagnostic(
                            new DiagnosticInfo(
                                    PERSIST_SQL_207.getCode(), PERSIST_SQL_207.getMessage(),
                                            PERSIST_SQL_207.getSeverity()), typeDefinitionNode.typeName().location())
                    );
                    if (entityNames.contains(entityName.toLowerCase(Locale.ROOT))) {
                        ctx.reportDiagnostic(DiagnosticFactory.createDiagnostic(
                                new DiagnosticInfo(PERSIST_202.getCode(),
                                        MessageFormat.format(PERSIST_202.getMessage(), entityName),
                                        PERSIST_202.getSeverity()), typeDefinitionNode.typeName().location())
                        );
                    } else {
                        foundEntities.add(typeDefinitionNode);
                        entityNames.add(entityName.toLowerCase(Locale.ROOT));
                        this.entityNames.add(entityName);
                    }
                    continue;
                }
            } else if (member instanceof EnumDeclarationNode) {
                String enumTypeName = stripEscapeCharacter(((EnumDeclarationNode) member).identifier().text().trim());
                enumTypes.add(enumTypeName);
                continue;
            }
            ctx.reportDiagnostic(DiagnosticFactory.createDiagnostic(
                    new DiagnosticInfo(PERSIST_101.getCode(), PERSIST_101.getMessage(), PERSIST_101.getSeverity()),
                    member.location()));
        }

        for (TypeDefinitionNode typeDefinitionNode : foundEntities) {
            String entityName = stripEscapeCharacter(typeDefinitionNode.typeName().text().trim());
            TypeDescriptorNode typeDescriptorNode = (TypeDescriptorNode) typeDefinitionNode.typeDescriptor();

            Entity entity = new Entity(entityName, typeDefinitionNode.typeName().location(),
                    ((RecordTypeDescriptorNode) typeDescriptorNode));
            validateEntityRelations(entity);
            entity.getDiagnostics().forEach((ctx::reportDiagnostic));
            this.entities.put(entityName, entity);
        }
    }

    private void validateEntityRelations(Entity entity) {
        if (!entity.isContainsRelations()) {
            return;
        }

        for (RelationField relationField : entity.getRelationFields().values()) {
            String referredEntity = relationField.getType();

            if (this.entities.containsKey(referredEntity)) {
                validateRelation(relationField, entity, this.entities.get(referredEntity), entity);
            }
        }
    }

    private void validateRelation(RelationField processingField, Entity processingEntity, Entity referredEntity,
                                  Entity reportDiagnosticsEntity) {
        processingEntity.getNonRelationFields().forEach(field -> {
                reportDiagnosticsEntity.reportDiagnostic(PERSIST_SQL_207.getCode(),
                                PERSIST_SQL_207.getMessage(),
                        PERSIST_SQL_207.getSeverity(), field.getNodeLocation());
        });

    }
}
