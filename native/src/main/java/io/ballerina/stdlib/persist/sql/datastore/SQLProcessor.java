/*
 *  Copyright (c) 2023, WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
 *
 *  WSO2 LLC. licenses this file to you under the Apache License,
 *  Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */

package io.ballerina.stdlib.persist.sql.datastore;

import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.PredefinedTypes;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BStream;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;
import io.ballerina.stdlib.persist.Constants;
import io.ballerina.stdlib.persist.sql.Utils;

import static io.ballerina.stdlib.persist.Constants.KEY_FIELDS;
import static io.ballerina.stdlib.persist.ErrorGenerator.wrapError;
import static io.ballerina.stdlib.persist.Utils.getEntity;
import static io.ballerina.stdlib.persist.Utils.getKey;
import static io.ballerina.stdlib.persist.Utils.getMetadata;
import static io.ballerina.stdlib.persist.Utils.getPersistClient;
import static io.ballerina.stdlib.persist.Utils.getRecordTypeWithKeyFields;
import static io.ballerina.stdlib.persist.sql.Constants.DB_CLIENT;
import static io.ballerina.stdlib.persist.sql.Constants.PERSIST_EXECUTION_RESULT;
import static io.ballerina.stdlib.persist.sql.Constants.SQL_EXECUTE_METHOD;
import static io.ballerina.stdlib.persist.sql.Constants.SQL_QUERY_METHOD;
import static io.ballerina.stdlib.persist.sql.ModuleUtils.getModule;
import static io.ballerina.stdlib.persist.sql.Utils.createPersistNativeSQLStream;
import static io.ballerina.stdlib.persist.sql.Utils.wrapSQLError;

/**
 * This class provides the SQL query processing implementations for persistence.
 *
 * @since 0.3.0
 */
public class SQLProcessor {

    private SQLProcessor() {
    }

    static BStream query(Environment env, BObject client, BTypedesc targetType, BObject whereClause,
                         BObject orderByClause, BObject limitClause, BObject groupByClause) {
        // This method will return `stream<targetType, persist:Error?>`
        BString entity = getEntity(env);
        BObject persistClient = getPersistClient(client, entity);
        BArray keyFields = (BArray) persistClient.get(KEY_FIELDS);
        RecordType recordType = (RecordType) targetType.getDescribingType();

        RecordType recordTypeWithIdFields = getRecordTypeWithKeyFields(keyFields, recordType);
        BTypedesc targetTypeWithIdFields = ValueCreator.createTypedescValue(recordTypeWithIdFields);
        BArray[] metadata = getMetadata(recordType);
        BArray fields = metadata[0];
        BArray includes = metadata[1];
        BArray typeDescriptions = metadata[2];
        return env.yieldAndRun(() -> {
            try {
                Object result = env.getRuntime().callMethod(
                        // Call `SQLClient.runReadQuery(
                        //      typedesc<record {}> rowType, string[] fields = [], string[] include = []
                        // )`
                        // which returns `stream<record {}, sql:Error?>|persist:Error`
                        persistClient, Constants.RUN_READ_QUERY_METHOD, null, targetTypeWithIdFields, fields, includes,
                        whereClause, orderByClause, limitClause, groupByClause);
                if (result instanceof BStream bStream) { // stream<record {}, sql:Error?>
                    return Utils.createPersistSQLStreamValue(bStream, targetType, fields, includes, typeDescriptions,
                            persistClient, null);
                }
                // persist:Error
                return Utils.createPersistSQLStreamValue(null, targetType, fields, includes, typeDescriptions,
                        persistClient, (BError) result);
            } catch (BError bError) {
                return Utils.createPersistSQLStreamValue(null, targetType, fields, includes, typeDescriptions,
                        persistClient, wrapError(bError));
            }
        });
    }

    static Object queryAsList(Environment env, BObject client, BTypedesc targetType, BObject whereClause,
                              BObject orderByClause, BObject limitClause) {
        // This method will return `targetType[]|persist:Error`
        BString entity = getEntity(env);
        BObject persistClient = getPersistClient(client, entity);
        BArray keyFields = (BArray) persistClient.get(KEY_FIELDS);
        RecordType recordType = (RecordType) targetType.getDescribingType();

        RecordType recordTypeWithIdFields = getRecordTypeWithKeyFields(keyFields, recordType);
        BTypedesc targetTypeWithIdFields = ValueCreator.createTypedescValue(recordTypeWithIdFields);
        BTypedesc rowsType = ValueCreator.createTypedescValue(TypeCreator.createArrayType(
                targetType.getDescribingType()));
        BArray[] metadata = getMetadata(recordType);
        BArray fields = metadata[0];
        BArray includes = metadata[1];
        BArray typeDescriptions = metadata[2];
        return env.yieldAndRun(() -> {
            try {
                return env.getRuntime().callMethod(
                        // Call `SQLClient.runReadQueryAsList(
                        //      typedesc<record {}[]> rowsType, typedesc<record {}> rowType,
                        //      typedesc<record {}> rowTypeWithIdFields, string[] fields = [], string[] include = [],
                        //      whereClause, orderByClause, limitClause, typedesc<record {}>[] typeDescriptions = []
                        // )`
                        // which returns `record {}[]|persist:Error`
                        persistClient, "runReadQueryAsList", null, rowsType, targetType,
                        targetTypeWithIdFields, fields, includes, whereClause, orderByClause, limitClause,
                        typeDescriptions);
            } catch (BError bError) {
                return wrapError(bError);
            }
        });
    }

