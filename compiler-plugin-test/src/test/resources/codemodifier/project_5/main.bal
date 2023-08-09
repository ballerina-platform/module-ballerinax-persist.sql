import foo/medical_center.entities;

public type Prod record {|
    string name;
    int age;
|};

public function main() returns error? {
    entities:Client mcClient = check new ();
    string value = "1";
    string name = "e.location.buildingCode";
    entities:WorkspaceWithRelations[] results = check from entities:WorkspaceWithRelations e in mcClient->/workspaces(targetType = entities:WorkspaceWithRelations)
                order by e.employee?.empNo ascending, e.location?.buildingCode descending
                limit getValue(5)
                where e.employee?.firstName == getStringValue(value) || e.workspaceId == "001" && e.location?.buildingCode == value
                select e;
    entities:WorkspaceWithRelations1[] result = check from entities:WorkspaceWithRelations1 e in mcClient->/workspaces(targetType = entities:WorkspaceWithRelations1)
                    order by e.employee?.empNo ascending, name descending
                    limit getValue(5)
                    where e.employee?.firstName == getStringValue(value) || e.workspaceId == "001" && e.location.buildingCode == value
                    group by var firstName = e.employee?.firstName,  var workspaceId = e.workspaceId, var buildingCode = name
                    select {workspaceId: workspaceId, location: {buildingCode: buildingCode}};
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
