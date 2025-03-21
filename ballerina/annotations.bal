// Copyright (c) 2024 WSO2 LLC. (http://www.wso2.com) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

# Maps an entity/field name to a database table/column name.
#
# + value - name of the table/column in the database
public type NameConfig record {|
    string value;
|};

# The Annotation used to specify the mapping of an entity/field to a database table/column.
public annotation NameConfig Name on type, record field;

# Groups the entity to a specific schema in the database.
#
# + value - name of the schema in the database
public type SchemaConfig record {|
    string value;
|};

# The Annotation used to specify the schema of an entity in the database.
public annotation SchemaConfig Schema on type;

# Marks the entity field as an index field.
#
# + name - specify a single index name or an array of index names
public type IndexConfig record {|
    string|string[]? name = ();
|};

# The Annotation used to specify the index name associated with a database column.
public annotation IndexConfig Index on record field;

# The Annotation used to specify the unique index name associated with a database column.
public annotation IndexConfig UniqueIndex on record field;

# Defines a string field as a VARCHAR column and defines its max length.
#
# + length - max length of the VARCHAR column
public type VarcharConfig record {|
    int length = 191;
|};

# Defines a string field as a CHAR column and defines its length.
#
# + length - length of the CHAR column
public type CharConfig record {|
    int length = 10;
|};

# The Annotation used to specify the max length of a VARCHAR column.
public annotation VarcharConfig Varchar on record field;

# The Annotation used to specify the length of a CHAR column.
public annotation CharConfig Char on record field;

# Defines a custom precision and scale to a DECIMAL column.
#
# + precision - precision of the DECIMAL column as an array of two integers [precision, scale]
public type DecimalConfig record {|
    [int, int] precision = [65, 30];
|};

# The Annotation used to specify a custom precision and scale of a DECIMAL column.
public annotation DecimalConfig Decimal on record field;

# Specifies your own foreign key column in the entity record.
#
# + keys - array of key fields in the entity
public type RelationConfig record {|
    string[] keys;
|};

# The Annotation used to specify the foreign key column in the entity record.
public annotation RelationConfig Relation on record field;

# Denotes an entity field as a database generated value field.
#
public type GeneratedConfig record {|
|};

# The Annotation used to specify a database generated column in the entity record.
public annotation GeneratedConfig Generated on record field;
