// Copyright (c) 2025 WSO2 LLC. (http://www.wso2.com).
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

    int[] names = check from entities:Product student in check mcClient->/products(targetType = entities:Product)
                      // The `let` clause binds the variables.
                      let int sum = (student.id + student.id)
                      where sum > 0
                      let int avg = sum / 2
                      select avg;

    entities:Product[] products = check from var e in check mcClient->/products.get(targetType = entities:Product)
        where e.id == value || e.id == 6
        order by e.id descending
        limit value
        select e;

    entities:Product[]|error result = from var e in check mcClient->/products(targetType = entities:Product)
            where e.id == value && e.id >= 2 && e.id <= 25
            select e;

    products = check from var e in check mcClient->/products(targetType = entities:Product)
            where (e.id == value || e.id == 6) && e.id != 8
            select e;

    entities:Product[] products2 = check from var e in check mcClient->/products(targetType = entities:Product)
            where e.id == value || e.id == 6 && e.id % 2 == 0
            select e;

    entities:Product[] products3 = check from var e in check mcClient->/products(targetType = entities:Product)
            where e.id == value || e.id == 3 && e.id >= 2
            select e;

    entities:Product[]|error result1 = from var e in check mcClient->/products(targetType = entities:Product)
                where e.id == value && e.id <= 5
                select e;

    entities:Product[] products4 = check from var e in check mcClient->/products(targetType = entities:Product)
                where (e.id == value || e.id == 5) && e.id != 6
                select e;

    entities:Product[] results1 = check from entities:Product e in check mcClient->/products(targetType = entities:Product)
            where e.id == value || e.id == 6 || e.id == 7 || e.id != 1  && e.id >= 1 && e.id <= 20 && e.name == getStringValue("Person2")
            order by getStringValue("name") ascending, e.age descending
            limit getValue(4)
            group by var id3 = getValue(4), var name = e.name, var age = e.age
            select {id: id3, name: name , age: age};

    entities:Product[] output = check from entities:Product e in check mcClient->/products(targetType = entities:Product)
                order by getStringValue("name") ascending, e.age descending
                limit getValue(4)
                where e.id == value || e.id == 6 || e.id == 7 || e.id != 1  && e.id >= 1 && e.id <= 20 && e.name == getStringValue("Person2")
                group by var id3 = getValue(4), var name = e.name, var age = e.age
                select {id: id3, name: name , age: age};

    output = check from entities:Product e in check mcClient->/products(targetType = entities:Product)
                    order by e.name ascending, e.age descending
                    limit 4
                    where e.id == value || e.id == 6 || e.id == 7 || e.id != 1  && e.id >= 1 && e.id <= 20 && e.name == "Person2"
                    group by var id3 = getValue(4), var name = e.name, var age = e.age
                    select {id: id3, name: name , age: age};

    products4 = check from var e in check mcClient->/products(targetType = entities:Product)
                    where (e.id == value || e.id == 5) && e.id != 6
                    select e;
    
    output = check from entities:Product e in check mcClient->/products(targetType = entities:Product)
                order by getStringValue("name"), e.age
                limit getValue(4)
                where e.id == value || e.id == 6 || e.id == 7 || e.id != 1  && e.id >= 1 && e.id <= 20 && e.name == getStringValue("Person2")
                group by var id3 = getValue(4), var name = e.name, var age = e.age
                select {id: id3, name: name , age: age};

    io:println(products);
    io:println(results1);
    check mcClient.close();
}

function getValue(int value) returns int {
    return value;
}

function getStringValue(string value) returns string {
    return value;
}
