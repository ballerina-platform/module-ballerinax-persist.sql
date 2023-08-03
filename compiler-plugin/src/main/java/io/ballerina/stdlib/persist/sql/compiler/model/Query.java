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

package io.ballerina.stdlib.persist.sql.compiler.model;

import io.ballerina.compiler.syntax.tree.FunctionArgumentNode;
import io.ballerina.compiler.syntax.tree.IntermediateClauseNode;
import io.ballerina.compiler.syntax.tree.Node;
import io.ballerina.compiler.syntax.tree.SeparatedNodeList;

import java.util.List;

/**
 * Model class to hold query properties.
 */
public class Query {
    private List<IntermediateClauseNode> whereClauseNodes;
    private List<IntermediateClauseNode> orderByClauseNode;
    private List<IntermediateClauseNode> groupByClauseNode;
    private List<IntermediateClauseNode> limitClauseNode;
    private List<IntermediateClauseNode> letClauseNodes;
    private final SeparatedNodeList<FunctionArgumentNode> arguments;
    public boolean validated = false;
    private final SeparatedNodeList<Node> path;
    private final String clientName;
    private String tableName;

    public Query(String clientName, SeparatedNodeList<FunctionArgumentNode> arguments, SeparatedNodeList<Node> path) {
        this.clientName = clientName;
        this.arguments = arguments;
        this.path = path;
    }

    public String getClientName() {
        return clientName;
    }

    public void addWhereClause(List<IntermediateClauseNode> whereClauseNodes) {
        this.whereClauseNodes = whereClauseNodes;
    }

    public List<IntermediateClauseNode> getWhereClause() {
        return whereClauseNodes;
    }

    public void addOrderByClause(List<IntermediateClauseNode> orderByClauseNodes) {
        this.orderByClauseNode = orderByClauseNodes;
    }

    public List<IntermediateClauseNode> getOrderByClause() {
        return orderByClauseNode;
    }

    public void addGroupByClauses(List<IntermediateClauseNode> groupByClauseNode) {
        this.groupByClauseNode = groupByClauseNode;
    }

    public List<IntermediateClauseNode> getGroupByClauses() {
        return groupByClauseNode;
    }

    public void addLimitClauses(List<IntermediateClauseNode> limitClauseNode) {
        this.limitClauseNode = limitClauseNode;
    }

    public List<IntermediateClauseNode> getLimitClauses() {
        return limitClauseNode;
    }

    public void addLetClauseNodes(List<IntermediateClauseNode> letClauseNodes) {
        this.letClauseNodes = letClauseNodes;
    }

    public List<IntermediateClauseNode> getLetClauseNodes() {
        return letClauseNodes;
    }

    public SeparatedNodeList<FunctionArgumentNode> getArguments() {
        return arguments;
    }

    public SeparatedNodeList<Node> getPath() {
        return path;
    }

    public boolean isValidated() {
        return this.validated;
    }

    public void addTableName(String tableName) {
        this.tableName = tableName;
    }
    public String getTableName() {
        return this.tableName;
    }
}
