package io.ballerina.stdlib.persist.sql;

import io.ballerina.runtime.api.values.BError;

public interface Handler {
    void notifySuccess(Object result);

    void notifyFailure(BError bError);
}
