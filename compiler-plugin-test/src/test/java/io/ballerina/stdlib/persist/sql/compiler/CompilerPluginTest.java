/*
 * Copyright (c) 2022, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
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

import static io.ballerina.stdlib.persist.compiler.DiagnosticsCodes.PERSIST_423;
import static io.ballerina.stdlib.persist.compiler.DiagnosticsCodes.PERSIST_424;
import static io.ballerina.stdlib.persist.compiler.DiagnosticsCodes.PERSIST_426;
import static io.ballerina.stdlib.persist.compiler.DiagnosticsCodes.PERSIST_427;
import static io.ballerina.stdlib.persist.compiler.DiagnosticsCodes.PERSIST_428;
import static io.ballerina.stdlib.persist.compiler.DiagnosticsCodes.PERSIST_429;
import static io.ballerina.stdlib.persist.compiler.DiagnosticsCodes.PERSIST_430;
import static io.ballerina.stdlib.persist.compiler.DiagnosticsCodes.PERSIST_600;
import static io.ballerina.stdlib.persist.compiler.DiagnosticsCodes.PERSIST_601;
import static io.ballerina.stdlib.persist.compiler.DiagnosticsCodes.PERSIST_604;
import static io.ballerina.stdlib.persist.compiler.DiagnosticsCodes.PERSIST_605;
import static io.ballerina.stdlib.persist.compiler.DiagnosticsCodes.PERSIST_606;
import static io.ballerina.stdlib.persist.compiler.DiagnosticsCodes.PERSIST_607;
import static io.ballerina.stdlib.persist.compiler.DiagnosticsCodes.PERSIST_608;
import static io.ballerina.stdlib.persist.compiler.DiagnosticsCodes.PERSIST_609;
import static io.ballerina.stdlib.persist.compiler.DiagnosticsCodes.PERSIST_610;
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
        List<Diagnostic> diagnostics = getErrorDiagnostics("project_1", "char.bal", 3);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_605.getCode(),
                        PERSIST_607.getCode(),
                        PERSIST_604.getCode()
                },
                new String[]{
                        "invalid use of VarChar and Char annotations. " +
                                "only one of either Char or Varchar annotations can be used at a time.",
                        "invalid use of 'Char' annotation. length cannot be 0.",
                        "invalid use of 'Char' annotation. 'Char' annotation can only be used for string data type."
                },
                new String[]{
                        "(17:4,19:18)",
                        "(28:4,29:16)",
                        "(30:4,31:12)"
                }
        );
    }

    @Test(enabled = true)
    public void validateVarCharAnnotations() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("project_1",
                "varchar.bal", 3);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_605.getCode(),
                        PERSIST_607.getCode(),
                        PERSIST_604.getCode()
                },
                new String[]{
                        "invalid use of VarChar and Char annotations. " +
                                "only one of either Char or Varchar annotations can be used at a time.",
                        "invalid use of 'VarChar' annotation. length cannot be 0.",
                        "invalid use of 'VarChar' annotation. 'VarChar' annotation can only be " +
                                "used for string data type."
                },
                new String[]{
                        "(17:4,19:18)",
                        "(28:4,29:16)",
                        "(30:4,31:12)"
                }
        );
    }

    @Test(enabled = true)
    public void validateDecimalAnnotations() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("project_1",
                "decimal.bal", 3);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_606.getCode(),
                        PERSIST_608.getCode(),
                        PERSIST_609.getCode()
                },
                new String[]{
                        "invalid use of Decimal annotation. Decimal annotation can only be used for decimal data type.",
                        "invalid use of Decimal annotation. precision cannot be 0.",
                        "invalid use of Decimal annotation. precision cannot be less than scale."
                },
                new String[]{
                        "(6:4,7:12)",
                        "(8:4,9:19)",
                        "(8:4,9:19)"
                }
        );
    }

    @Test(enabled = true)
    public void validateEntityNameMappingAnnotations() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("project_1",
                "entity_name_mapping.bal", 3);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_600.getCode(),
                        PERSIST_601.getCode(),
                        PERSIST_610.getCode()
                },
                new String[]{
                        "invalid use of Mapping annotation. mapping name cannot be empty.",
                        "mapping name is same as model definition.",
                        "invalid use of Mapping annotation. duplicate mapping name found."
                },
                new String[]{
                        "(16:12,16:23)",
                        "(26:12,26:19)",
                        "(44:12,44:17)"
                }
        );
    }

    @Test(enabled = true)
    public void validateFieldNameMappingAnnotations() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("project_1",
                "table_name_mapping.bal", 3);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_600.getCode(),
                        PERSIST_610.getCode(),
                        PERSIST_601.getCode()
                },
                new String[]{
                        "invalid use of Mapping annotation. mapping name cannot be empty.",
                        "invalid use of Mapping annotation. duplicate mapping name found.",
                        "mapping name is same as model definition."
                },
                new String[]{
                        "(20:4,21:29)",
                        "(32:4,33:24)",
                        "(43:4,44:23)"
                }
        );
    }

    @Test(enabled = true)
    public void validateRelationAnnotations1() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("project_1",
                "relation1.bal", 1);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_423.getCode()
                },
                new String[]{
                        "invalid use of Relation annotation. mismatched number of reference " +
                                "keys for entity 'Car' for relation 'Person'. expected 2 but found 1."
                },
                new String[]{
                        "(19:4,20:17)"
                }
        );
    }

    @Test(enabled = true)
    public void validateRelationAnnotations2() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("project_1",
                "relation2.bal", 1);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_424.getCode()
                },
                new String[]{
                        "invalid use of Relation annotation. mismatched key types for entity " +
                                "'Person' for its relationship."
                },
                new String[]{
                        "(18:4,19:17)"
                }
        );
    }

    @Test(enabled = true)
    public void validateRelationAnnotations3() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("project_1",
                "relation3.bal", 1);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_426.getCode()
                },
                new String[]{
                        "invalid use of Relation annotation. the field 'cars' is an array type in a 1-n " +
                                "relationship. therefore, it cannot have foreign keys."
                },
                new String[]{
                        "(9:4,10:15)"
                }
        );
    }
    @Test(enabled = true)
    public void validateRelationAnnotations4() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("project_1",
                "relation4.bal", 1);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_427.getCode()
                },
                new String[]{
                        "invalid use of Relation annotation. the field 'car' is an optional type in a 1-1 " +
                                "relationship. therefore, it cannot have foreign keys."
                },
                new String[]{
                        "(9:4,10:13)"
                }
        );
    }
    @Test(enabled = true)
    public void validateRelationAnnotations5() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("project_1",
                "relation5.bal", 1);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_428.getCode()
                },
                new String[]{
                        "invalid use of Relation annotation. the field 'ownerNic' is not found in the entity 'Car'."
                },
                new String[]{
                        "(18:4,19:17)"
                }
        );
    }
    @Test(enabled = true)
    public void validateRelationAnnotations6() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("project_1",
                "relation6.bal", 1);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_429.getCode()
                },
                new String[]{
                        "invalid use of Relation annotation. refs cannot contain duplicates."
                },
                new String[]{
                        "(19:4,20:17)"
                }
        );
    }
    @Test(enabled = true)
    public void validateRelationAnnotations7() {
        List<Diagnostic> diagnostics = getErrorDiagnostics("project_1",
                "relation7.bal", 1);
        testDiagnostic(
                diagnostics,
                new String[]{
                        PERSIST_430.getCode()
                },
                new String[]{
                        "invalid use of Relation annotation. duplicated reference field."
                },
                new String[]{
                        "(21:4,22:20)"
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

