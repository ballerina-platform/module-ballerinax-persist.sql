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

// A `DataSourceSpecifics` without error codes or SQL states falls back to matching the error message.
isolated function matchesError(sql:Error e, int[] errorCodes, string[] sqlStates, string message) returns boolean {
    if errorCodes.length() == 0 && sqlStates.length() == 0 {
        return e.message().includes(message);
    }
    int errorCode;
    string? sqlState;
    if e is sql:DatabaseError {
        errorCode = e.detail().errorCode;
        sqlState = e.detail().sqlState;
    } else if e is sql:BatchExecuteError {
        errorCode = e.detail().errorCode;
        sqlState = e.detail().sqlState;
    } else {
        return false;
    }
    // PostgreSQL reports no vendor error code, so it is matched on the SQL state instead.
    return errorCodes.indexOf(errorCode) is int || (sqlState is string && sqlStates.indexOf(sqlState) is int);
}

isolated function getKeyFromAlreadyExistsErrorMessage(string errorMessage, string startIndicator, string endIndicator) returns string|persist:Error {
    int? startIndex = errorMessage.indexOf(startIndicator);
    int? endIndex = errorMessage.indexOf(endIndicator);

    if startIndex is () || endIndex is () {
        return <persist:Error>error("Unable to determine key from DuplicateKey error message.");
    }

    string key = errorMessage.substring(startIndex + startIndicator.length(), endIndex);
    return key;
}

isolated function arrayToParameterizedQuery(string[] arr, sql:ParameterizedQuery delimiter = `,`) returns sql:ParameterizedQuery {
    sql:ParameterizedQuery query = stringToParameterizedQuery(arr[0]);
    foreach int i in 1 ..< arr.length() {
        query = sql:queryConcat(query, delimiter, stringToParameterizedQuery(arr[i]));
    }
    return query;
}
