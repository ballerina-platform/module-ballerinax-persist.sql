import ballerina/persist as _;
import ballerinax/persist.sql;

public type Person record {|
    readonly int nic;
    string name;
    int age;
    string city;
    Car? car;
    Car? driver;
|};

public type Car record {|
    readonly string plateNo;
    string make;
    string model;
    int year;
    string color;
    int ownerNic;
    @sql:Relation {refs: ["ownerNic"]}
    Person owner;
    @sql:Relation {refs: ["ownerNic"]}
    Person drivenBy;
|};