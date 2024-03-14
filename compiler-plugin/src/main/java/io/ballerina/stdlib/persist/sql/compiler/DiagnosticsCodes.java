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

import io.ballerina.tools.diagnostics.DiagnosticSeverity;

import static io.ballerina.tools.diagnostics.DiagnosticSeverity.ERROR;
import static io.ballerina.tools.diagnostics.DiagnosticSeverity.WARNING;

/**
 * Persist related diagnostic codes.
 */
public enum DiagnosticsCodes {

    PERSIST_SQL_201("PERSIST_201", "an entity should be a closed record", ERROR),
    PERSIST_SQL_202("PERSIST_202", "persist remote function call does not support ''{0}'' argument",
            ERROR),
    PERSIST_SQL_203("PERSIST_203", "A persist remote function call does not support anything " +
            "other than a target type argument", ERROR),
    PERSIST_SQL_204("PERSIST_204", "''group by'' clause cannot be defined before the ''{0}'' clause",
            ERROR),
    PERSIST_SQL_205("PERSIST_205", "''limit'' clause cannot be defined by the field of the entity", ERROR),
    PERSIST_SQL_206("PERSIST_206",  "the ''{0}'' clause cannot be defined by the array field " +
            "of the entity", ERROR),
    PERSIST_SQL_423("PERSIST_423", "invalid use of the `Relation` annotation. mismatched number of " +
            "reference keys for relation ''{0}'' in entity ''{1}''. expected {2} but found {3}.", ERROR),
    PERSIST_SQL_424("PERSIST_424", "invalid use of the `Relation` annotation. mismatched key types for " +
            "the related entity ''{0}''.", ERROR),
    PERSIST_SQL_426("PERSIST_426", "invalid use of the `Relation` annotation. the field ''{0}'' is " +
            "an array type in a 1-n relationship. therefore, it cannot have foreign keys.", ERROR),
    PERSIST_SQL_427("PERSIST_427", "invalid use of the `Relation` annotation. the field ''{0}'' is an " +
            "optional type in a 1-1 relationship. therefore, it cannot have foreign keys.", ERROR),
    PERSIST_SQL_428("PERSIST_428", "invalid use of the `Relation` annotation. the field ''{0}'' is not " +
            "found in the entity ''{1}''.", ERROR),
    PERSIST_SQL_429("PERSIST_429", "invalid use of the `Relation` annotation. keys cannot contain " +
            "duplicates.", ERROR),
    PERSIST_SQL_430("PERSIST_430", "invalid use of the `Relation` annotation. duplicated key field.",
                ERROR),
    PERSIST_SQL_600("PERSIST_600", "invalid use of the `Name` annotation. mapping value cannot be " +
            "empty.", ERROR),
    PERSIST_SQL_601("PERSIST_601", "redundant use of the `Name` annotation. mapping value is same as " +
            "model definition.", WARNING),
    PERSIST_SQL_602("PERSIST_602", "invalid use of the `Name` annotation. the `Name` annotation " +
            "cannot be used for relation fields.", ERROR),
    PERSIST_SQL_604("PERSIST_604", "invalid use of the `''{0}''` annotation. the `''{0}''` annotation " +
            "can only be used for ''string'' type.", ERROR),
    PERSIST_SQL_605("PERSIST_605", "invalid use of `Varchar` and `Char` annotations. only one of " +
            "either `Varchar` or `Char` annotations can be used at a time.", ERROR),
    PERSIST_SQL_606("PERSIST_606", "invalid use of the `Decimal` annotation. the `Decimal` annotation " +
            "can only be used for ''decimal'' type.", ERROR),
    PERSIST_SQL_607("PERSIST_607", "invalid use of the `''{0}''` annotation. length cannot be 0.", ERROR),
    PERSIST_SQL_608("PERSIST_608", "invalid use of the `Decimal` annotation. precision cannot be 0.",
            ERROR),
    PERSIST_SQL_609("PERSIST_609", "invalid use of the `Decimal` annotation. precision cannot be less " +
            "than scale.", ERROR),
    PERSIST_SQL_610("PERSIST_610", "invalid use of the `Name` annotation. duplicate mapping value " +
            "found.", ERROR),
    PERSIST_SQL_611("PERSIST_611", "invalid use of the `Index` annotation. the `Index` annotation " +
            "cannot be used for relation fields.", ERROR),
    PERSIST_SQL_612("PERSIST_612", "invalid use of the `UniqueIndex` annotation. the `UniqueIndex` " +
            "annotation cannot be used for relation fields.", ERROR),
    PERSIST_SQL_613("PERSIST_613", "invalid use of the `Index` annotation. duplicate index names.", ERROR),
    PERSIST_SQL_614("PERSIST_614", "invalid use of the `UniqueIndex` annotation. duplicate index " +
            "names.", ERROR),
    PERSIST_SQL_615("PERSIST_615", "invalid use of the `Index` annotation. there cannot be empty index " +
            "names.", ERROR),
    PERSIST_SQL_616("PERSIST_616", "invalid use of the `UniqueIndex` annotation. there cannot be empty " +
            "index names.", ERROR),
    PERSIST_SQL_617("PERSIST_617", "invalid use of the `Generated` annotation. the `Generated` " +
            "annotation can only be used for ''readonly'' fields.", ERROR),
    PERSIST_SQL_618("PERSIST_618", "invalid use of the `Generated` annotation. partial key fields " +
            "cannot be auto-generated.", ERROR),
    PERSIST_SQL_619("PERSIST_619", "invalid use of the `Generated` annotation. a generated field can " +
            "only be an ''int'' type.", ERROR),
    PERSIST_SQL_620("PERSIST_620", "invalid use of the `Name` annotation. a mapping value should not " +
            "conflict with an Entity name.", ERROR),
    PERSIST_SQL_621("PERSIST_621", "invalid use of the `Name` annotation. a mapping value should not " +
            "conflict with a field name.", ERROR),
    PERSIST_SQL_622("PERSIST_622", "invalid use of the `Index` annotation. index name cannot be empty.",
            ERROR),
    PERSIST_SQL_623("PERSIST_623", "invalid use of the `UniqueIndex` annotation. unique index name " +
            "cannot be empty.", ERROR),
    PERSIST_SQL_624("PERSIST_624", "invalid use of the `Index` annotation. name array should have at " +
            "least one index name.", ERROR),
    PERSIST_SQL_625("PERSIST_625", "invalid use of the `UniqueIndex` annotation. name array should " +
            "have at least one index name.", ERROR),
    ;
            
    private final String code;
    private final String message;
    private final DiagnosticSeverity severity;

    DiagnosticsCodes(String code, String message, DiagnosticSeverity severity) {
        this.code = code;
        this.message = message;
        this.severity = severity;
    }

    public String getCode() {
        return code;
    }

    public String getMessage() {
        return message;
    }

    public DiagnosticSeverity getSeverity() {
        return severity;
    }
}
