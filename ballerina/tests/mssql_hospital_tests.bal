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


@test:Config{
  groups: ["annotation", "mssql"]
}
function testCreatePatientMsSql() returns error? {
    MsSqlHospitalClient mssqlDbHospital = check new();
    PatientInsert patient = {
      name: "John Doe",
      age: 30,
      phoneNumber: "0771690000",
      gender: "MALE",
      address: "123, Main Street, Colombo 05"
    };
    _ = check mssqlDbHospital->/patients.post([patient]);
}

@test:Config{
  groups: ["annotation", "mssql"]
}
function testCreateDoctorMsSql() returns error? {
    MsSqlHospitalClient mssqlDbHospital = check new();
    DoctorInsert doctor = {
      id: 1,
      name: "Doctor Mouse",
      specialty: "Physician",
      phoneNumber: "077100100",
      salary: 20000
    };
    _ = check mssqlDbHospital->/doctors.post([doctor]);
}

@test:Config{
  groups: ["annotation", "mssql"],
  dependsOn: [testCreateDoctorMsSql]
}
function testCreateDoctorAlreadyExistsMsSql() returns error? {
    MsSqlHospitalClient mssqlDbHospital = check new();
    DoctorInsert doctor = {
      id: 1,
      name: "Doctor Mouse",
      specialty: "Physician",
      phoneNumber: "077100100",
      salary: 20000.00
    };
    int[]|persist:Error res = mssqlDbHospital->/doctors.post([doctor]);
    if !(res is persist:AlreadyExistsError) {
        test:assertFail("Doctor should not be created");
    }
}

@test:Config{
  groups: ["annotation", "mssql"],
  dependsOn: [testCreatePatientMsSql, testCreateDoctorMsSql]
}
function testCreateAppointmentMsSql() returns error? {
    MsSqlHospitalClient mssqlDbHospital = check new();
    AppointmentInsert appointment = {
      id: 1,
      patientId: 1,
      doctorId: 1,
      appointmentTime: {year: 2023, month: 7, day: 1, hour: 10, minute: 30},
      status: "SCHEDULED",
      reason: "Headache"
    };
    _ = check mssqlDbHospital->/appointments.post([appointment]);
}

@test:Config{
  groups: ["annotation", "mssql"],
  dependsOn: [testCreatePatientMsSql, testCreateDoctorMsSql, testCreateAppointmentMsSql]
}
function testCreateAppointmentAlreadyExistsMsSql() returns error? {
    MsSqlHospitalClient mssqlDbHospital = check new();
    AppointmentInsert appointment = {
      id: 1,
      patientId: 1,
      doctorId: 1,
      appointmentTime: {year: 2023, month: 7, day: 1, hour: 10, minute: 30},
      status: "SCHEDULED",
      reason: "Headache"
    };
    int[]|persist:Error res = mssqlDbHospital->/appointments.post([appointment]);
    if !(res is persist:AlreadyExistsError) {
        test:assertFail("Appointment should not be created");
    }
}

@test:Config{
  groups: ["annotation", "mssql"],
  dependsOn: [testCreateDoctorMsSql]
}
function testGetDoctorsMsSql() returns error? {
    MsSqlHospitalClient mssqlDbHospital = check new();
    stream<Doctor, persist:Error?> doctors = mssqlDbHospital->/doctors.get();
    Doctor[]|persist:Error doctorsArr = from Doctor doctor in doctors select doctor;
    Doctor[] expected = [
      {id: 1, name: "Doctor Mouse", specialty: "Physician", phoneNumber: "077100100", salary: 20000}
    ];
    test:assertEquals(doctorsArr, expected, "Doctor details should be returned");
}

@test:Config{
  groups: ["annotation", "mssql"],
  dependsOn: [testCreatePatientMsSql]
}
function testGetPatientByIdMsSql() returns error? {
    MsSqlHospitalClient mssqlDbHospital = check new();
    Patient|persist:Error patient = mssqlDbHospital->/patients/[1].get();
    Patient expected = {"id":1, "name": "John Doe", "age": 30, "address": "123, Main Street, Colombo 05", "phoneNumber":"0771690000", "gender":"MALE"};
    test:assertEquals(patient, expected, "Patient details should be returned");
}

@test:Config{
  groups: ["annotation", "mssql"]
}
function testGetPatientNotFoundMsSql() returns error? {
    MsSqlHospitalClient mssqlDbHospital = check new();
    Patient|persist:Error patient = mssqlDbHospital->/patients/[10].get();
    if !(patient is persist:NotFoundError) {
        test:assertFail("Patient should be not found");
    }
}

@test:Config{
  groups: ["annotation", "mssql"],
  dependsOn: [testCreateAppointmentMsSql]
}
function testGetAppointmentByDoctorMsSql() returns error? {
    MsSqlHospitalClient mssqlDbHospital = check new();
    stream<AppointmentWithRelations, persist:Error?> appointments = mssqlDbHospital->/appointments();
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

    stream<Appointment, persist:Error?> appointments2 = mssqlDbHospital->/appointments();
    Appointment[]|persist:Error? filteredAppointments2 =  from Appointment appointment in appointments2
            where appointment.doctorId == 5 &&
            appointment.appointmentTime.year == 2023 &&
            appointment.appointmentTime.month == 7 &&
            appointment.appointmentTime.day == 1
            select appointment;
    test:assertEquals(filteredAppointments2, [], "Appointment details should be empty");
}

