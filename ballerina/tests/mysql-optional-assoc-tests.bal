// Copyright (c) 2024 WSO2 LLC. (http://www.wso2.org).
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
    groups: ["assoc", "mysql"]
}
function MySqlAPMNoRelationsTest() returns error? {
    MySqlApimClient apimClient = check new ();

    [string, string][] metaId = check apimClient->/apimetadata.post([{
        apiId: "123457",
        orgId: "wso2",
        apiName: "abc",
        metadata: "metadata"
    }]);
    test:assertEquals(metaId, [["123457", "wso2"]]);

    stream<MySqlAPIMWithSubscriptions, persist:Error?> streamResult = apimClient->/apimetadata();
    MySqlAPIMWithSubscriptions[] apimResults = check from MySqlAPIMWithSubscriptions apiMetadata in streamResult
    select apiMetadata;

    test:assertEquals(apimResults.length(), 1);
    test:assertEquals(apimResults[0].subscription, ());
    check apimClient.close();
}

@test:Config {
    groups: ["assoc", "mysql"],
    dependsOn: [MySqlAPMNoRelationsTest, MySqlAPMWithRelationsTest]
}
function MySqlAPMWithoutRelationsTest() returns error? {
    MySqlApimClient apimClient = check new ();

    stream<MySqlApimWithoutSubscriptions, persist:Error?> streamResult = apimClient->/apimetadata();
    MySqlApimWithoutSubscriptions[] apimResults = check from MySqlApimWithoutSubscriptions apiMetadata in streamResult
    select apiMetadata;

    test:assertEquals(apimResults.length(), 2);
    test:assertEquals(apimResults[0], {
        apiId: "123457",
        orgId: "wso2",
        apiName: "abc",
        metadata: "metadata"
});
    check apimClient.close();
}

@test:Config {
    groups: ["assoc", "mysql"],
    dependsOn: [MySqlAPMNoRelationsTest]
}
function MySqlAPMWithRelationsTest() returns error? {
    MySqlApimClient apimClient = check new ();

    [string, string][] metaId = check apimClient->/apimetadata.post([{
        apiId: "123458",
        orgId: "wso2",
        apiName: "abc",
        metadata: "metadata"
    }]);
    test:assertEquals(metaId, [["123458", "wso2"]]);

    string[] subId = check apimClient->/subscriptions.post([{
        subscriptionId: "123",
        userName: "ballerina",
        apimetadataApiId: "123458",
        apimetadataOrgId: "wso2"
    }]);
    test:assertEquals(subId, ["123"]);

    stream<MySqlAPIMWithSubscriptions, persist:Error?> streamResult = apimClient->/apimetadata();
    MySqlAPIMWithSubscriptions[] apimResults = check from MySqlAPIMWithSubscriptions apiMetadata in streamResult
    select apiMetadata;

    test:assertEquals(apimResults.length(), 2);


    test:assertEquals(apimResults[1].subscription, {
        subscriptionId: "123",
        apimetadataApiId: "123458"
    });
    check apimClient.close();
}

type MySqlAPIMWithSubscriptions record {|
    string apiId;
    string orgId;
    string apiName;
    string metadata;
    record {|
        string subscriptionId;
        string apimetadataApiId;
    |} subscription?;
|};

type MySqlApimWithoutSubscriptions record {|
    string apiId;
    string orgId;
    string apiName;
    string metadata;
|};
