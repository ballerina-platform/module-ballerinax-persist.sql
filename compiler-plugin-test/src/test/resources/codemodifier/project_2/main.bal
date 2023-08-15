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

    entities:Product[] products = check from var e in mcClient->/products.get(targetType = entities:Product, whereClause = ``, orderByClause  = ``, limitClause = ``, groupByClause = `` )
            where e.id == value || e.id == 6
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
                limit e.id
                select e;

    entities:ProductWithRelations1[] out =  check from entities:ProductWithRelations1 e in mcClient->/products(targetType = entities:ProductWithRelations1)
                   order by getStringValue("name") ascending, e.manufacture[0].id descending
                   limit getValue(2)
                   where e.id == 5 || e.id == 6 || e.id == 7 || e.id != 1  || e.manufacture[0].productsId == 1 && e.id >= 1 && e.id <= 20 && e.name == getStringValue("abc") || e.manufacture[0].id == "1"
                   group by var id =  e.id, var productsId = e.manufacture[0].productsId, var name = e.name, var age = e.age, var manufactureId = e.manufacture[0].id
                   select {id, name, age, manufacture: [{id: manufactureId, productsId: productsId}]};
    io:println("Products: ", products);
    check mcClient.close();
}

function getValue(int value) returns int {
    return value;
}

function getStringValue(string value) returns string {
    return value;
}
