/*
 * Copyright (c) 2024 WSO2 LLC. (http://www.wso2.com) All Rights Reserved.
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.stdlib.persist.sql.compiler;

import io.ballerina.projects.DiagnosticResult;
import io.ballerina.projects.Package;
import io.ballerina.projects.directory.SingleFileProject;
import io.ballerina.tools.diagnostics.Diagnostic;
import io.ballerina.tools.diagnostics.DiagnosticInfo;
import io.ballerina.tools.diagnostics.DiagnosticSeverity;
import org.testng.Assert;
import org.testng.annotations.Test;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.stream.Collectors;

import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_423;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_424;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_426;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_427;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_428;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_429;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_430;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_600;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_601;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_604;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_605;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_606;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_607;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_608;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_609;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_610;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_611;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_612;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_613;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_614;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_615;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_616;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_617;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_618;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_619;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_620;
import static io.ballerina.stdlib.persist.sql.compiler.DiagnosticsCodes.PERSIST_SQL_621;
import static io.ballerina.stdlib.persist.sql.compiler.TestUtils.getEnvironmentBuilder;

/**
 * Tests persist compiler plugin.
 */
public class CompilerPluginTest {


    private Package loadPersistModelFile(String directory, String name) {
        Path projectDirPath = Paths.get("src", "test", "resources", directory, "persist").
                toAbsolutePath().resolve(name);
        SingleFileProject project = SingleFileProject.load(getEnvironmentBuilder(), projectDirPath);
        return project.currentPackage();
    }

