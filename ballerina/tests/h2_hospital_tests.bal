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

import ballerina/log;
import ballerina/persist;
import ballerina/test;

@test:Config {
    groups: ["annotation", "h2"]
}
function testCreatePatientH2() returns error? {
    H2HospitalClient h2DbHospital = check new ();
    PatientInsert patient = {
        name: "John Doe",
        age: 30,
        phoneNumber: "0771690000",
        gender: "MALE",
        address: "123, Main Street, Colombo 05"
    };
    int[] unionResult = check h2DbHospital->/patients.post([patient]);
    test:assertEquals(unionResult[0], 1, "Patient should be created");
}

@test:Config {
    groups: ["annotation", "h2"]
}
function testCreateDoctorH2() returns error? {
    H2HospitalClient h2DbHospital = check new ();
    DoctorInsert doctor = {
        id: 1,
        name: "Doctor Mouse",
        specialty: "Physician",
        phoneNumber: "077100100",
        salary: 20000
    };
    int[] res = check h2DbHospital->/doctors.post([doctor]);
    test:assertEquals(res[0], 1, "Doctor should be created");
}

@test:Config {
    groups: ["annotation", "h2"],
    dependsOn: [testCreateDoctorH2]
}
function testCreateDoctorAlreadyExistsH2() returns error? {
    H2HospitalClient h2DbHospital = check new ();
    DoctorInsert doctor = {
        id: 1,
        name: "Doctor Mouse",
        specialty: "Physician",
        phoneNumber: "077100100",
        salary: 20000.00
    };
    int[]|persist:Error res = h2DbHospital->/doctors.post([doctor]);
    if !(res is persist:AlreadyExistsError) {
        test:assertFail("Doctor should not be created");
    }
}

@test:Config {
    groups: ["annotation", "h2"],
    dependsOn: [testCreatePatientH2, testCreateDoctorH2]
}
function testCreateAppointmentH2() returns error? {
    H2HospitalClient h2DbHospital = check new ();
    AppointmentInsert appointment = {
        id: 1,
        patientId: 1,
        doctorId: 1,
        appointmentTime: {year: 2023, month: 7, day: 1, hour: 10, minute: 30},
        status: "SCHEDULED",
        reason: "Headache"
    };
    int[] res = check h2DbHospital->/appointments.post([appointment]);
    test:assertEquals(res[0], 1, "Appointment should be created");
}

@test:Config {
    groups: ["annotation", "h2"],
    dependsOn: [testCreatePatientH2, testCreateDoctorH2, testCreateAppointmentH2]
}
function testCreateAppointmentAlreadyExistsH2() returns error? {
    H2HospitalClient h2DbHospital = check new ();
    AppointmentInsert appointment = {
        id: 1,
        patientId: 1,
        doctorId: 1,
        appointmentTime: {year: 2023, month: 7, day: 1, hour: 10, minute: 30},
        status: "SCHEDULED",
        reason: "Headache"
    };
    int[]|persist:Error res = h2DbHospital->/appointments.post([appointment]);
    if !(res is persist:AlreadyExistsError) {
        test:assertFail("Appointment should not be created");
    }
}

@test:Config {
    groups: ["annotation", "h2"],
    dependsOn: [testCreateDoctorH2]
}
function testGetDoctorsH2() returns error? {
    H2HospitalClient h2DbHospital = check new ();
    stream<Doctor, persist:Error?> doctors = h2DbHospital->/doctors.get();
    Doctor[]|persist:Error doctorsArr = from Doctor doctor in doctors
        select doctor;
    Doctor[] expected = [
        {id: 1, name: "Doctor Mouse", specialty: "Physician", phoneNumber: "077100100", salary: 20000}
    ];
    test:assertEquals(doctorsArr, expected, "Doctor details should be returned");
}

@test:Config {
    groups: ["annotation", "h2"],
    dependsOn: [testCreatePatientH2]
}
function testGetPatientByIdH2() returns error? {
    H2HospitalClient h2DbHospital = check new ();
    Patient|persist:Error patient = h2DbHospital->/patients/[1].get();
    Patient expected = {"id": 1, "name": "John Doe", "age": 30, "address": "123, Main Street, Colombo 05", "phoneNumber": "0771690000", "gender": "MALE"};
    test:assertEquals(patient, expected, "Patient details should be returned");
}

@test:Config {
    groups: ["annotation", "h2"]
}
function testGetPatientNotFoundH2() returns error? {
    H2HospitalClient h2DbHospital = check new ();
    Patient|persist:Error patient = h2DbHospital->/patients/[10].get();
    if !(patient is persist:NotFoundError) {
        test:assertFail("Patient should be not found");
    }
}

