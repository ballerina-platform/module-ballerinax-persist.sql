// Copyright (c) 2024 WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
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

# Description.
# This annotation is used to map an entity/field name to a database table/column name.
# + name - name of the table/column in the database
public type MapConfig record {|
    # The DB table/column name
    string name;
|};

public annotation MapConfig Mapping on type, record field;

# Description.
# This annotation is used to define an Index on a database column.
# + name - name of the index in the database
public type SQLIndex record {|
    string name;
|};

public annotation SQLIndex Index on record field;

public annotation SQLIndex UniqueIndex on record field;

# Description.
# This annotation is used to define a custom max length to a VARCHAR column.
# + length - max length of the VARCHAR column
public type VarCharConfig record {|
    # Used to set the max length of the certain fields
    int length = 191;
|};

# Description.
# This annotation is used to define a custom max length to a   CHAR column.
# + length - length of the CHAR column
public type CharConfig record {|
    # Used to set the max length of the certain fields
    int length = 10;
|};

public annotation VarCharConfig VarChar on record field;

public annotation CharConfig Char on record field;

# Description.
# This annotation is used to define a custom precision to a DECIMAL column.
# + precision - precision of the DECIMAL column as an array of two integers [precision, scale]
public type DecimalConfig record {|
    [int, int] precision = [65, 30];
|};

public annotation DecimalConfig Decimal on record field;

# Description.
# To specify your own foreign key column in the entity record.
# + refs - array of key fields in the entity
public type RelationConfig record {|
    string[] refs;
|};

public annotation RelationConfig Relation on record field;

# Description.
# This annotation is used to denote an entity is auto_increment.
public type GeneratedConfig record {|
|};

public annotation GeneratedConfig Generated on record field;
