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
import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerinax/mssql;
import ballerinax/mssql.driver as _;
import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;
import ballerina/time;

configurable record {|
    int port;
    string host;
    string user;
    string database;
    string password;
    mysql:Options connectionOptions = {};
|} mysql = ?;

configurable record {|
    int port;
    string host;
    string user;
    string database;
    string password;
    mssql:Options connectionOptions = {};
|} mssql = ?;

configurable record {|
    int port;
    string host;
    string user;
    string database;
    string password;
    postgresql:Options connectionOptions = {};
|} postgresql = ?;

@test:BeforeSuite
function initTests() returns error? {
    // MySQL
    check initMySqlTests();

    //MSSQL
    check initMsSqlTests();

    // PostgreSQL
    check initPostgreSqlTests();
}

function initMySqlTests() returns error? {
  mysql:Client mysqlDbClient = check new (host = mysql.host, user = mysql.user, password = mysql.password, database = mysql.database, port = mysql.port);
      _ = check mysqlDbClient->execute(`SET FOREIGN_KEY_CHECKS = 0`);
      _ = check mysqlDbClient->execute(`TRUNCATE Employee`);
      _ = check mysqlDbClient->execute(`TRUNCATE Workspace`);
      _ = check mysqlDbClient->execute(`TRUNCATE Building`);
      _ = check mysqlDbClient->execute(`TRUNCATE Department`);
      _ = check mysqlDbClient->execute(`TRUNCATE OrderItem`);
      _ = check mysqlDbClient->execute(`TRUNCATE AllTypes`);
      _ = check mysqlDbClient->execute(`TRUNCATE FloatIdRecord`);
      _ = check mysqlDbClient->execute(`TRUNCATE StringIdRecord`);
      _ = check mysqlDbClient->execute(`TRUNCATE DecimalIdRecord`);
      _ = check mysqlDbClient->execute(`TRUNCATE BooleanIdRecord`);
      _ = check mysqlDbClient->execute(`TRUNCATE IntIdRecord`);
      _ = check mysqlDbClient->execute(`TRUNCATE AllTypesIdRecord`);
      _ = check mysqlDbClient->execute(`TRUNCATE CompositeAssociationRecord`);
      _ = check mysqlDbClient->execute(`TRUNCATE Doctor`);
      _ = check mysqlDbClient->execute(`TRUNCATE appointment`);
      _ = check mysqlDbClient->execute(`TRUNCATE patients`);
      _ = check mysqlDbClient->execute(`SET FOREIGN_KEY_CHECKS = 1`);
      check mysqlDbClient.close();
}

