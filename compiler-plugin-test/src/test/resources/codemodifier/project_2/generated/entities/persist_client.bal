// AUTO-GENERATED FILE. DO NOT MODIFY.

// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.

import ballerina/persist;
import ballerina/jballerina.java;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerinax/persist.sql as psql;
import ballerina/sql;

const MANUFACTURE = "manufactures";
const PRODUCT = "products";

public isolated client class Client {
    *persist:AbstractPersistClient;

    private final mysql:Client dbClient;

    private final map<psql:SQLClient> persistClients;

    private final record {|psql:SQLMetadata...;|} & readonly metadata = {
        [MANUFACTURE] : {
            entityName: "Manufacture",
            tableName: "Manufacture",
            fieldMetadata: {
                id: {columnName: "id"},
                productsId: {columnName: "productsId"},
                "products.id": {relation: {entityName: "products", refField: "id"}},
                "products.name": {relation: {entityName: "products", refField: "name"}},
                "products.age": {relation: {entityName: "products", refField: "age"}}
            },
            keyFields: ["id"],
            joinMetadata: {products: {entity: Product, fieldName: "products", refTable: "Product", refColumns: ["id"], joinColumns: ["productsId"], 'type: psql:ONE_TO_MANY}}
        },
        [PRODUCT] : {
            entityName: "Product",
            tableName: "Product",
            fieldMetadata: {
                id: {columnName: "id"},
                name: {columnName: "name"},
                age: {columnName: "age"},
                "manufacture[].id": {relation: {entityName: "manufacture", refField: "id"}},
                "manufacture[].productsId": {relation: {entityName: "manufacture", refField: "productsId"}}
            },
            keyFields: ["id"],
            joinMetadata: {manufacture: {entity: Manufacture, fieldName: "manufacture", refTable: "Manufacture", refColumns: ["productsId"], joinColumns: ["id"], 'type: psql:MANY_TO_ONE}}
        }
    };

    public isolated function init() returns persist:Error? {
        mysql:Client|error dbClient = new (host = host, user = user, password = password, database = database, port = port, options = connectionOptions);
        if dbClient is error {
            return <persist:Error>error(dbClient.message());
        }
        self.dbClient = dbClient;
        self.persistClients = {
            [MANUFACTURE] : check new (dbClient, self.metadata.get(MANUFACTURE), psql:MYSQL_SPECIFICS),
            [PRODUCT] : check new (dbClient, self.metadata.get(PRODUCT), psql:MYSQL_SPECIFICS)
        };
    }

    isolated resource function get manufactures(ManufactureTargetType targetType = <>,  sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``,
                        sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "datastore.io.ballerina.stdlib.persist.sql.compiler.MySQLProcessor",
        name: "query"
    } external;

    isolated resource function get manufactures/[string id](ManufactureTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "datastore.io.ballerina.stdlib.persist.sql.compiler.MySQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post manufactures(ManufactureInsert[] data) returns string[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(MANUFACTURE);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from ManufactureInsert inserted in data
            select inserted.id;
    }

    isolated resource function put manufactures/[string id](ManufactureUpdate value) returns Manufacture|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(MANUFACTURE);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        return self->/manufactures/[id].get();
    }

    isolated resource function delete manufactures/[string id]() returns Manufacture|persist:Error {
        Manufacture result = check self->/manufactures/[id].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(MANUFACTURE);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    isolated resource function get products(ProductTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``,
                        sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "datastore.io.ballerina.stdlib.persist.sql.compiler.MySQLProcessor",
        name: "query"
    } external;

    isolated resource function get products/[int id](ProductTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "datastore.io.ballerina.stdlib.persist.sql.compiler.MySQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post products(ProductInsert[] data) returns int[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(PRODUCT);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from ProductInsert inserted in data
            select inserted.id;
    }

    isolated resource function put products/[int id](ProductUpdate value) returns Product|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(PRODUCT);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        return self->/products/[id].get();
    }

    isolated resource function delete products/[int id]() returns Product|persist:Error {
        Product result = check self->/products/[id].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(PRODUCT);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    public isolated function close() returns persist:Error? {
        error? result = self.dbClient.close();
        if result is error {
            return <persist:Error>error(result.message());
        }
        return result;
    }
}