    static Object queryOne(Environment env, BObject client, BArray path, BTypedesc targetType) {
        // This method will return `targetType|persist:Error`
        BString entity = getEntity(env);
        BObject persistClient = getPersistClient(client, entity);

        BArray keyFields = (BArray) persistClient.get(KEY_FIELDS);
        RecordType recordType = (RecordType) targetType.getDescribingType();

        RecordType recordTypeWithIdFields = getRecordTypeWithKeyFields(keyFields, recordType);
        BTypedesc targetTypeWithIdFields = ValueCreator.createTypedescValue(recordTypeWithIdFields);

        BArray[] metadata = getMetadata(recordType);
        BArray fields = metadata[0];
        BArray includes = metadata[1];
        BArray typeDescriptions = metadata[2];

        Object key = getKey(env, path);
        return env.yieldAndRun(() -> {
            try {
                return env.getRuntime().callMethod(
                        // Call `SQLClient.runReadByKeyQuery(
                        //      typedesc<record {}> rowType, typedesc<record {}> rowTypeWithIdFields, anydata key,
                        //      string[] fields = [], string[] include = [], typedesc<record {}>[] typeDescriptions = []
                        // )`
                        // which returns `record {}|persist:Error`
                        getPersistClient(client, entity), Constants.RUN_READ_BY_KEY_QUERY_METHOD, null, targetType,
                        targetTypeWithIdFields, key, fields, includes, typeDescriptions);
            } catch (BError bError) {
                return wrapError(bError);
            }
        });
    }

    static BStream queryNativeSQL(Environment env, BObject client, BObject paramSQLString,
                                         BTypedesc targetType) {
        // This method will return `stream<targetType, persist:Error?>`
        return queryNativeSQLBal(env, client, paramSQLString, targetType);
    }

    static Object executeNativeSQL(Environment env, BObject client, BObject paramSQLString) {
        // This method will return `persist:ExecutionResult|persist:Error`
        return executeNativeSQLBal(env, client, paramSQLString);
    }

    private static BStream queryNativeSQLBal(Environment env, BObject client, BObject paramSQLString,
                                            BTypedesc targetType) {
        // This method will return `stream<targetType, persist:Error?>`
        BObject dbClient = (BObject) client.get(DB_CLIENT);
        return (BStream) env.yieldAndRun(() -> {
            try {
                Object result = env.getRuntime().callMethod(
                        // Call `sqlClient.query(paramSQLString, targetType)` which returns
                        // `stream<targetType, sql:Error?>`
                        dbClient, SQL_QUERY_METHOD, null, paramSQLString, targetType);
                // returned type is `stream<record {}, sql:Error?>`
                BStream sqlStream = (BStream) result;
                BObject persistNativeStream = createPersistNativeSQLStream(sqlStream, null);
                RecordType streamConstraint =
                        (RecordType) TypeUtils.getReferredType(targetType.getDescribingType());
                return ValueCreator.createStreamValue(TypeCreator.createStreamType(streamConstraint,
                        PredefinedTypes.TYPE_NULL), persistNativeStream);
            } catch (BError bError) {
                return Utils.createPersistNativeSQLStream(null, bError);
            }
        });
    }

    private static Object executeNativeSQLBal(Environment env, BObject client, BObject paramSQLString) {
        BObject dbClient = (BObject) client.get(DB_CLIENT);
        return env.yieldAndRun(() -> {
            try {
                Object result = env.getRuntime().callMethod(
                        // Call `sqlClient.execute(paramSQLString)` which returns `sql:ExecutionResult|sql:Error`
                        dbClient, SQL_EXECUTE_METHOD, null, paramSQLString);
                if (result instanceof BMap map) { // returned type is `sql:ExecutionResult`
                    return ValueCreator.createRecordValue(getModule(), PERSIST_EXECUTION_RESULT, (BMap<BString,
                            Object>) map);
                }
                return wrapSQLError((BError) result);
            } catch (BError bError) {
                return bError;
            }
        });
    }
}
