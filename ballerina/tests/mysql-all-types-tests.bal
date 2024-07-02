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

import ballerina/test;
import ballerina/persist;

@test:Config {
    groups: ["all-types", "mysql"]
}
function mysqlAllTypesCreateTest() returns error? {
    MySQLTestEntitiesClient testEntitiesClient = check new ();

    int[] ids = check testEntitiesClient->/alltypes.post([allTypes1, allTypes2]);
    test:assertEquals(ids, [allTypes1.id, allTypes2.id]);

    AllTypes allTypesRetrieved = check testEntitiesClient->/alltypes/[allTypes1.id].get();
    test:assertEquals(allTypesRetrieved, allTypes1Expected);

    allTypesRetrieved = check testEntitiesClient->/alltypes/[allTypes2.id].get();
    test:assertEquals(allTypesRetrieved, allTypes2Expected);

    check testEntitiesClient.close();
}

@test:Config {
    groups: ["all-types", "mysql"]
}
function mysqlAllTypesCreateMixedTest() returns error? {
    MySQLTestEntitiesClient testEntitiesClient = check new ();

    int[] ids = check testEntitiesClient->/alltypes.post([allTypes3, allTypes4]);
    test:assertEquals(ids, [allTypes3.id, allTypes4.id]);

    AllTypes allTypesRetrieved = check testEntitiesClient->/alltypes/[allTypes3.id].get();
    test:assertEquals(allTypesRetrieved, allTypes3Expected);

    allTypesRetrieved = check testEntitiesClient->/alltypes/[allTypes4.id].get();
    test:assertEquals(allTypesRetrieved, allTypes4Expected);

    check testEntitiesClient.close();
}

@test:Config {
    groups: ["all-types", "mysql"],
    dependsOn: [mysqlAllTypesCreateTest, mysqlAllTypesCreateMixedTest]
}
function mysqlAllTypesReadTest() returns error? {
    MySQLTestEntitiesClient testEntitiesClient = check new ();

    stream<AllTypes, error?> allTypesStream = testEntitiesClient->/alltypes.get();
    AllTypes[] allTypes = check from AllTypes allTypesRecord in allTypesStream
        select allTypesRecord;

    test:assertEquals(allTypes, [allTypes1Expected, allTypes2Expected, allTypes3Expected, allTypes4Expected]);
    check testEntitiesClient.close();
}

