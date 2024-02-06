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

public annotation MapConfig DatabaseMapping on type, record field;

# Description.
#
# + unique - true if the index is a unique index  
# + indexName - name of the index in the database
public type SQLIndex record {|
    boolean unique = false;
    # The DB table/column name
    string indexName;
|};

public annotation SQLIndex DatabaseIndex on record field;

# Description.
# This annotation is used to define a custom max length to a VARCHAR or CHAR column.
# + length - max length of the VARCHAR or length of the CHAR column
public type VarCharConfig record {|
    # Used to set the max length of the certain fields
    int length = 191;
|};

public annotation VarCharConfig VarChar on record field;
public annotation VarCharConfig Char on record field;

# Description.
# This annotation is used to define a custom precision to a DECIMAL column.
# + precision - precision of the DECIMAL column as an array of two integers [precision, scale]
public type DecimalConfig record {|
    [int, int] precision = [65, 30];
|};

public annotation DecimalConfig Decimal on record field;


public type RelationConfig record {|
    string[] refs;
|};

public annotation RelationConfig DatabaseRelation on record field;
