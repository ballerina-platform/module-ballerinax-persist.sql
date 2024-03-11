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

public type Appointment record {|
    readonly int id;
    @sql:Char {length: 100}
    @sql:VarChar {length: 20}
    string reason;
    time:Civil appointmentTime;
    AppointmentStatus status;
    int _patientId;
    int doctorId;
|};

public type Patient record {|
    readonly int id;
    @sql:Char {length: 0}
    string name;
    @sql:Char {length: 10}
    int age;
    string address;
    string phoneNumber;
    PatientGender gender;
|};