@test:Config {
    groups: ["annotation", "h2"],
    dependsOn: [testCreateAppointmentH2]
}
function testGetAppointmentByDoctorH2() returns error? {
    H2HospitalClient h2DbHospital = check new ();
    stream<AppointmentWithRelations, persist:Error?> appointments = h2DbHospital->/appointments();
    AppointmentWithRelations[]|persist:Error? filteredAppointments = from AppointmentWithRelations appointment in appointments
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

    stream<Appointment, persist:Error?> appointments2 = h2DbHospital->/appointments();
    Appointment[]|persist:Error? filteredAppointments2 = from Appointment appointment in appointments2
        where appointment.doctorId == 5 &&
            appointment.appointmentTime.year == 2023 &&
            appointment.appointmentTime.month == 7 &&
            appointment.appointmentTime.day == 1
        select appointment;
    test:assertEquals(filteredAppointments2, [], "Appointment details should be empty");
}

@test:Config {
    groups: ["annotation", "h2"],
    dependsOn: [testCreateAppointmentH2]
}
function testGetAppointmentByPatientH2() returns error? {
    H2HospitalClient h2DbHospital = check new ();
    stream<AppointmentWithRelations, persist:Error?> appointments = h2DbHospital->/appointments();
    AppointmentWithRelations[]|persist:Error? filteredAppointments = from AppointmentWithRelations appointment in appointments
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
    stream<AppointmentWithRelations, persist:Error?> appointments2 = h2DbHospital->/appointments();
    AppointmentWithRelations[]|persist:Error? filteredAppointments2 = from AppointmentWithRelations appointment in appointments2
        where appointment.patientId == 5
        select appointment;
    test:assertEquals(filteredAppointments2, [], "Appointment details should be empty");
}

@test:Config {
    groups: ["annotation", "h2"],
    dependsOn: [testCreateAppointmentH2, testGetAppointmentByDoctorH2, testGetAppointmentByPatientH2]
}
function testPatchAppointmentH2() returns error? {
    H2HospitalClient h2DbHospital = check new ();
    Appointment|persist:Error result = h2DbHospital->/appointments/[1].put({status: "STARTED"});
    if result is persist:Error {
        test:assertFail("Appointment should be updated");
    }
    stream<AppointmentWithRelations, persist:Error?> appointments = h2DbHospital->/appointments();
    AppointmentWithRelations[]|persist:Error? filteredAppointments = from AppointmentWithRelations appointment in appointments
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
    Appointment|persist:Error result2 = h2DbHospital->/appointments/[0].put({status: "STARTED"});
    if !(result2 is persist:NotFoundError) {
        test:assertFail("Appointment should not be found");
    }
}

@test:Config {
    groups: ["annotation", "h2"],
    dependsOn: [testCreateAppointmentH2, testGetAppointmentByDoctorH2, testGetAppointmentByPatientH2, testPatchAppointmentH2]
}
function testDeleteAppointmentByPatientIdH2() returns error? {
    H2HospitalClient h2DbHospital = check new ();
    stream<Appointment, persist:Error?> appointments = h2DbHospital->/appointments;
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
        Appointment|persist:Error result2 = h2DbHospital->/appointments/[appointment.id].delete();
        if result2 is persist:Error {
            test:assertFail("Appointment should be deleted");
        }
    }
    stream<Appointment, persist:Error?> appointments2 = h2DbHospital->/appointments;
    Appointment[]|persist:Error result3 = from Appointment appointment in appointments2
        where appointment.patientId == 1
                && appointment.appointmentTime.year == 2023
                && appointment.appointmentTime.month == 7
                && appointment.appointmentTime.day == 1
        select appointment;
    test:assertEquals(result3, [], "Appointment details should be empty");
}

@test:Config {
    groups: ["annotation", "h2"],
    dependsOn: [testGetPatientByIdH2, testDeleteAppointmentByPatientIdH2]
}
function testDeletePatientH2() returns error? {
    H2HospitalClient h2DbHospital = check new ();
    Patient|persist:Error result = h2DbHospital->/patients/[1].delete();
    if result is persist:Error {
        log:printError("Error: ", result);
        test:assertFail("Patient should be deleted");
    }
}

