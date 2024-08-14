// Copyright (c) 2024 WSO2 LLC. (http://www.wso2.org).
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

@test:Config {
    groups: ["native", "h2"],
    dependsOn: [h2EmployeeRelationsTest, h2WorkspaceRelationsTest, h2BuildingRelationsTest, h2DepartmentRelationsTest]
}
function h2NativeExecuteTest() returns error? {
    H2RainierClient rainierClient = check new ();
    _ = check rainierClient->executeNativeSQL(`DELETE FROM "Employee"`);
    _ = check rainierClient->executeNativeSQL(`DELETE FROM "Workspace"`);
    _ = check rainierClient->executeNativeSQL(`DELETE FROM "Building"`);
    _ = check rainierClient->executeNativeSQL(`DELETE FROM "Department"`);

    ExecutionResult executionResult = check rainierClient->executeNativeSQL(`
        INSERT INTO "Department" ("deptNo", "deptName")
        VALUES 
            (${departmentNative1.deptNo}, ${departmentNative1.deptName}),
            (${departmentNative2.deptNo}, ${departmentNative2.deptName}),
            (${departmentNative3.deptNo}, ${departmentNative3.deptName})
    `);
    test:assertEquals(executionResult, {affectedRowCount: 3, lastInsertId: "department-native-1"});

    executionResult = check rainierClient->executeNativeSQL(`
        INSERT INTO "Building" ("buildingCode", "city", "state", "country", "postalCode", "type")
        VALUES 
            (${buildingNative1.buildingCode}, ${buildingNative1.city}, ${buildingNative1.state}, ${buildingNative1.country}, ${buildingNative1.postalCode}, ${buildingNative1.'type}),
            (${buildingNative2.buildingCode}, ${buildingNative2.city}, ${buildingNative2.state}, ${buildingNative2.country}, ${buildingNative2.postalCode}, ${buildingNative2.'type}),
            (${buildingNative3.buildingCode}, ${buildingNative3.city}, ${buildingNative3.state}, ${buildingNative3.country}, ${buildingNative3.postalCode}, ${buildingNative3.'type})
    `);
    test:assertEquals(executionResult, {affectedRowCount: 3, lastInsertId: "building-native-1"});

    executionResult = check rainierClient->executeNativeSQL(`
        INSERT INTO "Workspace" ("workspaceId", "workspaceType", "locationBuildingCode")
        VALUES 
            (${workspaceNative1.workspaceId}, ${workspaceNative1.workspaceType}, ${workspaceNative1.locationBuildingCode}),
            (${workspaceNative2.workspaceId}, ${workspaceNative2.workspaceType}, ${workspaceNative2.locationBuildingCode}),
            (${workspaceNative3.workspaceId}, ${workspaceNative3.workspaceType}, ${workspaceNative3.locationBuildingCode})
    `);
    test:assertEquals(executionResult, {affectedRowCount: 3, lastInsertId: "workspace-native-1"});

    executionResult = check rainierClient->executeNativeSQL(`
        INSERT INTO "Employee" ("empNo", "firstName", "lastName", "birthDate", "gender", "hireDate", "departmentDeptNo", "workspaceWorkspaceId")
        VALUES 
            (${employeeNative1.empNo}, ${employeeNative1.firstName}, ${employeeNative1.lastName}, ${employeeNative1.birthDate}, ${employeeNative1.gender}, ${employeeNative1.hireDate}, ${employeeNative1.departmentDeptNo}, ${employeeNative1.workspaceWorkspaceId}),
            (${employeeNative2.empNo}, ${employeeNative2.firstName}, ${employeeNative2.lastName}, ${employeeNative2.birthDate}, ${employeeNative2.gender}, ${employeeNative2.hireDate}, ${employeeNative2.departmentDeptNo}, ${employeeNative2.workspaceWorkspaceId}),
            (${employeeNative3.empNo}, ${employeeNative3.firstName}, ${employeeNative3.lastName}, ${employeeNative3.birthDate}, ${employeeNative3.gender}, ${employeeNative3.hireDate}, ${employeeNative3.departmentDeptNo}, ${employeeNative3.workspaceWorkspaceId})
    `);
    test:assertEquals(executionResult, {affectedRowCount: 3, lastInsertId: "employee-native-1"});

    check rainierClient.close();
}

