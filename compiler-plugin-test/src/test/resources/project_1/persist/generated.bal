import ballerina/persist as _;
import ballerinax/persist.sql;

public type User record {|
    readonly int nic;
    @sql:Generated
    int age;
    string city;
|};

public type User1 record {|
    @sql:Generated
    readonly int id;
    readonly string email;
    string name;
    int age;
    string city;
|};

public type User2 record {|
    @sql:Generated
    readonly string nic;
    string name;
    int age;
    string city;
|};

public type User3 record {|
    @sql:Generated
    readonly int nic;
    string name;
    int age;
    string city;
|};