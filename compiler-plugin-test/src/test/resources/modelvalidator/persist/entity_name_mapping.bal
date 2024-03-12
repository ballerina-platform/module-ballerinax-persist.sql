// Copyright (c) 2024 WSO2 LLC. (http://www.wso2.com) All Rights Reserved.
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
    SCHEDULED,
    STARTED,
    ENDED
}

public enum PatientGender {
    MALE,
    FEMALE
}

@sql:Mapping {name: ""}
public type Appointment record {|
    readonly int id;
    string reason;
    time:Civil appointmentTime;
    AppointmentStatus status;
    int _patientId;
    int doctorId;
|};

@sql:Mapping {name: "Patient"}
public type Patient record {|
    readonly int id;
    string name;
    int age;
    string address;
    string phoneNumber;
    PatientGender gender;
|};

@sql:Mapping {name: "staff"}
public type Doctor record {|
    readonly int id;
    string name;
    string specialty;
    string phoneNumber;
|};

@sql:Mapping {name: "staff"}
public type Nurse record {|
    readonly int id;
    string name;
    string phoneNumber;
|};

@sql:Mapping {name: "receptioninst"}
public type Receptionist record {|
    readonly int id;
    string name;
    string phoneNumber;
|};

@sql:Mapping {name: "Receptionist"}
public type Receptionist1 record {|
    readonly int id;
    string name;
    string phoneNumber;
|};
