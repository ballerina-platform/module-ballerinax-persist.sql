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

import ballerina/time;

enum EnumType {
    TYPE_1,
    TYPE_2,
    TYPE_3,
    TYPE_4
}

type AllTypes record {|
    readonly int id;
    boolean booleanType;
    int intType;
    float floatType;
    decimal decimalType;
    string stringType;
    byte[] byteArrayType;
    time:Date dateType;
    time:TimeOfDay timeOfDayType;
    time:Utc utcType;
    time:Civil civilType;
    boolean? booleanTypeOptional;
    int? intTypeOptional;
    float? floatTypeOptional;
    decimal? decimalTypeOptional;
    string? stringTypeOptional;
    byte[]? byteArrayTypeOptional;
    time:Date? dateTypeOptional;
    time:TimeOfDay? timeOfDayTypeOptional;
    time:Utc? utcTypeOptional;
    time:Civil? civilTypeOptional;
    EnumType enumType;
    EnumType? enumTypeOptional;
|};

type StringIdRecord record {|
    readonly string id;
    string randomField;
|};

type IntIdRecord record {|
    readonly int id;
    string randomField;
|};

type FloatIdRecord record {|
    readonly float id;
    string randomField;
|};

type DecimalIdRecord record {|
    readonly decimal id;
    string randomField;
|};

type BooleanIdRecord record {|
    readonly boolean id;
    string randomField;
|};

type CompositeAssociationRecord record {|
    readonly string id;
    string randomField;
    AllTypesIdRecord allTypesIdRecord;
|};

type AllTypesIdRecord record {|
    readonly boolean booleanType;
    readonly int intType;
    readonly float floatType;
    readonly decimal decimalType;
    readonly string stringType;
    string randomField;
    CompositeAssociationRecord? compositeAssociationRecord;
|};