function initMsSqlTests() returns error? {
  mssql:Client mssqlDbClient = check new (host = mssql.host, user = mssql.user, password = mssql.password, port = mssql.port);
    _ = check mssqlDbClient->execute(`DROP DATABASE IF EXISTS test;`);
    _ = check mssqlDbClient->execute(`CREATE DATABASE test`);
    check mssqlDbClient.close();

    mssqlDbClient = check new (host = mssql.host, user = mssql.user, password = mssql.password, database = mssql.database, port = mssql.port);
    _ = check mssqlDbClient->execute(`
        CREATE TABLE Building (
            buildingCode VARCHAR(36) PRIMARY KEY,
            city VARCHAR(50),
            state VARCHAR(50),
            country VARCHAR(50),
            postalCode VARCHAR(50),
            type VARCHAR(50)
        )
    `);

    _ = check mssqlDbClient->execute(`
        CREATE TABLE Workspace (
            workspaceId VARCHAR(36) PRIMARY KEY,
            workspaceType VARCHAR(10),
            locationBuildingCode VARCHAR(36),
            FOREIGN KEY (locationBuildingCode) REFERENCES Building(buildingCode)
        )
    `);

    _ = check mssqlDbClient->execute(`
        CREATE TABLE Department (
            deptNo VARCHAR(36) PRIMARY KEY,
            deptName VARCHAR(30)
        )
    `);

    _ = check mssqlDbClient->execute(`
        CREATE TABLE Employee (
            empNo VARCHAR(36) PRIMARY KEY,
            firstName VARCHAR(30),
            lastName VARCHAR(30),
            birthDate DATE,
            gender VARCHAR(6) CHECK (gender IN ('MALE', 'FEMALE')) NOT NULL,
            hireDate DATE,
            departmentDeptNo VARCHAR(36),
            workspaceWorkspaceId VARCHAR(36),
            FOREIGN KEY (departmentDeptNo) REFERENCES Department(deptNo),
            FOREIGN KEY (workspaceWorkspaceId) REFERENCES Workspace(workspaceId)
        )
    `);

    _ = check mssqlDbClient->execute(`
        CREATE TABLE OrderItem (
            orderId VARCHAR(36),
            itemId VARCHAR(30),
            quantity INTEGER,
            notes VARCHAR(255),
            PRIMARY KEY(orderId, itemId)
        )
    `);

    _ = check mssqlDbClient->execute(`
        CREATE TABLE [AllTypes] (
        	[id] INT NOT NULL,
        	[booleanType] BIT NOT NULL,
        	[intType] INT NOT NULL,
        	[floatType] FLOAT NOT NULL,
        	[decimalType] DECIMAL(38,30) NOT NULL,
        	[stringType] VARCHAR(191) NOT NULL,
        	[byteArrayType] VARBINARY(MAX) NOT NULL,
        	[dateType] DATE NOT NULL,
        	[timeOfDayType] TIME NOT NULL,
        	[civilType] DATETIME2 NOT NULL,
        	[booleanTypeOptional] BIT,
        	[intTypeOptional] INT,
        	[floatTypeOptional] FLOAT,
        	[decimalTypeOptional] DECIMAL(38,30),
        	[stringTypeOptional] VARCHAR(191),
        	[dateTypeOptional] DATE,
        	[timeOfDayTypeOptional] TIME,
        	[civilTypeOptional] DATETIME2,
        	[enumType] VARCHAR(6) CHECK ([enumType] IN ('TYPE_1', 'TYPE_2', 'TYPE_3', 'TYPE_4')) NOT NULL,
        	[enumTypeOptional] VARCHAR(6) CHECK ([enumTypeOptional] IN ('TYPE_1', 'TYPE_2', 'TYPE_3', 'TYPE_4')),
        	PRIMARY KEY([id])
        );
    `);

    _ = check mssqlDbClient->execute(`
        CREATE TABLE FloatIdRecord (
            id FLOAT NOT NULL,
            randomField VARCHAR(191) NOT NULL,
            PRIMARY KEY(id)
        );
    `);

    _ = check mssqlDbClient->execute(`
        CREATE TABLE StringIdRecord (
            id VARCHAR(191) NOT NULL,
            randomField VARCHAR(191) NOT NULL,
            PRIMARY KEY(id)
        );
    `);

    _ = check mssqlDbClient->execute(`
        CREATE TABLE DecimalIdRecord (
            id DECIMAL(10, 2) NOT NULL,
            randomField VARCHAR(191) NOT NULL,
            PRIMARY KEY(id)
        );
    `);

    _ = check mssqlDbClient->execute(`
        CREATE TABLE BooleanIdRecord (
            id BIT NOT NULL,
            randomField VARCHAR(191) NOT NULL,
            PRIMARY KEY(id)
        );
    `);

    _ = check mssqlDbClient->execute(`
        CREATE TABLE IntIdRecord (
            id INT NOT NULL,
            randomField VARCHAR(191) NOT NULL,
            PRIMARY KEY(id)
        );
    `);

    _ = check mssqlDbClient->execute(`
        CREATE TABLE AllTypesIdRecord (
            booleanType BIT NOT NULL,
            intType INT NOT NULL,
            floatType FLOAT NOT NULL,
            decimalType DECIMAL(10, 2) NOT NULL,
            stringType VARCHAR(191) NOT NULL,
            randomField VARCHAR(191) NOT NULL,
            PRIMARY KEY(booleanType,intType,floatType,decimalType,stringType)
        );
    `);

    _ = check mssqlDbClient->execute(`
        CREATE TABLE CompositeAssociationRecord (
            id VARCHAR(191) NOT NULL,
            randomField VARCHAR(191) NOT NULL,
            alltypesidrecordBooleanType BIT NOT NULL,
            alltypesidrecordIntType INT NOT NULL,
            alltypesidrecordFloatType FLOAT NOT NULL,
            alltypesidrecordDecimalType DECIMAL(10, 2) NOT NULL,
            alltypesidrecordStringType VARCHAR(191) NOT NULL,
            CONSTRAINT FK_COMPOSITEASSOCIATIONRECORD_ALLTYPESIDRECORD FOREIGN KEY(alltypesidrecordBooleanType, alltypesidrecordIntType, alltypesidrecordFloatType, alltypesidrecordDecimalType, alltypesidrecordStringType) REFERENCES AllTypesIdRecord(booleanType, intType, floatType, decimalType, stringType),
            PRIMARY KEY(id)
        );
    `);
    _ = check mssqlDbClient->execute(`
        CREATE TABLE [Doctor] (
          	[id] INT NOT NULL,
	          [name] VARCHAR(191) NOT NULL,
	          [specialty] VARCHAR(191) NOT NULL,
	          [phone_number] VARCHAR(191) NOT NULL,
	          [salary] DECIMAL(10,2),
	          PRIMARY KEY([id])
        );
    `);
    _ = check mssqlDbClient->execute(`
        CREATE TABLE [patients] (
	          [IDP] INT IDENTITY(1,1),
	          [name] VARCHAR(191) NOT NULL,
	          [age] INT NOT NULL,
	          [ADD_RESS] VARCHAR(191) NOT NULL,
	          [phoneNumber] CHAR(10) NOT NULL,
	          [gender] VARCHAR(6) CHECK ([gender] IN ('MALE', 'FEMALE')) NOT NULL,
	          PRIMARY KEY([IDP])
        );
    `);
    _ = check mssqlDbClient->execute(`
        CREATE TABLE [appointment] (
	          [id] INT NOT NULL,
	          [reason] VARCHAR(191) NOT NULL,
	          [appointmentTime] DATETIME2 NOT NULL,
	          [status] VARCHAR(9) CHECK ([status] IN ('SCHEDULED', 'STARTED', 'ENDED')) NOT NULL,
	          [patient_id] INT NOT NULL,
	          FOREIGN KEY([patient_id]) REFERENCES [patients]([IDP]),
	          [doctorId] INT NOT NULL,
	          FOREIGN KEY([doctorId]) REFERENCES [Doctor]([id]),
	          PRIMARY KEY([id])
        );
    `);
}

