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

import ballerina/persist;
import ballerina/test;


@test:Config {
    groups: ["annotation", "postgresql"]
}
function testCreatePatientPostgreSql() returns error? {
    PostgreSqlHospitalClient postgreSqlDbHospital = check new();
    PatientInsert patient = {
      name: "John Doe",
      age: 30,
      phoneNumber: "0771690000",
      gender: "MALE",
      address: "123, Main Street, Colombo 05"
    };
    _ = check postgreSqlDbHospital->/patients.post([patient]);
}

@test:Config {
    groups: ["annotation", "postgresql"]
}
function testCreateDoctorPostgreSql() returns error? {
    PostgreSqlHospitalClient postgresSqlDbHospital = check new();
    DoctorInsert doctor = {
      id: 1,
      name: "Doctor Mouse",
      specialty: "Physician",
      phoneNumber: "077100100",
      salary: 20000
    };
    _ = check postgresSqlDbHospital->/doctors.post([doctor]);
}

@test:Config {
    groups: ["annotation", "postgresql"],
    dependsOn: [testCreateDoctorPostgreSql]
}
function testCreateDoctorAlreadyExistsPostgreSql() returns error? {
    PostgreSqlHospitalClient postgresSqlDbHospital = check new();
    DoctorInsert doctor = {
      id: 1,
      name: "Doctor Mouse",
      specialty: "Physician",
      phoneNumber: "077100100",
      salary: 20000.00
    };
    int[]|persist:Error res = postgresSqlDbHospital->/doctors.post([doctor]);
    if !(res is persist:AlreadyExistsError) {
        test:assertFail("Doctor should not be created");
    }
}

@test:Config {
    groups: ["annotation", "postgresql"],
    dependsOn: [testCreatePatientPostgreSql, testCreateDoctorPostgreSql]
}
function testCreateAppointmentPostgreSql() returns error? {
    PostgreSqlHospitalClient postgresSqlDbHospital = check new();
    AppointmentInsert appointment = {
      id: 1,
      patientId: 1,
      doctorId: 1,
      appointmentTime: {year: 2023, month: 7, day: 1, hour: 10, minute: 30},
      status: "SCHEDULED",
      reason: "Headache"
    };
    _ = check postgresSqlDbHospital->/appointments.post([appointment]);
}

@test:Config {
    groups: ["annotation", "postgresql"],
    dependsOn: [testCreatePatientPostgreSql, testCreateDoctorPostgreSql, testCreateAppointmentPostgreSql]
}
function testCreateAppointmentAlreadyExistsPostgreSql() returns error? {
    PostgreSqlHospitalClient postgresSqlDbHospital = check new();
    AppointmentInsert appointment = {
      id: 1,
      patientId: 1,
      doctorId: 1,
      appointmentTime: {year: 2023, month: 7, day: 1, hour: 10, minute: 30},
      status: "SCHEDULED",
      reason: "Headache"
    };
    int[]|persist:Error res = postgresSqlDbHospital->/appointments.post([appointment]);
    if !(res is persist:AlreadyExistsError) {
        test:assertFail("Appointment should not be created");
    }
}

@test:Config {
    groups: ["annotation", "postgresql"],
    dependsOn: [testCreateDoctorPostgreSql]
}
function testGetDoctorsPostgreSql() returns error? {
    PostgreSqlHospitalClient postgresSqlDbHospital = check new();
    stream<Doctor, persist:Error?> doctors = postgresSqlDbHospital->/doctors.get();
    Doctor[]|persist:Error doctorsArr = from Doctor doctor in doctors select doctor;
    Doctor[] expected = [
      {id: 1, name: "Doctor Mouse", specialty: "Physician", phoneNumber: "077100100", salary: 20000}
    ];
    test:assertEquals(doctorsArr, expected, "Doctor details should be returned");
}

@test:Config {
    groups: ["annotation", "postgresql"],
    dependsOn: [testCreatePatientPostgreSql]
}
function testGetPatientByIdPostgreSql() returns error? {
    PostgreSqlHospitalClient postgresSqlDbHospital = check new();
    Patient|persist:Error patient = postgresSqlDbHospital->/patients/[1].get();
    Patient expected = {"id":1, "name": "John Doe", "age": 30, "address": "123, Main Street, Colombo 05", "phoneNumber":"0771690000", "gender":"MALE"};
    test:assertEquals(patient, expected, "Patient details should be returned");
}

