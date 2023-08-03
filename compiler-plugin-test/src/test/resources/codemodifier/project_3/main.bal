import foo/medical_center.entities;

public type Prod record {|
    string name;
    int age;
|};

public function main() returns error? {
    entities:Client mcClient = check new ();
    string value = "1";
    int val = 2;
    entities:ManufactureWithRelations[] output = check from entities:ManufactureWithRelations e in mcClient->/manufactures(targetType = entities:ManufactureWithRelations)
               order by getStringValue("name") ascending, e.products?.id descending
               limit getValue(2)
               where e.id == value || e.id == "6" || e.id == "7" || e.products?.id == 1
               select e;
   entities:ProductWithRelations[] out =  check from entities:ProductWithRelations e in mcClient->/products(targetType = entities:ProductWithRelations)
               order by getStringValue("name") ascending
               limit getValue(2)
               where e.id == val || e.id == 6 || e.id == 7 || e.id != 1  && e.id >= 1 && e.id <= 20 && e.name == getStringValue("abc") || e.manufacture[0].id == "1"
               select e;
}

function getValue(int value) returns int {
    return value;
}

function getStringValue(string value) returns string {
    return value;
}

function getGroupValue(anydata value) returns anydata {
    return value; 
}