function initPostgreSqlTests() returns error? {
  postgresql:Client postgresqlDbClient = check new (host = postgresql.host, username = postgresql.user, password = postgresql.password, database = postgresql.database, port = postgresql.port);
    _ = check postgresqlDbClient->execute(`TRUNCATE "Employee" CASCADE`);
    _ = check postgresqlDbClient->execute(`TRUNCATE "Workspace" CASCADE`);
    _ = check postgresqlDbClient->execute(`TRUNCATE "Building" CASCADE`);
    _ = check postgresqlDbClient->execute(`TRUNCATE "Department" CASCADE`);
    _ = check postgresqlDbClient->execute(`TRUNCATE "OrderItem" CASCADE`);
    _ = check postgresqlDbClient->execute(`TRUNCATE "AllTypes" CASCADE`);
    _ = check postgresqlDbClient->execute(`TRUNCATE "FloatIdRecord" CASCADE`);
    _ = check postgresqlDbClient->execute(`TRUNCATE "StringIdRecord" CASCADE`);
    _ = check postgresqlDbClient->execute(`TRUNCATE "DecimalIdRecord" CASCADE`);
    _ = check postgresqlDbClient->execute(`TRUNCATE "BooleanIdRecord" CASCADE`);
    _ = check postgresqlDbClient->execute(`TRUNCATE "IntIdRecord" CASCADE`);
    _ = check postgresqlDbClient->execute(`TRUNCATE "AllTypesIdRecord" CASCADE`);
    _ = check postgresqlDbClient->execute(`TRUNCATE "CompositeAssociationRecord" CASCADE`);
    check postgresqlDbClient.close();
}

AllTypes allTypes1 = {
    id: 1,
    booleanType: false,
    intType: 5,
    floatType: 6.0,
    decimalType: 23.44,
    stringType: "test-2",
    byteArrayType: base16 `55 EE 66 FF 77 AB`,
    dateType: {year: 1993, month: 11, day: 3},
    timeOfDayType: {hour: 12, minute: 32, second: 34},
    civilType: {year: 1993, month: 11, day: 3, hour: 12, minute: 32, second: 34},
    booleanTypeOptional: false,
    intTypeOptional: 5,
    floatTypeOptional: 6.0,
    decimalTypeOptional: 23.44,
    stringTypeOptional: "test",
    dateTypeOptional: {year: 1993, month: 11, day: 3},
    timeOfDayTypeOptional: {hour: 12, minute: 32, second: 34},
    civilTypeOptional: {year: 1993, month: 11, day: 3, hour: 12, minute: 32, second: 34},
    enumType: "TYPE_3",
    enumTypeOptional: "TYPE_2"
};

AllTypes allTypes1Expected = {
    id: allTypes1.id,
    booleanType: allTypes1.booleanType,
    intType: allTypes1.intType,
    floatType: allTypes1.floatType,
    decimalType: allTypes1.decimalType,
    stringType: allTypes1.stringType,
    byteArrayType: allTypes1.byteArrayType,
    dateType: allTypes1.dateType,
    timeOfDayType: allTypes1.timeOfDayType,
    civilType: allTypes1.civilType,
    booleanTypeOptional: allTypes1.booleanTypeOptional,
    intTypeOptional: allTypes1.intTypeOptional,
    floatTypeOptional: allTypes1.floatTypeOptional,
    decimalTypeOptional: allTypes1.decimalTypeOptional,
    stringTypeOptional: allTypes1.stringTypeOptional,
    dateTypeOptional: allTypes1.dateTypeOptional,
    timeOfDayTypeOptional: allTypes1.timeOfDayTypeOptional,
    civilTypeOptional: allTypes1.civilTypeOptional,
    enumType: allTypes1.enumType,
    enumTypeOptional: allTypes1.enumTypeOptional
};

