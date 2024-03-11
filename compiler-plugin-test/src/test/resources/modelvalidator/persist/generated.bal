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
import ballerinax/persist.sql;

public type User record {|
    readonly int nic;
    @sql:Generated
    int age;
    string city;
|};

public type User1 record {|
    @sql:Generated
    readonly int id;
    readonly string email;
    string name;
    int age;
    string city;
|};

public type User2 record {|
    @sql:Generated
    readonly string nic;
    string name;
    int age;
    string city;
|};

public type User3 record {|
    @sql:Generated
    readonly int nic;
    string name;
    int age;
    string city;
|};
