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

import io.ballerina.compiler.syntax.tree.BindingPatternNode;
import io.ballerina.compiler.syntax.tree.ChildNodeEntry;
import io.ballerina.compiler.syntax.tree.ClientResourceAccessActionNode;
import io.ballerina.compiler.syntax.tree.FromClauseNode;
import io.ballerina.compiler.syntax.tree.IntermediateClauseNode;
import io.ballerina.compiler.syntax.tree.LimitClauseNode;
import io.ballerina.compiler.syntax.tree.NodeList;
import io.ballerina.compiler.syntax.tree.OrderByClauseNode;
import io.ballerina.compiler.syntax.tree.QueryPipelineNode;
import io.ballerina.compiler.syntax.tree.WhereClauseNode;
import io.ballerina.projects.plugins.AnalysisTask;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.stdlib.persist.sql.compiler.exception.NotSupportedExpressionException;
import io.ballerina.stdlib.persist.sql.compiler.expression.ExpressionBuilder;
import io.ballerina.stdlib.persist.sql.compiler.expression.ExpressionVisitor;
import io.ballerina.stdlib.persist.sql.compiler.utils.Utils;

import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Analysis task to validate queries.
 */
public class PersistQueryValidator implements AnalysisTask<SyntaxNodeAnalysisContext> {
    
    @Override
    public void perform(SyntaxNodeAnalysisContext ctx) {
        if (Utils.hasCompilationErrors(ctx)) {
            return;
        }

        QueryPipelineNode queryPipelineNode = (QueryPipelineNode) ctx.node();
        FromClauseNode fromClauseNode = queryPipelineNode.fromClause();
        if (!isQueryUsingPersistentClient(fromClauseNode)) {
            return;
        }

        NodeList<IntermediateClauseNode> intermediateClauseNodes = queryPipelineNode.intermediateClauses();
        List<IntermediateClauseNode> whereClauseNodes = intermediateClauseNodes.stream()
                .filter((node) -> node instanceof WhereClauseNode)
                .collect(Collectors.toList());

        List<IntermediateClauseNode> orderByClauseNode = intermediateClauseNodes.stream()
                .filter((node) -> node instanceof OrderByClauseNode)
                .collect(Collectors.toList());

        List<IntermediateClauseNode> limitClauseNode = intermediateClauseNodes.stream()
                .filter((node) -> node instanceof LimitClauseNode)
                .collect(Collectors.toList());

        boolean isWhereClauseUsed = whereClauseNodes.size() != 0;
        boolean isOrderByClauseUsed = orderByClauseNode.size() != 0;
        boolean isLimitClauseUsed = limitClauseNode.size() != 0;

        if (!isWhereClauseUsed && !isOrderByClauseUsed && !isLimitClauseUsed) {
            return;
        }

        if (isWhereClauseUsed) {
            BindingPatternNode bindingPatternNode = fromClauseNode.typedBindingPattern().bindingPattern();
            WhereClauseNode whereClauseNode = (WhereClauseNode) whereClauseNodes.get(0);
            try {
                ExpressionBuilder expressionBuilder = new ExpressionBuilder(whereClauseNode.expression(),
                        bindingPatternNode);
                ExpressionVisitor expressionVisitor = new ExpressionVisitor();
                expressionBuilder.build(expressionVisitor);
            } catch (NotSupportedExpressionException e) {
                ctx.reportDiagnostic(e.getDiagnostic());
            }
        }
    }

    private boolean isQueryUsingPersistentClient(FromClauseNode fromClauseNode) {
        if (fromClauseNode.expression() instanceof ClientResourceAccessActionNode) {
            ClientResourceAccessActionNode remoteCall =
                    (ClientResourceAccessActionNode) fromClauseNode.expression();
            Collection<ChildNodeEntry> clientResourceChildEntries = remoteCall.childEntries();
            return clientResourceChildEntries.size() == 5 || clientResourceChildEntries.size() == 7;
        }
        return false;
    }
}