@test:Config {
    groups: ["native", "h2"],
    dependsOn: [h2NativeExecuteTest]
}
function h2NativeExecuteTestNegative1() returns error? {
    H2RainierClient rainierClient = check new ();
    ExecutionResult|persist:Error executionResult = rainierClient->executeNativeSQL(`
        INSERT INTO "Department" ("deptNo", "deptName")
        VALUES (${departmentNative1.deptNo}, ${departmentNative1.deptName})
    `);

    if executionResult is persist:Error {
        test:assertTrue(executionResult.message().includes("Unique index or primary key violation: \"PUBLIC.PRIMARY_KEY_A9 ON PUBLIC.Department(deptNo) VALUES ( /* 6 */ 'department-native-1'"));
    } else {
        test:assertFail("persist:Error expected.");
    }

    check rainierClient.close();
}

@test:Config {
    groups: ["native", "h2"],
    dependsOn: [h2NativeExecuteTest]
}
function h2NativeExecuteTestNegative2() returns error? {
    H2RainierClient rainierClient = check new ();
    ExecutionResult|persist:Error executionResult = rainierClient->executeNativeSQL(`
        INSERT INTO "Departments" ("deptNo", "deptName")
        VALUES (${departmentNative1.deptNo}, ${departmentNative1.deptName})
    `);

    if executionResult is persist:Error {
        test:assertTrue(executionResult.message().includes("Table \"Departments\" not found;"));
    } else {
        test:assertFail("persist:Error expected.");
    }

    check rainierClient.close();
}

@test:Config {
    groups: ["native", "h2"],
    dependsOn: [h2NativeExecuteTest]
}
function h2NativeQueryTest() returns error? {
    H2RainierClient rainierClient = check new ();
    stream<Department, persist:Error?> departmentStream = rainierClient->queryNativeSQL(`SELECT * FROM "Department"`);
    Department[] departments = check from Department department in departmentStream
        select department;
    check departmentStream.close();
    test:assertEquals(departments, [departmentNative1, departmentNative2, departmentNative3]);

    stream<Building, persist:Error?> buildingStream = rainierClient->queryNativeSQL(`SELECT * FROM "Building"`);
    Building[] buildings = check from Building building in buildingStream
        select building;
    check buildingStream.close();
    test:assertEquals(buildings, [buildingNative1, buildingNative2, buildingNative3]);

    stream<Workspace, persist:Error?> workspaceStream = rainierClient->queryNativeSQL(`SELECT * FROM "Workspace"`);
    Workspace[] workspaces = check from Workspace workspace in workspaceStream
        select workspace;
    check workspaceStream.close();
    test:assertEquals(workspaces, [workspaceNative1, workspaceNative2, workspaceNative3]);

    stream<Employee, persist:Error?> employeeStream = rainierClient->queryNativeSQL(`SELECT * FROM "Employee"`);
    Employee[] employees = check from Employee employee in employeeStream
        select employee;
    check employeeStream.close();
    test:assertEquals(employees, [employeeNative1, employeeNative2, employeeNative3]);

    check rainierClient.close();
}

@test:Config {
    groups: ["native", "h2"],
    dependsOn: [h2NativeExecuteTest]
}
function h2NativeQueryTestNegative() returns error? {
    H2RainierClient rainierClient = check new ();
    stream<Department, persist:Error?> departmentStream = rainierClient->queryNativeSQL(`SELECT * FROM "Departments"`);
    Department[]|persist:Error departments = from Department department in departmentStream
        select department;
    check departmentStream.close();

    if departments is persist:Error {
        test:assertTrue(departments.message().includes("Table \"Departments\" not found"));
    } else {
        test:assertFail("persist:Error expected.");
    }

    check rainierClient.close();
}

