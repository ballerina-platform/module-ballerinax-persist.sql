import ballerina/persist as _;
import ballerinax/persist.sql;

public type Person record {|
    readonly int nic;
    string name;
    int age;
    string city;
    string carPlateNo;
    @sql:Relation {refs: ["carPlateNo"]}
    Car? car;
|};

public type Car record {|
    readonly string plateNo;
    string make;
    string model;
    int year;
    string color;
    Person owner;
|};