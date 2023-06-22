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
import io.ballerina.runtime.api.Future;
import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.async.Callback;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.ErrorType;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.types.StreamType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BStream;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;
import io.ballerina.stdlib.persist.Constants;
import io.ballerina.stdlib.persist.ModuleUtils;

import java.util.Map;

import static io.ballerina.stdlib.persist.Constants.ERROR;
import static io.ballerina.stdlib.persist.Constants.KEY_FIELDS;
import static io.ballerina.stdlib.persist.Utils.getEntity;
import static io.ballerina.stdlib.persist.Utils.getKey;
import static io.ballerina.stdlib.persist.Utils.getMetadata;
import static io.ballerina.stdlib.persist.Utils.getPersistClient;
import static io.ballerina.stdlib.persist.Utils.getRecordTypeWithKeyFields;
import static io.ballerina.stdlib.persist.Utils.getTransactionContextProperties;
import static io.ballerina.stdlib.persist.sql.Constants.DB_CLIENT;
import static io.ballerina.stdlib.persist.sql.Constants.PERSIST_SQL_STREAM;
import static io.ballerina.stdlib.persist.sql.Constants.SQL_EXECUTE_METHOD;
import static io.ballerina.stdlib.persist.sql.Constants.SQL_QUERY_METHOD;
import static io.ballerina.stdlib.persist.sql.ModuleUtils.getModule;
import static io.ballerina.stdlib.persist.sql.Utils.createPersistNativeSQLStream;
import static io.ballerina.stdlib.persist.sql.Utils.getBasicPersistError;
import static io.ballerina.stdlib.persist.sql.Utils.getErrorStream;
import static io.ballerina.stdlib.persist.sql.Utils.wrapError;
import static io.ballerina.stdlib.persist.sql.Utils.wrapSQLError;

/**
 * This class provides the SQL query processing implementations for persistence.
 *
 * @since 0.3.0
 */
public class SQLProcessor {

    static BStream query(Environment env, BObject client, BTypedesc targetType) {
        BString entity = getEntity(env);
        BObject persistClient = getPersistClient(client, entity);
        BArray keyFields = (BArray) persistClient.get(KEY_FIELDS);
        RecordType recordType = (RecordType) targetType.getDescribingType();

        RecordType recordTypeWithIdFields = getRecordTypeWithKeyFields(keyFields, recordType);
        BTypedesc targetTypeWithIdFields = ValueCreator.createTypedescValue(recordTypeWithIdFields);
        StreamType streamTypeWithIdFields = TypeCreator.createStreamType(recordTypeWithIdFields,
                PredefinedTypes.TYPE_NULL);

        Map<String, Object> trxContextProperties = getTransactionContextProperties();

        BArray[] metadata = getMetadata(recordType);
        BArray fields = metadata[0];
        BArray includes = metadata[1];
        BArray typeDescriptions = metadata[2];

        Future balFuture = env.markAsync();
        env.getRuntime().invokeMethodAsyncSequentially(
                persistClient, Constants.RUN_READ_QUERY_METHOD, null, null, new Callback() {
                    @Override
                    public void notifySuccess(Object o) {
                        BStream sqlStream = (BStream) o;
                        BObject persistStream = ValueCreator.createObjectValue(
                                getModule(), PERSIST_SQL_STREAM, sqlStream, targetType,
                                fields, includes, typeDescriptions, persistClient, null
                        );

                        RecordType streamConstraint =
                                (RecordType) TypeUtils.getReferredType(targetType.getDescribingType());
                        balFuture.complete(
                                ValueCreator.createStreamValue(TypeCreator.createStreamType(streamConstraint,
                                        PredefinedTypes.TYPE_NULL), persistStream)
                        );
                    }

                    @Override
                    public void notifyFailure(BError bError) {
                        balFuture.complete(bError);
                    }
                }, trxContextProperties, streamTypeWithIdFields,
                targetTypeWithIdFields, true, fields, true, includes, true
        );

        return null;
    }