@test:Config {
    groups: ["annotation", "postgresql"]
}
function testGetPatientNotFoundPostgreSql() returns error? {
    PostgreSqlHospitalClient postgresSqlDbHospital = check new();
    Patient|persist:Error patient = postgresSqlDbHospital->/patients/[10].get();
    if !(patient is persist:NotFoundError) {
        test:assertFail("Patient should be not found");
    }
}

@test:Config {
    groups: ["annotation", "postgresql"],
    dependsOn: [testCreateAppointmentPostgreSql]
}
function testGetAppointmentByDoctorPostgreSql() returns error? {
    PostgreSqlHospitalClient postgresSqlDbHospital = check new();
    stream<AppointmentWithRelations, persist:Error?> appointments = postgresSqlDbHospital->/appointments();
    AppointmentWithRelations[]|persist:Error? filteredAppointments =  from AppointmentWithRelations appointment in appointments
            where appointment.doctorId == 1 &&
            appointment.appointmentTime?.year == 2023 &&
            appointment.appointmentTime?.month == 7 &&
            appointment.appointmentTime?.day == 1
            select appointment;
    AppointmentWithRelations[] expected = [
      {
        "id": 1,
        "doctorId": 1,
        "patientId": 1,
        "reason": "Headache",
        "appointmentTime": {
          "year": 2023,
          "month": 7,
          "day": 1,
          "hour": 10,
          "minute": 30,
          "second": 0
        },
        "status": "SCHEDULED",
        "patient": {
          "id": 1,
          "name": "John Doe",
          "age": 30,
          "address": "123, Main Street, Colombo 05",
          "phoneNumber": "0771690000",
          "gender": "MALE"
        },
        "doctor": {
          "id": 1,
          "name": "Doctor Mouse",
          "specialty": "Physician",
          "phoneNumber": "077100100",
          "salary": 20000
        }
      }
    ];
    test:assertEquals(filteredAppointments, expected, "Appointment details should be returned");

    stream<Appointment, persist:Error?> appointments2 = postgresSqlDbHospital->/appointments();
    Appointment[]|persist:Error? filteredAppointments2 =  from Appointment appointment in appointments2
            where appointment.doctorId == 5 &&
            appointment.appointmentTime.year == 2023 &&
            appointment.appointmentTime.month == 7 &&
            appointment.appointmentTime.day == 1
            select appointment;
    test:assertEquals(filteredAppointments2, [], "Appointment details should be empty");
}

@test:Config {
    groups: ["annotation", "postgresql"],
    dependsOn: [testCreateAppointmentPostgreSql]
}
function testGetAppointmentByPatientPostgreSql() returns error? {
    PostgreSqlHospitalClient postgresSqlDbHospital = check new();
    stream<AppointmentWithRelations, persist:Error?> appointments = postgresSqlDbHospital->/appointments();
    AppointmentWithRelations[]|persist:Error? filteredAppointments =  from AppointmentWithRelations appointment in appointments
            where appointment.patientId == 1
            select appointment;
    AppointmentWithRelations[] expected = [
      {
        "id": 1,
        "doctorId": 1,
        "patientId": 1,
        "reason": "Headache",
        "appointmentTime": {
          "year": 2023,
          "month": 7,
          "day": 1,
          "hour": 10,
          "minute": 30,
          "second": 0
        },
        "status": "SCHEDULED",
        "patient": {
          "id": 1,
          "name": "John Doe",
          "age": 30,
          "address": "123, Main Street, Colombo 05",
          "phoneNumber": "0771690000",
          "gender": "MALE"
        },
        "doctor": {
          "id": 1,
          "name": "Doctor Mouse",
          "specialty": "Physician",
          "phoneNumber": "077100100",
          "salary": 20000
        }
      }
    ];        
    test:assertEquals(filteredAppointments, expected, "Appointment details should be returned");
    stream<AppointmentWithRelations, persist:Error?> appointments2 = postgresSqlDbHospital->/appointments();
    AppointmentWithRelations[]|persist:Error? filteredAppointments2 =  from AppointmentWithRelations appointment in appointments2
            where appointment.patientId == 5
            select appointment;
    test:assertEquals(filteredAppointments2, [], "Appointment details should be empty");
}

