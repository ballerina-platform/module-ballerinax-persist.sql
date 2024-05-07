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
import ballerina/time;

public enum AppointmentStatus {
    SCHEDULED = "SCHEDULED",
    STARTED = "STARTED",
    ENDED = "ENDED"
}

public enum PatientGender {
    MALE = "MALE",
    FEMALE = "FEMALE"
}

public type Appointment record {|
    readonly int id;
    string reason;
    time:Civil appointmentTime;
    AppointmentStatus status;
    int patientId;
    int doctorId;
|};

public type AppointmentOptionalized record {|
    int id?;
    string reason?;
    time:Civil appointmentTime?;
    AppointmentStatus status?;
    int patientId?;
    int doctorId?;
|};

public type AppointmentWithRelations record {|
    *AppointmentOptionalized;
    PatientOptionalized patient?;
    DoctorOptionalized doctor?;
|};

public type AppointmentTargetType typedesc<AppointmentWithRelations>;

public type AppointmentInsert Appointment;

public type AppointmentUpdate record {|
    string reason?;
    time:Civil appointmentTime?;
    AppointmentStatus status?;
    int patientId?;
    int doctorId?;
|};

public type Patient record {|
    readonly int id;
    string name;
    int age;
    string address;
    string phoneNumber;
    PatientGender gender;

|};

public type PatientOptionalized record {|
    int id?;
    string name?;
    int age?;
    string address?;
    string phoneNumber?;
    PatientGender gender?;
|};

public type PatientWithRelations record {|
    *PatientOptionalized;
    AppointmentOptionalized[] appointments?;
|};

public type PatientTargetType typedesc<PatientWithRelations>;

public type PatientInsert record {|
    string name;
    int age;
    string address;
    string phoneNumber;
    PatientGender gender;
|};

public type PatientUpdate record {|
    string name?;
    int age?;
    string address?;
    string phoneNumber?;
    PatientGender gender?;
|};

public type Doctor record {|
    readonly int id;
    string name;
    string specialty;
    string phoneNumber;
    decimal? salary;

|};

public type DoctorOptionalized record {|
    int id?;
    string name?;
    string specialty?;
    string phoneNumber?;
    decimal? salary?;
|};

public type DoctorWithRelations record {|
    *DoctorOptionalized;
    AppointmentOptionalized[] appointments?;
|};

public type DoctorTargetType typedesc<DoctorWithRelations>;

public type DoctorInsert Doctor;

public type DoctorUpdate record {|
    string name?;
    string specialty?;
    string phoneNumber?;
    decimal? salary?;
|};

