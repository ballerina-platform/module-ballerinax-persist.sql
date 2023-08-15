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

import io.ballerina.compiler.syntax.tree.ClassDefinitionNode;
import io.ballerina.compiler.syntax.tree.ModuleMemberDeclarationNode;
import io.ballerina.compiler.syntax.tree.ModulePartNode;
import io.ballerina.compiler.syntax.tree.ModuleVariableDeclarationNode;
import io.ballerina.compiler.syntax.tree.Node;
import io.ballerina.compiler.syntax.tree.QueryPipelineNode;
import io.ballerina.compiler.syntax.tree.RecordTypeDescriptorNode;
import io.ballerina.compiler.syntax.tree.TypeDefinitionNode;
import io.ballerina.compiler.syntax.tree.TypeDescriptorNode;
import io.ballerina.compiler.syntax.tree.VariableDeclarationNode;
import io.ballerina.projects.plugins.AnalysisTask;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.stdlib.persist.plural.Pluralizer;
import io.ballerina.stdlib.persist.sql.compiler.Constants;
import io.ballerina.stdlib.persist.sql.compiler.model.Query;

import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

import static io.ballerina.stdlib.persist.sql.compiler.codemodifier.QueryCodeModifierTask.hasCompilationErrors;
import static io.ballerina.stdlib.persist.sql.compiler.codemodifier.QueryCodeModifierTask.stripEscapeCharacter;

/**
 * Analysis task to identify all declared entities and clients.
 */
public class PersistEntityAndClassIdentifierTask implements AnalysisTask<SyntaxNodeAnalysisContext>  {

    private final Map<String, String> entities;
    private final List<String> persistClientNames;
    private final Map<String, String> variables;
    PersistQueryValidator queryValidator;

    PersistEntityAndClassIdentifierTask(Map<String, String> entities, List<String> persistClientNames,
                                        Map<String, String> variables,
                                        ConcurrentHashMap<QueryPipelineNode, Query> queries,
                                        Map<QueryPipelineNode, Query> validatedQueries,
                                        List<String> persistClientVariableNames) {
        this.entities = entities;
        this.persistClientNames = persistClientNames;
        this.variables = variables;
        this.queryValidator = new PersistQueryValidator(entities, persistClientNames, variables, queries,
                validatedQueries, persistClientVariableNames);
    }

    @Override
    public void perform(SyntaxNodeAnalysisContext ctx) {
        if (hasCompilationErrors(ctx)) {
            return;
        }
        Node node = ctx.node();
        if (node instanceof ModulePartNode) {
            ModulePartNode rootNode = (ModulePartNode) ctx.node();
            for (ModuleMemberDeclarationNode member : rootNode.members()) {
                if (member instanceof TypeDefinitionNode typeDefinitionNode) {
                    if (!ctx.node().syntaxTree().filePath().equals("persist_types.bal")) {
                        continue;
                    }
                    TypeDescriptorNode typeDescriptorNode = (TypeDescriptorNode) typeDefinitionNode.typeDescriptor();
                    if (typeDescriptorNode instanceof RecordTypeDescriptorNode) {
                        String typeName = typeDefinitionNode.typeName().text().trim();
                        entities.put(Pluralizer.pluralize(stripEscapeCharacter(typeName).
                                toLowerCase(Locale.ROOT)), stripEscapeCharacter(typeName));
                    }
                } else if (member instanceof ClassDefinitionNode classDefinitionNode) {
                    List<Node> persistTypeInheritanceNodes = classDefinitionNode.members().stream().filter(
                            (classMember) -> classMember.toString().trim().equals(
                                    Constants.PERSIST_INHERITANCE_NODE)).collect(Collectors.toList());
                    if (persistTypeInheritanceNodes.size() > 0) {
                        persistClientNames.add(classDefinitionNode.className().text().trim());
                    }
                }
            }
        } else if (node instanceof ModuleVariableDeclarationNode moduleVariableNode) {
            String type = moduleVariableNode.typedBindingPattern().typeDescriptor().toString().trim();
            String variableName = moduleVariableNode.typedBindingPattern().bindingPattern().toString().trim();
            variables.put(variableName, type);
        } else if (node instanceof VariableDeclarationNode moduleVariableNode) {
            String type = moduleVariableNode.typedBindingPattern().typeDescriptor().toString().trim();
            String variableName = moduleVariableNode.typedBindingPattern().bindingPattern().toString().trim();
            variables.put(variableName, type);
        }
        queryValidator.validateQuery(ctx);
    }
}
