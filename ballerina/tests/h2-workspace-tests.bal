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
    groups: ["workspace", "h2"],
    dependsOn: [h2BuildingDeleteTestNegative]
}
function h2WorkspaceCreateTest() returns error? {
    H2RainierClient rainierClient = check new ();

    string[] workspaceIds = check rainierClient->/workspaces.post([workspace1]);
    test:assertEquals(workspaceIds, [workspace1.workspaceId]);

    Workspace workspaceRetrieved = check rainierClient->/workspaces/[workspace1.workspaceId].get();
    test:assertEquals(workspaceRetrieved, workspace1);
}

@test:Config {
    groups: ["workspace", "h2"]
}
function h2WorkspaceCreateTest2() returns error? {
    H2RainierClient rainierClient = check new ();

    string[] workspaceIds = check rainierClient->/workspaces.post([workspace2, workspace3]);

    test:assertEquals(workspaceIds, [workspace2.workspaceId, workspace3.workspaceId]);

    Workspace workspaceRetrieved = check rainierClient->/workspaces/[workspace2.workspaceId].get();
    test:assertEquals(workspaceRetrieved, workspace2);

    workspaceRetrieved = check rainierClient->/workspaces/[workspace3.workspaceId].get();
    test:assertEquals(workspaceRetrieved, workspace3);
    check rainierClient.close();
}

@test:Config {
    groups: ["workspace", "h2"]
}
function h2WorkspaceCreateTestNegative() returns error? {
    H2RainierClient rainierClient = check new ();

    string[]|error workspace = rainierClient->/workspaces.post([invalidWorkspace]);
    if workspace is persist:Error {
        test:assertTrue(workspace.message().includes("Value too long for column \"workspaceId CHARACTER VARYING(36)"));
    } else {
        test:assertFail("Error expected.");
    }
    check rainierClient.close();
}

@test:Config {
    groups: ["workspace", "h2"],
    dependsOn: [h2WorkspaceCreateTest]
}
function h2WorkspaceReadOneTest() returns error? {
    H2RainierClient rainierClient = check new ();

    Workspace workspaceRetrieved = check rainierClient->/workspaces/[workspace1.workspaceId].get();
    test:assertEquals(workspaceRetrieved, workspace1);
    check rainierClient.close();
}

@test:Config {
    groups: ["workspace", "h2"],
    dependsOn: [h2WorkspaceCreateTest]
}
function h2WorkspaceReadOneDependentTest() returns error? {
    H2RainierClient rainierClient = check new ();

    WorkspaceInfo2 workspaceRetrieved = check rainierClient->/workspaces/[workspace1.workspaceId].get();
    test:assertEquals(workspaceRetrieved,
        {
        workspaceType: workspace1.workspaceType,
        locationBuildingCode: workspace1.locationBuildingCode
    }
    );
    check rainierClient.close();
}

@test:Config {
    groups: ["workspace", "h2"],
    dependsOn: [h2WorkspaceCreateTest]
}
function h2WorkspaceReadOneTestNegative() returns error? {
    H2RainierClient rainierClient = check new ();

    Workspace|error workspaceRetrieved = rainierClient->/workspaces/["invalid-workspace-id"].get();
    if workspaceRetrieved is persist:NotFoundError {
        test:assertEquals(workspaceRetrieved.message(), "A record with the key 'invalid-workspace-id' does not exist for the entity 'Workspace'.");
    } else {
        test:assertFail("NotFoundError expected.");
    }
    check rainierClient.close();
}

@test:Config {
    groups: ["workspace", "h2"],
    dependsOn: [h2WorkspaceCreateTest, h2WorkspaceCreateTest2]
}
function h2WorkspaceReadManyTest() returns error? {
    H2RainierClient rainierClient = check new ();

    stream<Workspace, error?> workspaceStream = rainierClient->/workspaces.get();
    Workspace[] workspaces = check from Workspace workspace in workspaceStream
        select workspace;

    test:assertEquals(workspaces, [workspace1, workspace2, workspace3]);
    check rainierClient.close();
}

@test:Config {
    groups: ["workspace", "h2", "dependent"],
    dependsOn: [h2WorkspaceCreateTest, h2WorkspaceCreateTest2]
}
function h2WorkspaceReadManyDependentTest() returns error? {
    H2RainierClient rainierClient = check new ();

    stream<WorkspaceInfo2, error?> workspaceStream = rainierClient->/workspaces.get();
    WorkspaceInfo2[] workspaces = check from WorkspaceInfo2 workspace in workspaceStream
        select workspace;

    test:assertEquals(workspaces, [
        {workspaceType: workspace1.workspaceType, locationBuildingCode: workspace1.locationBuildingCode},
        {workspaceType: workspace2.workspaceType, locationBuildingCode: workspace2.locationBuildingCode},
        {workspaceType: workspace3.workspaceType, locationBuildingCode: workspace3.locationBuildingCode}
    ]);
    check rainierClient.close();
}

