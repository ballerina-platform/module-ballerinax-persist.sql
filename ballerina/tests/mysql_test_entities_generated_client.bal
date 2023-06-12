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

import ballerina/jballerina.java;
import ballerinax/mysql;
import ballerina/persist;

const ALL_TYPES = "alltypes";
const STRING_ID_RECORD = "stringidrecords";
const INT_ID_RECORD = "intidrecords";
const FLOAT_ID_RECORD = "floatidrecords";
const DECIMAL_ID_RECORD = "decimalidrecords";
const BOOLEAN_ID_RECORD = "booleanidrecords";
const COMPOSITE_ASSOCIATION_RECORD = "compositeassociationrecords";
const ALL_TYPES_ID_RECORD = "alltypesidrecords";

public isolated client class MySQLTestEntitiesClient {
    *persist:AbstractPersistClient;

    private final mysql:Client dbClient;

    private final map<SQLClient> persistClients;

    private final record {|SQLMetadata...;|} & readonly metadata = {
        [ALL_TYPES] : {
            entityName: "AllTypes",
            tableName: "AllTypes",
            fieldMetadata: {
                id: {columnName: "id"},
                booleanType: {columnName: "booleanType"},
                intType: {columnName: "intType"},
                floatType: {columnName: "floatType"},
                decimalType: {columnName: "decimalType"},
                stringType: {columnName: "stringType"},
                byteArrayType: {columnName: "byteArrayType"},
                dateType: {columnName: "dateType"},
                timeOfDayType: {columnName: "timeOfDayType"},
                civilType: {columnName: "civilType"},
                booleanTypeOptional: {columnName: "booleanTypeOptional"},
                intTypeOptional: {columnName: "intTypeOptional"},
                floatTypeOptional: {columnName: "floatTypeOptional"},
                decimalTypeOptional: {columnName: "decimalTypeOptional"},
                stringTypeOptional: {columnName: "stringTypeOptional"},
                dateTypeOptional: {columnName: "dateTypeOptional"},
                timeOfDayTypeOptional: {columnName: "timeOfDayTypeOptional"},
                civilTypeOptional: {columnName: "civilTypeOptional"},
                enumType: {columnName: "enumType"},
                enumTypeOptional: {columnName: "enumTypeOptional"}
            },
            keyFields: ["id"]
        },
        [STRING_ID_RECORD] : {
            entityName: "StringIdRecord",
            tableName: "StringIdRecord",
            fieldMetadata: {
                id: {columnName: "id"},
                randomField: {columnName: "randomField"}
            },
            keyFields: ["id"]
        },
        [INT_ID_RECORD] : {
            entityName: "IntIdRecord",
            tableName: "IntIdRecord",
            fieldMetadata: {
                id: {columnName: "id"},
                randomField: {columnName: "randomField"}
            },
            keyFields: ["id"]
        },
        [FLOAT_ID_RECORD] : {
            entityName: "FloatIdRecord",
            tableName: "FloatIdRecord",
            fieldMetadata: {
                id: {columnName: "id"},
                randomField: {columnName: "randomField"}
            },
            keyFields: ["id"]
        },
        [DECIMAL_ID_RECORD] : {
            entityName: "DecimalIdRecord",
            tableName: "DecimalIdRecord",
            fieldMetadata: {
                id: {columnName: "id"},
                randomField: {columnName: "randomField"}
            },
            keyFields: ["id"]
        },
        [BOOLEAN_ID_RECORD] : {
            entityName: "BooleanIdRecord",
            tableName: "BooleanIdRecord",
            fieldMetadata: {
                id: {columnName: "id"},
                randomField: {columnName: "randomField"}
            },
            keyFields: ["id"]
        },
        [COMPOSITE_ASSOCIATION_RECORD] : {
            entityName: "CompositeAssociationRecord",
            tableName: "CompositeAssociationRecord",
            fieldMetadata: {
                id: {columnName: "id"},
                randomField: {columnName: "randomField"},
                alltypesidrecordBooleanType: {columnName: "alltypesidrecordBooleanType"},
                alltypesidrecordIntType: {columnName: "alltypesidrecordIntType"},
                alltypesidrecordFloatType: {columnName: "alltypesidrecordFloatType"},
                alltypesidrecordDecimalType: {columnName: "alltypesidrecordDecimalType"},
                alltypesidrecordStringType: {columnName: "alltypesidrecordStringType"},
                "allTypesIdRecord.booleanType": {relation: {entityName: "allTypesIdRecord", refField: "booleanType"}},
                "allTypesIdRecord.intType": {relation: {entityName: "allTypesIdRecord", refField: "intType"}},
                "allTypesIdRecord.floatType": {relation: {entityName: "allTypesIdRecord", refField: "floatType"}},
                "allTypesIdRecord.decimalType": {relation: {entityName: "allTypesIdRecord", refField: "decimalType"}},
                "allTypesIdRecord.stringType": {relation: {entityName: "allTypesIdRecord", refField: "stringType"}},
                "allTypesIdRecord.randomField": {relation: {entityName: "allTypesIdRecord", refField: "randomField"}}
            },
            keyFields: ["id"],
            joinMetadata: {allTypesIdRecord: {entity: AllTypesIdRecord, fieldName: "allTypesIdRecord", refTable: "AllTypesIdRecord", refColumns: ["booleanType", "intType", "floatType", "decimalType", "stringType"], joinColumns: ["alltypesidrecordBooleanType", "alltypesidrecordIntType", "alltypesidrecordFloatType", "alltypesidrecordDecimalType", "alltypesidrecordStringType"], 'type: ONE_TO_ONE}}
        },
        [ALL_TYPES_ID_RECORD] : {
            entityName: "AllTypesIdRecord",
            tableName: "AllTypesIdRecord",
            fieldMetadata: {
                booleanType: {columnName: "booleanType"},
                intType: {columnName: "intType"},
                floatType: {columnName: "floatType"},
                decimalType: {columnName: "decimalType"},
                stringType: {columnName: "stringType"},
                randomField: {columnName: "randomField"},
                "compositeAssociationRecord.id": {relation: {entityName: "compositeAssociationRecord", refField: "id"}},
                "compositeAssociationRecord.randomField": {relation: {entityName: "compositeAssociationRecord", refField: "randomField"}},
                "compositeAssociationRecord.alltypesidrecordBooleanType": {relation: {entityName: "compositeAssociationRecord", refField: "alltypesidrecordBooleanType"}},
                "compositeAssociationRecord.alltypesidrecordIntType": {relation: {entityName: "compositeAssociationRecord", refField: "alltypesidrecordIntType"}},
                "compositeAssociationRecord.alltypesidrecordFloatType": {relation: {entityName: "compositeAssociationRecord", refField: "alltypesidrecordFloatType"}},
                "compositeAssociationRecord.alltypesidrecordDecimalType": {relation: {entityName: "compositeAssociationRecord", refField: "alltypesidrecordDecimalType"}},
                "compositeAssociationRecord.alltypesidrecordStringType": {relation: {entityName: "compositeAssociationRecord", refField: "alltypesidrecordStringType"}}
            },
            keyFields: ["booleanType", "intType", "floatType", "decimalType", "stringType"],
            joinMetadata: {compositeAssociationRecord: {entity: CompositeAssociationRecord, fieldName: "compositeAssociationRecord", refTable: "CompositeAssociationRecord", refColumns: ["alltypesidrecordBooleanType", "alltypesidrecordIntType", "alltypesidrecordFloatType", "alltypesidrecordDecimalType", "alltypesidrecordStringType"], joinColumns: ["booleanType", "intType", "floatType", "decimalType", "stringType"], 'type: ONE_TO_ONE}}
        }
    };

    public isolated function init() returns persist:Error? {
        mysql:Client|error dbClient = new (host = mysql.host, user = mysql.user, password = mysql.password, database = mysql.database, port = mysql.port);
        if dbClient is error {
            return <persist:Error>error(dbClient.message());
        }
        self.dbClient = dbClient;
        self.persistClients = {
            [ALL_TYPES] : check new (self.dbClient, self.metadata.get(ALL_TYPES), MYSQL_SPECIFICS),
            [STRING_ID_RECORD] : check new (self.dbClient, self.metadata.get(STRING_ID_RECORD), MYSQL_SPECIFICS),
            [INT_ID_RECORD] : check new (self.dbClient, self.metadata.get(INT_ID_RECORD), MYSQL_SPECIFICS),
            [FLOAT_ID_RECORD] : check new (self.dbClient, self.metadata.get(FLOAT_ID_RECORD), MYSQL_SPECIFICS),
            [DECIMAL_ID_RECORD] : check new (self.dbClient, self.metadata.get(DECIMAL_ID_RECORD), MYSQL_SPECIFICS),
            [BOOLEAN_ID_RECORD] : check new (self.dbClient, self.metadata.get(BOOLEAN_ID_RECORD), MYSQL_SPECIFICS),
            [COMPOSITE_ASSOCIATION_RECORD] : check new (self.dbClient, self.metadata.get(COMPOSITE_ASSOCIATION_RECORD), MYSQL_SPECIFICS),
            [ALL_TYPES_ID_RECORD] : check new (self.dbClient, self.metadata.get(ALL_TYPES_ID_RECORD), MYSQL_SPECIFICS)
        };
    }

    isolated resource function get alltypes(AllTypesTargetType targetType = <>) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "query"
    } external;

    isolated resource function get alltypes/[int id](AllTypesTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post alltypes(AllTypesInsert[] data) returns int[]|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(ALL_TYPES);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from AllTypesInsert inserted in data
            select inserted.id;
    }

    isolated resource function put alltypes/[int id](AllTypesUpdate value) returns AllTypes|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(ALL_TYPES);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        return self->/alltypes/[id].get();
    }

    isolated resource function delete alltypes/[int id]() returns AllTypes|persist:Error {
        AllTypes result = check self->/alltypes/[id].get();
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(ALL_TYPES);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    isolated resource function get stringidrecords(StringIdRecordTargetType targetType = <>) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "query"
    } external;

    isolated resource function get stringidrecords/[string id](StringIdRecordTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post stringidrecords(StringIdRecordInsert[] data) returns string[]|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(STRING_ID_RECORD);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from StringIdRecordInsert inserted in data
            select inserted.id;
    }

    isolated resource function put stringidrecords/[string id](StringIdRecordUpdate value) returns StringIdRecord|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(STRING_ID_RECORD);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        return self->/stringidrecords/[id].get();
    }

    isolated resource function delete stringidrecords/[string id]() returns StringIdRecord|persist:Error {
        StringIdRecord result = check self->/stringidrecords/[id].get();
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(STRING_ID_RECORD);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    isolated resource function get intidrecords(IntIdRecordTargetType targetType = <>) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "query"
    } external;

    isolated resource function get intidrecords/[int id](IntIdRecordTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post intidrecords(IntIdRecordInsert[] data) returns int[]|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(INT_ID_RECORD);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from IntIdRecordInsert inserted in data
            select inserted.id;
    }

    isolated resource function put intidrecords/[int id](IntIdRecordUpdate value) returns IntIdRecord|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(INT_ID_RECORD);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        return self->/intidrecords/[id].get();
    }

    isolated resource function delete intidrecords/[int id]() returns IntIdRecord|persist:Error {
        IntIdRecord result = check self->/intidrecords/[id].get();
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(INT_ID_RECORD);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    isolated resource function get floatidrecords(FloatIdRecordTargetType targetType = <>) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "query"
    } external;

    isolated resource function get floatidrecords/[float id](FloatIdRecordTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post floatidrecords(FloatIdRecordInsert[] data) returns float[]|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(FLOAT_ID_RECORD);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from FloatIdRecordInsert inserted in data
            select inserted.id;
    }

    isolated resource function put floatidrecords/[float id](FloatIdRecordUpdate value) returns FloatIdRecord|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(FLOAT_ID_RECORD);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        return self->/floatidrecords/[id].get();
    }

    isolated resource function delete floatidrecords/[float id]() returns FloatIdRecord|persist:Error {
        FloatIdRecord result = check self->/floatidrecords/[id].get();
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(FLOAT_ID_RECORD);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    isolated resource function get decimalidrecords(DecimalIdRecordTargetType targetType = <>) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "query"
    } external;

    isolated resource function get decimalidrecords/[decimal id](DecimalIdRecordTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post decimalidrecords(DecimalIdRecordInsert[] data) returns decimal[]|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(DECIMAL_ID_RECORD);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from DecimalIdRecordInsert inserted in data
            select inserted.id;
    }

    isolated resource function put decimalidrecords/[decimal id](DecimalIdRecordUpdate value) returns DecimalIdRecord|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(DECIMAL_ID_RECORD);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        return self->/decimalidrecords/[id].get();
    }

    isolated resource function delete decimalidrecords/[decimal id]() returns DecimalIdRecord|persist:Error {
        DecimalIdRecord result = check self->/decimalidrecords/[id].get();
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(DECIMAL_ID_RECORD);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    isolated resource function get booleanidrecords(BooleanIdRecordTargetType targetType = <>) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "query"
    } external;

    isolated resource function get booleanidrecords/[boolean id](BooleanIdRecordTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post booleanidrecords(BooleanIdRecordInsert[] data) returns boolean[]|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(BOOLEAN_ID_RECORD);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from BooleanIdRecordInsert inserted in data
            select inserted.id;
    }

    isolated resource function put booleanidrecords/[boolean id](BooleanIdRecordUpdate value) returns BooleanIdRecord|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(BOOLEAN_ID_RECORD);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        return self->/booleanidrecords/[id].get();
    }

    isolated resource function delete booleanidrecords/[boolean id]() returns BooleanIdRecord|persist:Error {
        BooleanIdRecord result = check self->/booleanidrecords/[id].get();
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(BOOLEAN_ID_RECORD);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    isolated resource function get compositeassociationrecords(CompositeAssociationRecordTargetType targetType = <>) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "query"
    } external;

    isolated resource function get compositeassociationrecords/[string id](CompositeAssociationRecordTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post compositeassociationrecords(CompositeAssociationRecordInsert[] data) returns string[]|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(COMPOSITE_ASSOCIATION_RECORD);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from CompositeAssociationRecordInsert inserted in data
            select inserted.id;
    }

    isolated resource function put compositeassociationrecords/[string id](CompositeAssociationRecordUpdate value) returns CompositeAssociationRecord|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(COMPOSITE_ASSOCIATION_RECORD);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        return self->/compositeassociationrecords/[id].get();
    }

    isolated resource function delete compositeassociationrecords/[string id]() returns CompositeAssociationRecord|persist:Error {
        CompositeAssociationRecord result = check self->/compositeassociationrecords/[id].get();
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(COMPOSITE_ASSOCIATION_RECORD);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    isolated resource function get alltypesidrecords(AllTypesIdRecordTargetType targetType = <>) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "query"
    } external;

    isolated resource function get alltypesidrecords/[boolean booleanType]/[int intType]/[float floatType]/[decimal decimalType]/[string stringType](AllTypesIdRecordTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post alltypesidrecords(AllTypesIdRecordInsert[] data) returns [boolean, int, float, decimal, string][]|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(ALL_TYPES_ID_RECORD);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from AllTypesIdRecordInsert inserted in data
            select [inserted.booleanType, inserted.intType, inserted.floatType, inserted.decimalType, inserted.stringType];
    }

    isolated resource function put alltypesidrecords/[boolean booleanType]/[int intType]/[float floatType]/[decimal decimalType]/[string stringType](AllTypesIdRecordUpdate value) returns AllTypesIdRecord|persist:Error {
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(ALL_TYPES_ID_RECORD);
        }
        _ = check sqlClient.runUpdateQuery({"booleanType": booleanType, "intType": intType, "floatType": floatType, "decimalType": decimalType, "stringType": stringType}, value);
        return self->/alltypesidrecords/[booleanType]/[intType]/[floatType]/[decimalType]/[stringType].get();
    }

    isolated resource function delete alltypesidrecords/[boolean booleanType]/[int intType]/[float floatType]/[decimal decimalType]/[string stringType]() returns AllTypesIdRecord|persist:Error {
        AllTypesIdRecord result = check self->/alltypesidrecords/[booleanType]/[intType]/[floatType]/[decimalType]/[stringType].get();
        SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(ALL_TYPES_ID_RECORD);
        }
        _ = check sqlClient.runDeleteQuery({"booleanType": booleanType, "intType": intType, "floatType": floatType, "decimalType": decimalType, "stringType": stringType});
        return result;
    }

    public isolated function close() returns persist:Error? {
        error? result = self.dbClient.close();
        if result is error {
            return <persist:Error>error(result.message());
        }
        return result;
    }
}

