// Copyright (c) 2023 WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/test;
import ballerina/persist;

@test:BeforeGroups {value: ["native-mssql"]}
function mssqlTruncateTables() returns error? {
    MSSQLRainierClient rainierClient = check new ();
    _ = check rainierClient->executeNativeSQL(`DELETE FROM Employee`);
    _ = check rainierClient->executeNativeSQL(`DELETE FROM Workspace`);
    _ = check rainierClient->executeNativeSQL(`DELETE FROM Building`);
    _ = check rainierClient->executeNativeSQL(`DELETE FROM Department`);
    check rainierClient.close();
}

@test:Config {
    groups: ["native-mssql", "execute"],
    dependsOn: [mssqlEmployeeRelationsTest, mssqlWorkspaceRelationsTest, mssqlBuildingRelationsTest, mssqlDepartmentRelationsTest]
}
function mssqlNativeExecuteTest() returns error? {
    MSSQLRainierClient rainierClient = check new ();
    ExecutionResult executionResult = check rainierClient->executeNativeSQL(`
        INSERT INTO Department (deptNo, deptName)
        VALUES 
            (${departmentNative1.deptNo}, ${departmentNative1.deptName}),
            (${departmentNative2.deptNo}, ${departmentNative2.deptName}),
            (${departmentNative3.deptNo}, ${departmentNative3.deptName})
    `);
    test:assertEquals(executionResult, {affectedRowCount: 3, lastInsertId: ()});

    executionResult = check rainierClient->executeNativeSQL(`
        INSERT INTO Building (buildingCode, city, state, country, postalCode, type)
        VALUES 
            (${buildingNative1.buildingCode}, ${buildingNative1.city}, ${buildingNative1.state}, ${buildingNative1.country}, ${buildingNative1.postalCode}, ${buildingNative1.'type}),
            (${buildingNative2.buildingCode}, ${buildingNative2.city}, ${buildingNative2.state}, ${buildingNative2.country}, ${buildingNative2.postalCode}, ${buildingNative2.'type}),
            (${buildingNative3.buildingCode}, ${buildingNative3.city}, ${buildingNative3.state}, ${buildingNative3.country}, ${buildingNative3.postalCode}, ${buildingNative3.'type})
    `);
    test:assertEquals(executionResult, {affectedRowCount: 3, lastInsertId: ()});

    executionResult = check rainierClient->executeNativeSQL(`
        INSERT INTO Workspace (workspaceId, workspaceType, locationBuildingCode)
        VALUES 
            (${workspaceNative1.workspaceId}, ${workspaceNative1.workspaceType}, ${workspaceNative1.locationBuildingCode}),
            (${workspaceNative2.workspaceId}, ${workspaceNative2.workspaceType}, ${workspaceNative2.locationBuildingCode}),
            (${workspaceNative3.workspaceId}, ${workspaceNative3.workspaceType}, ${workspaceNative3.locationBuildingCode})
    `);
    test:assertEquals(executionResult, {affectedRowCount: 3, lastInsertId: ()});

    executionResult = check rainierClient->executeNativeSQL(`
        INSERT INTO Employee (empNo, firstName, lastName, birthDate, gender, hireDate, departmentDeptNo, workspaceWorkspaceId)
        VALUES 
            (${employeeNative1.empNo}, ${employeeNative1.firstName}, ${employeeNative1.lastName}, ${employeeNative1.birthDate}, ${employeeNative1.gender}, ${employeeNative1.hireDate}, ${employeeNative1.departmentDeptNo}, ${employeeNative1.workspaceWorkspaceId}),
            (${employeeNative2.empNo}, ${employeeNative2.firstName}, ${employeeNative2.lastName}, ${employeeNative2.birthDate}, ${employeeNative2.gender}, ${employeeNative2.hireDate}, ${employeeNative2.departmentDeptNo}, ${employeeNative2.workspaceWorkspaceId}),
            (${employeeNative3.empNo}, ${employeeNative3.firstName}, ${employeeNative3.lastName}, ${employeeNative3.birthDate}, ${employeeNative3.gender}, ${employeeNative3.hireDate}, ${employeeNative3.departmentDeptNo}, ${employeeNative3.workspaceWorkspaceId})
    `);
    test:assertEquals(executionResult, {affectedRowCount: 3, lastInsertId: ()});

    check rainierClient.close();
}

