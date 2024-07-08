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
    groups: ["department", "h2"]
}
function h2DepartmentCreateTest() returns error? {
    H2RainierClient rainierClient = check new ();

    string[] deptNos = check rainierClient->/departments.post([department1]);
    test:assertEquals(deptNos, [department1.deptNo]);

    Department departmentRetrieved = check rainierClient->/departments/[department1.deptNo].get();
    test:assertEquals(departmentRetrieved, department1);
    check rainierClient.close();
}

@test:Config {
    groups: ["department", "h2"]
}
function h2DepartmentCreateTest2() returns error? {
    H2RainierClient rainierClient = check new ();

    string[] deptNos = check rainierClient->/departments.post([department2, department3]);

    test:assertEquals(deptNos, [department2.deptNo, department3.deptNo]);

    Department departmentRetrieved = check rainierClient->/departments/[department2.deptNo].get();
    test:assertEquals(departmentRetrieved, department2);

    departmentRetrieved = check rainierClient->/departments/[department3.deptNo].get();
    test:assertEquals(departmentRetrieved, department3);
    check rainierClient.close();
}

@test:Config {
    groups: ["department", "h2"]
}
function h2DepartmentCreateTestNegative() returns error? {
    H2RainierClient rainierClient = check new ();

    string[]|error department = rainierClient->/departments.post([invalidDepartment]);
    if department is persist:Error {
        test:assertTrue(department.message().includes(".Value too long for column \"deptNo CHARACTER VARYING(36)"));
    } else {
        test:assertFail("Error expected.");
    }
    check rainierClient.close();
}

@test:Config {
    groups: ["department", "h2"],
    dependsOn: [h2DepartmentCreateTest]
}
function h2DepartmentReadOneTest() returns error? {
    H2RainierClient rainierClient = check new ();

    Department departmentRetrieved = check rainierClient->/departments/[department1.deptNo].get();
    test:assertEquals(departmentRetrieved, department1);
    check rainierClient.close();
}

@test:Config {
    groups: ["department", "h2"],
    dependsOn: [h2DepartmentCreateTest]
}
function h2DepartmentReadOneTestNegative() returns error? {
    H2RainierClient rainierClient = check new ();

    Department|error departmentRetrieved = rainierClient->/departments/["invalid-department-id"].get();
    if departmentRetrieved is persist:NotFoundError {
        test:assertEquals(departmentRetrieved.message(), "A record with the key 'invalid-department-id' does not exist for the entity 'Department'.");
    } else {
        test:assertFail("NotFoundError expected.");
    }
    check rainierClient.close();
}

@test:Config {
    groups: ["department", "h2"],
    dependsOn: [h2DepartmentCreateTest, h2DepartmentCreateTest2]
}
function h2DepartmentReadManyTest() returns error? {
    H2RainierClient rainierClient = check new ();
    stream<Department, error?> departmentStream = rainierClient->/departments.get();
    Department[] departments = check from Department department in departmentStream
        select department;

    test:assertEquals(departments, [department1, department2, department3]);
    check rainierClient.close();
}

@test:Config {
    groups: ["department", "h2", "dependent"],
    dependsOn: [h2DepartmentCreateTest, h2DepartmentCreateTest2]
}
function h2DepartmentReadManyTestDependent() returns error? {
    H2RainierClient rainierClient = check new ();

    stream<DepartmentInfo2, persist:Error?> departmentStream = rainierClient->/departments.get();
    DepartmentInfo2[] departments = check from DepartmentInfo2 department in departmentStream
        select department;

    test:assertEquals(departments, [
        {deptName: department1.deptName},
        {deptName: department2.deptName},
        {deptName: department3.deptName}
    ]);
    check rainierClient.close();
}

@test:Config {
    groups: ["department", "h2"],
    dependsOn: [h2DepartmentReadOneTest, h2DepartmentReadManyTest, h2DepartmentReadManyTestDependent]
}
function h2DepartmentUpdateTest() returns error? {
    H2RainierClient rainierClient = check new ();

    Department department = check rainierClient->/departments/[department1.deptNo].put({
        deptName: "Finance & Legalities"
    });

    test:assertEquals(department, updatedDepartment1);

    Department departmentRetrieved = check rainierClient->/departments/[department1.deptNo].get();
    test:assertEquals(departmentRetrieved, updatedDepartment1);
    check rainierClient.close();
}

@test:Config {
    groups: ["department", "h2"],
    dependsOn: [h2DepartmentReadOneTest, h2DepartmentReadManyTest, h2DepartmentReadManyTestDependent]
}
function h2DepartmentUpdateTestNegative1() returns error? {
    H2RainierClient rainierClient = check new ();

    Department|error department = rainierClient->/departments/["invalid-department-id"].put({
        deptName: "Human Resources"
    });

    if department is persist:NotFoundError {
        test:assertEquals(department.message(), "A record with the key 'invalid-department-id' does not exist for the entity 'Department'.");
    } else {
        test:assertFail("NotFoundError expected.");
    }
    check rainierClient.close();
}

@test:Config {
    groups: ["department", "h2"],
    dependsOn: [h2DepartmentReadOneTest, h2DepartmentReadManyTest, h2DepartmentReadManyTestDependent]
}
function h2DepartmentUpdateTestNegative2() returns error? {
    H2RainierClient rainierClient = check new ();

    Department|error department = rainierClient->/departments/[department1.deptNo].put({
        deptName: "unncessarily-long-department-name-to-force-error-on-update"
    });

    if department is persist:Error {
        test:assertTrue(department.message().includes("Value too long for column \"deptName CHARACTER VARYING(30)"));
    } else {
        test:assertFail("NotFoundError expected.");
    }
    check rainierClient.close();
}

@test:Config {
    groups: ["department", "h2"],
    dependsOn: [h2DepartmentUpdateTest, h2DepartmentUpdateTestNegative2]
}
function h2DepartmentDeleteTest() returns error? {
    H2RainierClient rainierClient = check new ();

    Department department = check rainierClient->/departments/[department1.deptNo].delete();
    test:assertEquals(department, updatedDepartment1);

    stream<Department, error?> departmentStream = rainierClient->/departments.get();
    Department[] departments = check from Department department2 in departmentStream
        select department2;

    test:assertEquals(departments, [department2, department3]);
    check rainierClient.close();
}

@test:Config {
    groups: ["department", "h2"],
    dependsOn: [h2DepartmentDeleteTest]
}
function h2DepartmentDeleteTestNegative() returns error? {
    H2RainierClient rainierClient = check new ();

    Department|error department = rainierClient->/departments/[department1.deptNo].delete();

    if department is persist:NotFoundError {
        test:assertEquals(department.message(), string `A record with the key '${department1.deptNo}' does not exist for the entity 'Department'.`);
    } else {
        test:assertFail("NotFoundError expected.");
    }
    check rainierClient.close();
}