    @Test(enabled = true)
    public void validateCharAnnotations() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("modelvalidator", "char.bal", 3);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_SQL_605.getCode(),
                        PERSIST_SQL_607.getCode(),
                        PERSIST_SQL_604.getCode()
                },
                new String[]{
                        "invalid use of `VarChar` and `Char` annotations. only one of either `VarChar` or `Char` " +
                                "annotations can be used at a time.",
                        "invalid use of the `'Char'` annotation. length cannot be 0.",
                        "invalid use of the `'Char'` annotation. the `'Char'` annotation can only be used for " +
                                "'string' type."
                },
                new String[]{
                        "(33:4,35:18)",
                        "(44:4,45:16)",
                        "(46:4,47:12)"
                }
        );
    }

    @Test(enabled = true)
    public void validateVarCharAnnotations() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("modelvalidator", "varchar.bal", 3);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_SQL_605.getCode(),
                        PERSIST_SQL_607.getCode(),
                        PERSIST_SQL_604.getCode()
                },
                new String[]{
                        "invalid use of `VarChar` and `Char` annotations. only one of either `VarChar` or `Char` " +
                                "annotations can be used at a time.",
                        "invalid use of the `'VarChar'` annotation. length cannot be 0.",
                        "invalid use of the `'VarChar'` annotation. the `'VarChar'` annotation can only be used for " +
                                "'string' type."
                },
                new String[]{
                        "(33:4,35:18)",
                        "(44:4,45:16)",
                        "(46:4,47:12)"
                }
        );
    }

    @Test(enabled = true)
    public void validateDecimalAnnotations() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("modelvalidator", "decimal.bal", 3);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_SQL_606.getCode(),
                        PERSIST_SQL_608.getCode(),
                        PERSIST_SQL_609.getCode()
                },
                new String[]{
                        "invalid use of the `Decimal` annotation. the `Decimal` annotation can only be used for " +
                                "''decimal'' type.",
                        "invalid use of the `Decimal` annotation. precision cannot be 0.",
                        "invalid use of the `Decimal` annotation. precision cannot be less than scale."
                },
                new String[]{
                        "(22:4,23:12)",
                        "(24:4,25:19)",
                        "(24:4,25:19)"
                }
        );
    }

    @Test(enabled = true)
    public void validateEntityNameMappingAnnotations() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("modelvalidator", "entity_name_mapping.bal", 4);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_SQL_600.getCode(),
                        PERSIST_SQL_601.getCode(),
                        PERSIST_SQL_610.getCode(),
                        PERSIST_SQL_620.getCode()
                },
                new String[]{
                        "invalid use of the `Mapping` annotation. mapping name cannot be empty.",
                        "redundant use of the `Mapping` annotation. mapping name is same as model definition.",
                        "invalid use of the `Mapping` annotation. duplicate mapping name found.",
                        "invalid use of the `Mapping` annotation. a mapping name should not conflict with an " +
                                "Entity name"
                },
                new String[]{
                        "(32:12,32:23)",
                        "(42:12,42:19)",
                        "(60:12,60:17)",
                        "(74:12,74:25)"
                }
        );
    }

    @Test(enabled = true)
    public void validateFieldNameMappingAnnotations() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("modelvalidator", "table_name_mapping.bal", 4);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_SQL_600.getCode(),
                        PERSIST_SQL_610.getCode(),
                        PERSIST_SQL_601.getCode(),
                        PERSIST_SQL_621.getCode()
                },
                new String[]{
                        "invalid use of the `Mapping` annotation. mapping name cannot be empty.",
                        "invalid use of the `Mapping` annotation. duplicate mapping name found.",
                        "redundant use of the `Mapping` annotation. mapping name is same as model definition.",
                        "invalid use of the `Mapping` annotation. a mapping name should not conflict with a field name"
                },
                new String[]{
                        "(36:4,37:29)",
                        "(48:4,49:24)",
                        "(59:4,60:23)",
                        "(70:4,71:18)"
                }
        );
    }

    @Test(enabled = true)
    public void validateRelationAnnotations1() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("modelvalidator", "relation1.bal", 1);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_SQL_423.getCode()
                },
                new String[]{
                        "invalid use of the `Relation` annotation. mismatched number of reference keys for relation " +
                                "'Person' in entity 'Car'. expected 2 but found 1."
                },
                new String[]{
                        "(35:4,36:17)"
                }
        );
    }

    @Test(enabled = true)
    public void validateRelationAnnotations2() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("modelvalidator", "relation2.bal", 1);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_SQL_424.getCode()
                },
                new String[]{
                        "invalid use of the `Relation` annotation. mismatched key types for the related " +
                                "entity 'Person'."
                },
                new String[]{
                        "(34:4,35:17)"
                }
        );
    }

    @Test(enabled = true)
    public void validateRelationAnnotations3() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("modelvalidator", "relation3.bal", 1);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_SQL_426.getCode()
                },
                new String[]{
                        "invalid use of the `Relation` annotation. the field 'cars' is an array type in a 1-n " +
                                "relationship. therefore, it cannot have foreign keys."
                },
                new String[]{
                        "(25:4,26:15)"
                }
        );
    }

    @Test(enabled = true)
    public void validateRelationAnnotations4() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("modelvalidator", "relation4.bal", 1);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_SQL_427.getCode()
                },
                new String[]{
                        "invalid use of the `Relation` annotation. the field 'car' is an optional type in a 1-1 " +
                                "relationship. therefore, it cannot have foreign keys."
                },
                new String[]{
                        "(25:4,26:13)"
                }
        );
    }

    @Test(enabled = true)
    public void validateRelationAnnotations5() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("modelvalidator", "relation5.bal", 1);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_SQL_428.getCode()
                },
                new String[]{
                        "invalid use of the `Relation` annotation. the field 'ownerNic' is not found in the entity " +
                                "'Car'."
                },
                new String[]{
                        "(34:4,35:17)"
                }
        );
    }

    @Test(enabled = true)
    public void validateRelationAnnotations6() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("modelvalidator", "relation6.bal", 1);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_SQL_429.getCode()
                },
                new String[]{
                        "invalid use of the `Relation` annotation. refs cannot contain duplicates."
                },
                new String[]{
                        "(35:4,36:17)"
                }
        );
    }

    @Test(enabled = true)
    public void validateRelationAnnotations7() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("modelvalidator", "relation7.bal", 1);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_SQL_430.getCode()
                },
                new String[]{
                        "invalid use of the `Relation` annotation. duplicated reference field."
                },
                new String[]{
                        "(37:4,38:20)"
                }
        );
    }

    @Test(enabled = true)
    public void validateIndexAnnotation() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("modelvalidator", "index.bal", 4);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_SQL_611.getCode(),
                        PERSIST_SQL_613.getCode(),
                        PERSIST_SQL_615.getCode(),
                        PERSIST_SQL_615.getCode(),
                },
                new String[]{
                        "invalid use of the `Index` annotation. the `Index` annotation cannot be used for relation " +
                                "fields.",
                        "invalid use of the `Index` annotation. duplicate index names.",
                        "invalid use of the `Index` annotation. there cannot be empty index names.",
                        "invalid use of the `Index` annotation. there cannot be empty index names."
                },
                new String[]{
                        "(22:4,23:20)",
                        "(28:4,29:17)",
                        "(30:4,31:18)",
                        "(32:4,33:15)"
                }
        );
    }

    @Test(enabled = true)
    public void validateUniqueIndexAnnotation() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("modelvalidator", "unique_index.bal", 4);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_SQL_612.getCode(),
                        PERSIST_SQL_614.getCode(),
                        PERSIST_SQL_616.getCode(),
                        PERSIST_SQL_616.getCode(),
                },
                new String[]{
                        "invalid use of the `UniqueIndex` annotation. the `UniqueIndex` annotation cannot be used " +
                                "for relation fields.",
                        "invalid use of the `UniqueIndex` annotation. duplicate index names.",
                        "invalid use of the `UniqueIndex` annotation. there cannot be empty index names.",
                        "invalid use of the `UniqueIndex` annotation. there cannot be empty index names."
                },
                new String[]{
                        "(22:4,23:20)",
                        "(28:4,29:17)",
                        "(30:4,31:18)",
                        "(32:4,33:15)"
                }
        );
    }

    @Test(enabled = true)
    public void validateGeneratedAnnotation() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("modelvalidator", "generated.bal", 3);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_SQL_617.getCode(),
                        PERSIST_SQL_619.getCode(),
                        PERSIST_SQL_618.getCode()
                },
                new String[]{
                        "invalid use of the `Generated` annotation. the `Generated` annotation can only be used for " +
                                "''readonly'' fields.",
                        "invalid use of the `Generated` annotation. a generated field can only be an ''int'' type.",
                        "invalid use of the `Generated` annotation. partial key fields cannot be auto-generated."
                },
                new String[]{
                        "(21:4,22:12)",
                        "(36:4,37:24)",
                        "(27:4,28:20)"
                }
        );
    }

    private List<Diagnostic> getErrorDiagnostics(String modelDirectory, String modelFileName, int count) {
        DiagnosticResult diagnosticResult = loadPersistModelFile(modelDirectory, modelFileName).getCompilation()
                .diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream().filter
                (r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR)
                        || r.diagnosticInfo().severity().equals(DiagnosticSeverity.WARNING))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), count);
        return errorDiagnosticsList;
    }

    private void testDiagnostic(List<Diagnostic> errorDiagnosticsList, String[] codes, String[] messages,
                                String[] locations) {
        for (int index = 0; index < errorDiagnosticsList.size(); index++) {
            Diagnostic diagnostic = errorDiagnosticsList.get(index);
            DiagnosticInfo diagnosticInfo = diagnostic.diagnosticInfo();
            Assert.assertEquals(diagnosticInfo.code(), codes[index]);
            Assert.assertTrue(diagnosticInfo.messageFormat().startsWith(messages[index]));
            String location = diagnostic.location().lineRange().toString();
            Assert.assertEquals(location, locations[index]);
        }
    }
}