@test:Config {
    groups: ["annotation", "postgresql"],
    dependsOn: [testCreateAppointmentPostgreSql, testGetAppointmentByDoctorPostgreSql, testGetAppointmentByPatientPostgreSql]
}
function testPatchAppointmentPostgreSql() returns error? {
    PostgreSqlHospitalClient postgresSqlDbHospital = check new();
    Appointment|persist:Error result = postgresSqlDbHospital->/appointments/[1].put({status: "STARTED"});
    if result is persist:Error {
        test:assertFail("Appointment should be updated");
    }
    stream<AppointmentWithRelations, persist:Error?> appointments = postgresSqlDbHospital->/appointments();
    AppointmentWithRelations[]|persist:Error? filteredAppointments =  from AppointmentWithRelations appointment in appointments
            where appointment.patientId == 1
            select appointment;
    AppointmentWithRelations[] expected = [
      {
        "id": 1,
        "doctorId": 1,
        "patientId": 1,
        "reason": "Headache",
        "appointmentTime": {
          "year": 2023,
          "month": 7,
          "day": 1,
          "hour": 10,
          "minute": 30,
          "second": 0
        },
        "status": "STARTED",
        "patient": {
          "id": 1,
          "name": "John Doe",
          "age": 30,
          "address": "123, Main Street, Colombo 05",
          "phoneNumber": "0771690000",
          "gender": "MALE"
        },
        "doctor": {
          "id": 1,
          "name": "Doctor Mouse",
          "specialty": "Physician",
          "phoneNumber": "077100100",
          "salary": 20000
        }
      }
    ];        
    test:assertEquals(filteredAppointments, expected, "Appointment details should be updated");
    Appointment|persist:Error result2 = postgresSqlDbHospital->/appointments/[0].put({status: "STARTED"});
    if !(result2 is persist:NotFoundError) {
        test:assertFail("Appointment should not be found");
    }
}

@test:Config {
    groups: ["annotation", "postgresql"],
    dependsOn: [testCreateAppointmentPostgreSql, testGetAppointmentByDoctorPostgreSql, testGetAppointmentByPatientPostgreSql, testPatchAppointmentPostgreSql]
}
function testDeleteAppointmentByPatientIdPostgreSql() returns error? {
    PostgreSqlHospitalClient postgresSqlDbHospital = check new();
    stream<Appointment, persist:Error?> appointments = postgresSqlDbHospital->/appointments;
    Appointment[]|persist:Error result = from Appointment appointment in appointments
            where appointment.patientId == 1
                && appointment.appointmentTime.year == 2023
                && appointment.appointmentTime.month == 7
                && appointment.appointmentTime.day == 1
            select appointment;
    if (result is persist:Error) {
        test:assertFail("Appointment should be found");
    }
    foreach Appointment appointment in result {
        Appointment|persist:Error result2 = postgresSqlDbHospital->/appointments/[appointment.id].delete();
        if result2 is persist:Error {
            test:assertFail("Appointment should be deleted");
        }
    }
    stream<Appointment, persist:Error?> appointments2 = postgresSqlDbHospital->/appointments;
    Appointment[]|persist:Error result3 = from Appointment appointment in appointments2
            where appointment.patientId == 1
                && appointment.appointmentTime.year == 2023
                && appointment.appointmentTime.month == 7
                && appointment.appointmentTime.day == 1
            select appointment;
    test:assertEquals(result3, [], "Appointment details should be empty");
}

@test:Config {
    groups: ["annotation", "postgresql"],
    dependsOn: [testGetPatientByIdPostgreSql, testDeleteAppointmentByPatientIdPostgreSql]
}
function testDeletePatientPostgreSql() returns error? {
    PostgreSqlHospitalClient postgresSqlDbHospital = check new();
    Patient|persist:Error result = postgresSqlDbHospital->/patients/[1].delete();
    if result is persist:Error {
            test:assertFail("Patient should be deleted");
    }
}

@test:Config {
    groups: ["annotation", "postgresql"],
    dependsOn: [testGetDoctorsPostgreSql, testDeleteAppointmentByPatientIdPostgreSql]
}
function testDeleteDoctorPostgreSql() returns error? {
    PostgreSqlHospitalClient postgresSqlDbHospital = check new();
    Doctor|persist:Error result = postgresSqlDbHospital->/doctors/[1].delete();
    if result is persist:Error {
            test:assertFail("Patient should be deleted");
    }
}