@test:Config {
    groups: ["native", "h2"],
    dependsOn: [h2NativeExecuteTest]
}
function h2NativeQueryComplexTest() returns error? {
    H2RainierClient rainierClient = check new ();
    stream<EmployeeInfo, persist:Error?> employeeInfoStream = rainierClient->queryNativeSQL(`
        SELECT 
            "firstName",
            "lastName",
            department."deptName" AS "department.deptName",
            workspace."workspaceId" AS "workspace.workspaceId",
            workspace."workspaceType" AS "workspace.workspaceType",
            workspace."locationBuildingCode" AS "workspace.locationBuildingCode"
        FROM "Employee"
        INNER JOIN 
            "Department" department ON "Employee"."departmentDeptNo" = department."deptNo"
        INNER JOIN
            "Workspace" workspace ON "Employee"."workspaceWorkspaceId" = workspace."workspaceId"
    `);
    EmployeeInfo[] employees = check from EmployeeInfo employee in employeeInfoStream
        select employee;
    check employeeInfoStream.close();
    test:assertEquals(employees, [employeeInfoNative1, employeeInfoNative2, employeeInfoNative3]);

    check rainierClient.close();
}

@test:Config {
    groups: ["transactions", "h2", "native"],
    dependsOn: [h2NativeExecuteTestNegative1, h2NativeQueryTest, h2NativeQueryTestNegative, h2NativeQueryComplexTest],
    enable: true
}
function h2NativeTransactionTest() returns error? {
    H2RainierClient rainierClient = check new ();
    _ = check rainierClient->executeNativeSQL(`DELETE FROM "Employee"`);
    _ = check rainierClient->executeNativeSQL(`DELETE FROM "Workspace"`);
    _ = check rainierClient->executeNativeSQL(`DELETE FROM "Building"`);
    _ = check rainierClient->executeNativeSQL(`DELETE FROM "Department"`);

    transaction {
        ExecutionResult executionResult = check rainierClient->executeNativeSQL(`
        INSERT INTO "Building" ("buildingCode", "city", "state", "country", "postalCode", "type")
        VALUES 
            (${building31.buildingCode}, ${building31.city}, ${building31.state}, ${building31.country}, ${building31.postalCode}, ${building31.'type}),
            (${building32.buildingCode}, ${building32.city}, ${building32.state}, ${building32.country}, ${building32.postalCode}, ${building32.'type})
        `);
        test:assertEquals(executionResult, {affectedRowCount: 2, lastInsertId: "building-31"});

        stream<Building, persist:Error?> buildingStream = rainierClient->queryNativeSQL(`SELECT * FROM "Building"`);
        Building[] buildings = check from Building building in buildingStream
            select building;
        check buildingStream.close();
        test:assertEquals(buildings, [building31, building32]);

        executionResult = check rainierClient->executeNativeSQL(`
        INSERT INTO "Building" ("buildingCode", "city", "state", "country", "postalCode", "type")
        VALUES 
            (${building31.buildingCode}, ${building31.city}, ${building31.state}, ${building31.country}, ${building31.postalCode}, ${building31.'type})
        `);
        check commit;
    } on fail error e {
        test:assertTrue(e is persist:Error, "persist:Error expected");
    }

    stream<Building, persist:Error?> buildingStream = rainierClient->queryNativeSQL(`SELECT * FROM "Building"`);
    Building[] buildings = check from Building building in buildingStream
        select building;
    check buildingStream.close();
    test:assertEquals(buildings, []);

    check rainierClient.close();
}