    static Object queryOne(Environment env, BObject client, BArray path, BTypedesc targetType) {

        BString entity = getEntity(env);
        BObject persistClient = getPersistClient(client, entity);

        BArray keyFields = (BArray) persistClient.get(KEY_FIELDS);
        RecordType recordType = (RecordType) targetType.getDescribingType();

        Map<String, Object> trxContextProperties = getTransactionContextProperties();

        RecordType recordTypeWithIdFields = getRecordTypeWithKeyFields(keyFields, recordType);
        BTypedesc targetTypeWithIdFields = ValueCreator.createTypedescValue(recordTypeWithIdFields);
        ErrorType persistErrorType = TypeCreator.createErrorType(ERROR, ModuleUtils.getModule());
        Type unionType = TypeCreator.createUnionType(recordTypeWithIdFields, persistErrorType);

        BArray[] metadata = getMetadata(recordType);
        BArray fields = metadata[0];
        BArray includes = metadata[1];
        BArray typeDescriptions = metadata[2];

        Object key = getKey(env, path);

        Future balFuture = env.markAsync();
        env.getRuntime().invokeMethodAsyncSequentially(
                getPersistClient(client, entity), Constants.RUN_READ_BY_KEY_QUERY_METHOD, null, null, new Callback() {
                    @Override
                    public void notifySuccess(Object o) {
                        balFuture.complete(o);
                    }

                    @Override
                    public void notifyFailure(BError bError) {
                        balFuture.complete(bError);
                    }
                },  trxContextProperties, unionType,
                targetType, true, targetTypeWithIdFields, true, key, true, fields, true, includes, true,
                typeDescriptions, true
        );

        return null;
    }

    public static BStream queryNativeSQL(Environment env, BObject client, BObject paramSQLString,
                                         BTypedesc targetType) {
        // This method will return `stream<targetType, persist:Error?>`

        BObject dbClient = (BObject) client.get(DB_CLIENT);
        RecordType recordType = (RecordType) targetType.getDescribingType();
        StreamType streamType = TypeCreator.createStreamType(recordType, PredefinedTypes.TYPE_NULL);

        Map<String, Object> trxContextProperties = getTransactionContextProperties();

        Future balFuture = env.markAsync();
        env.getRuntime().invokeMethodAsyncSequentially(
                // Call `sqlClient.query(paramSQLString, targetType)` which returns `stream<targetType, sql:Error?>`

                dbClient, SQL_QUERY_METHOD, null, null, new Callback() {
                    @Override
                    public void notifySuccess(Object o) {
                        if (o instanceof BStream) { // returned type is `stream<record {}, sql:Error?>`
                            BStream sqlStream = (BStream) o;
                            BObject persistNativeStream = createPersistNativeSQLStream(sqlStream, null);
                            RecordType streamConstraint =
                                    (RecordType) TypeUtils.getReferredType(targetType.getDescribingType());
                            balFuture.complete(
                                    ValueCreator.createStreamValue(TypeCreator.createStreamType(streamConstraint,
                                            PredefinedTypes.TYPE_NULL), persistNativeStream)
                            );
                        } else { // Unreachable code
                            BError persistError = getBasicPersistError("Error while executing native SQL query.");
                            BStream errorStream = getErrorStream(recordType, persistError);
                            balFuture.complete(errorStream);
                        }
                    }

                    @Override
                    public void notifyFailure(BError bError) { // can only be hit on a panic
                        BError persistError = wrapError(bError);
                        BStream errorStream = getErrorStream(recordType, persistError);
                        balFuture.complete(errorStream);
                    }
                }, trxContextProperties, streamType, paramSQLString, true, targetType, true
        );

        return null;
    }

    public static Object executeNativeSQL(Environment env, BObject client, BObject paramSQLString) {
        // This method will return `persist:ExecutionResult|persist:Error`

        BObject dbClient = (BObject) client.get(DB_CLIENT);
        RecordType persistExecutionResultType = TypeCreator.createRecordType(
                io.ballerina.stdlib.persist.sql.Constants.PERSIST_EXECUTION_RESULT, getModule(), 0, true, 0);
        Map<String, Object> trxContextProperties = getTransactionContextProperties();

        Future balFuture = env.markAsync();
        env.getRuntime().invokeMethodAsyncSequentially(
                // Call `sqlClient.execute(paramSQLString)` which returns `sql:ExecutionResult|sql:Error`

                dbClient, SQL_EXECUTE_METHOD, null, null, new Callback() {
                    @Override
                    public void notifySuccess(Object o) {
                        if (o instanceof BMap) { // returned type is `sql:ExecutionResult`
                            BMap<BString, Object> persistExecutionResult =
                                    ValueCreator.createRecordValue(getModule(),
                                            io.ballerina.stdlib.persist.sql.Constants.PERSIST_EXECUTION_RESULT,
                                            (BMap<BString, Object>) o);
                            balFuture.complete(persistExecutionResult);
                        } else if (o instanceof BError) { // returned type is `sql:Error`
                            BError persistError = wrapSQLError((BError) o);
                            balFuture.complete(persistError);
                        } else { // Unreachable code
                            BError persistError = getBasicPersistError("Error while executing native SQL query.");
                            balFuture.complete(persistError);
                        }
                    }

                    @Override
                    public void notifyFailure(BError bError) { // can only be hit on a panic
                        BError persistError = wrapError(bError);
                        balFuture.complete(persistError);
                    }
                }, trxContextProperties, persistExecutionResultType, paramSQLString, true
        );

        return null;
    }
}
