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
import io.ballerina.compiler.syntax.tree.Node;
import io.ballerina.compiler.syntax.tree.RecordTypeDescriptorNode;
import io.ballerina.compiler.syntax.tree.TypeDefinitionNode;
import io.ballerina.compiler.syntax.tree.TypeDescriptorNode;
import io.ballerina.projects.plugins.AnalysisTask;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.stdlib.persist.plural.Pluralizer;
import io.ballerina.stdlib.persist.sql.compiler.Constants;
import io.ballerina.stdlib.persist.sql.compiler.utils.Utils;

import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;

/**
 * Analysis task to identify all declared entities and clients.
 */
public class PersistEntityAndClassIdentifierTask implements AnalysisTask<SyntaxNodeAnalysisContext>  {

    private final List<String> entities;
    private final List<String> persistClientNames;

    PersistEntityAndClassIdentifierTask(List<String> entities, List<String> persistClientNames) {
        this.entities = entities;
        this.persistClientNames = persistClientNames;
    }

    @Override
    public void perform(SyntaxNodeAnalysisContext ctx) {
        if (Utils.hasCompilationErrors(ctx)) {
            return;
        }
        ModulePartNode rootNode = (ModulePartNode) ctx.node();
        for (ModuleMemberDeclarationNode member : rootNode.members()) {
            if (member instanceof TypeDefinitionNode) {
                TypeDefinitionNode typeDefinitionNode = (TypeDefinitionNode) member;
                TypeDescriptorNode typeDescriptorNode = (TypeDescriptorNode) typeDefinitionNode.typeDescriptor();
                if (typeDescriptorNode instanceof RecordTypeDescriptorNode) {
                    entities.add(Pluralizer.pluralize(typeDefinitionNode.typeName().text()).
                            toLowerCase(Locale.ROOT));
                }
            } else if (member instanceof ClassDefinitionNode) {
                ClassDefinitionNode classDefinitionNode = (ClassDefinitionNode) member;
                List<Node> persistTypeInheritanceNodes = classDefinitionNode.members().stream().filter(
                        (classMember) -> classMember.toString().trim().equals(
                                Constants.PERSIST_INHERITANCE_NODE)).collect(Collectors.toList());
                if (persistTypeInheritanceNodes.size() > 0) {
                    persistClientNames.add(classDefinitionNode.className().text().trim());
                }
            }
        }
    }
}