@test:Config {
    groups: ["annotation", "h2"],
    dependsOn: [testGetDoctorsH2, testDeleteAppointmentByPatientIdH2]
}
function testDeleteDoctorH2() returns error? {
    H2HospitalClient h2DbHospital = check new ();
    Doctor|persist:Error result = h2DbHospital->/doctors/[1].delete();
    if result is persist:Error {
        log:printError("Error: ", result);
        test:assertFail("Patient should be deleted");
    }
}

// Regression tests for: MANY_TO_ONE secondary SELECT with snake_case columns (refColumn != refField).
// The appointment table uses patient_id (SQL column) which maps to patientId (Ballerina field).
// Without the fix in getManyRelationColumnNames, this caused:
//   "No mapping field found for SQL table column 'patient_id' in the record type 'AppointmentOptionalized'"

@test:Config {
    groups: ["annotation", "h2"],
    dependsOn: [testDeletePatientH2, testDeleteDoctorH2]
}
function testPatientWithAppointmentsManyRelationColumnAliasH2() returns error? {
    H2HospitalClient h2DbHospital = check new ();

    _ = check h2DbHospital->/doctors.post([{id: 50, name: "Dr. Alias Test", specialty: "Neurologist", phoneNumber: "0779990000", salary: 25000}]);
    int[] patientIds = check h2DbHospital->/patients.post([{name: "Alias Test Patient", age: 28, phoneNumber: "0779990001", gender: "FEMALE", address: "10, Test St, Colombo 03"}]);
    int patientId = patientIds[0];
    _ = check h2DbHospital->/appointments.post([{id: 50, patientId: patientId, doctorId: 50, appointmentTime: {year: 2024, month: 3, day: 20, hour: 10, minute: 0}, status: "SCHEDULED", reason: "Routine check"}]);

    // queryOne path: PatientWithRelations triggers MANY_TO_ONE secondary SELECT.
    // patient_id column must be aliased to patientId for AppointmentOptionalized mapping to succeed.
    PatientWithRelations patient = check h2DbHospital->/patients/[patientId].get();
    AppointmentOptionalized[]? appts = patient.appointments;
    test:assertTrue(appts is AppointmentOptionalized[], "appointments array should be populated");
    test:assertEquals((<AppointmentOptionalized[]>appts).length(), 1);
    test:assertEquals((<AppointmentOptionalized[]>appts)[0].patientId, patientId,
        "patient_id column must be aliased to patientId in MANY_TO_ONE secondary SELECT");

    // stream path: same getManyRelations call is exercised per row via PersistSQLStream.next()
    stream<PatientWithRelations, persist:Error?> patientStream = h2DbHospital->/patients.get();
    PatientWithRelations[] patients = check from PatientWithRelations p in patientStream
        where p.name == "Alias Test Patient"
        select p;
    AppointmentOptionalized[]? appointments = patients[0].appointments;
    if appointments is () {
        test:assertFail("appointments should be populated in stream path");
    }
    if appointments.length() != 1 {
        test:assertFail("there should be 1 appointment in stream path");
    }
    test:assertEquals(appointments[0].patientId, patientId,
        "patient_id column must be aliased to patientId in stream path");

    check h2DbHospital.close();
}

@test:Config {
    groups: ["annotation", "h2"],
    dependsOn: [testPatientWithAppointmentsManyRelationColumnAliasH2]
}
function testDoctorWithAppointmentsManyRelationColumnAliasH2() returns error? {
    H2HospitalClient h2DbHospital = check new ();

    // queryOne path: DoctorWithRelations triggers MANY_TO_ONE secondary SELECT.
    // The appointments table's patient_id column must be aliased to patientId.
    DoctorWithRelations doctor = check h2DbHospital->/doctors/[50].get();
    AppointmentOptionalized[]? appts = doctor.appointments;
    test:assertTrue(appts is AppointmentOptionalized[], "doctor appointments should be populated");
    test:assertEquals((<AppointmentOptionalized[]>appts).length(), 1);
    test:assertNotEquals((<AppointmentOptionalized[]>appts)[0].patientId, (),
        "patientId should be mapped from patient_id column in doctor's appointment list");

    // stream path
    stream<DoctorWithRelations, persist:Error?> doctorStream = h2DbHospital->/doctors.get();
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

    // cleanup
    _ = check h2DbHospital->/appointments/[50].delete();
    _ = check h2DbHospital->/doctors/[50].delete();
    stream<Patient, persist:Error?> patientStream = h2DbHospital->/patients.get();
    Patient[] patients = check from Patient p in patientStream
        where p.name == "Alias Test Patient"
        select p;
    foreach Patient p in patients {
        _ = check h2DbHospital->/patients/[p.id].delete();
    }
    check h2DbHospital.close();
}