AllTypes allTypes2 = {
    id: 2,
    booleanType: true,
    intType: 35,
    floatType: 63.0,
    decimalType: 233.44,
    stringType: "test2",
    byteArrayType: base16 `55 EE 66 AF 77 AB`,
    dateType: {year: 1996, month: 11, day: 3},
    timeOfDayType: {hour: 17, minute: 32, second: 34},
    civilType: {year: 1999, month: 11, day: 3, hour: 12, minute: 32, second: 34},
    booleanTypeOptional: true,
    intTypeOptional: 6,
    floatTypeOptional: 66.0,
    decimalTypeOptional: 233.44,
    stringTypeOptional: "test2",
    dateTypeOptional: {year: 1293, month: 11, day: 3},
    timeOfDayTypeOptional: {hour: 19, minute: 32, second: 34},
    civilTypeOptional: {year: 1989, month: 11, day: 3, hour: 12, minute: 32, second: 34},
    enumType: "TYPE_1",
    enumTypeOptional: "TYPE_3"
};

AllTypes allTypes2Expected = {
    id: allTypes2.id,
    booleanType: allTypes2.booleanType,
    intType: allTypes2.intType,
    floatType: allTypes2.floatType,
    decimalType: allTypes2.decimalType,
    stringType: allTypes2.stringType,
    byteArrayType: allTypes2.byteArrayType,
    dateType: allTypes2.dateType,
    timeOfDayType: allTypes2.timeOfDayType,
    civilType: allTypes2.civilType,
    booleanTypeOptional: allTypes2.booleanTypeOptional,
    intTypeOptional: allTypes2.intTypeOptional,
    floatTypeOptional: allTypes2.floatTypeOptional,
    decimalTypeOptional: allTypes2.decimalTypeOptional,
    stringTypeOptional: allTypes2.stringTypeOptional,
    dateTypeOptional: allTypes2.dateTypeOptional,
    timeOfDayTypeOptional: allTypes2.timeOfDayTypeOptional,
    civilTypeOptional: allTypes2.civilTypeOptional,
    enumType: allTypes2.enumType,
    enumTypeOptional: allTypes2.enumTypeOptional
};

AllTypes allTypes3 = {
    id: 3,
    booleanType: true,
    intType: 35,
    floatType: 63.0,
    decimalType: 233.44,
    stringType: "test2",
    byteArrayType: base16 `55 EE 66 AF 77 AB`,
    dateType: {year: 1996, month: 11, day: 3},
    timeOfDayType: {hour: 17, minute: 32, second: 34},
    civilType: {year: 1999, month: 11, day: 3, hour: 12, minute: 32, second: 34},
    booleanTypeOptional: (),
    intTypeOptional: (),
    floatTypeOptional: (),
    decimalTypeOptional: (),
    stringTypeOptional: (),
    dateTypeOptional: (),
    timeOfDayTypeOptional: (),
    civilTypeOptional: (),
    enumType: "TYPE_1",
    enumTypeOptional: ()
};

AllTypes allTypes3Expected = {
    id: allTypes3.id,
    booleanType: allTypes3.booleanType,
    intType: allTypes3.intType,
    floatType: allTypes3.floatType,
    decimalType: allTypes3.decimalType,
    stringType: allTypes3.stringType,
    byteArrayType: allTypes3.byteArrayType,
    dateType: allTypes3.dateType,
    timeOfDayType: allTypes3.timeOfDayType,
    civilType: allTypes3.civilType,
    booleanTypeOptional: allTypes3.booleanTypeOptional,
    intTypeOptional: allTypes3.intTypeOptional,
    floatTypeOptional: allTypes3.floatTypeOptional,
    decimalTypeOptional: allTypes3.decimalTypeOptional,
    stringTypeOptional: allTypes3.stringTypeOptional,
    dateTypeOptional: allTypes3.dateTypeOptional,
    timeOfDayTypeOptional: allTypes3.timeOfDayTypeOptional,
    civilTypeOptional: allTypes3.civilTypeOptional,
    enumType: allTypes3.enumType,
    enumTypeOptional: allTypes3.enumTypeOptional
};

AllTypes allTypes4 = {
    id: 4,
    booleanType: true,
    intType: 35,
    floatType: 63.0,
    decimalType: 233.44,
    stringType: "test2",
    byteArrayType: base16 `55 EE 66 AF 77 AB`,
    dateType: {year: 1996, month: 11, day: 3},
    timeOfDayType: {hour: 17, minute: 32, second: 34},
    civilType: {year: 1999, month: 11, day: 3, hour: 12, minute: 32, second: 34},
    booleanTypeOptional: true,
    intTypeOptional: 35,
    floatTypeOptional: 63.0,
    decimalTypeOptional: 233.44,
    stringTypeOptional: "test2",
    dateTypeOptional: {year: 1996, month: 11, day: 3},
    timeOfDayTypeOptional: {hour: 17, minute: 32, second: 34},
    civilTypeOptional: {year: 1999, month: 11, day: 3, hour: 12, minute: 32, second: 34},
    enumType: "TYPE_1",
    enumTypeOptional: "TYPE_3"
};

