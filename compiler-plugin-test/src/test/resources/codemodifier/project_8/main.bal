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

import foo/medical_center.entities;

class ProductReader {
    private final entities:Client mcClient;

    function init(entities:Client mcClient) {
        self.mcClient = mcClient;
    }

    function read(int offset) returns entities:Product[]|error {
        return from var e in self.mcClient->/products(targetType = entities:Product, offsetClause = `${offset}`)
            order by e.id
            select e;
    }
}

public function main() returns error? {
    entities:Client mcClient = check new ();
    int offset = 2;

    int[] ids = check from var e in mcClient->/products(targetType = entities:Product, offsetClause = `${offset}`)
        let int id = e.id
        where id > 1
        select id;

    entities:Product[] products = check from var e in mcClient->/products(targetType = entities:Product, offsetClause = `${offset}`)
        where e.name.startsWith("p")
        select e;

    ProductReader reader = new (mcClient);
    products = check reader.read(offset);
}
