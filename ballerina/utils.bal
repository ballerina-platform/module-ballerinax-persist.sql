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

import ballerina/sql;
import ballerina/persist;

isolated function stringToParameterizedQuery(string queryStr) returns sql:ParameterizedQuery {
    sql:ParameterizedQuery query = ``;
    query.strings = [queryStr];
    return query;
}

isolated function getKeyFromAlreadyExistsErrorMessage(string errorMessage) returns string|persist:Error {
    int? startIndex = errorMessage.indexOf(".Duplicate entry '");
    int? endIndex = errorMessage.indexOf("' for key");

    if startIndex is () || endIndex is () {
        return <persist:Error>error("Unable to determine key from DuplicateKey error message.");
    }

    string key = errorMessage.substring(startIndex + 18, endIndex);
    return key;
}

isolated function arrayToParameterizedQuery(string[] arr, sql:ParameterizedQuery delimiter = `,`) returns sql:ParameterizedQuery {
    sql:ParameterizedQuery query = stringToParameterizedQuery(arr[0]);
    foreach int i in 1 ..< arr.length() {
        query = sql:queryConcat(query, delimiter, stringToParameterizedQuery(arr[i]));
    }
    return query;
}
