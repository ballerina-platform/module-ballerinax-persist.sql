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


@test:Config{}
function testCreatePatientH2() returns error? {
    H2HospitalClient h2DbHospital = check new();
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

@test:Config{}
function testCreateDoctorH2() returns error? {
    H2HospitalClient h2DbHospital = check new();
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

@test:Config{
  dependsOn: [testCreateDoctorH2]
}
function testCreateDoctorAlreadyExistsH2() returns error? {
    H2HospitalClient h2DbHospital = check new();
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

@test:Config{
  dependsOn: [testCreatePatientH2, testCreateDoctorH2]
}
function testCreateAppointmentH2() returns error? {
    H2HospitalClient h2DbHospital = check new();
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

@test:Config{
  dependsOn: [testCreatePatientH2, testCreateDoctorH2, testCreateAppointmentH2]
}
function testCreateAppointmentAlreadyExistsH2() returns error? {
    H2HospitalClient h2DbHospital = check new();
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

@test:Config{
  dependsOn: [testCreateDoctorH2]
}
function testGetDoctorsH2() returns error? {
    H2HospitalClient h2DbHospital = check new();
    stream<Doctor, persist:Error?> doctors = h2DbHospital->/doctors.get();
    Doctor[]|persist:Error doctorsArr = from Doctor doctor in doctors select doctor;
    Doctor[] expected = [
      {id: 1, name: "Doctor Mouse", specialty: "Physician", phoneNumber: "077100100", salary: 20000}
    ];
    test:assertEquals(doctorsArr, expected, "Doctor details should be returned");
}

@test:Config{
  dependsOn: [testCreatePatientH2]
}
function testGetPatientByIdH2() returns error? {
    H2HospitalClient h2DbHospital = check new();
    Patient|persist:Error patient = h2DbHospital->/patients/[1].get();
    Patient expected = {"id":1, "name": "John Doe", "age": 30, "address": "123, Main Street, Colombo 05", "phoneNumber":"0771690000", "gender":"MALE"};
    test:assertEquals(patient, expected, "Patient details should be returned");
}

@test:Config{}
function testGetPatientNotFoundH2() returns error? {
    H2HospitalClient h2DbHospital = check new();
    Patient|persist:Error patient = h2DbHospital->/patients/[10].get();
    if !(patient is persist:NotFoundError) {
        test:assertFail("Patient should be not found");
    }
}

@test:Config{
  dependsOn: [testCreateAppointmentH2]
}
function testGetAppointmentByDoctorH2() returns error? {
    H2HospitalClient h2DbHospital = check new();
    stream<AppointmentWithRelations, persist:Error?> appointments = h2DbHospital->/appointments();
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

    stream<Appointment, persist:Error?> appointments2 = h2DbHospital->/appointments();
    Appointment[]|persist:Error? filteredAppointments2 =  from Appointment appointment in appointments2
            where appointment.doctorId == 5 &&
            appointment.appointmentTime.year == 2023 &&
            appointment.appointmentTime.month == 7 &&
            appointment.appointmentTime.day == 1
            select appointment;
    test:assertEquals(filteredAppointments2, [], "Appointment details should be empty");
}

@test:Config{
  dependsOn: [testCreateAppointmentH2]
}
function testGetAppointmentByPatientH2() returns error? {
    H2HospitalClient h2DbHospital = check new();
    stream<AppointmentWithRelations, persist:Error?> appointments = h2DbHospital->/appointments();
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
    stream<AppointmentWithRelations, persist:Error?> appointments2 = h2DbHospital->/appointments();
    AppointmentWithRelations[]|persist:Error? filteredAppointments2 =  from AppointmentWithRelations appointment in appointments2
            where appointment.patientId == 5
            select appointment;
    test:assertEquals(filteredAppointments2, [], "Appointment details should be empty");
}

@test:Config{
  dependsOn: [testCreateAppointmentH2, testGetAppointmentByDoctorH2, testGetAppointmentByPatientH2]
}
function testPatchAppointmentH2() returns error? {
    H2HospitalClient h2DbHospital = check new();
    Appointment|persist:Error result = h2DbHospital->/appointments/[1].put({status: "STARTED"});
    if result is persist:Error {
        test:assertFail("Appointment should be updated");
    }
    stream<AppointmentWithRelations, persist:Error?> appointments = h2DbHospital->/appointments();
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
    Appointment|persist:Error result2 = h2DbHospital->/appointments/[0].put({status: "STARTED"});
    if !(result2 is persist:NotFoundError) {
        test:assertFail("Appointment should not be found");
    }
}

@test:Config{
  dependsOn: [testCreateAppointmentH2, testGetAppointmentByDoctorH2, testGetAppointmentByPatientH2, testPatchAppointmentH2]
}
function testDeleteAppointmentByPatientIdH2() returns error? {
    H2HospitalClient h2DbHospital = check new();
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

@test:Config{
  dependsOn: [testGetPatientByIdH2, testDeleteAppointmentByPatientIdH2]
}
function testDeletePatientH2() returns error? {
    MySqlHospitalClient h2DbHospital = check new();
    Patient|persist:Error result = h2DbHospital->/patients/[1].delete();
    if result is persist:Error {
        log:printError("Error: ", result);
        test:assertFail("Patient should be deleted");
    }
}

@test:Config{
  dependsOn: [testGetDoctorsH2, testDeleteAppointmentByPatientIdH2]
}
function testDeleteDoctorH2() returns error? {
    MySqlHospitalClient h2DbHospital = check new();
    Doctor|persist:Error result = h2DbHospital->/doctors/[1].delete();
    if result is persist:Error {
        test:assertFail("Patient should be deleted");
    }
}