@test:Config {
    groups: ["all-types", "mysql", "dependent"],
    dependsOn: [mysqlAllTypesCreateTest, mysqlAllTypesCreateMixedTest]
}
function mysqlAllTypesReadDependentTest() returns error? {
    MySQLTestEntitiesClient testEntitiesClient = check new ();

    stream<AllTypesDependent, error?> allTypesStream = testEntitiesClient->/alltypes.get();
    AllTypesDependent[] allTypes = check from AllTypesDependent allTypesRecord in allTypesStream
        select allTypesRecord;

    test:assertEquals(allTypes, [
        {
            booleanType: allTypes1Expected.booleanType,
            intType: allTypes1Expected.intType,
            floatType: allTypes1Expected.floatType,
            decimalType: allTypes1Expected.decimalType,
            stringType: allTypes1Expected.stringType,
            byteArrayType: allTypes1Expected.byteArrayType,
            dateType: allTypes1Expected.dateType,
            timeOfDayType: allTypes1Expected.timeOfDayType,
            civilType: allTypes1Expected.civilType,
            booleanTypeOptional: allTypes1Expected.booleanTypeOptional,
            intTypeOptional: allTypes1Expected.intTypeOptional,
            floatTypeOptional: allTypes1Expected.floatTypeOptional,
            decimalTypeOptional: allTypes1Expected.decimalTypeOptional,
            stringTypeOptional: allTypes1Expected.stringTypeOptional,
            dateTypeOptional: allTypes1Expected.dateTypeOptional,
            timeOfDayTypeOptional: allTypes1Expected.timeOfDayTypeOptional,
            civilTypeOptional: allTypes1Expected.civilTypeOptional
        },
        {
            booleanType: allTypes2Expected.booleanType,
            intType: allTypes2Expected.intType,
            floatType: allTypes2Expected.floatType,
            decimalType: allTypes2Expected.decimalType,
            stringType: allTypes2Expected.stringType,
            byteArrayType: allTypes2Expected.byteArrayType,
            dateType: allTypes2Expected.dateType,
            timeOfDayType: allTypes2Expected.timeOfDayType,
            civilType: allTypes2Expected.civilType,
            booleanTypeOptional: allTypes2Expected.booleanTypeOptional,
            intTypeOptional: allTypes2Expected.intTypeOptional,
            floatTypeOptional: allTypes2Expected.floatTypeOptional,
            decimalTypeOptional: allTypes2Expected.decimalTypeOptional,
            stringTypeOptional: allTypes2Expected.stringTypeOptional,
            dateTypeOptional: allTypes2Expected.dateTypeOptional,
            timeOfDayTypeOptional: allTypes2Expected.timeOfDayTypeOptional,
            civilTypeOptional: allTypes2Expected.civilTypeOptional
        },
        {
            booleanType: allTypes3Expected.booleanType,
            intType: allTypes3Expected.intType,
            floatType: allTypes3Expected.floatType,
            decimalType: allTypes3Expected.decimalType,
            stringType: allTypes3Expected.stringType,
            byteArrayType: allTypes3Expected.byteArrayType,
            dateType: allTypes3Expected.dateType,
            timeOfDayType: allTypes3Expected.timeOfDayType,
            civilType: allTypes3Expected.civilType,
            booleanTypeOptional: allTypes3Expected.booleanTypeOptional,
            intTypeOptional: allTypes3Expected.intTypeOptional,
            floatTypeOptional: allTypes3Expected.floatTypeOptional,
            decimalTypeOptional: allTypes3Expected.decimalTypeOptional,
            stringTypeOptional: allTypes3Expected.stringTypeOptional,
            dateTypeOptional: allTypes3Expected.dateTypeOptional,
            timeOfDayTypeOptional: allTypes3Expected.timeOfDayTypeOptional,
            civilTypeOptional: allTypes3Expected.civilTypeOptional
        },
        {
            booleanType: allTypes4Expected.booleanType,
            intType: allTypes4Expected.intType,
            floatType: allTypes4Expected.floatType,
            decimalType: allTypes4Expected.decimalType,
            stringType: allTypes4Expected.stringType,
            byteArrayType: allTypes4Expected.byteArrayType,
            dateType: allTypes4Expected.dateType,
            timeOfDayType: allTypes4Expected.timeOfDayType,
            civilType: allTypes4Expected.civilType,
            booleanTypeOptional: allTypes4Expected.booleanTypeOptional,
            intTypeOptional: allTypes4Expected.intTypeOptional,
            floatTypeOptional: allTypes4Expected.floatTypeOptional,
            decimalTypeOptional: allTypes4Expected.decimalTypeOptional,
            stringTypeOptional: allTypes4Expected.stringTypeOptional,
            dateTypeOptional: allTypes4Expected.dateTypeOptional,
            timeOfDayTypeOptional: allTypes4Expected.timeOfDayTypeOptional,
            civilTypeOptional: allTypes4Expected.civilTypeOptional
        }
    ]);
    check testEntitiesClient.close();
}