AllTypes allTypes4Expected = {
    id: allTypes4.id,
    booleanType: allTypes4.booleanType,
    intType: allTypes4.intType,
    floatType: allTypes4.floatType,
    decimalType: allTypes4.decimalType,
    stringType: allTypes4.stringType,
    byteArrayType: allTypes4.byteArrayType,
    dateType: allTypes4.dateType,
    timeOfDayType: allTypes4.timeOfDayType,
    civilType: allTypes4.civilType,
    booleanTypeOptional: allTypes4.booleanTypeOptional,
    intTypeOptional: allTypes4.intTypeOptional,
    floatTypeOptional: allTypes4.floatTypeOptional,
    decimalTypeOptional: allTypes4.decimalTypeOptional,
    stringTypeOptional: allTypes4.stringTypeOptional,
    dateTypeOptional: allTypes4.dateTypeOptional,
    timeOfDayTypeOptional: allTypes4.timeOfDayTypeOptional,
    civilTypeOptional: allTypes4.civilTypeOptional,
    enumType: allTypes4.enumType,
    enumTypeOptional: allTypes4.enumTypeOptional
};

AllTypes allTypes1Updated = {
    id: 1,
    booleanType: true,
    intType: 99,
    floatType: 63.0,
    decimalType: 53.44,
    stringType: "testUpdate",
    byteArrayType: base16 `55 FE 66 FF 77 AB`,
    dateType: {year: 1996, month: 12, day: 13},
    timeOfDayType: {hour: 16, minute: 12, second: 14},
    civilType: {year: 1998, month: 9, day: 13, hour: 12, minute: 32, second: 34},
    booleanTypeOptional: true,
    intTypeOptional: 53,
    floatTypeOptional: 26.0,
    decimalTypeOptional: 223.44,
    stringTypeOptional: "testUpdate",
    dateTypeOptional: {year: 1923, month: 11, day: 3},
    timeOfDayTypeOptional: {hour: 18, minute: 32, second: 34},
    civilTypeOptional: {year: 1991, month: 11, day: 3, hour: 12, minute: 32, second: 34},
    enumType: "TYPE_4",
    enumTypeOptional: "TYPE_4"
};

AllTypes allTypes1UpdatedExpected = {
    id: allTypes1Updated.id,
    booleanType: allTypes1Updated.booleanType,
    intType: allTypes1Updated.intType,
    floatType: allTypes1Updated.floatType,
    decimalType: allTypes1Updated.decimalType,
    stringType: allTypes1Updated.stringType,
    byteArrayType: allTypes1Updated.byteArrayType,
    dateType: allTypes1Updated.dateType,
    timeOfDayType: allTypes1Updated.timeOfDayType,
    civilType: allTypes1Updated.civilType,
    booleanTypeOptional: allTypes1Updated.booleanTypeOptional,
    intTypeOptional: allTypes1Updated.intTypeOptional,
    floatTypeOptional: allTypes1Updated.floatTypeOptional,
    decimalTypeOptional: allTypes1Updated.decimalTypeOptional,
    stringTypeOptional: allTypes1Updated.stringTypeOptional,
    dateTypeOptional: allTypes1Updated.dateTypeOptional,
    timeOfDayTypeOptional: allTypes1Updated.timeOfDayTypeOptional,
    civilTypeOptional: allTypes1Updated.civilTypeOptional,
    enumType: allTypes1Updated.enumType,
    enumTypeOptional: allTypes1Updated.enumTypeOptional
};

public type AllTypesDependent record {|
    boolean booleanType;
    int intType;
    float floatType;
    decimal decimalType;
    string stringType;
    byte[] byteArrayType;
    time:Date dateType;
    time:TimeOfDay timeOfDayType;
    time:Civil civilType;
    boolean? booleanTypeOptional;
    int? intTypeOptional;
    float? floatTypeOptional;
    decimal? decimalTypeOptional;
    string? stringTypeOptional;
    time:Date? dateTypeOptional;
    time:TimeOfDay? timeOfDayTypeOptional;
    time:Civil? civilTypeOptional;
|};

OrderItemExtended orderItemExtended1 = {
    orderId: "order-1",
    itemId: "item-1",
    CustomerId: 1,
    paid: false,
    ammountPaid: 10.5f,
    ammountPaidDecimal: 10.5,
    arivalTimeCivil: {"utcOffset": {"hours": 5, "minutes": 30}, "timeAbbrev": "Asia/Colombo", "dayOfWeek": 1, "year": 2021, "month": 4, "day": 12, "hour": 23, "minute": 20, "second": 50.52},
    arivalTimeUtc: [1684493685, 0.998012000],
    arivalTimeDate: {year: 2021, month: 4, day: 12},
    arivalTimeTimeOfDay: {hour: 17, minute: 50, second: 50.52},
    orderType: INSTORE
};

