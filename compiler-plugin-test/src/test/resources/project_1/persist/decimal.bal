import ballerina/persist as _;
import ballerinax/persist.sql;

public type Person record {|
    readonly int id;
    string name;
    @sql:Decimal {precision: [10,2]}
    int age;
    @sql:Decimal {precision: [0,2]}
    decimal salary;
    decimal height;
|};