@test:Config {
    groups: ["all-types", "mysql"],
    dependsOn: [mysqlAllTypesCreateTest, mysqlAllTypesCreateMixedTest]
}
function mysqlAllTypesReadOneTest() returns error? {
    MySQLTestEntitiesClient testEntitiesClient = check new ();

    AllTypes allTypesRetrieved = check testEntitiesClient->/alltypes/[allTypes1.id].get();
    test:assertEquals(allTypesRetrieved, allTypes1Expected);

    allTypesRetrieved = check testEntitiesClient->/alltypes/[allTypes2.id].get();
    test:assertEquals(allTypesRetrieved, allTypes2Expected);

    allTypesRetrieved = check testEntitiesClient->/alltypes/[allTypes3.id].get();
    test:assertEquals(allTypesRetrieved, allTypes3Expected);

    allTypesRetrieved = check testEntitiesClient->/alltypes/[allTypes4.id].get();
    test:assertEquals(allTypesRetrieved, allTypes4Expected);

    check testEntitiesClient.close();
}

@test:Config {
    groups: ["all-types", "mysql"]
}
function mysqlAllTypesReadOneTestNegative() returns error? {
    MySQLTestEntitiesClient testEntitiesClient = check new ();

    AllTypes|persist:Error allTypesRetrieved = testEntitiesClient->/alltypes/[5].get();
    if allTypesRetrieved is persist:NotFoundError {
        test:assertEquals(allTypesRetrieved.message(), "A record with the key '5' does not exist for the entity 'AllTypes'.");
    }
    else {
        test:assertFail("persist:NotFoundError expected.");
    }

    check testEntitiesClient.close();
}

@test:Config {
    groups: ["all-types", "mysql"],
    dependsOn: [mysqlAllTypesReadOneTest, mysqlAllTypesReadTest, mysqlAllTypesReadDependentTest]
}
function mysqlAllTypesUpdateTest() returns error? {
    MySQLTestEntitiesClient testEntitiesClient = check new ();

    AllTypes allTypes = check testEntitiesClient->/alltypes/[allTypes1.id].put({
        booleanType: allTypes3.booleanType,
        intType: allTypes1Updated.intType,
        floatType: allTypes1Updated.floatType,
        decimalType: allTypes1Updated.decimalType,
        stringType: allTypes1Updated.stringType,
        byteArrayType: allTypes1Updated.byteArrayType,
        dateType: allTypes1Updated.dateType,
        timeOfDayType: allTypes1Updated.timeOfDayType,
        civilType: allTypes1Updated.civilType,
        booleanTypeOptional: allTypes1Updated.booleanTypeOptional,
        intTypeOptional: allTypes1Updated.intTypeOptional,
        floatTypeOptional: allTypes1Updated.floatTypeOptional,
        decimalTypeOptional: allTypes1Updated.decimalTypeOptional,
        stringTypeOptional: allTypes1Updated.stringTypeOptional,
        dateTypeOptional: allTypes1Updated.dateTypeOptional,
        timeOfDayTypeOptional: allTypes1Updated.timeOfDayTypeOptional,
        civilTypeOptional: allTypes1Updated.civilTypeOptional,
        enumType: allTypes1Updated.enumType,
        enumTypeOptional: allTypes1Updated.enumTypeOptional
    });
    test:assertEquals(allTypes, allTypes1UpdatedExpected);

    AllTypes allTypesRetrieved = check testEntitiesClient->/alltypes/[allTypes1.id].get();
    test:assertEquals(allTypesRetrieved, allTypes1UpdatedExpected);
    check testEntitiesClient.close();
}

@test:Config {
    groups: ["all-types", "mysql"],
    dependsOn: [mysqlAllTypesUpdateTest]
}
function mysqlAllTypesDeleteTest() returns error? {
    MySQLTestEntitiesClient testEntitiesClient = check new ();

    AllTypes allTypes = check testEntitiesClient->/alltypes/[allTypes2.id].delete();
    test:assertEquals(allTypes, allTypes2Expected);

    stream<AllTypes, error?> allTypesStream = testEntitiesClient->/alltypes.get();
    AllTypes[] allTypesCollection = check from AllTypes allTypesRecord in allTypesStream
        select allTypesRecord;

    test:assertEquals(allTypesCollection, [allTypes1UpdatedExpected, allTypes3Expected, allTypes4Expected]);
    check testEntitiesClient.close();
}
