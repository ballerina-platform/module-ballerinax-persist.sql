// AUTO-GENERATED FILE. DO NOT MODIFY.

// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.

import ballerina/jballerina.java;
import ballerina/persist;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerinax/persist.sql as psql;

const CUSTOMER = "customers";
const SALES_ORDER = "salesorders";
const ORDER_ITEM = "orderitems";
const PRODUCT = "products";

# MySQL persist client.
public isolated client class Client {
    *persist:AbstractPersistClient;

    private final mysql:Client dbClient;

    private final map<psql:SQLClient> persistClients;

    private final record {|psql:SQLMetadata...;|} & readonly metadata = {
        [CUSTOMER]: {
            entityName: "Customer",
            tableName: "Customer",
            fieldMetadata: {
                id: {columnName: "id"},
                name: {columnName: "name"},
                email: {columnName: "email"},
                country: {columnName: "country"},
                tier: {columnName: "tier"},
                "orders[].id": {relation: {entityName: "orders", refField: "id"}},
                "orders[].status": {relation: {entityName: "orders", refField: "status"}},
                "orders[].total": {relation: {entityName: "orders", refField: "total"}},
                "orders[].placedOn": {relation: {entityName: "orders", refField: "placedOn"}},
                "orders[].customerId": {relation: {entityName: "orders", refField: "customerId"}}
            },
            keyFields: ["id"],
            joinMetadata: {orders: {entity: SalesOrder, fieldName: "orders", refTable: "SalesOrder", refColumns: ["customerId"], joinColumns: ["id"], 'type: psql:MANY_TO_ONE}}
        },
        [SALES_ORDER]: {
            entityName: "SalesOrder",
            tableName: "SalesOrder",
            fieldMetadata: {
                id: {columnName: "id"},
                status: {columnName: "status"},
                total: {columnName: "total"},
                placedOn: {columnName: "placedOn"},
                customerId: {columnName: "customerId"},
                "customer.id": {relation: {entityName: "customer", refField: "id"}},
                "customer.name": {relation: {entityName: "customer", refField: "name"}},
                "customer.email": {relation: {entityName: "customer", refField: "email"}},
                "customer.country": {relation: {entityName: "customer", refField: "country"}},
                "customer.tier": {relation: {entityName: "customer", refField: "tier"}},
                "items[].id": {relation: {entityName: "items", refField: "id"}},
                "items[].sku": {relation: {entityName: "items", refField: "sku"}},
                "items[].quantity": {relation: {entityName: "items", refField: "quantity"}},
                "items[].price": {relation: {entityName: "items", refField: "price"}},
                "items[].salesorderId": {relation: {entityName: "items", refField: "salesorderId"}},
                "items[].productId": {relation: {entityName: "items", refField: "productId"}}
            },
            keyFields: ["id"],
            joinMetadata: {
                customer: {entity: Customer, fieldName: "customer", refTable: "Customer", refColumns: ["id"], joinColumns: ["customerId"], 'type: psql:ONE_TO_MANY},
                items: {entity: OrderItem, fieldName: "items", refTable: "OrderItem", refColumns: ["salesorderId"], joinColumns: ["id"], 'type: psql:MANY_TO_ONE}
            }
        },
        [ORDER_ITEM]: {
            entityName: "OrderItem",
            tableName: "OrderItem",
            fieldMetadata: {
                id: {columnName: "id"},
                sku: {columnName: "sku"},
                quantity: {columnName: "quantity"},
                price: {columnName: "price"},
                salesorderId: {columnName: "salesorderId"},
                productId: {columnName: "productId"},
                "salesOrder.id": {relation: {entityName: "salesOrder", refField: "id"}},
                "salesOrder.status": {relation: {entityName: "salesOrder", refField: "status"}},
                "salesOrder.total": {relation: {entityName: "salesOrder", refField: "total"}},
                "salesOrder.placedOn": {relation: {entityName: "salesOrder", refField: "placedOn"}},
                "salesOrder.customerId": {relation: {entityName: "salesOrder", refField: "customerId"}},
                "product.id": {relation: {entityName: "product", refField: "id"}},
                "product.name": {relation: {entityName: "product", refField: "name"}},
                "product.description": {relation: {entityName: "product", refField: "description"}},
                "product.attr01": {relation: {entityName: "product", refField: "attr01"}},
                "product.attr02": {relation: {entityName: "product", refField: "attr02"}},
                "product.attr03": {relation: {entityName: "product", refField: "attr03"}},
                "product.attr04": {relation: {entityName: "product", refField: "attr04"}},
                "product.attr05": {relation: {entityName: "product", refField: "attr05"}},
                "product.attr06": {relation: {entityName: "product", refField: "attr06"}},
                "product.attr07": {relation: {entityName: "product", refField: "attr07"}},
                "product.attr08": {relation: {entityName: "product", refField: "attr08"}},
                "product.attr09": {relation: {entityName: "product", refField: "attr09"}},
                "product.attr10": {relation: {entityName: "product", refField: "attr10"}},
                "product.attr11": {relation: {entityName: "product", refField: "attr11"}},
                "product.attr12": {relation: {entityName: "product", refField: "attr12"}},
                "product.attr13": {relation: {entityName: "product", refField: "attr13"}},
                "product.attr14": {relation: {entityName: "product", refField: "attr14"}},
                "product.num01": {relation: {entityName: "product", refField: "num01"}},
                "product.num02": {relation: {entityName: "product", refField: "num02"}},
                "product.num03": {relation: {entityName: "product", refField: "num03"}},
                "product.num04": {relation: {entityName: "product", refField: "num04"}},
                "product.num05": {relation: {entityName: "product", refField: "num05"}},
                "product.num06": {relation: {entityName: "product", refField: "num06"}},
                "product.num07": {relation: {entityName: "product", refField: "num07"}},
                "product.dec01": {relation: {entityName: "product", refField: "dec01"}},
                "product.dec02": {relation: {entityName: "product", refField: "dec02"}},
                "product.dec03": {relation: {entityName: "product", refField: "dec03"}},
                "product.dec04": {relation: {entityName: "product", refField: "dec04"}},
                "product.dec05": {relation: {entityName: "product", refField: "dec05"}},
                "product.dec06": {relation: {entityName: "product", refField: "dec06"}}
            },
            keyFields: ["id"],
            joinMetadata: {
                salesOrder: {entity: SalesOrder, fieldName: "salesOrder", refTable: "SalesOrder", refColumns: ["id"], joinColumns: ["salesorderId"], 'type: psql:ONE_TO_MANY},
                product: {entity: Product, fieldName: "product", refTable: "Product", refColumns: ["id"], joinColumns: ["productId"], 'type: psql:ONE_TO_MANY}
            }
        },
        [PRODUCT]: {
            entityName: "Product",
            tableName: "Product",
            fieldMetadata: {
                id: {columnName: "id"},
                name: {columnName: "name"},
                description: {columnName: "description"},
                attr01: {columnName: "attr01"},
                attr02: {columnName: "attr02"},
                attr03: {columnName: "attr03"},
                attr04: {columnName: "attr04"},
                attr05: {columnName: "attr05"},
                attr06: {columnName: "attr06"},
                attr07: {columnName: "attr07"},
                attr08: {columnName: "attr08"},
                attr09: {columnName: "attr09"},
                attr10: {columnName: "attr10"},
                attr11: {columnName: "attr11"},
                attr12: {columnName: "attr12"},
                attr13: {columnName: "attr13"},
                attr14: {columnName: "attr14"},
                num01: {columnName: "num01"},
                num02: {columnName: "num02"},
                num03: {columnName: "num03"},
                num04: {columnName: "num04"},
                num05: {columnName: "num05"},
                num06: {columnName: "num06"},
                num07: {columnName: "num07"},
                dec01: {columnName: "dec01"},
                dec02: {columnName: "dec02"},
                dec03: {columnName: "dec03"},
                dec04: {columnName: "dec04"},
                dec05: {columnName: "dec05"},
                dec06: {columnName: "dec06"},
                "orderItems[].id": {relation: {entityName: "orderItems", refField: "id"}},
                "orderItems[].sku": {relation: {entityName: "orderItems", refField: "sku"}},
                "orderItems[].quantity": {relation: {entityName: "orderItems", refField: "quantity"}},
                "orderItems[].price": {relation: {entityName: "orderItems", refField: "price"}},
                "orderItems[].salesorderId": {relation: {entityName: "orderItems", refField: "salesorderId"}},
                "orderItems[].productId": {relation: {entityName: "orderItems", refField: "productId"}}
            },
            keyFields: ["id"],
            joinMetadata: {orderItems: {entity: OrderItem, fieldName: "orderItems", refTable: "OrderItem", refColumns: ["productId"], joinColumns: ["id"], 'type: psql:MANY_TO_ONE}}
        }
    };

    public isolated function init() returns persist:Error? {
        mysql:Client|error dbClient = new (host = host, user = user, password = password, database = database, port = port, options = connectionOptions);
        if dbClient is error {
            return <persist:Error>error(dbClient.message());
        }
        self.dbClient = dbClient;
        self.persistClients = {
            [CUSTOMER]: check new (dbClient, self.metadata.get(CUSTOMER), psql:MYSQL_SPECIFICS),
            [SALES_ORDER]: check new (dbClient, self.metadata.get(SALES_ORDER), psql:MYSQL_SPECIFICS),
            [ORDER_ITEM]: check new (dbClient, self.metadata.get(ORDER_ITEM), psql:MYSQL_SPECIFICS),
            [PRODUCT]: check new (dbClient, self.metadata.get(PRODUCT), psql:MYSQL_SPECIFICS)
        };
    }

    # Get rows from Customer table.
    #
    # + targetType - Defines which fields to retrieve from the results
    # + whereClause - SQL WHERE clause to filter the results (e.g., `column_name = value`)
    # + orderByClause - SQL ORDER BY clause to sort the results (e.g., `column_name ASC`)
    # + limitClause - SQL LIMIT clause to limit the number of results (e.g., `10`)
    # + groupByClause - SQL GROUP BY clause to group the results (e.g., `column_name`)
    # + offsetClause - Number of rows to skip before returning results (e.g., `10`)
    # + return - A collection of matching records or an error
    isolated resource function get customers(CustomerTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``, sql:ParameterizedQuery offsetClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "queryWithOffset"
    } external;

    # Get row from Customer table.
    #
    # + id - The value of the primary key field id
    # + targetType - Defines which fields to retrieve from the result
    # + return - The matching record or an error
    isolated resource function get customers/[int id](CustomerTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "queryOne"
    } external;

    # Insert rows into Customer table.
    #
    # + data - A list of records to be inserted
    # + return - The primary key value(s) of the inserted rows or an error
    isolated resource function post customers(CustomerInsert[] data) returns int[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(CUSTOMER);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from CustomerInsert inserted in data
            select inserted.id;
    }

    # Update row in Customer table.
    #
    # + id - The value of the primary key field id
    # + value - The record containing updated field values
    # + return - The updated record or an error
    isolated resource function put customers/[int id](CustomerUpdate value) returns Customer|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(CUSTOMER);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        Customer|persist:Error result = self->/customers/[id].get();
        if result is Customer || result is persist:NotFoundError {
            return result;
        }
        return error persist:ReadBackError(string `The record was updated but could not be read back: ${result.message()}`, result);
    }

    # Delete row from Customer table.
    #
    # + id - The value of the primary key field id
    # + return - The deleted record or an error
    isolated resource function delete customers/[int id]() returns Customer|persist:Error {
        Customer result = check self->/customers/[id].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(CUSTOMER);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    # Get rows from SalesOrder table.
    #
    # + targetType - Defines which fields to retrieve from the results
    # + whereClause - SQL WHERE clause to filter the results (e.g., `column_name = value`)
    # + orderByClause - SQL ORDER BY clause to sort the results (e.g., `column_name ASC`)
    # + limitClause - SQL LIMIT clause to limit the number of results (e.g., `10`)
    # + groupByClause - SQL GROUP BY clause to group the results (e.g., `column_name`)
    # + offsetClause - Number of rows to skip before returning results (e.g., `10`)
    # + return - A collection of matching records or an error
    isolated resource function get salesorders(SalesOrderTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``, sql:ParameterizedQuery offsetClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "queryWithOffset"
    } external;

    # Get row from SalesOrder table.
    #
    # + id - The value of the primary key field id
    # + targetType - Defines which fields to retrieve from the result
    # + return - The matching record or an error
    isolated resource function get salesorders/[int id](SalesOrderTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "queryOne"
    } external;

    # Insert rows into SalesOrder table.
    #
    # + data - A list of records to be inserted
    # + return - The primary key value(s) of the inserted rows or an error
    isolated resource function post salesorders(SalesOrderInsert[] data) returns int[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(SALES_ORDER);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from SalesOrderInsert inserted in data
            select inserted.id;
    }

    # Update row in SalesOrder table.
    #
    # + id - The value of the primary key field id
    # + value - The record containing updated field values
    # + return - The updated record or an error
    isolated resource function put salesorders/[int id](SalesOrderUpdate value) returns SalesOrder|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(SALES_ORDER);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        SalesOrder|persist:Error result = self->/salesorders/[id].get();
        if result is SalesOrder || result is persist:NotFoundError {
            return result;
        }
        return error persist:ReadBackError(string `The record was updated but could not be read back: ${result.message()}`, result);
    }

    # Delete row from SalesOrder table.
    #
    # + id - The value of the primary key field id
    # + return - The deleted record or an error
    isolated resource function delete salesorders/[int id]() returns SalesOrder|persist:Error {
        SalesOrder result = check self->/salesorders/[id].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(SALES_ORDER);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    # Get rows from OrderItem table.
    #
    # + targetType - Defines which fields to retrieve from the results
    # + whereClause - SQL WHERE clause to filter the results (e.g., `column_name = value`)
    # + orderByClause - SQL ORDER BY clause to sort the results (e.g., `column_name ASC`)
    # + limitClause - SQL LIMIT clause to limit the number of results (e.g., `10`)
    # + groupByClause - SQL GROUP BY clause to group the results (e.g., `column_name`)
    # + offsetClause - Number of rows to skip before returning results (e.g., `10`)
    # + return - A collection of matching records or an error
    isolated resource function get orderitems(OrderItemTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``, sql:ParameterizedQuery offsetClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "queryWithOffset"
    } external;

    # Get row from OrderItem table.
    #
    # + id - The value of the primary key field id
    # + targetType - Defines which fields to retrieve from the result
    # + return - The matching record or an error
    isolated resource function get orderitems/[int id](OrderItemTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "queryOne"
    } external;

    # Insert rows into OrderItem table.
    #
    # + data - A list of records to be inserted
    # + return - The primary key value(s) of the inserted rows or an error
    isolated resource function post orderitems(OrderItemInsert[] data) returns int[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(ORDER_ITEM);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from OrderItemInsert inserted in data
            select inserted.id;
    }

    # Update row in OrderItem table.
    #
    # + id - The value of the primary key field id
    # + value - The record containing updated field values
    # + return - The updated record or an error
    isolated resource function put orderitems/[int id](OrderItemUpdate value) returns OrderItem|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(ORDER_ITEM);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        OrderItem|persist:Error result = self->/orderitems/[id].get();
        if result is OrderItem || result is persist:NotFoundError {
            return result;
        }
        return error persist:ReadBackError(string `The record was updated but could not be read back: ${result.message()}`, result);
    }

    # Delete row from OrderItem table.
    #
    # + id - The value of the primary key field id
    # + return - The deleted record or an error
    isolated resource function delete orderitems/[int id]() returns OrderItem|persist:Error {
        OrderItem result = check self->/orderitems/[id].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(ORDER_ITEM);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    # Get rows from Product table.
    #
    # + targetType - Defines which fields to retrieve from the results
    # + whereClause - SQL WHERE clause to filter the results (e.g., `column_name = value`)
    # + orderByClause - SQL ORDER BY clause to sort the results (e.g., `column_name ASC`)
    # + limitClause - SQL LIMIT clause to limit the number of results (e.g., `10`)
    # + groupByClause - SQL GROUP BY clause to group the results (e.g., `column_name`)
    # + offsetClause - Number of rows to skip before returning results (e.g., `10`)
    # + return - A collection of matching records or an error
    isolated resource function get products(ProductTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``, sql:ParameterizedQuery offsetClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "queryWithOffset"
    } external;

    # Get row from Product table.
    #
    # + id - The value of the primary key field id
    # + targetType - Defines which fields to retrieve from the result
    # + return - The matching record or an error
    isolated resource function get products/[int id](ProductTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "queryOne"
    } external;

    # Insert rows into Product table.
    #
    # + data - A list of records to be inserted
    # + return - The primary key value(s) of the inserted rows or an error
    isolated resource function post products(ProductInsert[] data) returns int[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(PRODUCT);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from ProductInsert inserted in data
            select inserted.id;
    }

    # Update row in Product table.
    #
    # + id - The value of the primary key field id
    # + value - The record containing updated field values
    # + return - The updated record or an error
    isolated resource function put products/[int id](ProductUpdate value) returns Product|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(PRODUCT);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        Product|persist:Error result = self->/products/[id].get();
        if result is Product || result is persist:NotFoundError {
            return result;
        }
        return error persist:ReadBackError(string `The record was updated but could not be read back: ${result.message()}`, result);
    }

    # Delete row from Product table.
    #
    # + id - The value of the primary key field id
    # + return - The deleted record or an error
    isolated resource function delete products/[int id]() returns Product|persist:Error {
        Product result = check self->/products/[id].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(PRODUCT);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    # Execute a custom SQL query and return results.
    #
    # + sqlQuery - The SQL query to execute
    # + rowType - Defines the structure of the result rows
    # + return - A collection of result rows or an error
    remote isolated function queryNativeSQL(sql:ParameterizedQuery sqlQuery, typedesc<record {}> rowType = <>) returns stream<rowType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor"
    } external;

    # Execute a custom SQL command (INSERT, UPDATE, DELETE, etc.).
    #
    # + sqlQuery - The SQL command to execute
    # + return - The execution result or an error
    remote isolated function executeNativeSQL(sql:ParameterizedQuery sqlQuery) returns psql:ExecutionResult|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor"
    } external;

    # Close the database client and release connections.
    #
    # + return - An error if closing fails
    public isolated function close() returns persist:Error? {
        error? result = self.dbClient.close();
        if result is error {
            return <persist:Error>error(result.message());
        }
        return result;
    }
}

