// AUTO-GENERATED FILE. DO NOT MODIFY.

// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.

import ballerina/time;

# Represents the `Customer` entity.
public type Customer record {|
    readonly int id;
    string name;
    string email;
    string country;
    int tier;

|};

# Represents `Customer` with every field optional, for projected reads.
public type CustomerOptionalized record {|
    int id?;
    string name?;
    string email?;
    string country?;
    int tier?;
|};

# Represents `Customer` with its related entities, for projected reads.
public type CustomerWithRelations record {|
    *CustomerOptionalized;
    SalesOrderOptionalized[] orders?;
|};

# The `Customer` type or a projection of it, for reads.
public type CustomerTargetType typedesc<CustomerWithRelations>;

# The fields to insert a new `Customer`.
public type CustomerInsert Customer;

# The fields to update on an existing `Customer`.
public type CustomerUpdate record {|
    string name?;
    string email?;
    string country?;
    int tier?;
|};

# Represents the `SalesOrder` entity.
public type SalesOrder record {|
    readonly int id;
    string status;
    decimal total;
    time:Date placedOn;
    int customerId;

|};

# Represents `SalesOrder` with every field optional, for projected reads.
public type SalesOrderOptionalized record {|
    int id?;
    string status?;
    decimal total?;
    time:Date placedOn?;
    int customerId?;
|};

# Represents `SalesOrder` with its related entities, for projected reads.
public type SalesOrderWithRelations record {|
    *SalesOrderOptionalized;
    CustomerOptionalized customer?;
    OrderItemOptionalized[] items?;
|};

# The `SalesOrder` type or a projection of it, for reads.
public type SalesOrderTargetType typedesc<SalesOrderWithRelations>;

# The fields to insert a new `SalesOrder`.
public type SalesOrderInsert SalesOrder;

# The fields to update on an existing `SalesOrder`.
public type SalesOrderUpdate record {|
    string status?;
    decimal total?;
    time:Date placedOn?;
    int customerId?;
|};

# Represents the `OrderItem` entity.
public type OrderItem record {|
    readonly int id;
    string sku;
    int quantity;
    decimal price;
    int salesorderId;
    int productId;
|};

# Represents `OrderItem` with every field optional, for projected reads.
public type OrderItemOptionalized record {|
    int id?;
    string sku?;
    int quantity?;
    decimal price?;
    int salesorderId?;
    int productId?;
|};

# Represents `OrderItem` with its related entities, for projected reads.
public type OrderItemWithRelations record {|
    *OrderItemOptionalized;
    SalesOrderOptionalized salesOrder?;
    ProductOptionalized product?;
|};

# The `OrderItem` type or a projection of it, for reads.
public type OrderItemTargetType typedesc<OrderItemWithRelations>;

# The fields to insert a new `OrderItem`.
public type OrderItemInsert OrderItem;

# The fields to update on an existing `OrderItem`.
public type OrderItemUpdate record {|
    string sku?;
    int quantity?;
    decimal price?;
    int salesorderId?;
    int productId?;
|};

# Represents the `Product` entity.
public type Product record {|
    readonly int id;
    string name;
    string description;
    string attr01;
    string attr02;
    string attr03;
    string attr04;
    string attr05;
    string attr06;
    string attr07;
    string attr08;
    string attr09;
    string attr10;
    string attr11;
    string attr12;
    string attr13;
    string attr14;
    int num01;
    int num02;
    int num03;
    int num04;
    int num05;
    int num06;
    int num07;
    decimal dec01;
    decimal dec02;
    decimal dec03;
    decimal dec04;
    decimal dec05;
    decimal dec06;

|};

# Represents `Product` with every field optional, for projected reads.
public type ProductOptionalized record {|
    int id?;
    string name?;
    string description?;
    string attr01?;
    string attr02?;
    string attr03?;
    string attr04?;
    string attr05?;
    string attr06?;
    string attr07?;
    string attr08?;
    string attr09?;
    string attr10?;
    string attr11?;
    string attr12?;
    string attr13?;
    string attr14?;
    int num01?;
    int num02?;
    int num03?;
    int num04?;
    int num05?;
    int num06?;
    int num07?;
    decimal dec01?;
    decimal dec02?;
    decimal dec03?;
    decimal dec04?;
    decimal dec05?;
    decimal dec06?;
|};

# Represents `Product` with its related entities, for projected reads.
public type ProductWithRelations record {|
    *ProductOptionalized;
    OrderItemOptionalized[] orderItems?;
|};

# The `Product` type or a projection of it, for reads.
public type ProductTargetType typedesc<ProductWithRelations>;

# The fields to insert a new `Product`.
public type ProductInsert Product;

# The fields to update on an existing `Product`.
public type ProductUpdate record {|
    string name?;
    string description?;
    string attr01?;
    string attr02?;
    string attr03?;
    string attr04?;
    string attr05?;
    string attr06?;
    string attr07?;
    string attr08?;
    string attr09?;
    string attr10?;
    string attr11?;
    string attr12?;
    string attr13?;
    string attr14?;
    int num01?;
    int num02?;
    int num03?;
    int num04?;
    int num05?;
    int num06?;
    int num07?;
    decimal dec01?;
    decimal dec02?;
    decimal dec03?;
    decimal dec04?;
    decimal dec05?;
    decimal dec06?;
|};

