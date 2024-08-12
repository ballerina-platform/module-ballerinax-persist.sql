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
import io.ballerina.runtime.api.constants.RuntimeConstants;
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
import io.ballerina.runtime.transactions.TransactionLocalContext;
import io.ballerina.runtime.transactions.TransactionResourceManager;
import io.ballerina.stdlib.persist.Constants;
import io.ballerina.stdlib.persist.ModuleUtils;
import io.ballerina.stdlib.persist.sql.Utils;

import java.util.Map;

import static io.ballerina.stdlib.persist.Constants.ERROR;
import static io.ballerina.stdlib.persist.Constants.KEY_FIELDS;
import static io.ballerina.stdlib.persist.ErrorGenerator.wrapError;
import static io.ballerina.stdlib.persist.Utils.getEntity;
import static io.ballerina.stdlib.persist.Utils.getKey;
import static io.ballerina.stdlib.persist.Utils.getMetadata;
import static io.ballerina.stdlib.persist.Utils.getPersistClient;
import static io.ballerina.stdlib.persist.Utils.getRecordTypeWithKeyFields;
import static io.ballerina.stdlib.persist.Utils.getTransactionContextProperties;
import static io.ballerina.stdlib.persist.sql.Constants.DB_CLIENT;
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
        StreamType streamTypeWithIdFields = TypeCreator.createStreamType(recordTypeWithIdFields,
                PredefinedTypes.TYPE_NULL);

        Map<String, Object> trxContextProperties = getTransactionContextProperties();
        String strandName = env.getStrandName().isPresent() ? env.getStrandName().get() : null;

        BArray[] metadata = getMetadata(recordType);
        BArray fields = metadata[0];
        BArray includes = metadata[1];
        BArray typeDescriptions = metadata[2];

        Future balFuture = env.markAsync();
        env.getRuntime().invokeMethodAsyncSequentially(
                // Call `SQLClient.runReadQuery(
                //      typedesc<record {}> rowType, string[] fields = [], string[] include = []
                // )`
                // which returns `stream<record {}, sql:Error?>|persist:Error`

                persistClient, Constants.RUN_READ_QUERY_METHOD, strandName, env.getStrandMetadata(), new Callback() {
                    @Override
                    public void notifySuccess(Object o) {
                        if (o instanceof BStream) { // stream<record {}, sql:Error?>
                            BStream sqlStream = (BStream) o;
                            balFuture.complete(Utils.createPersistSQLStreamValue(sqlStream, targetType, fields,
                                    includes, typeDescriptions, persistClient, null));
                        } else { // persist:Error
                            balFuture.complete(Utils.createPersistSQLStreamValue(null, targetType, fields, includes,
                                    typeDescriptions, persistClient, (BError) o));
                        }
                    }

                    @Override
                    public void notifyFailure(BError bError) {
                        balFuture.complete(Utils.createPersistSQLStreamValue(null, targetType, fields, includes,
                                typeDescriptions, persistClient, wrapError(bError)));
                    }
                }, trxContextProperties, streamTypeWithIdFields,
                targetTypeWithIdFields, true, fields, true, includes, true, whereClause, true, orderByClause,
                true, limitClause, true, groupByClause, true
        );

        return null;
    }

    static Object queryOne(Environment env, BObject client, BArray path, BTypedesc targetType) {
        // This method will return `targetType|persist:Error`

        BString entity = getEntity(env);
        BObject persistClient = getPersistClient(client, entity);

        BArray keyFields = (BArray) persistClient.get(KEY_FIELDS);
        RecordType recordType = (RecordType) targetType.getDescribingType();

        Map<String, Object> trxContextProperties = getTransactionContextProperties();
        String strandName = env.getStrandName().isPresent() ? env.getStrandName().get() : null;

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
                // Call `SQLClient.runReadByKeyQuery(
                //      typedesc<record {}> rowType, typedesc<record {}> rowTypeWithIdFields, anydata key,
                //      string[] fields = [], string[] include = [], typedesc<record {}>[] typeDescriptions = []
                // )`
                // which returns `record {}|persist:Error`

                getPersistClient(client, entity), Constants.RUN_READ_BY_KEY_QUERY_METHOD, strandName,
                env.getStrandMetadata(), new Callback() {
                    @Override
                    public void notifySuccess(Object o) {
                        balFuture.complete(o);
                    }

                    @Override
                    public void notifyFailure(BError bError) {
                        balFuture.complete(wrapError(bError));
                    }
                },  trxContextProperties, unionType,
                targetType, true, targetTypeWithIdFields, true, key, true, fields, true, includes, true,
                typeDescriptions, true
        );

        return null;
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
        RecordType recordType = (RecordType) targetType.getDescribingType();
        StreamType streamType = TypeCreator.createStreamType(recordType, PredefinedTypes.TYPE_NULL);
        TransactionResourceManager trxResourceManager = TransactionResourceManager.getInstance();
        TransactionLocalContext currentTrxContext = trxResourceManager.getCurrentTransactionContext();
        Map<String, Object> properties = null;
        if (currentTrxContext != null) {
            properties = Map.of(RuntimeConstants.CURRENT_TRANSACTION_CONTEXT_PROPERTY, currentTrxContext);
        }

        Future balFuture = env.markAsync();
        env.getRuntime().invokeMethodAsyncSequentially(
                // Call `sqlClient.query(paramSQLString, targetType)` which returns `stream<targetType, sql:Error?>`

                dbClient, SQL_QUERY_METHOD, null, env.getStrandMetadata(), new Callback() {
                    @Override
                    public void notifySuccess(Object o) {
                        // returned type is `stream<record {}, sql:Error?>`
                        BStream sqlStream = (BStream) o;
                        BObject persistNativeStream = createPersistNativeSQLStream(sqlStream, null);
                        RecordType streamConstraint =
                                (RecordType) TypeUtils.getReferredType(targetType.getDescribingType());
                        balFuture.complete(
                                ValueCreator.createStreamValue(TypeCreator.createStreamType(streamConstraint,
                                        PredefinedTypes.TYPE_NULL), persistNativeStream)
                        );
                    }

                    @Override
                    public void notifyFailure(BError bError) { // can only be hit on a panic
                        BObject errorStream = Utils.createPersistNativeSQLStream(null, bError);
                        balFuture.complete(errorStream);
                    }
                }, properties, streamType, paramSQLString, true, targetType, true
        );

        return null;
    }

    private static Object executeNativeSQLBal(Environment env, BObject client, BObject paramSQLString) {
        BObject dbClient = (BObject) client.get(DB_CLIENT);
        RecordType persistExecutionResultType = TypeCreator.createRecordType(
                io.ballerina.stdlib.persist.sql.Constants.PERSIST_EXECUTION_RESULT, getModule(), 0, true, 0);
        TransactionResourceManager trxResourceManager = TransactionResourceManager.getInstance();
        TransactionLocalContext currentTrxContext = trxResourceManager.getCurrentTransactionContext();
        Map<String, Object> properties = null;
        if (currentTrxContext != null) {
            properties = Map.of(RuntimeConstants.CURRENT_TRANSACTION_CONTEXT_PROPERTY, currentTrxContext);
        }

        Future balFuture = env.markAsync();
        env.getRuntime().invokeMethodAsyncSequentially(
                // Call `sqlClient.execute(paramSQLString)` which returns `sql:ExecutionResult|sql:Error`

                dbClient, SQL_EXECUTE_METHOD, null, env.getStrandMetadata(), new Callback() {
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
                        }
                    }

                    @Override
                    public void notifyFailure(BError bError) { // can only be hit on a panic
                        BError persistError = wrapError(bError);
                        balFuture.complete(persistError);
                    }
                }, properties,
                persistExecutionResultType, paramSQLString, true);

        return null;
    }
}