@test:Config{
  groups: ["annotation", "mssql"],
  dependsOn: [testCreateAppointmentMsSql]
}
function testGetAppointmentByPatientMsSql() returns error? {
    MsSqlHospitalClient mssqlDbHospital = check new();
    stream<AppointmentWithRelations, persist:Error?> appointments = mssqlDbHospital->/appointments();
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
    stream<AppointmentWithRelations, persist:Error?> appointments2 = mssqlDbHospital->/appointments();
    AppointmentWithRelations[]|persist:Error? filteredAppointments2 =  from AppointmentWithRelations appointment in appointments2
            where appointment.patientId == 5
            select appointment;
    test:assertEquals(filteredAppointments2, [], "Appointment details should be empty");
}

@test:Config{
  groups: ["annotation", "mssql"],
  dependsOn: [testCreateAppointmentMsSql, testGetAppointmentByDoctorMsSql, testGetAppointmentByPatientMsSql]
}
function testPatchAppointmentMsSql() returns error? {
    MsSqlHospitalClient mssqlDbHospital = check new();
    Appointment|persist:Error result = mssqlDbHospital->/appointments/[1].put({status: "STARTED"});
    if result is persist:Error {
        test:assertFail("Appointment should be updated");
    }
    stream<AppointmentWithRelations, persist:Error?> appointments = mssqlDbHospital->/appointments();
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
    Appointment|persist:Error result2 = mssqlDbHospital->/appointments/[0].put({status: "STARTED"});
    if !(result2 is persist:NotFoundError) {
        test:assertFail("Appointment should not be found");
    }
}

@test:Config{
  groups: ["annotation", "mssql"],
  dependsOn: [testCreateAppointmentMsSql, testGetAppointmentByDoctorMsSql, testGetAppointmentByPatientMsSql, testPatchAppointmentMsSql]
}
function testDeleteAppointmentByPatientIdMsSql() returns error? {
    MsSqlHospitalClient mssqlDbHospital = check new();
    stream<Appointment, persist:Error?> appointments = mssqlDbHospital->/appointments;
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
        Appointment|persist:Error result2 = mssqlDbHospital->/appointments/[appointment.id].delete();
        if result2 is persist:Error {
            test:assertFail("Appointment should be deleted");
        }
    }
    stream<Appointment, persist:Error?> appointments2 = mssqlDbHospital->/appointments;
    Appointment[]|persist:Error result3 = from Appointment appointment in appointments2
            where appointment.patientId == 1
                && appointment.appointmentTime.year == 2023
                && appointment.appointmentTime.month == 7
                && appointment.appointmentTime.day == 1
            select appointment;
    test:assertEquals(result3, [], "Appointment details should be empty");
}

@test:Config{
  groups: ["annotation", "mssql"],
  dependsOn: [testGetPatientByIdMsSql, testDeleteAppointmentByPatientIdMsSql]
}
function testDeletePatientMsSql() returns error? {
    MsSqlHospitalClient mssqlDbHospital = check new();
    Patient|persist:Error result = mssqlDbHospital->/patients/[1].delete();
    if result is persist:Error {
            test:assertFail("Patient should be deleted");
    }
}

@test:Config{
  groups: ["annotation", "mssql"],
  dependsOn: [testGetDoctorsMsSql, testDeleteAppointmentByPatientIdMsSql],
  enable: true
}
function testDeleteDoctorMsSql() returns error? {
    MsSqlHospitalClient mssqlDbHospital = check new();
    Doctor|persist:Error result = mssqlDbHospital->/doctors/[1].delete();
    if result is persist:Error {
            test:assertFail("Patient should be deleted");
    }
}