@test:Config {
    groups: ["transactions", "h2", "native"],
    dependsOn: [h2NativeExecuteTestNegative1, h2NativeQueryTest, h2NativeQueryTestNegative, h2NativeQueryComplexTest]
}
function h2NativeTransactionTest2() returns error? {
    H2RainierClient rainierClient = check new ();

    ExecutionResult executionResult = check rainierClient->executeNativeSQL(`
        INSERT INTO "Building" ("buildingCode", "city", "state", "country", "postalCode", "type")
        VALUES 
            (${building33.buildingCode}, ${building33.city}, ${building33.state}, ${building33.country}, ${building33.postalCode}, ${building33.'type})
        `);
    test:assertEquals(executionResult, {affectedRowCount: 1, lastInsertId: "building-33"});

    stream<Building, persist:Error?> buildingStream = rainierClient->queryNativeSQL(`SELECT * FROM "Building" WHERE "buildingCode" = ${building33.buildingCode}`);
    Building[] buildings = check from Building building in buildingStream
        select building;
    check buildingStream.close();
    test:assertEquals(buildings, [building33]);

    _ = check rainierClient->executeNativeSQL(`
        UPDATE "Building"
        SET
            "city" = ${building33Updated.city},
            "state" = ${building33Updated.state},
            "country" = ${building33Updated.country}
        WHERE "buildingCode" = ${building33.buildingCode}
    `);

    stream<Building, persist:Error?> buildingStream3 = rainierClient->queryNativeSQL(`SELECT * FROM "Building" WHERE "buildingCode" = ${building33.buildingCode}`);
    Building[] buildings3 = check from Building building in buildingStream3
        select building;
    check buildingStream3.close();
    test:assertEquals(buildings3, [building33Updated]);

    check rainierClient.close();
}

@test:Config {
    groups: ["h2", "native"],
    dependsOn: [h2AllTypesDeleteTest]
}
function h2NativeAllTypesTest() returns error? {
    H2RainierClient rainierClient = check new ();
    _ = check rainierClient->executeNativeSQL(`DELETE FROM "AllTypes"`);

    ExecutionResult executionResult = check rainierClient->executeNativeSQL(`
        INSERT INTO "AllTypes" (
            "id", "booleanType", "intType", "floatType", "decimalType", "stringType", "byteArrayType", "dateType", "timeOfDayType", "civilType", "booleanTypeOptional", "intTypeOptional", 
            "floatTypeOptional", "decimalTypeOptional", "stringTypeOptional", "dateTypeOptional", "timeOfDayTypeOptional", "civilTypeOptional", "enumType", "enumTypeOptional"
        ) VALUES (
            ${allTypes1.id}, ${allTypes1.booleanType}, ${allTypes1.intType}, ${allTypes1.floatType}, ${allTypes1.decimalType}, ${allTypes1.stringType}, ${allTypes1.byteArrayType}, 
            ${allTypes1.dateType}, ${allTypes1.timeOfDayType}, ${allTypes1.civilType}, ${allTypes1.booleanTypeOptional}, ${allTypes1.intTypeOptional}, ${allTypes1.floatTypeOptional}, 
            ${allTypes1.decimalTypeOptional}, ${allTypes1.stringTypeOptional}, ${allTypes1.dateTypeOptional}, ${allTypes1.timeOfDayTypeOptional}, ${allTypes1.civilTypeOptional}, ${allTypes1.enumType}, ${allTypes1.enumTypeOptional}
        )
        `);
    test:assertEquals(executionResult, {affectedRowCount: 1, lastInsertId: 1});

    stream<AllTypes, persist:Error?> allTypesStream = rainierClient->queryNativeSQL(`SELECT * FROM "AllTypes" WHERE "id" = ${allTypes1.id}`);
    AllTypes[] allTypes = check from AllTypes allType in allTypesStream
        select allType;
    check allTypesStream.close();
    test:assertEquals(allTypes, [allTypes1]);
    check rainierClient.close();
}
