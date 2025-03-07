// Copyright (c) 2024 WSO2 LLC. (http://www.wso2.org).
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

import ballerina/jballerina.java;
import ballerina/persist;
import ballerina/sql;
import ballerinax/mssql;
import ballerinax/mssql.driver as _;

const SUBSCRIPTION = "subscriptions";
const API_METADATA = "apimetadata";

public isolated client class MsSqlApimClient {
    *persist:AbstractPersistClient;

    private final mssql:Client dbClient;

    private final map<SQLClient> persistClients;

    private final record {|SQLMetadata...;|} metadata = {
        [SUBSCRIPTION]: {
            entityName: "Subscription",
            tableName: "Subscription",
            fieldMetadata: {
                subscriptionId: {columnName: "subscriptionId"},
                userName: {columnName: "userName"},
                apimetadataApiId: {columnName: "apimetadataApiId"},
                apimetadataOrgId: {columnName: "apimetadataOrgId"},
                "apimetadata.apiId": {relation: {entityName: "apimetadata", refField: "apiId"}},
                "apimetadata.orgId": {relation: {entityName: "apimetadata", refField: "orgId"}},
                "apimetadata.apiName": {relation: {entityName: "apimetadata", refField: "apiName"}},
                "apimetadata.metadata": {relation: {entityName: "apimetadata", refField: "metadata"}}
            },
            keyFields: ["subscriptionId"],
            joinMetadata: {apimetadata: {entity: ApiMetadata, fieldName: "apimetadata", refTable: "ApiMetadata", refColumns: ["apiId", "orgId"], joinColumns: ["apimetadataApiId", "apimetadataOrgId"], 'type: ONE_TO_ONE}}
        },
        [API_METADATA]: {
            entityName: "ApiMetadata",
            tableName: "ApiMetadata",
            fieldMetadata: {
                apiId: {columnName: "apiId"},
                orgId: {columnName: "orgId"},
                apiName: {columnName: "apiName"},
                metadata: {columnName: "metadata"},
                "subscription.subscriptionId": {relation: {entityName: "subscription", refField: "subscriptionId"}},
                "subscription.userName": {relation: {entityName: "subscription", refField: "userName"}},
                "subscription.apimetadataApiId": {relation: {entityName: "subscription", refField: "apimetadataApiId"}},
                "subscription.apimetadataOrgId": {relation: {entityName: "subscription", refField: "apimetadataOrgId"}}
            },
            keyFields: ["apiId", "orgId"],
            joinMetadata: {subscription: {entity: Subscription, fieldName: "subscription", refTable: "Subscription", refColumns: ["apimetadataApiId", "apimetadataOrgId"], joinColumns: ["apiId", "orgId"], 'type: ONE_TO_ONE}}
        }
    };

    public isolated function init() returns persist:Error? {
        mssql:Client|error dbClient = new (host = mssql.host, user = mssql.user, password = mssql.password, database = mssql.database, port = mssql.port);
        if dbClient is error {
            return error persist:Error(dbClient.message());
        }
        self.dbClient = dbClient;
        self.persistClients = {
            [SUBSCRIPTION]: check new (dbClient, self.metadata.get(SUBSCRIPTION).cloneReadOnly(), MSSQL_SPECIFICS),
            [API_METADATA]: check new (dbClient, self.metadata.get(API_METADATA).cloneReadOnly(), MSSQL_SPECIFICS)
        };
    }

    isolated resource function get subscriptions(SubscriptionTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MSSQLProcessor",
        name: "query"
    } external;

    isolated resource function get subscriptions/[string subscriptionId](SubscriptionTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MSSQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post subscriptions(SubscriptionInsert[] data) returns string[]|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(SUBSCRIPTION);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from SubscriptionInsert inserted in data
            select inserted.subscriptionId;
    }

    isolated resource function put subscriptions/[string subscriptionId](SubscriptionUpdate value) returns Subscription|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(SUBSCRIPTION);
        }
        _ = check sqlClient.runUpdateQuery(subscriptionId, value);
        return self->/subscriptions/[subscriptionId].get();
    }

    isolated resource function delete subscriptions/[string subscriptionId]() returns Subscription|persist:Error {
        Subscription result = check self->/subscriptions/[subscriptionId].get();
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(SUBSCRIPTION);
        }
        _ = check sqlClient.runDeleteQuery(subscriptionId);
        return result;
    }

    isolated resource function get apimetadata(ApiMetadataTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MSSQLProcessor",
        name: "query"
    } external;

    isolated resource function get apimetadata/[string apiId]/[string orgId](ApiMetadataTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MSSQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post apimetadata(ApiMetadataInsert[] data) returns [string, string][]|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(API_METADATA);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from ApiMetadataInsert inserted in data
            select [inserted.apiId, inserted.orgId];
    }

    isolated resource function put apimetadata/[string apiId]/[string orgId](ApiMetadataUpdate value) returns ApiMetadata|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(API_METADATA);
        }
        _ = check sqlClient.runUpdateQuery({"apiId": apiId, "orgId": orgId}, value);
        return self->/apimetadata/[apiId]/[orgId].get();
    }

    isolated resource function delete apimetadata/[string apiId]/[string orgId]() returns ApiMetadata|persist:Error {
        ApiMetadata result = check self->/apimetadata/[apiId]/[orgId].get();
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(API_METADATA);
        }
        _ = check sqlClient.runDeleteQuery({"apiId": apiId, "orgId": orgId});
        return result;
    }

    remote isolated function queryNativeSQL(sql:ParameterizedQuery sqlQuery, typedesc<record {}> rowType = <>) returns stream<rowType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MSSQLProcessor"
    } external;

    remote isolated function executeNativeSQL(sql:ParameterizedQuery sqlQuery) returns ExecutionResult|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MSSQLProcessor"
    } external;

    public isolated function close() returns persist:Error? {
        error? result = self.dbClient.close();
        if result is error {
            return <persist:Error>error(result.message());
        }
        return result;
    }
}

