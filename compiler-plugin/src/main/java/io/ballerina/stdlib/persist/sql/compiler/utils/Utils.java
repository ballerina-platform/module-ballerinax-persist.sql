package io.ballerina.stdlib.persist.sql.compiler.utils;

public class Utils {
    public static String stripEscapeCharacter(String name) {
        return name.startsWith("'") ? name.substring(1) : name;
    }
}
