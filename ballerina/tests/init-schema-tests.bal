// Copyright (c) 2025 WSO2 LLC. (http://www.wso2.org).
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
import ballerinax/h2.driver as _;
import ballerinax/java.jdbc;
import ballerinax/mssql;
import ballerinax/mssql.driver as _;
import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;

configurable record {|
    string url;
    string user;
    string password;
    string? defaultSchema = ();
    jdbc:Options connectionOptions = {};
|} & readonly h2WithSchema = ?;

configurable record {|
    int port;
    string host;
    string user;
    string database;
    string password;
    string? defaultSchema = ();
    mssql:Options connectionOptions = {};
|} & readonly mssqlWithSchema = ?;

configurable record {|
    int port;
    string host;
    string user;
    string database;
    string password;
    string? defaultSchema = ();
    postgresql:Options connectionOptions = {};
|} & readonly postgresqlWithSchema = ?;

@test:BeforeSuite
function initSuiteWithSchema() returns error? {
    check initPostgreSqlTestsWithSchema();
    check initH2TestsWithSchema();
    check initMsSqlTestsWithSchema();
}

function initMsSqlTestsWithSchema() returns error? {
    mssql:Client mssqlDbClient = check new (host = mssqlWithSchema.host, user = mssqlWithSchema.user, password = mssqlWithSchema.password, port = mssqlWithSchema.port);
    // create `persist` schema and set it as the default schema

    _ = check mssqlDbClient->execute(`CREATE DATABASE testschema`);

    _ = check mssqlDbClient.close();

    mssqlDbClient = check new (host = mssqlWithSchema.host, user = mssqlWithSchema.user, password = mssqlWithSchema.password, database = mssqlWithSchema.database, port = mssqlWithSchema.port);

    _ = check mssqlDbClient->call(`IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'persist')
                                      BEGIN
                                          EXEC ('CREATE SCHEMA persist AUTHORIZATION dbo');
                                      END`);
    _ = check mssqlDbClient->call(`IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'hospital')
                                      BEGIN
                                          EXEC ('CREATE SCHEMA hospital AUTHORIZATION dbo');
                                      END`);

    _ = check mssqlDbClient->execute(`
        CREATE TABLE persist.[Doctor] (
          	[id] INT NOT NULL,
	          [name] VARCHAR(191) NOT NULL,
	          [specialty] VARCHAR(191) NOT NULL,
	          [phone_number] VARCHAR(191) NOT NULL,
	          [salary] DECIMAL(10,2),
	          PRIMARY KEY([id])
        );
    `);
    _ = check mssqlDbClient->execute(`
        CREATE TABLE persist.[patients] (
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
        CREATE TABLE hospital.[appointment] (
	          [id] INT NOT NULL,
	          [reason] VARCHAR(191) NOT NULL,
	          [appointmentTime] DATETIME2 NOT NULL,
	          [status] VARCHAR(9) CHECK ([status] IN ('SCHEDULED', 'STARTED', 'ENDED')) NOT NULL,
	          [patient_id] INT NOT NULL,
	          FOREIGN KEY([patient_id]) REFERENCES persist.[patients]([IDP]),
	          [doctorId] INT NOT NULL,
	          FOREIGN KEY([doctorId]) REFERENCES persist.[Doctor]([id]),
	          PRIMARY KEY([id])
        );
    `);
    check mssqlDbClient.close();
}