OrderItemExtended orderItemExtendedRetrieved = {
    orderId: "order-1",
    itemId: "item-1",
    CustomerId: 1,
    paid: false,
    ammountPaid: 10.5f,
    ammountPaidDecimal: 10.5,
    arivalTimeCivil: {"timeAbbrev": "Z", "dayOfWeek": 1, "year": 2021, "month": 4, "day": 12, "hour": 17, "minute": 50, "second": 50.52},
    arivalTimeUtc: [1684493685, 0.998012000],
    arivalTimeDate: {year: 2021, month: 4, day: 12},
    arivalTimeTimeOfDay: {hour: 17, minute: 50, second: 50.52},
    orderType: INSTORE
};

OrderItemExtended orderItemExtended2 = {
    orderId: "order-2",
    itemId: "item-2",
    CustomerId: 1,
    paid: false,
    ammountPaid: 10.5f,
    ammountPaidDecimal: 10.5,
    arivalTimeCivil: {"utcOffset": {"hours": 5, "minutes": 30}, "timeAbbrev": "Asia/Colombo", "dayOfWeek": 1, "year": 2024, "month": 4, "day": 12, "hour": 17, "minute": 50, "second": 50.52},
    arivalTimeUtc: [1684493685, 0.998012000],
    arivalTimeDate: {year: 2021, month: 4, day: 12},
    arivalTimeTimeOfDay: {hour: 17, minute: 50, second: 50.52},
    orderType: ONLINE
};

public type EmployeeInfo record {|
    string firstName;
    string lastName;
    record {|
        string deptName;
    |} department;
    Workspace workspace;
|};

OrderItemExtended orderItemExtended2Retrieved = {
    orderId: "order-2",
    itemId: "item-2",
    CustomerId: 1,
    paid: false,
    ammountPaid: 10.5f,
    ammountPaidDecimal: 10.5,
    arivalTimeCivil: {"timeAbbrev": "Z", "dayOfWeek": 5, "year": 2024, "month": 4, "day": 12, "hour": 12, "minute": 20, "second": 50.52},
    arivalTimeUtc: [1684493685, 0.998012000],
    arivalTimeDate: {year: 2021, month: 4, day: 12},
    arivalTimeTimeOfDay: {hour: 17, minute: 50, second: 50.52},
    orderType: ONLINE
};

OrderItemExtended orderItemExtended3 = {
    orderId: "order-3",
    itemId: "item-3",
    CustomerId: 4,
    paid: true,
    ammountPaid: 20.5f,
    ammountPaidDecimal: 20.5,
    arivalTimeCivil: {"utcOffset": {"hours": 5, "minutes": 30}, "timeAbbrev": "Asia/Colombo", "dayOfWeek": 1, "year": 2021, "month": 4, "day": 12, "hour": 23, "minute": 20, "second": 50.52},
    arivalTimeUtc: [1684493685, 0.998012000],
    arivalTimeDate: {year: 2021, month: 4, day: 12},
    arivalTimeTimeOfDay: {hour: 17, minute: 50, second: 50.52},
    orderType: INSTORE
};

OrderItemExtended orderItemExtended3Retrieved = {
    orderId: "order-2",
    itemId: "item-2",
    CustomerId: 1,
    paid: true,
    ammountPaid: 10.5f,
    ammountPaidDecimal: 10.5,
    arivalTimeCivil: {"timeAbbrev": "Z", "dayOfWeek": 1, "year": 2021, "month": 4, "day": 12, "hour": 17, "minute": 50, "second": 50.52},
    arivalTimeUtc: [1684493685, 0.998012000],
    arivalTimeDate: {year: 2021, month: 4, day: 12},
    arivalTimeTimeOfDay: {hour: 17, minute: 50, second: 50.52},
    orderType: ONLINE
};

public type DepartmentInfo record {|
    string deptNo;
    string deptName;
    record {|
        string firstName;
        string lastName;
    |}[] employees;
|};

public type WorkspaceInfo record {|
    string workspaceType;
    Building location;
    Employee[] employees;
|};

public type BuildingInfo record {|
    string buildingCode;
    string city;
    string state;
    string country;
    string postalCode;
    string 'type;
    Workspace[] workspaces;
|};

Building building1 = {
    buildingCode: "building-1",
    city: "Colombo",
    state: "Western Province",
    country: "Sri Lanka",
    postalCode: "10370",
    'type: "rented"
};

Building invalidBuilding = {
    buildingCode: "building-invalid-extra-characters-to-force-failure",
    city: "Colombo",
    state: "Western Province",
    country: "Sri Lanka",
    postalCode: "10370",
    'type: "owned"
};

