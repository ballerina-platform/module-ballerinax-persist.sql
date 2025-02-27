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

import ballerina/sql;
import ballerina/persist;

public class PersistSQLStream {

    private stream<record {}, sql:Error?>? anydataStream;
    private persist:Error? err;
    private string[] fields;
    private string[] include;
    private typedesc<record {}>[] typeDescriptions;
    private SQLClient? persistClient;
    private typedesc<record {}> targetType;

    public isolated function init(stream<record {}, sql:Error?>? anydataStream, typedesc<record {}> targetType, string[] fields, string[] include, any[] typeDescriptions, SQLClient persistClient, persist:Error? err = ()) {
        self.anydataStream = anydataStream;
        self.fields = fields;
        self.include = include;
        self.targetType = targetType;

        typedesc<record {}>[] typeDescriptionsArray = [];
        foreach any typeDescription in typeDescriptions {
            typeDescriptionsArray.push(<typedesc<record {}>>typeDescription);
        }
        self.typeDescriptions = typeDescriptionsArray;

        self.persistClient = persistClient;
        self.err = err;
    }

    public isolated function next() returns record {|record {} value;|}|persist:Error? {
        if self.err is persist:Error {
            return <persist:Error>self.err;
        }
        else if self.anydataStream is stream<record {}, sql:Error?> {
            var anydataStream = <stream<record {}, sql:Error?>>self.anydataStream;
            var streamValue = anydataStream.next();
            if streamValue is () {
                return streamValue;
            } else if (streamValue is sql:Error) {
                return <persist:Error>error(streamValue.message());
            } else {
                record {}|error value = streamValue.value;
                if value is error {
                    return <persist:Error>error(value.message());
                }
                check (<SQLClient>self.persistClient).getManyRelations(value, self.fields, self.include, self.typeDescriptions);
                // verifies the entity association whether associated entity is available in the database.
                check (<SQLClient>self.persistClient).verifyEntityAssociation(value, self.fields, self.include);

                string[] keyFields = (<SQLClient>self.persistClient).getKeyFields();
                foreach string keyField in keyFields {
                    if self.fields.indexOf(keyField) is () && value.hasKey(keyField) {
                        _ = value.remove(keyField);
                    }
                }
                record {}|error result = value.cloneWithType(self.targetType);
                if result is error {
                    return error persist:Error("Error occurred while converting to the record: " +
                                result.detail().toString());
                }
                record {|record {} value;|} nextRecord = {value: result};
                return nextRecord;
            }
        } else {
            return ();
        }
    }

    public isolated function close() returns persist:Error? {
        if self.anydataStream is stream<anydata, sql:Error?> {
            error? e = (<stream<anydata, sql:Error?>>self.anydataStream).close();
            if e is error {
                return <persist:Error>error(e.message());
            }
        }
    }
}

public class PersistNativeSQLStream {

    private stream<record {}, sql:Error?>? anydataStream;
    private persist:Error? err;

    public isolated function init(stream<record {}, sql:Error?>? anydataStream, persist:Error? err = ()) {
        self.anydataStream = anydataStream;
        self.err = err;
    }

    public isolated function next() returns record {|record {} value;|}|persist:Error? {
        if self.err is persist:Error {
            return <persist:Error>self.err;
        }
        else if self.anydataStream is stream<record {}, sql:Error?> {
            var anydataStream = <stream<record {}, sql:Error?>>self.anydataStream;
            var streamValue = anydataStream.next();
            if streamValue is () {
                return streamValue;
            } else if (streamValue is sql:Error) {
                return <persist:Error>error(streamValue.message());
            } else {
                record {}|error value = streamValue.value;
                if value is error {
                    return <persist:Error>error(value.message());
                }

                record {|record {} value;|} nextRecord = {value: value};
                return nextRecord;
            }
        } else {
            return ();
        }
    }

    public isolated function close() returns persist:Error? {
        if self.anydataStream is stream<anydata, sql:Error?> {
            error? e = (<stream<anydata, sql:Error?>>self.anydataStream).close();
            if e is error {
                return <persist:Error>error(e.message());
            }
        }
    }
}
