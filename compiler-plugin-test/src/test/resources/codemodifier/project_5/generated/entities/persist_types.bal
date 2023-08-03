// AUTO-GENERATED FILE. DO NOT MODIFY.

// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.

public type Employee record {|
    readonly string empNo;
    string firstName;
    string lastName;
    Workspace? workspace;
|};

public type EmployeeOptionalized record {|
    string empNo?;
    string firstName?;
    string lastName?;
    Workspace? workspace?;
|};

public type EmployeeTargetType typedesc<EmployeeOptionalized>;

public type EmployeeInsert Employee;

public type EmployeeUpdate record {|
    string firstName?;
    string lastName?;
    Workspace? workspace?;
|};

public type Workspace record {|
    readonly string workspaceId;
    string workspaceType;
    string locationBuildingCode;
    'Employee employee;
|};

public type WorkspaceOptionalized record {|
    string workspaceId?;
    string workspaceType?;
    string locationBuildingCode?;
    'Employee employee?;
|};

public type WorkspaceWithRelations record {|
    *WorkspaceOptionalized;
    BuildingOptionalized location?;
|};

public type WorkspaceTargetType typedesc<WorkspaceWithRelations>;

public type WorkspaceInsert Workspace;

public type WorkspaceUpdate record {|
    string workspaceType?;
    string locationBuildingCode?;
    'Employee employee?;
|};

public type Building record {|
    readonly string buildingCode;
    string city;
|};

public type BuildingOptionalized record {|
    string buildingCode?;
    string city?;
|};

public type BuildingWithRelations record {|
    *BuildingOptionalized;
    WorkspaceOptionalized[] workspaces?;
|};

public type BuildingTargetType typedesc<BuildingWithRelations>;

public type BuildingInsert Building;

public type BuildingUpdate record {|
    string city?;
|};

