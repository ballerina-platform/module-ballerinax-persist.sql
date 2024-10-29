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

public type Subscription record {|
    readonly string subscriptionId;
    string userName;
    string apimetadataApiId;
    string apimetadataOrgId;
|};

public type SubscriptionOptionalized record {|
    string subscriptionId?;
    string userName?;
    string apimetadataApiId?;
    string apimetadataOrgId?;
|};

public type SubscriptionWithRelations record {|
    *SubscriptionOptionalized;
    ApiMetadataOptionalized apimetadata?;
|};

public type SubscriptionTargetType typedesc<SubscriptionWithRelations>;

public type SubscriptionInsert Subscription;

public type SubscriptionUpdate record {|
    string userName?;
    string apimetadataApiId?;
    string apimetadataOrgId?;
|};

public type ApiMetadata record {|
    readonly string apiId;
    readonly string orgId;
    string apiName;
    string metadata;

|};

public type ApiMetadataOptionalized record {|
    string apiId?;
    string orgId?;
    string apiName?;
    string metadata?;
|};

public type ApiMetadataWithRelations record {|
    *ApiMetadataOptionalized;
    SubscriptionOptionalized subscription?;
|};

public type ApiMetadataTargetType typedesc<ApiMetadataWithRelations>;

public type ApiMetadataInsert ApiMetadata;

public type ApiMetadataUpdate record {|
    string apiName?;
    string metadata?;
|};
