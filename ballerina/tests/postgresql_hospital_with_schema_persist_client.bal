// Copyright (c) 2024 WSO2 LLC. (http://www.wso2.com).
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

// AUTO-GENERATED FILE. DO NOT MODIFY.
// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.
import ballerina/jballerina.java;
import ballerina/persist;
import ballerina/sql;
import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;

const APPOINTMENT = "appointments";
const PATIENT = "patients";
const DOCTOR = "doctors";

public isolated client class PostgreSqlHospitalWithSchemaClient {
    *persist:AbstractPersistClient;

    private final postgresql:Client dbClient;

    private final map<SQLClient> persistClients;

    private final record {|SQLMetadata...;|} metadata = {
        [APPOINTMENT]: {
            entityName: "Appointment",
            tableName: "appointment",
            schemaName: "hospital",
            fieldMetadata: {
                id: {columnName: "id"},
                reason: {columnName: "reason"},
                appointmentTime: {columnName: "appointmentTime"},
                status: {columnName: "status"},
                patientId: {columnName: "patient_id"},
                doctorId: {columnName: "doctorId"},
                "patient.id": {relation: {entityName: "patient", refField: "id", refColumn: "IDP"}},
                "patient.name": {relation: {entityName: "patient", refField: "name"}},
                "patient.age": {relation: {entityName: "patient", refField: "age"}},
                "patient.address": {relation: {entityName: "patient", refField: "address", refColumn: "ADD_RESS"}},
                "patient.phoneNumber": {relation: {entityName: "patient", refField: "phoneNumber"}},
                "patient.gender": {relation: {entityName: "patient", refField: "gender"}},
                "doctor.id": {relation: {entityName: "doctor", refField: "id"}},
                "doctor.name": {relation: {entityName: "doctor", refField: "name"}},
                "doctor.specialty": {relation: {entityName: "doctor", refField: "specialty"}},
                "doctor.phoneNumber": {relation: {entityName: "doctor", refField: "phoneNumber", refColumn: "phone_number"}},
                "doctor.salary": {relation: {entityName: "doctor", refField: "salary"}}
            },
            keyFields: ["id"],
            joinMetadata: {
                patient: {entity: Patient, fieldName: "patient", refTable: "patients", refColumns: ["IDP"], joinColumns: ["patient_id"], 'type: ONE_TO_MANY},
                doctor: {entity: Doctor, fieldName: "doctor", refTable: "Doctor", refColumns: ["id"], joinColumns: ["doctorId"], 'type: ONE_TO_MANY}
            }
        },
        [PATIENT]: {
            entityName: "Patient",
            tableName: "patients",
            fieldMetadata: {
                id: {columnName: "IDP", dbGenerated: true},
                name: {columnName: "name"},
                age: {columnName: "age"},
                address: {columnName: "ADD_RESS"},
                phoneNumber: {columnName: "phoneNumber"},
                gender: {columnName: "gender"},
                "appointments[].id": {relation: {entityName: "appointments", refField: "id"}},
                "appointments[].reason": {relation: {entityName: "appointments", refField: "reason"}},
                "appointments[].appointmentTime": {relation: {entityName: "appointments", refField: "appointmentTime"}},
                "appointments[].status": {relation: {entityName: "appointments", refField: "status"}},
                "appointments[].patientId": {relation: {entityName: "appointments", refField: "patientId", refColumn: "patient_id"}},
                "appointments[].doctorId": {relation: {entityName: "appointments", refField: "doctorId"}}
            },
            keyFields: ["id"],
            joinMetadata: {appointments: {entity: Appointment, fieldName: "appointments", refTable: "appointment", refSchema: "hospital", refColumns: ["patient_id"], joinColumns: ["IDP"], 'type: MANY_TO_ONE}}
        },
        [DOCTOR]: {
            entityName: "Doctor",
            tableName: "Doctor",
            fieldMetadata: {
                id: {columnName: "id"},
                name: {columnName: "name"},
                specialty: {columnName: "specialty"},
                phoneNumber: {columnName: "phone_number"},
                salary: {columnName: "salary"},
                "appointments[].id": {relation: {entityName: "appointments", refField: "id"}},
                "appointments[].reason": {relation: {entityName: "appointments", refField: "reason"}},
                "appointments[].appointmentTime": {relation: {entityName: "appointments", refField: "appointmentTime"}},
                "appointments[].status": {relation: {entityName: "appointments", refField: "status"}},
                "appointments[].patientId": {relation: {entityName: "appointments", refField: "patientId", refColumn: "patient_id"}},
                "appointments[].doctorId": {relation: {entityName: "appointments", refField: "doctorId"}}
            },
            keyFields: ["id"],
            joinMetadata: {appointments: {entity: Appointment, fieldName: "appointments", refTable: "appointment", refSchema: "hospital", refColumns: ["doctorId"], joinColumns: ["id"], 'type: MANY_TO_ONE}}
        }
    };

    public isolated function init() returns persist:Error? {
        postgresql:Client|error dbClient = new (host = postgresqlWithSchema.host, username = postgresqlWithSchema.user, password = postgresqlWithSchema.password, database = postgresqlWithSchema.database, port = postgresqlWithSchema.port);
        if dbClient is error {
            return <persist:Error>error(dbClient.message());
        }
        self.dbClient = dbClient;
        // Update the metadata with the schema name
        if postgresqlWithSchema.defaultSchema != () {
            lock {
                foreach string key in self.metadata.keys() {
                    SQLMetadata metadata = self.metadata.get(key);
                    if metadata.schemaName == () {
                        metadata.schemaName = mssqlWithSchema.defaultSchema;
                    }
                    map<JoinMetadata>? joinMetadataMap = metadata.joinMetadata;
                    if joinMetadataMap == () {
                        continue;
                    }
                    foreach [string, JoinMetadata][_, joinMetadata] in joinMetadataMap.entries() {
                        if joinMetadata.refSchema == () {
                            joinMetadata.refSchema = mssqlWithSchema.defaultSchema;
                        }
                    }
                }
            }
        }

        self.persistClients = {
            [APPOINTMENT]: check new (dbClient, self.metadata.get(APPOINTMENT).cloneReadOnly(), POSTGRESQL_SPECIFICS),
            [PATIENT]: check new (dbClient, self.metadata.get(PATIENT).cloneReadOnly(), POSTGRESQL_SPECIFICS),
            [DOCTOR]: check new (dbClient, self.metadata.get(DOCTOR).cloneReadOnly(), POSTGRESQL_SPECIFICS)
        };
    }

    isolated resource function get appointments(AppointmentTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "query"
    } external;

    isolated resource function get appointments/[int id](AppointmentTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post appointments(AppointmentInsert[] data) returns int[]|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(APPOINTMENT);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from AppointmentInsert inserted in data
            select inserted.id;
    }

    isolated resource function put appointments/[int id](AppointmentUpdate value) returns Appointment|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(APPOINTMENT);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        return self->/appointments/[id].get();
    }

    isolated resource function delete appointments/[int id]() returns Appointment|persist:Error {
        Appointment result = check self->/appointments/[id].get();
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(APPOINTMENT);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    isolated resource function get patients(PatientTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "query"
    } external;

    isolated resource function get patients/[int id](PatientTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post patients(PatientInsert[] data) returns int[]|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(PATIENT);
        }
        sql:ExecutionResult[] result = check sqlClient.runBatchInsertQuery(data);
        return from sql:ExecutionResult inserted in result
            where inserted.lastInsertId != ()
            select <int>inserted.lastInsertId;
    }

    isolated resource function put patients/[int id](PatientUpdate value) returns Patient|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(PATIENT);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        return self->/patients/[id].get();
    }

    isolated resource function delete patients/[int id]() returns Patient|persist:Error {
        Patient result = check self->/patients/[id].get();
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(PATIENT);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    isolated resource function get doctors(DoctorTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "query"
    } external;

    isolated resource function get doctors/[int id](DoctorTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post doctors(DoctorInsert[] data) returns int[]|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(DOCTOR);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from DoctorInsert inserted in data
            select inserted.id;
    }

    isolated resource function put doctors/[int id](DoctorUpdate value) returns Doctor|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(DOCTOR);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        return self->/doctors/[id].get();
    }

    isolated resource function delete doctors/[int id]() returns Doctor|persist:Error {
        Doctor result = check self->/doctors/[id].get();
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(DOCTOR);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    remote isolated function queryNativeSQL(sql:ParameterizedQuery sqlQuery, typedesc<record {}> rowType = <>) returns stream<rowType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor"
    } external;

    remote isolated function executeNativeSQL(sql:ParameterizedQuery sqlQuery) returns ExecutionResult|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor"
    } external;

    public isolated function close() returns persist:Error? {
        error? result = self.dbClient.close();
        if result is error {
            return <persist:Error>error(result.message());
        }
        return result;
    }
}

