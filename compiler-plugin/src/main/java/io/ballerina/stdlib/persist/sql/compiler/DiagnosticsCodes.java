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
    PERSIST_SQL_205("PERSIST_205", "''limit'' clause cannot be defined by the field of the entity",
            ERROR),

    PERSIST_SQL_206("PERSIST_206",  "the ''{0}'' clause cannot be defined by the array field " +
            "of the entity",
            ERROR);

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