BuildingInsert building2 = {
    buildingCode: "building-2",
    city: "Manhattan",
    state: "New York",
    country: "USA",
    postalCode: "10570",
    'type: "owned"
};

BuildingInsert building3 = {
    buildingCode: "building-3",
    city: "London",
    state: "London",
    country: "United Kingdom",
    postalCode: "39202",
    'type: "rented"
};

Building updatedBuilding1 = {
    buildingCode: "building-1",
    city: "Galle",
    state: "Southern Province",
    country: "Sri Lanka",
    postalCode: "10890",
    'type: "owned"
};

Department department1 = {
    deptNo: "department-1",
    deptName: "Finance"
};

Department invalidDepartment = {
    deptNo: "invalid-department-extra-characters-to-force-failure",
    deptName: "Finance"
};

Department department2 = {
    deptNo: "department-2",
    deptName: "Marketing"
};

Department department3 = {
    deptNo: "department-3",
    deptName: "Engineering"
};

Department updatedDepartment1 = {
    deptNo: "department-1",
    deptName: "Finance & Legalities"
};

Employee employee1 = {
    empNo: "employee-1",
    firstName: "Tom",
    lastName: "Scott",
    birthDate: {year: 1992, month: 11, day: 13},
    gender: MALE,
    hireDate: {year: 2022, month: 8, day: 1},
    departmentDeptNo: "department-2",
    workspaceWorkspaceId: "workspace-2"
};

Employee invalidEmployee = {
    empNo: "invalid-employee-no-extra-characters-to-force-failure",
    firstName: "Tom",
    lastName: "Scott",
    birthDate: {year: 1992, month: 11, day: 13},
    gender: MALE,
    hireDate: {year: 2022, month: 8, day: 1},
    departmentDeptNo: "department-2",
    workspaceWorkspaceId: "workspace-2"
};

Employee employee2 = {
    empNo: "employee-2",
    firstName: "Jane",
    lastName: "Doe",
    birthDate: {year: 1996, month: 9, day: 15},
    gender: FEMALE,
    hireDate: {year: 2022, month: 6, day: 1},
    departmentDeptNo: "department-2",
    workspaceWorkspaceId: "workspace-2"
};

Employee employee3 = {
    empNo: "employee-3",
    firstName: "Hugh",
    lastName: "Smith",
    birthDate: {year: 1986, month: 9, day: 15},
    gender: FEMALE,
    hireDate: {year: 2021, month: 6, day: 1},
    departmentDeptNo: "department-3",
    workspaceWorkspaceId: "workspace-3"
};

Employee updatedEmployee1 = {
    empNo: "employee-1",
    firstName: "Tom",
    lastName: "Jones",
    birthDate: {year: 1994, month: 11, day: 13},
    gender: MALE,
    hireDate: {year: 2022, month: 8, day: 1},
    departmentDeptNo: "department-3",
    workspaceWorkspaceId: "workspace-2"
};

public type IntIdRecordDependent record {|
    string randomField;
|};

public type StringIdRecordDependent record {|
    string randomField;
|};

public type FloatIdRecordDependent record {|
    string randomField;
|};

public type DecimalIdRecordDependent record {|
    string randomField;
|};

public type BooleanIdRecordDependent record {|
    string randomField;
|};

public type AllTypesIdRecordDependent record {|
    string randomField;
|};

public type CompositeAssociationRecordDependent record {|
    string randomField;
    int alltypesidrecordIntType;
    decimal alltypesidrecordDecimalType;
    record {|
        int intType;
        string stringType;
        boolean booleanType;
        string randomField;
    |} allTypesIdRecord;
|};

Workspace workspace1 = {
    workspaceId: "workspace-1",
    workspaceType: "small",
    locationBuildingCode: "building-2"
};

Workspace invalidWorkspace = {
    workspaceId: "invalid-workspace-extra-characters-to-force-failure",
    workspaceType: "small",
    locationBuildingCode: "building-2"
};

Workspace workspace2 = {
    workspaceId: "workspace-2",
    workspaceType: "medium",
    locationBuildingCode: "building-2"
};

Workspace workspace3 = {
    workspaceId: "workspace-3",
    workspaceType: "small",
    locationBuildingCode: "building-2"
};

Workspace updatedWorkspace1 = {
    workspaceId: "workspace-1",
    workspaceType: "large",
    locationBuildingCode: "building-2"
};

public type EmployeeName record {|
    string firstName;
    string lastName;
|};

public type EmployeeInfo2 record {|
    readonly string empNo;
    time:Date birthDate;
    string departmentDeptNo;
    string workspaceWorkspaceId;
|};

public type WorkspaceInfo2 record {|
    string workspaceType;
    string locationBuildingCode;
|};

