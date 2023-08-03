import foo/medical_center.entities;

public type Prod record {|
    string name;
    int age;
|};

public function main() returns error? {
    entities:Client mcClient = check new ();
    string value = "1";
    entities:Employee[] output = check from entities:Employee e in mcClient->/employees(targetType = entities:Employee)
                order by e.'lastName ascending, e.empNo descending
                limit getValue(2)
                where e.'lastName == getStringValue(value) || e.empNo == "001"
                group by var 'lastName = e.'lastName, var empNo = e.empNo, var birthDate = e.birthDate, var 'firstName = e.'firstName, var gender = e.gender, var hireDate = e.hireDate
                select {'lastName, empNo, birthDate, 'firstName, gender, hireDate};

    entities:WorkspaceWithRelations[] results = check from entities:WorkspaceWithRelations e in mcClient->/workspaces(targetType = entities:WorkspaceWithRelations)
                order by e.'employee?.'firstName ascending, e.'location?.buildingCode descending
                limit getValue(5)
                where e.'employee?.'firstName == getStringValue(value) || e.workspaceId == "001" && e.'location?.buildingCode == value
                group by var workspaceId = e.workspaceId, var buildingCode = e.'location?.buildingCode
                select {workspaceId, 'location: {buildingCode}};

    entities:BuildingWithRelations[] res = check from entities:BuildingWithRelations e in mcClient->/buildings(targetType = entities:BuildingWithRelations)
                order by e.buildingCode descending
                limit getValue(5)
                let entities:WorkspaceOptionalized[]? workSpace = e.'workspaces
                where workSpace !is () && workSpace[0].workspaceEmpNo == "1"
                group by var buildingCode = e.buildingCode, var city = e.city, var workspaces = workSpace[0].workspaceEmpNo 
                select {buildingCode, city};
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
