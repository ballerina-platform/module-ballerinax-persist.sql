# Specification: Ballerina Persist SQL Library

_Owners_: @daneshk @niveathika  
_Reviewers_: @daneshk  
_Created_: 2026/11/06  
_Updated_: 2026/11/06  
_Edition_: Swan Lake  

## Introduction

This is the specification for the `ballerinax/persist.sql` package of the [Ballerina language](https://ballerina.io/), which stores the data of a `persist` data model in an SQL database. It covers what is specific to the SQL datastores: the supported datastores and types, the SQL annotations of the model, the query clauses of the generated client, the native SQL methods, transactions, and the errors that each operation returns.

This specification builds on the [persist specification](https://github.com/ballerina-platform/module-ballerina-persist/blob/main/docs/spec/spec.md), which specifies the [data model](https://github.com/ballerina-platform/module-ballerina-persist/blob/main/docs/spec/spec.md#3-data-model-definition), and the [derived entity types, the persist client API and the error types](https://github.com/ballerina-platform/module-ballerina-persist/blob/main/docs/spec/spec.md#4-derived-entity-types-and-persist-clients). The `bal persist` commands and the code generation are specified in the [persist tools specification](https://github.com/ballerina-platform/persist-tools/blob/main/docs/spec/spec.md).

The conforming implementation of the specification is released and included in the distribution. Any deviation from the specification is considered a bug. The released versions of the specification can be found under the relevant GitHub tag.

### Notation

The key words MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY and OPTIONAL are interpreted as described in [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) and [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174) when, and only when, they appear in all capitals. Sentences that state behaviour in the present tense are also normative. The overview, notes and examples are informative.

## Contents

- [1. Overview](#1-overview)
- [2. Terminology](#2-terminology)
- [3. Supported datastores and types](#3-supported-datastores-and-types)
    - [3.1. Description](#31-description)
    - [3.2. Behaviour](#32-behaviour)
- [4. SQL annotations](#4-sql-annotations)
    - [4.1. Description](#41-description)
    - [4.2. Configuration](#42-configuration)
    - [4.3. Behaviour](#43-behaviour)
    - [4.4. Compile-time validation](#44-compile-time-validation)
- [5. SQL client](#5-sql-client)
    - [5.1. Description](#51-description)
    - [5.2. Query clauses](#52-query-clauses)
        - [5.2.1. Configuration](#521-configuration)
        - [5.2.2. Behaviour](#522-behaviour)
        - [5.2.3. Query expressions](#523-query-expressions)
        - [5.2.4. Compile-time validation](#524-compile-time-validation)
        - [5.2.5. Errors](#525-errors)
    - [5.3. Native SQL methods](#53-native-sql-methods)
    - [5.4. Transactions](#54-transactions)
    - [5.5. Errors](#55-errors)
        - [5.5.1. Database error classification](#551-database-error-classification)
        - [5.5.2. Errors per operation](#552-errors-per-operation)
- [6. Security considerations](#6-security-considerations)
- [References](#references)

## 1. Overview

The `persist` library lets a Ballerina application store and query data through a data model, and the persist tool generates a persist client from the model. When the datastore of the model is MySQL, MSSQL, PostgreSQL or H2, the generated client uses the `ballerinax/persist.sql` package to run SQL statements against the database.

On top of the persist client API, the client of an SQL datastore lets the application filter, group, sort, limit and skip the records of a `get` call in the database, and run its own SQL through native SQL methods. The model can configure how entities map to tables and columns with the `@sql:` annotations, and the package's compiler plugin validates those annotations, and the query expressions that use the client.

## 2. Terminology

- **SQL datastore:** one of MySQL, MSSQL, PostgreSQL and H2.
- **SQL client:** the persist client that the persist tool generates for a model whose datastore is an SQL datastore.
- **Eager-loading client:** an SQL client generated with the `--eager-loading` option of the [persist tool](https://github.com/ballerina-platform/persist-tools/blob/main/docs/spec/spec.md#32-configuration).
- **`get` many:** the `get` resource method of an entity without path parameters, which returns the records of the entity.
- **Query clause:** one of the `whereClause`, `orderByClause`, `limitClause`, `groupByClause` and `offsetClause` arguments of `get` many, as specified in [5.2](#52-query-clauses).
- **Empty template:** the `sql:ParameterizedQuery` value written as an empty backtick template, with no text and no insertions.
- **Entity alias:** the name by which the table of the entity is referred to in the SQL statement of `get` many. It is the entity name.
- **Relation alias:** the name by which the table of a related entity is referred to in the SQL statement of `get` many. It is the name of the relation field.

## 3. Supported datastores and types

### 3.1. Description

The package supports four SQL datastores. Each has a constant of the package that the generated client passes to the package, which selects how identifiers are quoted, how rows are paged and how database errors are classified.

### 3.2. Behaviour

1. The SQL datastores are:

    | Datastore | `--datastore` value | Constant | Identifier quotes |
    |---|---|---|---|
    | MySQL | `mysql` | `MYSQL_SPECIFICS` | `` `name` `` |
    | MSSQL | `mssql` | `MSSQL_SPECIFICS` | `[name]` |
    | PostgreSQL | `postgresql` | `POSTGRESQL_SPECIFICS` | `"name"` |
    | H2 | `h2` | `H2_SPECIFICS` | `"name"` |

2. The SQL client quotes each table, column and alias name that it writes into an SQL statement with the identifier quotes of its datastore. A schema name given by `@sql:Schema` is written without quotes.
3. The types of the non-relation fields that the SQL datastores support are as follows. The `time` types are `time:Date`, `time:TimeOfDay`, `time:Utc` and `time:Civil`.

    | Datastore | Simple types | Array types |
    |---|---|---|
    | MySQL, MSSQL, PostgreSQL, H2 | `int`, `boolean`, `decimal`, `float`, `string`, enum types, the `time` types | `byte[]` |

4. A field of a simple type `T`, or of `byte[]`, MAY be declared nillable, `T?`, and is then mapped to a nullable column.
5. The `persist` compiler plugin rejects any other type of a non-relation field, as specified in the [data model](https://github.com/ballerina-platform/module-ballerina-persist/blob/main/docs/spec/spec.md#3-data-model-definition) of the persist specification.

## 4. SQL annotations

### 4.1. Description

The package defines annotations that configure how an entity is stored in an SQL datastore. They are used in the model definition file with the `sql` prefix, such as `@sql:Name`. The persist tool reads them when it generates the SQL client and the [database schema](https://github.com/ballerina-platform/persist-tools/blob/main/docs/spec/spec.md#57-database-schema).

### 4.2. Configuration

| Annotation | Applies to | Field | Type | Default | Meaning |
|---|---|---|---|---|---|
| `Name` | Entity, non-relation field | `value` | `string` | Required | The name of the table of the entity, or of the column of the field. |
| `Schema` | Entity | `value` | `string` | Required | The database schema of the table of the entity. |
| `Index` | Non-relation field | `name` | `string\|string[]?` | `()` | The name of the index, or the names of the indexes, that include the column. `()` gives the name `idx_<lowercased field name>`. |
| `UniqueIndex` | Non-relation field | `name` | `string\|string[]?` | `()` | The name of the unique index, or the names of the unique indexes, that include the column. `()` gives the name `unique_idx_<lowercased field name>`. |
| `Varchar` | `string` field | `length` | `int` | `191` | The maximum length of the `VARCHAR` column. `0` is rejected, as specified in [4.4](#44-compile-time-validation). |
| `Char` | `string` field | `length` | `int` | `10` | The length of the `CHAR` column. `0` is rejected, as specified in [4.4](#44-compile-time-validation). |
| `Decimal` | `decimal` field | `precision` | `[int, int]` | `[65, 30]` | The precision and the scale of the `DECIMAL` column. A precision of `0`, or a precision less than the scale, is rejected, as specified in [4.4](#44-compile-time-validation). Without `Decimal`, or without `precision`, the persist tool generates `DECIMAL(38,30)` for MSSQL. |
| `Relation` | Relation field of the owner | `keys` | `string[]` | Required | The fields of the owner that hold the foreign key, in place of the default foreign key fields. |
| `Generated` | Identity field | None | - | - | The datastore generates the value of the field. |

### 4.3. Behaviour

1. The SQL client reads and writes the table named by the `Name` of an entity, and the column named by the `Name` of a field. Without `Name`, the table name is the entity name and the column name is the field name.
2. The SQL client refers to the table of an entity with a `Schema` as `<schema>.<table>`.
3. Fields of one entity that give the same `Index` name form one index, and fields that give the same `UniqueIndex` name form one unique index. With PostgreSQL, an index name is unique within a schema, so two indexes of different entities of a schema that have the same name, including a default name, cannot both be created.
4. The `keys` of `Relation` are matched, in order, to the identity fields of the related entity. Each key MUST have the same type, and the same `Char`, `Varchar` or `Decimal` annotation, as its identity field.
5. A `Generated` field MUST be the only identity field of its entity, and MUST be of type `int`.
6. The SQL client leaves a `Generated` field out of the `INSERT` statement of `post`, so the datastore generates its value. The insert type of the entity does not have that field, and `post` returns the values that the datastore generated.

### 4.4. Compile-time validation

The `persist.sql` compiler plugin validates the SQL annotations of a model definition file that imports `ballerinax/persist.sql`, when the file is in the `persist` directory of a project that has a `Ballerina.toml` file. It does not validate the file when the file has a compilation error. It reports these conditions:

| Condition | Code | Kind |
|---|---|---|
| The number of `Relation` keys differs from the number of identity fields of the related entity | `PERSIST_423` | error |
| A `Relation` key differs from its identity field in type, or in its `Char`, `Varchar` or `Decimal` annotation | `PERSIST_424` | error |
| `Relation` is on an `EntityType[]` field | `PERSIST_426` | error |
| `Relation` is on an `EntityType?` field | `PERSIST_427` | error |
| A `Relation` key is not a field of the owner | `PERSIST_428` | error |
| A `Relation` key is listed more than once | `PERSIST_429` | error |
| The `Relation` keys are all used by another relation of the entity | `PERSIST_430` | error |
| A `Name` value is empty | `PERSIST_600` | error |
| A `Name` value is the same as the entity or field name | `PERSIST_601` | warning |
| `Name` is on a relation field | `PERSIST_602` | error |
| `Char` or `Varchar` is on a field that is not of type `string` | `PERSIST_604` | error |
| A field has both `Char` and `Varchar` | `PERSIST_605` | error |
| `Decimal` is on a field that is not of type `decimal` | `PERSIST_606` | error |
| The `length` of `Char` or `Varchar` is `0` | `PERSIST_607` | error |
| The precision of `Decimal` is `0` | `PERSIST_608` | error |
| The precision of `Decimal` is less than its scale | `PERSIST_609` | error |
| Two entities, or two fields of an entity, have the same `Name` value | `PERSIST_610` | error |
| `Index` is on a relation field | `PERSIST_611` | error |
| `UniqueIndex` is on a relation field | `PERSIST_612` | error |
| An `Index` name array has a name more than once | `PERSIST_613` | error |
| A `UniqueIndex` name array has a name more than once | `PERSIST_614` | error |
| An `Index` name array has an empty name | `PERSIST_615` | error |
| A `UniqueIndex` name array has an empty name | `PERSIST_616` | error |
| `Generated` is on a field that is not an identity field | `PERSIST_617` | error |
| `Generated` is on an identity field of an entity with more than one identity field | `PERSIST_618` | error |
| `Generated` is on a field that is not of type `int` | `PERSIST_619` | error |
| An entity's `Name` value is the name of another entity | `PERSIST_620` | error |
| A field's `Name` value is the name of another field of the entity | `PERSIST_621` | error |
| An `Index` name is empty | `PERSIST_622` | error |
| A `UniqueIndex` name is empty | `PERSIST_623` | error |
| An `Index` name array is empty | `PERSIST_624` | error |
| A `UniqueIndex` name array is empty | `PERSIST_625` | error |

### 4.5. Example: Annotated model

In this model, the `Patient` entity is stored in the `patients` table, the datastore generates its `id`, and `Appointment` holds the foreign key of `Patient` in its own `patientId` field, which is indexed.

```ballerina
import ballerina/persist as _;
import ballerinax/persist.sql;

@sql:Name {value: "patients"}
type Patient record {|
    @sql:Generated
    readonly int id;
    @sql:Varchar {length: 100}
    string name;
    Appointment[] appointments;
|};

type Appointment record {|
    readonly int id;
    @sql:Index {name: "patient_index"}
    int patientId;
    @sql:Relation {keys: ["patientId"]}
    Patient patient;
|};
```

## 5. SQL client

### 5.1. Description

The SQL client has the resource methods that the persist specification specifies for every [persist client](https://github.com/ballerina-platform/module-ballerina-persist/blob/main/docs/spec/spec.md#4-derived-entity-types-and-persist-clients). In addition, its `get` many method takes query clauses that run in the database, it has two native SQL methods, and it takes part in Ballerina transactions.

### 5.2. Query clauses

#### 5.2.1. Configuration

`get` many takes these optional arguments, each of type `sql:ParameterizedQuery`. The default of each is the empty template, which leaves the clause out.

| Argument | Meaning |
|---|---|
| `whereClause` | The condition of the `WHERE` clause. |
| `groupByClause` | The grouping keys of the `GROUP BY` clause. The `get` many method of an eager-loading client does not have this argument. |
| `orderByClause` | The order keys of the `ORDER BY` clause. |
| `limitClause` | The maximum number of rows to return. |
| `offsetClause` | The number of rows to skip before the first row returned. It MUST be a non-negative integer, given either as a single insertion of an `int` value with no other text, such as `` `${offset}` ``, or as text with no insertions that is an integer literal, such as `` `10` ``. Surrounding whitespace is ignored. |

#### 5.2.2. Behaviour

1. `get` many runs one `SELECT` statement on the table of the entity, with the entity alias.
2. Each related entity in the target type whose relation field is not an array is joined to the statement with a `LEFT JOIN`, with its relation alias. A query clause can refer to a relation alias only when the target type includes that relation.
3. The statement has the query clauses that are not the empty template, in this order: ` WHERE <whereClause>`, ` GROUP BY <groupByClause>`, ` ORDER BY <orderByClause>`, then the paging clause of rule 7.
4. The text of each query clause is written into the statement as given. A query clause refers to a table by the entity alias or a relation alias, and to a column by its column name, quoted as needed by the datastore.
5. Each insertion in `whereClause` and `limitClause` is bound as a parameter of the statement.
6. Each insertion in `orderByClause` and `groupByClause` is written into the statement text as the `toString` value of the insertion, and is not bound as a parameter, because these clauses hold column names and sort directions, which SQL cannot bind.
7. When `limitClause` or `offsetClause` is given, the paging clause is as follows, where `l` is the `limitClause` and `o` is the `offsetClause` value, which is bound as a parameter:

    | Datastore | `limitClause` only | `offsetClause` only | Both |
    |---|---|---|---|
    | MySQL | `LIMIT l` | `LIMIT 18446744073709551615 OFFSET o` | `LIMIT l OFFSET o` |
    | MSSQL | `OFFSET 0 ROWS FETCH NEXT l ROWS ONLY` | `OFFSET o ROWS` | `OFFSET o ROWS FETCH NEXT l ROWS ONLY` |
    | PostgreSQL, H2 | `LIMIT l` | `OFFSET o` | `LIMIT l OFFSET o` |

8. With MSSQL, when the paging clause is present and `orderByClause` is the empty template, the client writes ` ORDER BY (SELECT NULL)` before the paging clause.
9. For each row, each related entity in the target type whose relation field is an array is read with a separate `SELECT` statement on the table of the related entity, which selects the rows whose foreign key matches the row. The query clauses do not apply to that statement.
10. The `get` many method of an SQL client returns a stream of records of the target type. The `get` many method of an eager-loading client returns an array of them, read in full before the method returns.

#### 5.2.3. Query expressions

1. The `persist.sql` compiler plugin rewrites a query expression so that its `where`, `order by`, `limit` and `group by` clauses also run in the database, when all of these hold:
    1. The package has no compilation error.
    2. The expression of the `from` clause, with or without `check`, is a `get` many call on a variable whose type is the SQL client of the package. A call on any other expression, such as a field access like `self.client`, is not rewritten.
    3. The call has a `targetType` argument, and no other argument except `offsetClause`.
    4. The query expression has at least one `where`, `order by`, `limit` or `group by` clause, and no `let` clause.
    5. Each expression in the `where` clause has one of the forms in rule 3.
2. The rewritten call has a `whereClause`, `orderByClause`, `groupByClause` and `limitClause` argument for each of those clauses that the query expression has. The clauses of the query expression are kept, so they also run on the records that the database returns.
3. The clauses are translated as follows, where `e` is the variable of the `from` clause, `f` is a field, `r` is a relation field and `Entity` is the entity name:

    | Query expression | Query clause |
    |---|---|
    | `e.f` | `Entity.f` |
    | `e.r.f`, `e.r?.f` | `r.f` |
    | A variable reference, except in `where` with a mapping binding pattern in the `from` clause | An insertion of the variable |
    | A variable reference in `where`, with a mapping binding pattern in the `from` clause | The name of the variable |
    | A function call | An insertion of the call |
    | A literal | The literal as written |
    | `==`, `!=` | `=`, `<>` |
    | `<`, `<=`, `>`, `>=`, `%` | The same operator |
    | `&&`, `\|\|` | `AND`, `OR` |
    | `( ... )` | `( ... )` |
    | `ascending`, `descending`, or no direction in `order by` | `ASC`, `DESC`, `ASC` |
    | A numeric literal, a variable reference or a function call in `limit` | The literal as written, or an insertion of the variable or the call |

4. The names that the translation writes are not quoted. With PostgreSQL, which folds an unquoted name to lowercase, a name that has an uppercase letter does not match its quoted alias or column, so the rewritten query fails.
5. A query expression that is not rewritten runs its clauses only in memory, on all the records that `get` many returns.

#### 5.2.4. Compile-time validation

The `persist.sql` compiler plugin reports these conditions on a query expression of a package that has no compilation error. It checks `PERSIST_204`, `PERSIST_205` and `PERSIST_206` when the `from` clause is a `get` resource access on a variable, whether or not the variable is an SQL client, and `PERSIST_202` and `PERSIST_203` when that variable is an SQL client. It checks `PERSIST_207` when the `from` clause is a resource access on any expression.

| Condition | Code | Kind |
|---|---|---|
| The query expression has a `where`, `order by`, `limit` or `group by` clause, and the call has a named argument other than `targetType` and `offsetClause` | `PERSIST_202` | error |
| The query expression has a `where`, `order by`, `limit` or `group by` clause, and the call has a positional argument that is a template expression | `PERSIST_203` | error |
| The `group by` clause is on a line before the `where` or `order by` clause | `PERSIST_204` | error |
| The expression of the `limit` clause is not a numeric literal, a variable reference or a function call | `PERSIST_205` | error |
| An expression of the `where`, `order by` or `group by` clause accesses a field of a member of an array, such as `e.items[0].id` | `PERSIST_206` | error |
| The call has an `offsetClause` argument, the query expression has a `where`, `order by` or `group by` clause, and the query expression is not rewritten as specified in [5.2.3](#523-query-expressions) | `PERSIST_207` | error |

> **Note:** `PERSIST_202` here is not the `PERSIST_202` of the `persist` compiler plugin.

#### 5.2.5. Errors

1. When `offsetClause` is not a non-negative integer as specified in [5.2.1](#521-configuration), `get` many returns a `persist:Error` with the message `Invalid 'offsetClause': expected a non-negative integer, found '<text>'.`, where `<text>` is the trimmed text of the clause with each insertion written as its `toString` value. The statement is not run.
2. When the statement fails in the database, `get` many returns a `persist:Error` with the message of the database error.
3. When a row cannot be converted to the target type, `get` many returns a `persist:Error` whose message starts with `Error occurred while converting to the record: `.
4. The `get` many method of an SQL client returns these errors from the stream. The `get` many method of an eager-loading client returns them from the method.

#### 5.2.6. Example: Paging

This call skips the first `offset` workspaces of the `small` type, in the order of their identity, and returns at most `count` of them. With PostgreSQL, the statement ends with `LIMIT ? OFFSET ?`, with `count` and `offset` bound as parameters.

```ballerina
stream<Workspace, persist:Error?> workspaces = rainierClient->/workspaces.get(
    whereClause = `"Workspace"."workspaceType" = ${"small"}`,
    orderByClause = `"Workspace"."workspaceId"`,
    limitClause = `${count}`,
    offsetClause = `${offset}`);
```

An `offsetClause` of `` `${-1}` `` returns a `persist:Error` with the message `Invalid 'offsetClause': expected a non-negative integer, found '-1'.`

#### 5.2.7. Example: Query expression

The compiler plugin rewrites this query expression:

```ballerina
Product[] products = check from var e in mcClient->/products(targetType = Product, offsetClause = `${offset}`)
    where e.id > 1
    order by e.id
    limit 5
    select e;
```

so that its call is:

```ballerina
mcClient->/products(targetType = Product, offsetClause = `${offset}`, whereClause = ` Product.id > 1`,
    orderByClause = ` Product.id ASC `, limitClause = `  5`)
```

If the query expression had a `let` clause, it would not be rewritten, and the plugin would report `PERSIST_207`.

### 5.3. Native SQL methods

1. The SQL client has two remote methods that run SQL written by the user: `queryNativeSQL` and `executeNativeSQL`. The clients of the other datastores do not have them.
2. `queryNativeSQL` runs a parameterized SQL query and returns a stream of records of the given row type. It does not read related entities.
3. `executeNativeSQL` runs a parameterized SQL command, such as `INSERT`, `UPDATE` or `DELETE`, and returns a `persist.sql:ExecutionResult`, which holds the number of affected rows, `affectedRowCount`, and the last inserted identity value, `lastInsertId`, as the database reports them. Each is `()` when the database does not report it.
4. Each insertion of the query or the command is bound as a parameter.
5. When the command fails, `executeNativeSQL` returns a `persist:Error` with the message of the database error. When the query fails, `queryNativeSQL` returns a `persist:Error` with the message of the database error from the stream.
6. The compiler plugin does not rewrite a query expression over the stream of `queryNativeSQL`.

For example:

```ballerina
persist.sql:ExecutionResult result = check rainierClient->executeNativeSQL(`
    UPDATE Building SET city = ${city} WHERE buildingCode = ${buildingCode}`);

stream<Building, persist:Error?> buildings = rainierClient->queryNativeSQL(
    `SELECT * FROM Building WHERE buildingCode = ${buildingCode}`);
```

### 5.4. Transactions

1. The resource methods and the native SQL methods of the SQL client take part in an enclosing Ballerina `transaction` statement. The changes that they make in the transaction are committed by `commit`, and are rolled back when the transaction fails or is rolled back.
2. A read in a transaction sees the changes made earlier in the same transaction.

For example, the second `post` fails with a `persist:AlreadyExistsError`, so the transaction fails, and neither building is stored:

```ballerina
transaction {
    _ = check rainierClient->/buildings.post([building31, building32]);
    _ = check rainierClient->/buildings.post([building31]);
    check commit;
} on fail error e {
    // e is a persist:AlreadyExistsError
}
```

### 5.5. Errors

#### 5.5.1. Database error classification

1. The SQL client classifies a database error as a foreign key violation or a duplicate key by its vendor error code, or by its SQL state for PostgreSQL:

    | Datastore | Foreign key violation | Duplicate key |
    |---|---|---|
    | MySQL | Error code `1451` or `1452` | Error code `1062` |
    | MSSQL | Error code `547` | Error code `2601` or `2627` |
    | PostgreSQL | SQL state `23503` | SQL state `23505` |
    | H2 | Error code `23503` or `23506` | Error code `23505` |

2. For a duplicate key, the client reads the key from the message of the database error, as the text between these markers:

    | Datastore | Start marker | End marker |
    |---|---|---|
    | MySQL | `Duplicate entry '` | `' for key` |
    | MSSQL | `The duplicate key value is (` | `)..` |
    | PostgreSQL | `Detail: Key ` | ` already exists.` |
    | H2 | `Unique index or primary key violation: "` | ` ON ` |

3. When it reads the key, the client returns a `persist:AlreadyExistsError` created by `persist:getAlreadyExistsError` with the entity name and the key. When the message has no such markers, the client returns a `persist:AlreadyExistsError` with the message of the database error.

For example, inserting an `OrderItem` whose composite identity already exists gives the message `A record with the key 'order-1-item-1' already exists for the entity 'OrderItem'.` with MySQL, and `A record with the key '("orderId", "itemId")=(order-1, item-1)' already exists for the entity 'OrderItem'.` with PostgreSQL.

#### 5.5.2. Errors per operation

The resource methods of the SQL client return these errors. The error types are specified in the [persist specification](https://github.com/ballerina-platform/module-ballerina-persist/blob/main/docs/spec/spec.md#4-derived-entity-types-and-persist-clients).

| Resource method | Errors |
|---|---|
| `get` by identity | `persist:NotFoundError` created by `persist:getNotFoundError` when no row has the identity. |
| `get` many | As specified in [5.2.5](#525-errors). |
| `post` | `persist:AlreadyExistsError` when a row has the same identity or unique value, as specified in [5.5.1](#551-database-error-classification). `persist:ConstraintViolationError` when a foreign key has no matching row. |
| `put` | `persist:ConstraintViolationError` when a foreign key has no matching row. `persist:AlreadyExistsError` when another row has the same unique value. After the update, the method reads the record back by its identity: `persist:NotFoundError` when no row has the identity, and `persist:ReadBackError` when the read fails for another reason. The update is not rolled back when the read fails. |
| `delete` | `persist:NotFoundError` when no row has the identity, from a read before the deletion. `persist:ConstraintViolationError` when another row refers to the row through a foreign key. |

Any other failure of a resource method is returned as a `persist:Error` with the message of the database error. The errors of the native SQL methods are specified in [5.3](#53-native-sql-methods).

## 6. Security considerations

1. The text of every query clause, and the SQL of the native SQL methods, is written into the SQL statement as given. Text built from untrusted input can change the statement.
2. The insertions of `whereClause` and `limitClause`, the `offsetClause` value, and the insertions of the native SQL methods are bound as parameters.
3. The insertions of `orderByClause` and `groupByClause` are written into the SQL statement text as their `toString` values, as specified in [5.2.2](#522-behaviour), and are not bound as parameters. An application MUST NOT pass an untrusted value as such an insertion, and SHOULD map a caller's choice to a known column name instead.
4. `offsetClause` is accepted only as a non-negative integer, as specified in [5.2.1](#521-configuration), so text such as `0; DROP TABLE Workspace` is rejected with a `persist:Error`.
5. The SQL client logs the SQL statements that it builds for the resource methods, with the values of their parameters, at the `DEBUG` log level.
6. The SQL client connects to the database with the database configuration that the persist tool generates, as specified in the [persist tools specification](https://github.com/ballerina-platform/persist-tools/blob/main/docs/spec/spec.md#9-security-considerations).

## References

- [Ballerina persist specification](https://github.com/ballerina-platform/module-ballerina-persist/blob/main/docs/spec/spec.md)
- [Ballerina persist tools specification](https://github.com/ballerina-platform/persist-tools/blob/main/docs/spec/spec.md)
- [RFC 2119: Key words for use in RFCs to Indicate Requirement Levels](https://www.rfc-editor.org/rfc/rfc2119)
- [RFC 8174: Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words](https://www.rfc-editor.org/rfc/rfc8174)
