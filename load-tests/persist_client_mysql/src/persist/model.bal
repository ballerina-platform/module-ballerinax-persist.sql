// Copyright (c) 2026 WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
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

type Customer record {|
    readonly int id;
    string name;
    string email;
    string country;
    int tier;
    SalesOrder[] orders;
|};

type SalesOrder record {|
    readonly int id;
    string status;
    decimal total;
    time:Date placedOn;
    Customer customer;
    OrderItem[] items;
|};

type OrderItem record {|
    readonly int id;
    string sku;
    int quantity;
    decimal price;
    SalesOrder salesOrder;
    Product product;
|};

type Product record {|
    readonly int id;
    string name;
    @sql:Varchar {length: 1024}
    string description;
    string attr01;
    string attr02;
    string attr03;
    string attr04;
    string attr05;
    string attr06;
    string attr07;
    string attr08;
    string attr09;
    string attr10;
    string attr11;
    string attr12;
    string attr13;
    string attr14;
    int num01;
    int num02;
    int num03;
    int num04;
    int num05;
    int num06;
    int num07;
    decimal dec01;
    decimal dec02;
    decimal dec03;
    decimal dec04;
    decimal dec05;
    decimal dec06;
    OrderItem[] orderItems;
|};
