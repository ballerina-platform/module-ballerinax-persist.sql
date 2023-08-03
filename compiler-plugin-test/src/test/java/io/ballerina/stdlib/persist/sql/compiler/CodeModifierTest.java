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
import io.ballerina.tools.diagnostics.Diagnostic;
import io.ballerina.tools.diagnostics.DiagnosticSeverity;
import org.testng.Assert;
import org.testng.annotations.Test;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.stream.Collectors;

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
                String modifiedFunction =
                        "entities:Product[] products = check from var e in mcClient->/products(" +
                                "targetType = entities:Product, whereClause = ` product.id = ${value}  OR " +
                                "product.id = 6`, orderByClause = ` product.id DESC `, limitClause = ` ${value}`)\n" +
                                "        where e.id == value || e.id == 6\n" +
                                "        order by e.id descending\n" +
                                "        limit value\n" +
                                "        select e;\n";
                String modifiedFunction1 =
                        "entities:Product[]|error result = from var e in mcClient->/products(targetType = " +
                                "entities:Product, whereClause = ` product.id = ${value}  AND product.id >= 2 AND " +
                                "product.id <= 25`)\n            where e.id == value && e.id >= 2 && e.id <= 25\n" +
                                "            select e;\n";
                String modifiedFunction2 = "products = check from var e in mcClient->/products(targetType = " +
                        "entities:Product, whereClause = ` ( product.id = ${value}  OR product.id = 6)  " +
                        "AND product.id <> 8`)\n            where (e.id == value || e.id == 6) && e.id != 8\n" +
                        "            select e;\n";
                String modifiedFunction3 = "entities:Product[] results1 = check from entities:Product e in " +
                        "mcClient->/products(targetType = entities:Product, whereClause = ` product.id = ${value}  " +
                        "OR product.id = 6 OR product.id = 7 OR product.id <> 1 AND product.id >= 1 AND " +
                        "product.id <= 20 AND product.name = ${getStringValue(\"Person2\")} `, orderByClause = " +
                        "` ${getStringValue(\"name\")} ASC , product.age DESC `, groupByClause = " +
                        "` ${getValue(4)}, product.name, product.age`, limitClause = ` ${getValue(4)}`)\n" +
                        "            where e.id == value || e.id == 6 || e.id == 7 || e.id != 1  && e.id >= 1 " +
                        "&& e.id <= 20 && e.name == getStringValue(\"Person2\")\n" +
                        "            order by getStringValue(\"name\") ascending, e.age descending\n" +
                        "            limit getValue(4)\n" +
                        "            group by var id3 = getValue(4), var name = e.name, var age = e.age\n" +
                        "            select {id: id3, name: name , age: age};\n";
                String modifiedFunction5 = "entities:Product[] output = check from entities:Product e in " +
                        "mcClient->/products(targetType = entities:Product, whereClause = ` product.id = ${value}  " +
                        "OR product.id = 6 OR product.id = 7 OR product.id <> 1 AND product.id >= 1 AND " +
                        "product.id <= 20 AND product.name = ${getStringValue(\"Person2\")} `, " +
                        "orderByClause = ` ${getStringValue(\"name\")} ASC , product.age DESC `, groupByClause = " +
                        "` ${getValue(4)}, product.name, product.age`, limitClause = ` ${getValue(4)}`)\n" +
                        "                order by getStringValue(\"name\") ascending, e.age descending\n" +
                        "                limit getValue(4)\n" +
                        "                where e.id == value || e.id == 6 || e.id == 7 || e.id != 1  && e.id >= 1 " +
                        "&& e.id <= 20 && e.name == getStringValue(\"Person2\")\n" +
                        "                group by var id3 = getValue(4), var name = e.name, var age = e.age\n" +
                        "                select {id: id3, name: name , age: age};\n";
                Assert.assertTrue(sourceCode.contains(modifiedFunction));
                Assert.assertTrue(sourceCode.contains(modifiedFunction1));
                Assert.assertTrue(sourceCode.contains(modifiedFunction2));
                Assert.assertTrue(sourceCode.contains(modifiedFunction3));
                Assert.assertTrue(sourceCode.contains(modifiedFunction5));
            }
        }
    }

    @Test
    public void testCodeModifierWithRelationTables() {

        Package newPackage = getModifiedPackage("project_3");

        for (DocumentId documentId : newPackage.getDefaultModule().documentIds()) {
            Document document = newPackage.getDefaultModule().document(documentId);

            if (document.name().equals("main.bal")) {
                String sourceCode = document.syntaxTree().toSourceCode();
                String modifiedFunction = "entities:ProductWithRelations[] out =  check from " +
                        "entities:ProductWithRelations e in mcClient->/products(targetType = " +
                        "entities:ProductWithRelations, whereClause = ` product.id = ${val}  OR product.id = 6 " +
                        "OR product.id = 7 OR product.id <> 1 AND product.id >= 1 AND product.id <= 20 " +
                        "AND product.name = ${getStringValue(\"abc\")}  OR manufacture.id = \"1\"`, " +
                        "orderByClause = ` ${getStringValue(\"name\")} ASC `, limitClause = ` ${getValue(2)}`)\n" +
                        "               order by getStringValue(\"name\") ascending\n" +
                        "               limit getValue(2)\n" +
                        "               where e.id == val || e.id == 6 || e.id == 7 || e.id != 1  && " +
                        "e.id >= 1 && e.id <= 20 && e.name == getStringValue(\"abc\") || " +
                        "e.manufacture[0].id == \"1\"\n" +
                        "               select e;\n";
                String modifiedFunction1 = "entities:ManufactureWithRelations[] output = check from " +
                        "entities:ManufactureWithRelations e in mcClient->/manufactures(targetType = " +
                        "entities:ManufactureWithRelations, whereClause = ` manufacture.id = ${value}  " +
                        "OR manufacture.id = \"6\" OR manufacture.id = \"7\" OR products.id = 1`, orderByClause = " +
                        "` ${getStringValue(\"name\")} ASC , products.id DESC `, limitClause = ` ${getValue(2)}`)\n" +
                        "               order by getStringValue(\"name\") ascending, e.products?.id descending\n" +
                        "               limit getValue(2)\n" +
                        "               where e.id == value || e.id == \"6\" || e.id == \"7\" || " +
                        "e.products?.id == 1\n" +
                        "               select e;\n";
                Assert.assertTrue(sourceCode.contains(modifiedFunction));
                Assert.assertTrue(sourceCode.contains(modifiedFunction1));
            }
        }
    }

    @Test
    public void testCodeModifierWhenNameHasEscapeCharacter() {

        Package newPackage = getModifiedPackage("project_4");

        for (DocumentId documentId : newPackage.getDefaultModule().documentIds()) {
            Document document = newPackage.getDefaultModule().document(documentId);

            if (document.name().equals("main.bal")) {
                String sourceCode = document.syntaxTree().toSourceCode();
                String modifiedFunction = "entities:Employee[] output = check from entities:Employee e in " +
                        "mcClient->/employees(targetType = entities:Employee, whereClause = ` employee.lastName = " +
                        "${getStringValue(value)}  OR employee.empNo = \"001\"`, orderByClause = ` " +
                        "employee.lastName ASC , employee.empNo DESC `, groupByClause = ` employee.lastName, " +
                        "employee.empNo, employee.birthDate, employee.firstName, employee.gender, " +
                        "employee.hireDate`, limitClause = ` ${getValue(2)}`)\n" +
                        "                order by e.'lastName ascending, e.empNo descending\n" +
                        "                limit getValue(2)\n" +
                        "                where e.'lastName == getStringValue(value) || e.empNo == \"001\"\n" +
                        "                group by var 'lastName = e.'lastName, var empNo = e.empNo, var " +
                        "birthDate = e.birthDate, var 'firstName = e.'firstName, var gender = e.gender, " +
                        "var hireDate = e.hireDate\n" +
                        "                select {'lastName, empNo, birthDate, 'firstName, gender, hireDate};";
                String modifiedFunction1 = "entities:WorkspaceWithRelations[] results = check from " +
                        "entities:WorkspaceWithRelations e in mcClient->/workspaces(targetType = " +
                        "entities:WorkspaceWithRelations, whereClause = ` employee.firstName = " +
                        "${getStringValue(value)}  OR workspace.workspaceId = \"001\" AND location.buildingCode" +
                        " = ${value} `, orderByClause = ` employee.firstName ASC , location.buildingCode DESC `," +
                        " groupByClause = ` workspace.workspaceId, location.buildingCode`, limitClause = " +
                        "` ${getValue(5)}`)\n" +
                        "                order by e.'employee?.'firstName ascending, e.'location?.buildingCode " +
                        "descending\n" +
                        "                limit getValue(5)\n" +
                        "                where e.'employee?.'firstName == getStringValue(value) || " +
                        "e.workspaceId == \"001\" && e.'location?.buildingCode == value\n" +
                        "                group by var workspaceId = e.workspaceId, var buildingCode = " +
                        "e.'location?.buildingCode\n" +
                        "                select {workspaceId, 'location: {buildingCode}};";
                String modifiedFunction2 = "entities:BuildingWithRelations[] res = check from " +
                        "entities:BuildingWithRelations e in mcClient->/buildings(targetType = " +
                        "entities:BuildingWithRelations)\n" +
                        "                order by e.buildingCode descending\n" +
                        "                limit getValue(5)\n" +
                        "                let entities:WorkspaceOptionalized[]? workSpace = e.'workspaces\n" +
                        "                where workSpace !is () && workSpace[0].workspaceEmpNo == \"1\"\n" +
                        "                group by var buildingCode = e.buildingCode, var city = e.city, " +
                        "var workspaces = workSpace[0].workspaceEmpNo \n" +
                        "                select {buildingCode, city};";
                Assert.assertTrue(sourceCode.contains(modifiedFunction));
                Assert.assertTrue(sourceCode.contains(modifiedFunction1));
                Assert.assertTrue(sourceCode.contains(modifiedFunction2));
            }
        }
    }


    @Test
    public void testCodeModifierWhenFieldIsInTypeDescriptor() {

        Package newPackage = getModifiedPackage("project_5");

        for (DocumentId documentId : newPackage.getDefaultModule().documentIds()) {
            Document document = newPackage.getDefaultModule().document(documentId);

            if (document.name().equals("main.bal")) {
                String sourceCode = document.syntaxTree().toSourceCode();
                String modifiedFunction = "entities:WorkspaceWithRelations[] results = check " +
                        "from entities:WorkspaceWithRelations e in mcClient->/workspaces(targetType = " +
                        "entities:WorkspaceWithRelations, whereClause = ` employee.firstName = " +
                        "${getStringValue(value)}  OR workspace.workspaceId = \"001\" AND " +
                        "location.buildingCode = ${value} `, orderByClause = ` employee.empNo ASC , " +
                        "location.buildingCode DESC `, limitClause = ` ${getValue(5)}`)\n" +
                        "                order by e.employee?.empNo ascending, e.location?.buildingCode descending\n" +
                        "                limit getValue(5)\n" +
                        "                where e.employee?.firstName == getStringValue(value) || " +
                        "e.workspaceId == \"001\" && e.location?.buildingCode == value\n" +
                        "                select e;";
                Assert.assertTrue(sourceCode.contains(modifiedFunction));
            }
        }
    }

    @Test
    public void testCodeModifierWithDiagnostic() {
        Package currentPackage = loadPackage("project_2");
        DiagnosticResult diagnosticResult = currentPackage.getCompilation().diagnosticResult();
        Assert.assertEquals(diagnosticResult.errorCount(), 0);
        CodeModifierResult codeModifierResult = currentPackage.runCodeModifierPlugins();
        List<Diagnostic> errorDiagnosticsList = codeModifierResult.reportedDiagnostics().diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 6);
        String errorMessage = "persist remote function call does not support";
        String errMessage = "group by clause cannot be used before where clause";
        String msg = errorDiagnosticsList.get(5).message();
        String message = errorDiagnosticsList.get(0).message();
        Assert.assertTrue(message.contains(errorMessage) || msg.contains(errorMessage));
        Assert.assertTrue(message.contains(errMessage) || msg.contains(errMessage));
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
