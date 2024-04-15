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

public type Person record {|
    @sql:Char {length:12}
    readonly string nic;
    string name;
    int age;
    string city;
    Car? car;
|};

public type Car record {|
    readonly string plateNo;
    string make;
    string model;
    int year;
    string color;
    @sql:Char {length:12}
    string ownerNic;
    @sql:Relation {keys: ["ownerNic"]}
    Person owner;
|};

public type Person2 record {|
    readonly string nic;
    string name;
    int age;
    string city;
    Car2? car;
|};

public type Car2 record {|
    readonly string plateNo;
    string make;
    string model;
    int year;
    string color;
    @sql:Char {length:12}
    string ownerNic;
    @sql:Relation {keys: ["ownerNic"]}
    Person2 owner;
|};

public type Person3 record {|
    @sql:Varchar {length:12}
    readonly string nic;
    string name;
    int age;
    string city;
    Car3? car;
|};

public type Car3 record {|
    readonly string plateNo;
    string make;
    string model;
    int year;
    string color;
    @sql:Char {length:12}
    string ownerNic;
    @sql:Relation {keys: ["ownerNic"]}
    Person3 owner;
|};

public type Person4 record {|
    @sql:Char {length:11}
    readonly string nic;
    string name;
    int age;
    string city;
    Car4? car;
|};

public type Car4 record {|
    readonly string plateNo;
    string make;
    string model;
    int year;
    string color;
    @sql:Char {length:12}
    string ownerNic;
    @sql:Relation {keys: ["ownerNic"]}
    Person4 owner;
|};

public type Person5 record {|
    @sql:Char {length:11}
    readonly string nic;
    string name;
    int age;
    string city;
    Car5? car;
|};

public type Car5 record {|
    readonly string plateNo;
    string make;
    string model;
    int year;
    string color;
    @sql:Varchar {length:12}
    string ownerNic;
    @sql:Relation {keys: ["ownerNic"]}
    Person5 owner;
|};

public type Person6 record {|
    @sql:Decimal {precision:[10,2]}
    readonly decimal nic;
    string name;
    int age;
    string city;
    Car6? car;
|};

public type Car6 record {|
    readonly string plateNo;
    string make;
    string model;
    int year;
    string color;
    @sql:Decimal {precision:[10,2]}
    decimal ownerNic;
    @sql:Relation {keys: ["ownerNic"]}
    Person6 owner;
|};

public type Person7 record {|
    @sql:Decimal {precision:[10,2]}
    readonly decimal nic;
    string name;
    int age;
    string city;
    Car7? car;
|};

public type Car7 record {|
    readonly string plateNo;
    string make;
    string model;
    int year;
    string color;
    @sql:Decimal {precision:[10,9]}
    decimal ownerNic;
    @sql:Relation {keys: ["ownerNic"]}
    Person7 owner;
|};

public type Person8 record {|
    @sql:Varchar {length: 10}
    readonly string nic;
    string name;
    int age;
    string city;
    Car8? car;
|};

public type Car8 record {|
    readonly string plateNo;
    string make;
    string model;
    int year;
    string color;
    @sql:Varchar {length:5}
    string ownerNic;
    @sql:Relation {keys: ["ownerNic"]}
    Person8 owner;
|};
