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

import io.ballerina.compiler.syntax.tree.QueryPipelineNode;
import io.ballerina.compiler.syntax.tree.SyntaxKind;
import io.ballerina.projects.plugins.CodeModifier;
import io.ballerina.projects.plugins.CodeModifierContext;
import io.ballerina.stdlib.persist.sql.compiler.model.Query;

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
    private final List<String> persistClientVariableNames = new ArrayList<>();
    private final Map<String, String> variables = new HashMap<>();
    private final List<String> entities = new ArrayList<>();
    private final Map<QueryPipelineNode, Query> queries = new HashMap<>();
    private final Map<QueryPipelineNode, Query> validatedQueries = new HashMap<>();

    @Override
    public void init(CodeModifierContext codeModifierContext) {
        // Add validations to find the query
        codeModifierContext.addSyntaxNodeAnalysisTask(new PersistQueryValidator(entities, persistClientNames,
                variables, queries, validatedQueries, persistClientVariableNames), SyntaxKind.QUERY_PIPELINE);
        // Identify all persist client in the package and all declared entity and variable names with type.
        codeModifierContext.addSyntaxNodeAnalysisTask(new PersistEntityAndClassIdentifierTask(
                entities, persistClientNames, variables, queries, validatedQueries, persistClientVariableNames),
                Arrays.asList(SyntaxKind.LOCAL_VAR_DECL, SyntaxKind.MODULE_VAR_DECL, SyntaxKind.MODULE_PART));

        codeModifierContext.addSourceModifierTask(new QueryCodeModifierTask(validatedQueries));
    }
}
