/*
 * Copyright (c) 2023, WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
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

import io.ballerina.projects.CodeModifierResult;
import io.ballerina.projects.DiagnosticResult;
import io.ballerina.projects.Document;
import io.ballerina.projects.DocumentId;
import io.ballerina.projects.Package;
import io.ballerina.projects.ProjectEnvironmentBuilder;
import io.ballerina.projects.directory.BuildProject;
import io.ballerina.projects.environment.Environment;
import io.ballerina.projects.environment.EnvironmentBuilder;
import io.ballerina.tools.diagnostics.DiagnosticSeverity;
import org.testng.Assert;
import org.testng.annotations.Test;

import java.io.PrintStream;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Code modifier related test cases.
 */
public class CodeModifierTest {

    private static ProjectEnvironmentBuilder getEnvironmentBuilder() {
        Path distributionPath = Paths.get("../", "target", "ballerina-runtime")
                .toAbsolutePath();
        Environment environment = EnvironmentBuilder.getBuilder().setBallerinaHome(distributionPath).build();
        return ProjectEnvironmentBuilder.getBuilder(environment);
    }

    private Package loadPackage(String path) {
        Path projectDirPath = Paths.get("src", "test", "resources", "codemodifier").
                toAbsolutePath().resolve(path);
        BuildProject project = BuildProject.load(getEnvironmentBuilder(), projectDirPath);
        return project.currentPackage();
    }

    @Test
    public void testCodeModifier() {

        Package newPackage = getModifiedPackage("project_1");

        for (DocumentId documentId : newPackage.getDefaultModule().documentIds()) {
            Document document = newPackage.getDefaultModule().document(documentId);

            if (document.name().equals("main.bal")) {
                String sourceCode = document.syntaxTree().toSourceCode();
                PrintStream asd = System.out;
                asd.println(sourceCode);
                String modifiedFunction =
                        "entities:Product[] products = check from var e in mcClient->/products(" +
                                "targetType = entities:Product, whereClause = ` id = ${value}  OR id = 6`, " +
                                "orderByClause = ` id DESC `, limitClause = ` ${value}`)\n" +
                                "        where e.id == value || e.id == 6\n" +
                                "        order by e.id descending\n" +
                                "        limit value\n" +
                                "        select e;\n";
                String modifiedFunction1 =
                        "entities:Product[]|error result = from var e in mcClient->/products(targetType = " +
                                "entities:Product, whereClause = ` id = ${value}  AND id >= 2 AND id <= 25`)\n" +
                                "            where e.id == value && e.id >= 2 && e.id <= 25\n" +
                                "            select e;\n";
                String modifiedFunction2 = "products = check from var e in mcClient->/products(targetType = " +
                        "entities:Product, whereClause = ` ( id = ${value}  OR id = 6)  AND id <> 8`)\n" +
                        "            where (e.id == value || e.id == 6) && e.id != 8\n" +
                        "            select e;\n";
                String modifiedFunction3 = "entities:Product[] results1 = check from entities:Product e in " +
                        "mcClient->/products(targetType = entities:Product, whereClause = ` id = ${value}  OR " +
                        "id = 6 OR id = 7 OR id <> 1 AND id >= 1 AND id <= 20 AND name = " +
                        "${getStringValue(\"Person2\")} `, orderByClause = ` ${getStringValue(\"name\")} ASC , " +
                        "age DESC `, groupByClause = ` ${getValue(4)}, name, age`, limitClause = ` ${getValue(4)}`)\n" +
                        "            where e.id == value || e.id == 6 || e.id == 7 || e.id != 1  && e.id >= 1 " +
                        "&& e.id <= 20 && e.name == getStringValue(\"Person2\")\n" +
                        "            order by getStringValue(\"name\") ascending, e.age descending\n" +
                        "            limit getValue(4)\n" +
                        "            group by var id3 = getValue(4), var name = e.name, var age = e.age\n" +
                        "            select {id: id3, name: name , age: age};";
                Assert.assertTrue(sourceCode.contains(modifiedFunction));
                Assert.assertTrue(sourceCode.contains(modifiedFunction1));
                Assert.assertTrue(sourceCode.contains(modifiedFunction2));
                Assert.assertTrue(sourceCode.contains(modifiedFunction3));
            }
        }
    }

    @Test
    public void testCodeModifierWithDiagnostic() {
        Package currentPackage = loadPackage("project_2");
        DiagnosticResult diagnosticResult = currentPackage.getCompilation().diagnosticResult();
        Assert.assertEquals(diagnosticResult.errorCount(), 0);
        CodeModifierResult codeModifierResult = currentPackage.runCodeModifierPlugins();
        codeModifierResult.reportedDiagnostics().diagnostics().forEach(diagnostic -> {
            Assert.assertEquals(diagnostic.diagnosticInfo().severity(), DiagnosticSeverity.ERROR);
            Assert.assertTrue(diagnostic.diagnosticInfo().messageFormat().contains("'whereClause' argument is not " +
                    "allowed for the remote function call"));
        });
    }

    private Package getModifiedPackage(String path) {
        Package currentPackage = loadPackage(path);
        DiagnosticResult diagnosticResult = currentPackage.getCompilation().diagnosticResult();
        Assert.assertEquals(diagnosticResult.errorCount(), 0);
        CodeModifierResult codeModifierResult = currentPackage.runCodeModifierPlugins();
        Assert.assertEquals(codeModifierResult.reportedDiagnostics().errorCount(), 0);
        return codeModifierResult.updatedPackage().orElse(currentPackage);
    }
}
