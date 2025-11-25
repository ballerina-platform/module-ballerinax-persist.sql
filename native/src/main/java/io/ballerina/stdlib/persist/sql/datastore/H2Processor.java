/*
 *  Copyright (c) 2024, WSO2 LLC. (http://www.wso2.org).
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
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BStream;
import io.ballerina.runtime.api.values.BTypedesc;

public class H2Processor {

    private H2Processor() {
    }

    public static BStream query(Environment env, BObject client, BTypedesc targetType, BObject whereClause,
                                BObject orderClause, BObject limitClause, BObject groupByClause) {
        return SQLProcessor.query(env, client, targetType, whereClause, orderClause, limitClause, groupByClause);
    }

    public static Object queryAsList(Environment env, BObject client, BTypedesc targetType, BObject whereClause,
                                     BObject orderClause, BObject limitClause, BObject groupByClause) {
        return SQLProcessor.queryAsList(env, client, targetType, whereClause, orderClause, limitClause, groupByClause);
    }

    public static Object queryOne(Environment env, BObject client, BArray path, BTypedesc targetType) {
        return SQLProcessor.queryOne(env, client, path, targetType);
    }

    public static Object executeNativeSQL(Environment env, BObject client, BObject paramSQLString) {
        return SQLProcessor.executeNativeSQL(env, client, paramSQLString);
    }

    public static BStream queryNativeSQL(Environment env, BObject client, BObject paramSQLString,
                                         BTypedesc targetType) {
        return SQLProcessor.queryNativeSQL(env, client, paramSQLString, targetType);
    }
}
