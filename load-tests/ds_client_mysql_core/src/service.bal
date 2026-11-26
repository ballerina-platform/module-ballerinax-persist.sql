import ballerina/http;
import ballerina/persist;
import ballerina/time;

configurable int servicePort = 9291;

type OrderRow record {|
    int id;
    string status;
    decimal total;
    time:Date placedOn;
    int customerId;
|};

type OrderWithCustomer record {|
    int id;
    string status;
    decimal total;
    record {|
        int id;
        string name;
        string email;
        string country;
        int tier;
    |} customer;
|};

type OrderWithItems record {|
    int id;
    string status;
    decimal total;
    record {|
        int id;
        string sku;
        int quantity;
        decimal price;
        int salesorderId;
        int productId;
    |}[] items;
|};

type ItemWithProduct record {|
    int id;
    int quantity;
    record {|
        int id;
        string name;
    |} product;
|};

type ProductWithItems record {|
    int id;
    string name;
    record {|
        int id;
        string sku;
        int quantity;
        decimal price;
        int salesorderId;
        int productId;
    |}[] orderItems;
|};

type ProductNarrow record {|
    int id;
    string name;
    int num01;
|};


final Client persistClient = check new;

// The persist client called directly, with the same queries the data service scenarios produce.
service /bare on new http:Listener(servicePort) {

    resource function get get_by_key/[int id]() returns OrderRow|error {
        return persistClient->/salesorders/[id];
    }

    resource function get list(int size, int offset) returns OrderRow[]|error {
        stream<OrderRow, persist:Error?> rows = persistClient->/salesorders(
            orderByClause = `SalesOrder.id`, limitClause = `${size}`, offsetClause = `${offset}`);
        return from OrderRow row in rows
            select row;
    }

    resource function get filter_sort(int size, int offset) returns OrderRow[]|error {
        stream<OrderRow, persist:Error?> rows = persistClient->/salesorders(
            whereClause = `SalesOrder.status = ${"PAID"}`, orderByClause = `SalesOrder.placedOn DESC, SalesOrder.id`,
            limitClause = `${size}`, offsetClause = `${offset}`);
        return from OrderRow row in rows
            select row;
    }

    resource function get to_one/[int id]() returns OrderWithCustomer|error {
        return persistClient->/salesorders/[id];
    }

    resource function get to_many(int size, int offset) returns OrderWithItems[]|error {
        stream<OrderWithItems, persist:Error?> rows = persistClient->/salesorders(
            orderByClause = `SalesOrder.id`, limitClause = `${size}`, offsetClause = `${offset}`);
        return from OrderWithItems row in rows
            select row;
    }

    resource function get many_to_many/[int orderId]() returns ItemWithProduct[]|error {
        stream<ItemWithProduct, persist:Error?> rows = persistClient->/orderitems(
            whereClause = `OrderItem.salesorderId = ${orderId}`);
        return from ItemWithProduct row in rows
            select row;
    }

    resource function get many_to_many_rev/[int id]() returns ProductWithItems|error {
        return persistClient->/products/[id];
    }

    resource function get wide_2_fields(int size, int offset) returns ProductNarrow[]|error {
        stream<ProductNarrow, persist:Error?> rows = persistClient->/products(
            orderByClause = `Product.id`, limitClause = `${size}`, offsetClause = `${offset}`);
        return from ProductNarrow row in rows
            select row;
    }

    resource function get wide_all(int size, int offset) returns Product[]|error {
        stream<Product, persist:Error?> rows = persistClient->/products(
            orderByClause = `Product.id`, limitClause = `${size}`, offsetClause = `${offset}`);
        return from Product row in rows
            select row;
    }

    resource function post create(CustomerInsert payload) returns int[]|error {
        return persistClient->/customers.post([payload]);
    }

    resource function patch patch/[int id](CustomerUpdate payload) returns Customer|error {
        return persistClient->/customers/[id].put(payload);
    }
}
