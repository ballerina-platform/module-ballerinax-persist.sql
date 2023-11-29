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
    duplicateEntryErrorMessage: "Duplicate entry",
    duplicateKeyStartIndicator: ".Duplicate entry '",
    duplicateKeyEndIndicator: "' for key",
    columnIdentifier: ""
};

public final DataSourceSpecifics & readonly MSSQL_SPECIFICS = {
    quoteOpen: "[",
    quoteClose: "]",
    constraintViolationErrorMessage: "conflicted with the FOREIGN KEY constraint",
    duplicateEntryErrorMessage: "Cannot insert duplicate key",
    duplicateKeyStartIndicator: "The duplicate key value is (",
    duplicateKeyEndIndicator: ")..",
    columnIdentifier: ""
};

public final DataSourceSpecifics & readonly POSTGRESQL_SPECIFICS = {
    quoteOpen: "",
    quoteClose: "",
    constraintViolationErrorMessage: "violates foreign key constraint",
    duplicateEntryErrorMessage: "duplicate key value violates unique constraint",
    duplicateKeyStartIndicator: "Detail: Key ",
    duplicateKeyEndIndicator: " already exists.",
    columnIdentifier: "\""
};