@test:Config {
    groups: ["annotation", "mssql"],
    dependsOn: [testDeletePatientMsSql, testDeleteDoctorMsSql]
}
function testPatientWithAppointmentsManyRelationColumnAliasMsSql() returns error? {
    MsSqlHospitalClient mssqlDbHospital = check new ();

    _ = check mssqlDbHospital->/doctors.post([{id: 50, name: "Dr. Alias Test", specialty: "Neurologist", phoneNumber: "0779990000", salary: 25000}]);
    _ = check mssqlDbHospital->/patients.post([{name: "Alias Test Patient", age: 28, phoneNumber: "0779990001", gender: "FEMALE", address: "10, Test St, Colombo 03"}]);
    // MSSQL IDENTITY columns do not return lastInsertId via batchExecute — query to get the generated ID.
    stream<Patient, persist:Error?> pStream = mssqlDbHospital->/patients.get();
    Patient[] pFound = check from Patient p in pStream where p.name == "Alias Test Patient" select p;
    if pFound.length() == 0 {
        check mssqlDbHospital.close();
        return error("Could not find seeded patient 'Alias Test Patient'");
    }
    int patientId = pFound[0].id;
    _ = check mssqlDbHospital->/appointments.post([{id: 50, patientId: patientId, doctorId: 50, appointmentTime: {year: 2024, month: 3, day: 20, hour: 10, minute: 0}, status: "SCHEDULED", reason: "Routine check"}]);

    error? testError = ();
    do {
        // queryOne: PatientWithRelations triggers MANY_TO_ONE secondary SELECT.
        // patient_id column must be aliased to patientId for AppointmentOptionalized mapping to succeed.
        PatientWithRelations patient = check mssqlDbHospital->/patients/[patientId].get();
        AppointmentOptionalized[]? appts = patient.appointments;
        if appts is AppointmentOptionalized[] {
            test:assertEquals(appts.length(), 1);
            test:assertEquals(appts[0].patientId, patientId,
                "patient_id column must be aliased to patientId in MANY_TO_ONE secondary SELECT");
        } else {
            test:assertFail("appointments array should be populated");
        }

        // stream path
        stream<PatientWithRelations, persist:Error?> patientStream = mssqlDbHospital->/patients.get();
        PatientWithRelations[] patients = check from PatientWithRelations p in patientStream
            where p.name == "Alias Test Patient"
            select p;
        if patients.length() != 1 {
            check error("Expected exactly 1 patient named 'Alias Test Patient' in stream path, got " + patients.length().toString());
        }
        AppointmentOptionalized[]? appointments = patients[0].appointments;
        if appointments is () {
            test:assertFail("appointments array should be populated in stream path");
        }
        if appointments.length() != 1 {
            test:assertFail("there should be 1 appointment in stream path");
        }
        test:assertEquals(appointments[0].patientId, patientId,
            "patient_id column must be aliased to patientId in stream path");
    } on fail error e {
        testError = e;
    }

    _ = check mssqlDbHospital->/appointments/[50].delete();
    _ = check mssqlDbHospital->/doctors/[50].delete();
    _ = check mssqlDbHospital->/patients/[patientId].delete();
    check mssqlDbHospital.close();
    return testError;
}

@test:Config {
    groups: ["annotation", "mssql"],
    dependsOn: [testPatientWithAppointmentsManyRelationColumnAliasMsSql]
}
function testDoctorWithAppointmentsManyRelationColumnAliasMsSql() returns error? {
    MsSqlHospitalClient mssqlDbHospital = check new ();

    _ = check mssqlDbHospital->/doctors.post([{id: 50, name: "Dr. Alias Test", specialty: "Neurologist", phoneNumber: "0779990000", salary: 25000}]);
    _ = check mssqlDbHospital->/patients.post([{name: "Alias Test Patient", age: 28, phoneNumber: "0779990001", gender: "FEMALE", address: "10, Test St, Colombo 03"}]);
    stream<Patient, persist:Error?> pStream = mssqlDbHospital->/patients.get();
    Patient[] pFound = check from Patient p in pStream where p.name == "Alias Test Patient" select p;
    if pFound.length() == 0 {
        check mssqlDbHospital.close();
        return error("Could not find seeded patient 'Alias Test Patient'");
    }
    int patientId = pFound[0].id;
    _ = check mssqlDbHospital->/appointments.post([{id: 50, patientId: patientId, doctorId: 50, appointmentTime: {year: 2024, month: 3, day: 20, hour: 10, minute: 0}, status: "SCHEDULED", reason: "Routine check"}]);

    error? testError = ();
    do {
        DoctorWithRelations doctor = check mssqlDbHospital->/doctors/[50].get();
        AppointmentOptionalized[]? appts = doctor.appointments;
        if appts is AppointmentOptionalized[] {
            test:assertEquals(appts.length(), 1);
            test:assertEquals(appts[0].patientId, patientId,
                "patientId should be mapped from patient_id column in doctor's appointment list");
        } else {
            test:assertFail("doctor appointments should be populated");
        }

        stream<DoctorWithRelations, persist:Error?> doctorStream = mssqlDbHospital->/doctors.get();
        DoctorWithRelations[] doctors = check from DoctorWithRelations d in doctorStream
            where d.name == "Dr. Alias Test"
            select d;
        if doctors.length() != 1 {
            check error("Expected exactly 1 doctor named 'Dr. Alias Test' in stream path, got " + doctors.length().toString());
        }
        AppointmentOptionalized[]? appointments = doctors[0].appointments;
        if appointments is () {
            test:assertFail("appointments should be populated in stream path");
        }
        if appointments.length() != 1 {
            test:assertFail("there should be 1 appointment in stream path");
        }
        test:assertEquals(appointments[0].patientId, patientId,
            "patientId should be correctly mapped in doctor stream path");
    } on fail error e {
        testError = e;
    }

    _ = check mssqlDbHospital->/appointments/[50].delete();
    _ = check mssqlDbHospital->/doctors/[50].delete();
    _ = check mssqlDbHospital->/patients/[patientId].delete();
    check mssqlDbHospital.close();
    return testError;
}