@test:Config {
    groups: ["annotation", "postgresql"],
    dependsOn: [testDeletePatientPostgreSql, testDeleteDoctorPostgreSql]
}
function testPatientWithAppointmentsManyRelationColumnAliasPostgreSql() returns error? {
    PostgreSqlHospitalClient postgresSqlDbHospital = check new ();

    _ = check postgresSqlDbHospital->/doctors.post([{id: 50, name: "Dr. Alias Test", specialty: "Neurologist", phoneNumber: "0779990000", salary: 25000}]);
    _ = check postgresSqlDbHospital->/patients.post([{name: "Alias Test Patient", age: 28, phoneNumber: "0779990001", gender: "FEMALE", address: "10, Test St, Colombo 03"}]);
    // PostgreSQL sequences may not return lastInsertId via batchExecute — query to get the generated ID.
    stream<Patient, persist:Error?> pStream = postgresSqlDbHospital->/patients.get();
    Patient[] pFound = check from Patient p in pStream where p.name == "Alias Test Patient" select p;
    int patientId = pFound[0].id;
    _ = check postgresSqlDbHospital->/appointments.post([{id: 50, patientId: patientId, doctorId: 50, appointmentTime: {year: 2024, month: 3, day: 20, hour: 10, minute: 0}, status: "SCHEDULED", reason: "Routine check"}]);

    // queryOne: PatientWithRelations triggers MANY_TO_ONE secondary SELECT.
    // patient_id column must be aliased to patientId for AppointmentOptionalized mapping to succeed.
    PatientWithRelations patient = check postgresSqlDbHospital->/patients/[patientId].get();
    AppointmentOptionalized[]? appts = patient.appointments;
    test:assertTrue(appts is AppointmentOptionalized[], "appointments array should be populated");
    test:assertEquals((<AppointmentOptionalized[]>appts).length(), 1);
    test:assertEquals((<AppointmentOptionalized[]>appts)[0].patientId, patientId,
        "patient_id column must be aliased to patientId in MANY_TO_ONE secondary SELECT");

    // stream path
    stream<PatientWithRelations, persist:Error?> patientStream = postgresSqlDbHospital->/patients.get();
    PatientWithRelations[] patients = check from PatientWithRelations p in patientStream
        where p.name == "Alias Test Patient"
        select p;
    AppointmentOptionalized[]? apptsFromStream = patients[0].appointments;
    if apptsFromStream is () {
        test:assertFail("appointments array should be populated in stream path");
    }
    if apptsFromStream.length() != 1 {
        test:assertFail("there should be 1 appointment in stream path");
    }
    test:assertEquals(apptsFromStream[0].patientId, patientId,
        "patient_id column must be aliased to patientId in stream path");

    check postgresSqlDbHospital.close();
}

@test:Config {
    groups: ["annotation", "postgresql"],
    dependsOn: [testPatientWithAppointmentsManyRelationColumnAliasPostgreSql]
}
function testDoctorWithAppointmentsManyRelationColumnAliasPostgreSql() returns error? {
    PostgreSqlHospitalClient postgresSqlDbHospital = check new ();

    DoctorWithRelations doctor = check postgresSqlDbHospital->/doctors/[50].get();
    AppointmentOptionalized[]? appts = doctor.appointments;
    test:assertTrue(appts is AppointmentOptionalized[], "doctor appointments should be populated");
    test:assertEquals((<AppointmentOptionalized[]>appts).length(), 1);
    test:assertNotEquals((<AppointmentOptionalized[]>appts)[0].patientId, (),
        "patientId should be mapped from patient_id column in doctor's appointment list");

    stream<DoctorWithRelations, persist:Error?> doctorStream = postgresSqlDbHospital->/doctors.get();
    DoctorWithRelations[] doctors = check from DoctorWithRelations d in doctorStream
        where d.name == "Dr. Alias Test"
        select d;
    test:assertEquals(doctors.length(), 1);
    AppointmentOptionalized[]? appointments = doctors[0].appointments;
    if appointments is () {
        test:assertFail("appointments should be populated in stream path");
    }
    if appointments.length() != 1 {
        test:assertFail("there should be 1 appointment in stream path");
    }
    test:assertNotEquals(appointments[0].patientId, (),
        "patientId should be correctly mapped in doctor stream path");

    _ = check postgresSqlDbHospital->/appointments/[50].delete();
    _ = check postgresSqlDbHospital->/doctors/[50].delete();
    stream<Patient, persist:Error?> patientStream = postgresSqlDbHospital->/patients.get();
    Patient[] patients = check from Patient p in patientStream
        where p.name == "Alias Test Patient"
        select p;
    foreach Patient p in patients {
        _ = check postgresSqlDbHospital->/patients/[p.id].delete();
    }
    check postgresSqlDbHospital.close();
}
