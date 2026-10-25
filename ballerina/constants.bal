// Copyright (c) 2023 WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

public final DataSourceSpecifics & readonly MYSQL_SPECIFICS = {
    quoteOpen: "`",
    quoteClose: "`",
    constraintViolationErrorMessage: "a foreign key constraint fails",
    constraintViolationErrorCodes: [1451, 1452],
    duplicateEntryErrorMessage: "Duplicate entry",
    duplicateEntryErrorCodes: [1062],
    duplicateKeyStartIndicator: "Duplicate entry '",
    duplicateKeyEndIndicator: "' for key",
    paginationSyntax: LIMIT_REQUIRED_WITH_OFFSET
};

public final DataSourceSpecifics & readonly MSSQL_SPECIFICS = {
    quoteOpen: "[",
    quoteClose: "]",
    constraintViolationErrorMessage: "conflicted with the FOREIGN KEY constraint",
    constraintViolationErrorCodes: [547],
    duplicateEntryErrorMessage: "Cannot insert duplicate key",
    duplicateEntryErrorCodes: [2601, 2627],
    duplicateKeyStartIndicator: "The duplicate key value is (",
    duplicateKeyEndIndicator: ")..",
    paginationSyntax: OFFSET_FETCH
};

public final DataSourceSpecifics & readonly POSTGRESQL_SPECIFICS = {
    quoteOpen: "\"",
    quoteClose: "\"",
    constraintViolationErrorMessage: "violates foreign key constraint",
    constraintViolationSqlStates: ["23503"],
    duplicateEntryErrorMessage: "duplicate key value violates unique constraint",
    duplicateEntrySqlStates: ["23505"],
    duplicateKeyStartIndicator: "Detail: Key ",
    duplicateKeyEndIndicator: " already exists."
};

public final DataSourceSpecifics & readonly H2_SPECIFICS = {
    quoteOpen: "\"",
    quoteClose: "\"",
    constraintViolationErrorMessage: "Referential integrity constraint violation",
    constraintViolationErrorCodes: [23503, 23506],
    duplicateEntryErrorMessage: "Unique index or primary key violation",
    duplicateEntryErrorCodes: [23505],
    duplicateKeyStartIndicator: "Unique index or primary key violation: \"",
    duplicateKeyEndIndicator: " ON "
};
