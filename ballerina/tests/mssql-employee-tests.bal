// // Copyright (c) 2023 WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
// //
// // WSO2 LLC. licenses this file to you under the Apache License,
// // Version 2.0 (the "License"); you may not use this file except
// // in compliance with the License.
// // You may obtain a copy of the License at
// //
// // http://www.apache.org/licenses/LICENSE-2.0
// //
// // Unless required by applicable law or agreed to in writing,
// // software distributed under the License is distributed on an
// // "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// // KIND, either express or implied.  See the License for the
// // specific language governing permissions and limitations
// // under the License.

// import ballerina/test;
// import ballerina/persist;

// @test:Config {
//     groups: ["employee", "mssql"],
//     dependsOn: [mssqlWorkspaceDeleteTestNegative, mssqlDepartmentDeleteTestNegative]
// }
// function mssqlEmployeeCreateTest() returns error? {
//     MSSQLRainierClient rainierClient = check new ();

//     string[] empNos = check rainierClient->/employees.post([employee1]);
//     test:assertEquals(empNos, [employee1.empNo]);

//     Employee employeeRetrieved = check rainierClient->/employees/[employee1.empNo].get();
//     test:assertEquals(employeeRetrieved, employee1);
//     check rainierClient.close();
// }

// @test:Config {
//     groups: ["employee", "mssql"],
//     dependsOn: [mssqlWorkspaceDeleteTestNegative, mssqlDepartmentDeleteTestNegative]
// }
// function mssqlEmployeeCreateTest2() returns error? {
//     MSSQLRainierClient rainierClient = check new ();

//     string[] empNos = check rainierClient->/employees.post([employee2, employee3]);

//     test:assertEquals(empNos, [employee2.empNo, employee3.empNo]);

//     Employee employeeRetrieved = check rainierClient->/employees/[employee2.empNo].get();
//     test:assertEquals(employeeRetrieved, employee2);

//     employeeRetrieved = check rainierClient->/employees/[employee3.empNo].get();
//     test:assertEquals(employeeRetrieved, employee3);
//     check rainierClient.close();
// }

// @test:Config {
//     groups: ["employee", "mssql"]
// }
// function mssqlEmployeeCreateTestNegative() returns error? {
//     MSSQLRainierClient rainierClient = check new ();

//     string[]|error employee = rainierClient->/employees.post([invalidEmployee]);
//     if employee is persist:Error {
//         test:assertTrue(employee.message().includes("String or binary data would be truncated in table"));
//     } else {
//         test:assertFail("Error expected.");
//     }
//     check rainierClient.close();
// }

// @test:Config {
//     groups: ["employee", "mssql"],
//     dependsOn: [mssqlEmployeeCreateTest]
// }
// function mssqlEmployeeReadOneTest() returns error? {
//     MSSQLRainierClient rainierClient = check new ();

//     Employee employeeRetrieved = check rainierClient->/employees/[employee1.empNo].get();
//     test:assertEquals(employeeRetrieved, employee1);
//     check rainierClient.close();
// }

// @test:Config {
//     groups: ["employee", "mssql"],
//     dependsOn: [mssqlEmployeeCreateTest]
// }
// function mssqlEmployeeReadOneTestNegative() returns error? {
//     MSSQLRainierClient rainierClient = check new ();

//     Employee|error employeeRetrieved = rainierClient->/employees/["invalid-employee-id"].get();
//     if employeeRetrieved is persist:NotFoundError {
//         test:assertEquals(employeeRetrieved.message(), "A record with the key 'invalid-employee-id' does not exist for the entity 'Employee'.");
//     } else {
//         test:assertFail("NotFoundError expected.");
//     }
//     check rainierClient.close();
// }

// @test:Config {
//     groups: ["employee", "mssql"],
//     dependsOn: [mssqlEmployeeCreateTest, mssqlEmployeeCreateTest2]
// }
// function mssqlEmployeeReadManyTest() returns error? {
//     MSSQLRainierClient rainierClient = check new ();

//     stream<Employee, persist:Error?> employeeStream = rainierClient->/employees.get();
//     Employee[] employees = check from Employee employee in employeeStream
//         select employee;

//     test:assertEquals(employees, [employee1, employee2, employee3]);
//     check rainierClient.close();
// }

// @test:Config {
//     groups: ["dependent", "employee"],
//     dependsOn: [mssqlEmployeeCreateTest, mssqlEmployeeCreateTest2]
// }
// function mssqlEmployeeReadManyDependentTest1() returns error? {
//     MSSQLRainierClient rainierClient = check new ();

//     stream<EmployeeName, persist:Error?> employeeStream = rainierClient->/employees.get();
//     EmployeeName[] employees = check from EmployeeName employee in employeeStream
//         select employee;

//     test:assertEquals(employees, [
//         {firstName: employee1.firstName, lastName: employee1.lastName},
//         {firstName: employee2.firstName, lastName: employee2.lastName},
//         {firstName: employee3.firstName, lastName: employee3.lastName}
//     ]);
//     check rainierClient.close();
// }

// @test:Config {
//     groups: ["dependent", "employee"],
//     dependsOn: [mssqlEmployeeCreateTest, mssqlEmployeeCreateTest2]
// }
// function mssqlEmployeeReadManyDependentTest2() returns error? {
//     MSSQLRainierClient rainierClient = check new ();

