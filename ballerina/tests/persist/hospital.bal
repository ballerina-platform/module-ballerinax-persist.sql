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

import ballerina/persist as _;
import ballerina/time;
import ballerinax/persist.sql;

public enum AppointmentStatus {
    SCHEDULED = "SCHEDULED",
    STARTED = "STARTED",
    ENDED = "ENDED"
}

public enum PatientGender {
    MALE = "MALE",
    FEMALE = "FEMALE"
}

@sql:Name {value: "appointment"}
public type Appointment record {|
    readonly int id;
    @sql:UniqueIndex {name: "reason_index"}
    string reason;
    time:Civil appointmentTime;
    AppointmentStatus status;
    @sql:Name {value: "patient_id"}
    @sql:Index {name: "patient_id"}
    int patientId;
    @sql:Index {name: "doctorId"}
    int doctorId;
    @sql:Relation {keys: ["patientId"]}
    Patient patient;
    @sql:Relation {keys: ["doctorId"]}
    Doctor doctor;
|};

@sql:Name {value: "patients"}
public type Patient record {|
    @sql:Name {value: "ID_P"}
    @sql:Generated
    readonly int idP;
    string name;
    int age;
    @sql:Name {value: "ADDRESS"}
    string address;
    @sql:Char {length: 10}
    string phoneNumber;
    PatientGender gender;
    Appointment[] appointments;
|};

public type Doctor record {|
    readonly int id;
    string name;
    @sql:Varchar {length: 20}
    @sql:Index {name: "specialty_index"}
    string specialty;
    @sql:Name {value: "phone_number"}
    string phoneNumber;
    @sql:Decimal {precision: [10, 2]}
    decimal? salary;
    Appointment[] appointments;
|};
