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

import io.ballerina.compiler.syntax.tree.LiteralValueToken;
import io.ballerina.compiler.syntax.tree.NodeFactory;
import io.ballerina.compiler.syntax.tree.SyntaxKind;
import io.ballerina.compiler.syntax.tree.Token;

import static io.ballerina.compiler.syntax.tree.AbstractNodeFactory.createEmptyMinutiaeList;

/**
 * Constants class.
 */
public final class Constants {

    private Constants() {
    }
    public static final String BACKTICK = "`";
    public static final String SPACE = " ";
    public static final String PERSIST_INHERITANCE_NODE = "*persist:AbstractPersistClient;";
    public static final String DESCENDING = "descending";
    public static final String OPEN_BRACES_WITH_SPACE = "( ";
    public static final String CLOSE_BRACES_WITH_SPACE = ") ";
    public static final String BAL_ESCAPE_TOKEN = "'";
    public static final String OPEN_BRACES = "(";
    public static final String CLOSE_BRACES_WITH_NEW_LINE = ")\n";
    public static final String INTERPOLATION_START_TOKEN = "${";
    public static final String INTERPOLATION_END_TOKEN = "}";
    public static final String COMMA_WITH_SPACE = ", ";
    public static final String COLON = ":";
    public static final String GET = "get";
    public static final String TARGET_TYPE = "targetType";
    public static final String WHERE = "where";
    public static final String ORDER_BY = "order by";
    public static final String PERSIST_DIRECTORY = "persist";
    public static final String SQL_DB_MAPPING_ANNOTATION_NAME = "sql:Mapping";
    public static final String SQL_VARCHAR_MAPPING_ANNOTATION_NAME = "sql:VarChar";
    public static final String SQL_CHAR_MAPPING_ANNOTATION_NAME = "sql:Char";
    public static final String SQL_DECIMAL_MAPPING_ANNOTATION_NAME = "sql:Decimal";
    public static final String SQL_RELATION_MAPPING_ANNOTATION_NAME = "sql:Relation";
    public static final String SQL_INDEX_MAPPING_ANNOTATION_NAME = "sql:Index";
    public static final String SQL_UNIQUE_INDEX_MAPPING_ANNOTATION_NAME = "sql:UniqueIndex";
    public static final String SQL_GENERATED_ANNOTATION_NAME = "sql:Generated";
    public static final String ANNOTATION_NAME_FIELD = "name";
    public static final String ANNOTATION_NAMES_FIELD = "names";
    public static final String ANNOTATION_PRECISION_FIELD = "precision";
    public static final String ANNOTATION_REFS_FIELD = "refs";
    public static final String ANNOTATION_LENGTH_FIELD = "length";

    /**
     * SQL keywords used to construct the query.
     */
    public static final class SQLKeyWords {

        private SQLKeyWords() {}
        public static final String NOT_EQUAL_TOKEN = "<>";
        public static final String AND = "AND";
        public static final String OR = "OR";
        public static final String ORDER_BY_ASCENDING = "ASC";
        public static final String ORDER_BY_DESCENDING = "DESC";
    }

    /**
     * Constant nodes used in code modification.
     */
    public static final class TokenNodes {

        private TokenNodes() {}

        public static final Token INTERPOLATION_START_TOKEN = NodeFactory.createLiteralValueToken(
                SyntaxKind.INTERPOLATION_START_TOKEN, "${", createEmptyMinutiaeList(), createEmptyMinutiaeList());
        public static final Token INTERPOLATION_END_TOKEN = NodeFactory.createLiteralValueToken(
                SyntaxKind.CLOSE_BRACE_TOKEN, "}", createEmptyMinutiaeList(), createEmptyMinutiaeList());
        public static final Token WHERE_CLAUSE_NAME = NodeFactory.createLiteralValueToken(
                SyntaxKind.NAMED_ARG, "whereClause", createEmptyMinutiaeList(), createEmptyMinutiaeList());
        public static final Token ORDER_BY_CLAUSE_NAME = NodeFactory.createLiteralValueToken(
                SyntaxKind.NAMED_ARG, "orderByClause", createEmptyMinutiaeList(), createEmptyMinutiaeList());
        public static final Token LIMIT_CLAUSE_NAME = NodeFactory.createLiteralValueToken(
                SyntaxKind.NAMED_ARG, "limitClause", createEmptyMinutiaeList(), createEmptyMinutiaeList());
        public static final Token GROUP_BY_CLAUSE_NAME = NodeFactory.createLiteralValueToken(
                SyntaxKind.NAMED_ARG, "groupByClause", createEmptyMinutiaeList(), createEmptyMinutiaeList());
        public static final Token EQUAL_TOKEN = NodeFactory.createLiteralValueToken(
                SyntaxKind.EQUAL_TOKEN, " = ", createEmptyMinutiaeList(), createEmptyMinutiaeList());
        public static final Token COMMA_TOKEN = NodeFactory.createLiteralValueToken(
                SyntaxKind.COMMA_TOKEN, ", ", createEmptyMinutiaeList(), createEmptyMinutiaeList());
        public static final LiteralValueToken BACKTICK_TOKEN = NodeFactory.createLiteralValueToken(
                SyntaxKind.BACKTICK_TOKEN, BACKTICK, createEmptyMinutiaeList(), createEmptyMinutiaeList());
        public static final Token OPEN_PAREN_TOKEN = NodeFactory.createLiteralValueToken(SyntaxKind.OPEN_PAREN_TOKEN,
                OPEN_BRACES, createEmptyMinutiaeList(), createEmptyMinutiaeList());
        public static final Token CLOSE_PAREN_WITH_NEW_LINE_TOKEN = NodeFactory.createLiteralValueToken(
                SyntaxKind.CLOSE_PAREN_TOKEN, CLOSE_BRACES_WITH_NEW_LINE, createEmptyMinutiaeList(),
                createEmptyMinutiaeList());
    }

    public static final class BallerinaTypes {

        public static final String INT = "int";
        public static final String STRING = "string";
        public static final String BOOLEAN = "boolean";
        public static final String DECIMAL = "decimal";
        public static final String FLOAT = "float";
        public static final String BYTE = "byte";
        public static final String ENUM = "enum";

        private BallerinaTypes() {
        }
    }
}