public type DepartmentInfo2 record {|
    string deptName;
|};

public type BuildingInfo2 record {|
    string city;
    string state;
    string country;
    string postalCode;
    string 'type;
|};

OrderItem orderItem1 = {
    orderId: "order-1",
    itemId: "item-1",
    quantity: 5,
    notes: "none"
};

OrderItem orderItem2 = {
    orderId: "order-2",
    itemId: "item-2",
    quantity: 10,
    notes: "more"
};

OrderItem orderItem2Updated = {
    orderId: "order-2",
    itemId: "item-2",
    quantity: 20,
    notes: "more than more"
};

Building building31 = {
    buildingCode: "building-31",
    city: "Colombo",
    state: "Western Province",
    country: "Sri Lanka",
    postalCode: "10370",
    'type: "rented"
};

BuildingInsert building32 = {
    buildingCode: "building-32",
    city: "Manhattan",
    state: "New York",
    country: "USA",
    postalCode: "10570",
    'type: "owned"
};

BuildingInsert building33 = {
    buildingCode: "building-33",
    city: "Manhattan",
    state: "New York",
    country: "USA",
    postalCode: "10570",
    'type: "owned"
};

Building building33Updated = {
    buildingCode: "building-33",
    city: "ColomboUpdated",
    state: "Western ProvinceUpdated",
    country: "Sri LankaUpdated",
    postalCode: "10570",
    'type: "owned"
};

Department departmentNative1 = {
    deptNo: "department-native-1",
    deptName: "Finance"
};

Department departmentNative2 = {
    deptNo: "department-native-2",
    deptName: "HR"
};

Department departmentNative3 = {
    deptNo: "department-native-3",
    deptName: "Marketing"
};

Building buildingNative1 = {
    buildingCode: "building-native-1",
    city: "Colombo",
    state: "Western",
    country: "Sri Lanka",
    postalCode: "10370",
    'type: "office"
};

Building buildingNative2 = {
    buildingCode: "building-native-2",
    city: "Kandy",
    state: "Central",
    country: "Sri Lanka",
    postalCode: "20000",
    'type: "coworking space"
};

Building buildingNative3 = {
    buildingCode: "building-native-3",
    city: "San Francisco",
    state: "California",
    country: "USA",
    postalCode: "80000",
    'type: "office"
};

Workspace workspaceNative1 = {
    workspaceId: "workspace-native-1",
    workspaceType: "hot seat",
    locationBuildingCode: "building-native-2"
};

Workspace workspaceNative2 = {
    workspaceId: "workspace-native-2",
    workspaceType: "dedicated",
    locationBuildingCode: "building-native-2"
};

Workspace workspaceNative3 = {
    workspaceId: "workspace-native-3",
    workspaceType: "hot seat",
    locationBuildingCode: "building-native-3"
};

Employee employeeNative1 = {
    empNo: "employee-native-1",
    firstName: "John",
    lastName: "Doe",
    birthDate: {year: 1994, month: 10, day: 30},
    gender: MALE,
    hireDate: {year: 2020, month: 10, day: 30},
    departmentDeptNo: "department-native-1",
    workspaceWorkspaceId: "workspace-native-1"
};

Employee employeeNative2 = {
    empNo: "employee-native-2",
    firstName: "Jane",
    lastName: "Doe",
    birthDate: {year: 1996, month: 8, day: 12},
    gender: FEMALE,
    hireDate: {year: 2021, month: 10, day: 30},
    departmentDeptNo: "department-native-2",
    workspaceWorkspaceId: "workspace-native-2"
};

Employee employeeNative3 = {
    empNo: "employee-native-3",
    firstName: "Sam",
    lastName: "Smith",
    birthDate: {year: 1991, month: 8, day: 12},
    gender: MALE,
    hireDate: {year: 2019, month: 10, day: 30},
    departmentDeptNo: "department-native-3",
    workspaceWorkspaceId: "workspace-native-3"
};

EmployeeInfo employeeInfoNative1 = {
    firstName: "John",
    lastName: "Doe",
    department: {
        deptName: "Finance"
    },
    workspace: {
        workspaceId: "workspace-native-1",
        workspaceType: "hot seat",
        locationBuildingCode: "building-native-2"
    }
};

EmployeeInfo employeeInfoNative2 = {
    firstName: "Jane",
    lastName: "Doe",
    department: {
        deptName: "HR"
    },
    workspace: {
        workspaceId: "workspace-native-2",
        workspaceType: "dedicated",
        locationBuildingCode: "building-native-2"
    }
};

EmployeeInfo employeeInfoNative3 = {
    firstName: "Sam",
    lastName: "Smith",
    department: {
        deptName: "Marketing"
    },
    workspace: {
        workspaceId: "workspace-native-3",
        workspaceType: "hot seat",
        locationBuildingCode: "building-native-3"
    }
};