@test:Config {
    groups: ["workspace", "h2"],
    dependsOn: [h2WorkspaceReadOneTest, h2WorkspaceReadManyTest, h2WorkspaceReadManyDependentTest]
}
function h2WorkspaceUpdateTest() returns error? {
    H2RainierClient rainierClient = check new ();

    Workspace workspace = check rainierClient->/workspaces/[workspace1.workspaceId].put({
        workspaceType: "large"
    });

    test:assertEquals(workspace, updatedWorkspace1);

    Workspace workspaceRetrieved = check rainierClient->/workspaces/[workspace1.workspaceId].get();
    test:assertEquals(workspaceRetrieved, updatedWorkspace1);
    check rainierClient.close();
}

@test:Config {
    groups: ["workspace", "h2"],
    dependsOn: [h2WorkspaceCreateTest, h2WorkspaceCreateTest2]
}
function h2WorkspaceReadWithClauses() returns error? {
    H2RainierClient rainierClient = check new ();
    string value = "small";
    string value2 = "medium";
    string id = "\"Workspace\".\"workspaceId\"";
    int count = 2;
    stream<Workspace, error?> workspaceStream = rainierClient->/workspaces.get(whereClause = `"Workspace"."workspaceType" = ${value} OR "Workspace"."workspaceType" = ${value2}`, orderByClause = `"Workspace"."workspaceId" DESC `, limitClause = ` ${count}`, groupByClause = `${id}`);
    Workspace[] workspaces = check from Workspace workspace in workspaceStream
            select workspace;
    test:assertEquals(workspaces, [workspace3, workspace2]);
    check rainierClient.close();
}

@test:Config {
    groups: ["workspace", "h2"],
    dependsOn: [h2WorkspaceReadOneTest, h2WorkspaceReadManyTest, h2WorkspaceReadManyDependentTest, h2WorkspaceReadWithClauses]
}
function h2WorkspaceUpdateTestNegative1() returns error? {
    H2RainierClient rainierClient = check new ();

    Workspace|error workspace = rainierClient->/workspaces/["invalid-workspace-id"].put({
        workspaceType: "large"
    });

    if workspace is persist:NotFoundError {
        test:assertEquals(workspace.message(), "A record with the key 'invalid-workspace-id' does not exist for the entity 'Workspace'.");
    } else {
        test:assertFail("NotFoundError expected.");
    }
    check rainierClient.close();
}

@test:Config {
    groups: ["workspace", "h2"],
    dependsOn: [h2WorkspaceReadOneTest, h2WorkspaceReadManyTest, h2WorkspaceReadManyDependentTest, h2WorkspaceReadWithClauses]
}
function h2WorkspaceUpdateTestNegative2() returns error? {
    H2RainierClient rainierClient = check new ();

    Workspace|error workspace = rainierClient->/workspaces/[workspace1.workspaceId].put({
        workspaceType: "unncessarily-long-workspace-type-to-force-error-on-update"
    });

    if workspace is persist:Error {
        test:assertTrue(workspace.message().includes("Value too long for column \"workspaceType CHARACTER VARYING(10)"));
    } else {
        test:assertFail("NotFoundError expected.");
    }
    check rainierClient.close();
}

@test:Config {
    groups: ["workspace", "h2"],
    dependsOn: [h2WorkspaceUpdateTest, h2WorkspaceUpdateTestNegative2]
}
function h2WorkspaceDeleteTest() returns error? {
    H2RainierClient rainierClient = check new ();

    Workspace workspace = check rainierClient->/workspaces/[workspace1.workspaceId].delete();
    test:assertEquals(workspace, updatedWorkspace1);

    stream<Workspace, error?> workspaceStream = rainierClient->/workspaces.get();
    Workspace[] workspaces = check from Workspace workspace2 in workspaceStream
        select workspace2;

    test:assertEquals(workspaces, [workspace2, workspace3]);
    check rainierClient.close();
}

@test:Config {
    groups: ["workspace", "h2"],
    dependsOn: [h2WorkspaceDeleteTest]
}
function h2WorkspaceDeleteTestNegative() returns error? {
    H2RainierClient rainierClient = check new ();

    Workspace|error workspace = rainierClient->/workspaces/[workspace1.workspaceId].delete();

    if workspace is persist:NotFoundError {
        test:assertEquals(workspace.message(), string `A record with the key '${workspace1.workspaceId}' does not exist for the entity 'Workspace'.`);
    } else {
        test:assertFail("NotFoundError expected.");
    }
    check rainierClient.close();
}
