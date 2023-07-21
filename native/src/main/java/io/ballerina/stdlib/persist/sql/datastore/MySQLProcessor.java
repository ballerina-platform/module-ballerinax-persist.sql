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
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BStream;
import io.ballerina.runtime.api.values.BTypedesc;

/**
 * This class provides the MySQL query processing implementations for persistence.
 *
 * @since 1.0.1
 */
public class MySQLProcessor {

    private MySQLProcessor() {
    }

    public static BStream query(Environment env, BObject client, BTypedesc targetType, BObject whereClause,
                                BObject orderClause, BObject limitClause, BObject groupByClause) {
        return SQLProcessor.query(env, client, targetType, whereClause, orderClause, limitClause, groupByClause);
    }

    public static Object queryOne(Environment env, BObject client, BArray path, BTypedesc targetType) {
        return SQLProcessor.queryOne(env, client, path, targetType);
    }

}
