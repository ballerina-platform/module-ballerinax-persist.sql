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

package io.ballerina.stdlib.persist.sql;

import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BStream;
import io.ballerina.runtime.api.values.BTypedesc;

import static io.ballerina.stdlib.persist.sql.Constants.PERSIST_SQL_STREAM;
import static io.ballerina.stdlib.persist.sql.ModuleUtils.getModule;

/**
 * This class provides the SQL util methods for persistence.
 *
 * @since 1.1.0
 */
public class Utils {

    private static BObject createPersistSQLStream(BStream sqlStream, BTypedesc targetType, BArray fields,
                                                  BArray includes, BArray typeDescriptions, BObject persistClient,
                                                  BError persistError) {
        return ValueCreator.createObjectValue(getModule(), PERSIST_SQL_STREAM,
                sqlStream, targetType, fields, includes, typeDescriptions, persistClient, persistError);
    }

    private static BStream createPersistSQLStreamValue(BTypedesc targetType, BObject persistSQLStream) {
        RecordType streamConstraint =
                (RecordType) TypeUtils.getReferredType(targetType.getDescribingType());
        return ValueCreator.createStreamValue(
                TypeCreator.createStreamType(streamConstraint, PredefinedTypes.TYPE_NULL), persistSQLStream);
    }

    public static BStream createPersistSQLStreamValue(BStream sqlStream, BTypedesc targetType, BArray fields,
                                                      BArray includes, BArray typeDescriptions, BObject persistClient,
                                                      BError persistError) {
        BObject persistSQLStream = createPersistSQLStream(sqlStream, targetType, fields, includes, typeDescriptions,
                persistClient, persistError);
        return createPersistSQLStreamValue(targetType, persistSQLStream);
    }
}