function initPostgreSqlTestsWithSchema() returns error? {
    postgresql:Client postgresqlDbClient = check new (host = postgresqlWithSchema.host, username = postgresqlWithSchema.user, password = postgresqlWithSchema.password, database = postgresqlWithSchema.database, port = postgresqlWithSchema.port);
    _ = check postgresqlDbClient->execute(`CREATE SCHEMA persist`);
    _ = check postgresqlDbClient->execute(`CREATE SCHEMA hospital`);
    _ = check postgresqlDbClient->execute(`DROP TABLE IF EXISTS persist."Doctor"`);
    _ = check postgresqlDbClient->execute(`
        CREATE TABLE persist."Doctor" (
        	"id" INT NOT NULL,
        	"name" VARCHAR(191) NOT NULL,
        	"specialty" VARCHAR(191) NOT NULL,
        	"phone_number" VARCHAR(191) NOT NULL,
        	"salary" DECIMAL(10,2),
        	PRIMARY KEY("id")
        );
    `);
    _ = check postgresqlDbClient->execute(`DROP TABLE IF EXISTS persist."patients"`);
    _ = check postgresqlDbClient->execute(`
                         CREATE TABLE persist."patients" (
                            "IDP"  SERIAL,
                            "name" VARCHAR(191) NOT NULL,
                            "age" INT NOT NULL,
                            "ADD_RESS" VARCHAR(191) NOT NULL,
                            "phoneNumber" CHAR(10) NOT NULL,
                            "gender" VARCHAR(6) CHECK ("gender" IN ('MALE', 'FEMALE')) NOT NULL,
                            PRIMARY KEY("IDP")
                         );
                      `);

    _ = check postgresqlDbClient->execute(`DROP TABLE IF EXISTS hospital."appointment"`);
    _ = check postgresqlDbClient->execute(`CREATE TABLE hospital."appointment" (
                                           	"id" INT NOT NULL,
                                           	"reason" VARCHAR(191) NOT NULL,
                                           	"appointmentTime" TIMESTAMP NOT NULL,
                                           	"status" VARCHAR(9) CHECK ("status" IN ('SCHEDULED', 'STARTED', 'ENDED')) NOT NULL,
                                           	"patient_id" INT NOT NULL,
                                           	FOREIGN KEY("patient_id") REFERENCES persist."patients"("IDP"),
                                           	"doctorId" INT NOT NULL,
                                           	FOREIGN KEY("doctorId") REFERENCES persist."Doctor"("id"),
                                           	PRIMARY KEY("id")
                                           );`);
    check postgresqlDbClient.close();
}

function initH2TestsWithSchema() returns error? {
    jdbc:Client h2DbClient = check new (url = h2WithSchema.url, user = h2WithSchema.user, password = h2WithSchema.password);
    // create `persist` schema and set it as the default schema
    _ = check h2DbClient->execute(`CREATE SCHEMA persist`);
    _ = check h2DbClient->execute(`CREATE SCHEMA hospital`);
    _ = check h2DbClient->execute(`SET SCHEMA persist`);

    _ = check h2DbClient->execute(`DROP TABLE IF EXISTS "Doctor"`);
    _ = check h2DbClient->execute(`
        CREATE TABLE "Doctor" (
            "id" INT NOT NULL,
            "name" VARCHAR(191) NOT NULL,
            "specialty" VARCHAR(191) NOT NULL,
            "phone_number" VARCHAR(191) NOT NULL,
            "salary" DECIMAL(10,2),
            PRIMARY KEY("id")
        );
    `);

    _ = check h2DbClient->execute(`DROP TABLE IF EXISTS "patients"`);
    _ = check h2DbClient->execute(`
        CREATE TABLE "patients" (
            "IDP" INT AUTO_INCREMENT,
            "name" VARCHAR(191) NOT NULL,
            "age" INT NOT NULL,
            "ADD_RESS" VARCHAR(191) NOT NULL,
            "phoneNumber" CHAR(10) NOT NULL,
            "gender" VARCHAR(6) CHECK ("gender" IN ('MALE', 'FEMALE')) NOT NULL,
            PRIMARY KEY("IDP")
        );
    `);

    _ = check h2DbClient->execute(`DROP TABLE IF EXISTS hospital."appointment"`);
    _ = check h2DbClient->execute(`CREATE TABLE hospital."appointment" (
        "id" INT NOT NULL,
        "reason" VARCHAR(191) NOT NULL,
        "appointmentTime" DATETIME NOT NULL,
        "status" VARCHAR(9) CHECK ("status" IN ('SCHEDULED', 'STARTED', 'ENDED')) NOT NULL,
        "patient_id" INT NOT NULL,
        FOREIGN KEY("patient_id") REFERENCES persist."patients"("IDP"),
        "doctorId" INT NOT NULL,
        FOREIGN KEY("doctorId") REFERENCES persist."Doctor"("id"),
        PRIMARY KEY("id")
    )`);

    check h2DbClient.close();
}
