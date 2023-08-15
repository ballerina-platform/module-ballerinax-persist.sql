import ballerina/persist as _;

type Employee record {|
    readonly string empNo;
    string firstName;
    string lastName;

    Workspace? workspace;
|};

type Workspace record {|
    readonly string workspaceId;
    string workspaceType;

    Building location;
    'Employee employee;
|};

type Building record {|
    readonly string buildingCode;
    string city;

    Workspace[] workspaces;
|};

