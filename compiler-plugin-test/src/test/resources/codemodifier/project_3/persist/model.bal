import ballerina/persist as _;

public type Manufacture record {|
    readonly string id;
    Product products;
    
|};

public type Product record {|
    readonly int id;
    string name;
    int age;
	Manufacture? manufacture;
|};