@test:Config {
    groups: ["native-mssql", "execute"],
    dependsOn: [mssqlNativeExecuteTest]
}
function mssqlNativeExecuteTestNegative1() returns error? {
    MSSQLRainierClient rainierClient = check new ();
    ExecutionResult|persist:Error executionResult = rainierClient->executeNativeSQL(`
        INSERT INTO Department (deptNo, deptName)
        VALUES 
            (${departmentNative1.deptNo}, ${departmentNative1.deptName})
    `);

    if executionResult is persist:Error {
        test:assertTrue(executionResult.message().includes("Cannot insert duplicate key"));
    } else {
        test:assertFail("persist:Error expected.");
    }
}

@test:Config {
    groups: ["native-mssql", "execute"],
    dependsOn: [mssqlNativeExecuteTest]
}
function mssqlNativeExecuteTestNegative2() returns error? {
    MSSQLRainierClient rainierClient = check new ();
    ExecutionResult|persist:Error executionResult = rainierClient->executeNativeSQL(`
        INSERT INTO Departments (deptNo, deptName)
        VALUES 
            (${departmentNative1.deptNo}, ${departmentNative1.deptName})
    `);

    if executionResult is persist:Error {
        test:assertTrue(executionResult.message().includes("Invalid object name 'Departments'"));
    } else {
        test:assertFail("persist:Error expected.");
    }
}

@test:Config {
    groups: ["native", "query", "mssql"],
    dependsOn: [mssqlNativeExecuteTest]
}
function mssqlNativeQueryTest() returns error? {
    MSSQLRainierClient rainierClient = check new ();
    stream<Department, persist:Error?> departmentStream = rainierClient->queryNativeSQL(`SELECT * FROM Department`);
    Department[] departments = check from Department department in departmentStream
        select department;

    test:assertEquals(departments, [departmentNative1, departmentNative2, departmentNative3]);

    stream<Building, persist:Error?> buildingStream = rainierClient->queryNativeSQL(`SELECT * FROM Building`);
    Building[] buildings = check from Building building in buildingStream
        select building;
    test:assertEquals(buildings, [buildingNative1, buildingNative2, buildingNative3]);

    stream<Workspace, persist:Error?> workspaceStream = rainierClient->queryNativeSQL(`SELECT * FROM Workspace`);
    Workspace[] workspaces = check from Workspace workspace in workspaceStream
        select workspace;
    test:assertEquals(workspaces, [workspaceNative1, workspaceNative2, workspaceNative3]);

    stream<Employee, persist:Error?> employeeStream = rainierClient->queryNativeSQL(`SELECT * FROM Employee`);
    Employee[] employees = check from Employee employee in employeeStream
        select employee;
    test:assertEquals(employees, [employeeNative1, employeeNative2, employeeNative3]);

    check rainierClient.close();
}

@test:Config {
    groups: ["native", "query", "mssql"],
    dependsOn: [mssqlNativeExecuteTest]
}
function mssqlNativeQueryTestNegative() returns error? {
    MSSQLRainierClient rainierClient = check new ();
    stream<Department, persist:Error?> departmentStream = rainierClient->queryNativeSQL(`SELECT * FROM Departments`);
    Department[]|persist:Error departments = from Department department in departmentStream
        select department;

    if departments is persist:Error {
        test:assertTrue(departments.message().includes("Invalid object name 'Departments'"));
    } else {
        test:assertFail("persist:Error expected.");
    }
}

@test:Config {
    groups: ["native", "query", "mssql"],
    dependsOn: [mssqlNativeExecuteTest]
}
function mssqlNativeQueryComplexTest() returns error? {
    MSSQLRainierClient rainierClient = check new ();
    stream<EmployeeInfo, persist:Error?> employeeInfoStream = rainierClient->queryNativeSQL(`
        SELECT 
            firstName,
            lastName,
            department.deptName AS 'department.deptName',
            workspace.workspaceId AS 'workspace.workspaceId',
            workspace.workspaceType AS 'workspace.workspaceType',
            workspace.locationBuildingCode AS 'workspace.locationBuildingCode'
        FROM Employee
        INNER JOIN 
            Department department ON Employee.departmentDeptNo = Department.deptNo
        INNER JOIN
            Workspace workspace ON Employee.workspaceWorkspaceId = Workspace.workspaceId
    `);
    EmployeeInfo[] employees = check from EmployeeInfo employee in employeeInfoStream
        select employee;
    test:assertEquals(employees, [employeeInfoNative1, employeeInfoNative2, employeeInfoNative3]);

    check rainierClient.close();
}