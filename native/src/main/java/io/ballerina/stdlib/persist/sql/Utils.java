package io.ballerina.stdlib.persist.sql;

import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BStream;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;

import static io.ballerina.stdlib.persist.sql.Constants.PERSIST_ERROR;
import static io.ballerina.stdlib.persist.sql.ModuleUtils.getModule;

/**
 * This is the util class for persist.
 *
 * @since 1.1.0
 */
public class Utils {

    private static BError generatePersistError(BString message, BError cause, BMap<BString, Object> details) {
        return ErrorCreator.createError(
                io.ballerina.stdlib.persist.ModuleUtils.getModule(), PERSIST_ERROR, message, cause, details);
    }

    public static BError getBasicPersistError(String message) {
        return generatePersistError(StringUtils.fromString(message), null, null);
    }

    public static BError wrapSQLError(BError sqlError) {
        return generatePersistError(sqlError.getErrorMessage(), sqlError.getCause(),
                (BMap<BString, Object>) (sqlError.getDetails()));
    }

    public static BError wrapError(BError error) {
        return generatePersistError(error.getErrorMessage(), error.getCause(), null);
    }

    public static BStream getErrorStream(Object recordType, BError errorValue) {
        BObject persistNativeStream = createPersistNativeSQLStream(null, errorValue);

        return ValueCreator.createStreamValue(
                TypeCreator.createStreamType(((BTypedesc) recordType).getDescribingType(),
                        PredefinedTypes.TYPE_NULL), persistNativeStream);
    }

    public static BObject createPersistNativeSQLStream(BStream sqlStream, BError error) {
        return ValueCreator.createObjectValue(getModule(),
                io.ballerina.stdlib.persist.sql.Constants.PERSIST_NATIVE_SQL_STREAM, sqlStream, error);
    }

}
