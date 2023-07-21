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

import io.ballerina.compiler.syntax.tree.SyntaxKind;
import io.ballerina.projects.plugins.CodeModifier;
import io.ballerina.projects.plugins.CodeModifierContext;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Analyzes a Ballerina Persist.
 */
public class PersistCodeModifier extends CodeModifier {

    private final List<String> persistClientNames = new ArrayList<>();
    private final Map<String, String> variables = new HashMap<>();
    private final List<String> entities = new ArrayList<>();

    @Override
    public void init(CodeModifierContext codeModifierContext) {
        // Add validations for unsupported expressions in where clause
        codeModifierContext.addSyntaxNodeAnalysisTask(new PersistQueryValidator(), SyntaxKind.QUERY_PIPELINE);
        // Identify all persist client in the package and declared entity
        codeModifierContext.addSyntaxNodeAnalysisTask(new PersistEntityAndClassIdentifierTask(
                entities, persistClientNames), SyntaxKind.MODULE_PART);
        // Identify all declared variable names with type
        codeModifierContext.addSyntaxNodeAnalysisTask(new PersistVariableIdentifierTask(variables),
                Arrays.asList(SyntaxKind.LOCAL_VAR_DECL, SyntaxKind.MODULE_VAR_DECL));

        codeModifierContext.addSourceModifierTask(new QueryCodeModifierTask(persistClientNames, entities, variables));
    }
}
