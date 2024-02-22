import ballerina/persist as _;
import ballerinax/persist.sql;

public type Person record {|
    readonly int id;
    string name;
    @sql:UniqueIndex {names: ["address"]}
    Address address;
    @sql:UniqueIndex {names: ["favs"]}
    string favColor;
    @sql:UniqueIndex {names: ["favs"]}
    string favCar;
    @sql:UniqueIndex {names: ["email", "email"]}
    string email;
    @sql:UniqueIndex {names: ["gender_idx", " "]}
    string gender;
    @sql:UniqueIndex {names: [""]}
    string nic;
    int numOfChildren;

|};

public type Address record {|
    readonly int id;
    string street;
    string city;
    string country;
    Person? user;
|};