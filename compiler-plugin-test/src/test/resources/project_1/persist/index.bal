import ballerina/persist as _;
import ballerinax/persist.sql;

public type Person record {|
    readonly int id;
    string name;
    @sql:Index {names: ["address"]}
    Address address;
    @sql:Index {names: ["favs"]}
    string favColor;
    @sql:Index {names: ["favs"]}
    string favCar;
    @sql:Index {names: ["email", "email"]}
    string email;
    @sql:Index {names: ["gender_idx", " "]}
    string gender;
    @sql:Index {names: [""]}
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