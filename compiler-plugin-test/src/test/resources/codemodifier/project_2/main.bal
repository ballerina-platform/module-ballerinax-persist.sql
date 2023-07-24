// Copyright (c) 2023 WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/io;
import foo/medical_center.entities;

public function main() returns error? {
    entities:Client mcClient = check new ();
    int value = 5;
    entities:Product product = {
        id: 2,
        name: "product2",
        age: 22
    };
    int[] needIds = check mcClient->/products.post([product]);
    io:println("Created need id: ", needIds[0]);

    entities:Product[] products = check from var e in mcClient->/products.get(targetType = entities:Product, whereClause = ``)
            where e.id == value || e.id == 6
            order by e.id descending
            limit value
            select e;

    products = check from var e in mcClient->/products(entities:Product, ``, ``, ``, ``)
            where e.id == value || e.id == 6
            order by e.id descending
            limit value
            select e;

    products = check from var e in mcClient->/products(entities:Product)
                group by var id = e.id, var name = e.name, var age = e.age
                where id == value || id == 6
                limit 5
                select {id, name, age};

    io:println("Products: ", products);
    check mcClient.close();
}

function getValue(int value) returns int {
    return value;
}

function getStringValue(string value) returns string {
    return value;
}