//     stream<EmployeeInfo2, persist:Error?> employeeStream = rainierClient->/employees.get();
//     EmployeeInfo2[] employees = check from EmployeeInfo2 employee in employeeStream
//         select employee;

//     test:assertEquals(employees, [
//         {empNo: employee1.empNo, birthDate: employee1.birthDate, departmentDeptNo: employee1.departmentDeptNo, workspaceWorkspaceId: employee1.workspaceWorkspaceId},
//         {empNo: employee2.empNo, birthDate: employee2.birthDate, departmentDeptNo: employee2.departmentDeptNo, workspaceWorkspaceId: employee2.workspaceWorkspaceId},
//         {empNo: employee3.empNo, birthDate: employee3.birthDate, departmentDeptNo: employee3.departmentDeptNo, workspaceWorkspaceId: employee3.workspaceWorkspaceId}
//     ]);
//     check rainierClient.close();
// }

// @test:Config {
//     groups: ["employee", "mssql"],
//     dependsOn: [mssqlEmployeeReadOneTest, mssqlEmployeeReadManyTest, mssqlEmployeeReadManyDependentTest1, mssqlEmployeeReadManyDependentTest2]
// }
// function mssqlEmployeeUpdateTest() returns error? {
//     MSSQLRainierClient rainierClient = check new ();

//     Employee employee = check rainierClient->/employees/[employee1.empNo].put({
//         lastName: "Jones",
//         departmentDeptNo: "department-3",
//         birthDate: {year: 1994, month: 11, day: 13}
//     });

//     test:assertEquals(employee, updatedEmployee1);

//     Employee employeeRetrieved = check rainierClient->/employees/[employee1.empNo].get();
//     test:assertEquals(employeeRetrieved, updatedEmployee1);
//     check rainierClient.close();
// }

// @test:Config {
//     groups: ["employee", "mssql"],
//     dependsOn: [mssqlEmployeeReadOneTest, mssqlEmployeeReadManyTest, mssqlEmployeeReadManyDependentTest1, mssqlEmployeeReadManyDependentTest2]
// }
// function mssqlEmployeeUpdateTestNegative1() returns error? {
//     MSSQLRainierClient rainierClient = check new ();

//     Employee|error employee = rainierClient->/employees/["invalid-employee-id"].put({
//         lastName: "Jones"
//     });

//     if employee is persist:NotFoundError {
//         test:assertEquals(employee.message(), "A record with the key 'invalid-employee-id' does not exist for the entity 'Employee'.");
//     } else {
//         test:assertFail("NotFoundError expected.");
//     }
//     check rainierClient.close();
// }

// @test:Config {
//     groups: ["employee", "mssql"],
//     dependsOn: [mssqlEmployeeReadOneTest, mssqlEmployeeReadManyTest, mssqlEmployeeReadManyDependentTest1, mssqlEmployeeReadManyDependentTest2]
// }
// function mssqlEmployeeUpdateTestNegative2() returns error? {
//     MSSQLRainierClient rainierClient = check new ();

//     Employee|error employee = rainierClient->/employees/[employee1.empNo].put({
//         firstName: "unncessarily-long-employee-name-to-force-error-on-update"
//     });

//     if employee is persist:Error {
//         test:assertTrue(employee.message().includes("String or binary data would be truncated in table"));
//     } else {
//         test:assertFail("NotFoundError expected.");
//     }
//     check rainierClient.close();
// }

// @test:Config {
//     groups: ["employee", "mssql"],
//     dependsOn: [mssqlEmployeeReadOneTest, mssqlEmployeeReadManyTest, mssqlEmployeeReadManyDependentTest1, mssqlEmployeeReadManyDependentTest2]
// }
// function mssqlEmployeeUpdateTestNegative3() returns error? {
//     MSSQLRainierClient rainierClient = check new ();

//     Employee|error employee = rainierClient->/employees/[employee1.empNo].put({
//         workspaceWorkspaceId: "invalid-workspaceWorkspaceId"
//     });

//     test:assertTrue(employee is persist:ConstraintViolationError);
//     check rainierClient.close();
// }

// @test:Config {
//     groups: ["employee", "mssql"],
//     dependsOn: [mssqlEmployeeUpdateTest, mssqlEmployeeUpdateTestNegative2, mssqlEmployeeUpdateTestNegative3]
// }
// function mssqlEmployeeDeleteTest() returns error? {
//     MSSQLRainierClient rainierClient = check new ();

//     Employee employee = check rainierClient->/employees/[employee1.empNo].delete();
//     test:assertEquals(employee, updatedEmployee1);

//     stream<Employee, error?> employeeStream = rainierClient->/employees.get();
//     Employee[] employees = check from Employee employee2 in employeeStream
//         select employee2;

//     test:assertEquals(employees, [employee2, employee3]);
//     check rainierClient.close();
// }

// @test:Config {
//     groups: ["employee", "mssql"],
//     dependsOn: [mssqlEmployeeDeleteTest]
// }
// function mssqlEmployeeDeleteTestNegative() returns error? {
//     MSSQLRainierClient rainierClient = check new ();

//     Employee|error employee = rainierClient->/employees/[employee1.empNo].delete();

//     if employee is persist:NotFoundError {
//         test:assertEquals(employee.message(), string `A record with the key '${employee1.empNo}' does not exist for the entity 'Employee'.`);
//     } else {
//         test:assertFail("NotFoundError expected.");
//     }
//     check rainierClient.close();
// }
