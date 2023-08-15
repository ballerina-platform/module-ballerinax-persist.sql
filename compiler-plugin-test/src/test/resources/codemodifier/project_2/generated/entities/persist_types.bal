// AUTO-GENERATED FILE. DO NOT MODIFY.

// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.

public type Manufacture record {|
    readonly string id;
    int productsId;
|};

public type ManufactureOptionalized record {|
    string id?;
    int productsId?;
|};

public type ManufactureWithRelations record {|
    *ManufactureOptionalized;
    ProductOptionalized products?;
|};

public type ManufactureTargetType typedesc<ManufactureWithRelations>;

public type ManufactureInsert Manufacture;

public type ManufactureUpdate record {|
    int productsId?;
|};

public type Product record {|
    readonly int id;
    string name;
    int age;
|};

public type ProductOptionalized record {|
    int id?;
    string name?;
    int age?;
|};

public type ProductWithRelations record {|
    *ProductOptionalized;
    ManufactureOptionalized[] manufacture?;
|};

public type ProductTargetType typedesc<ProductWithRelations>;

public type ProductInsert Product;

public type ProductUpdate record {|
    string name?;
    int age?;
|};

public type ProductWithRelations1 record {|
    *ProductOptionalized;
    ManufactureOptionalized[] manufacture;
|};
