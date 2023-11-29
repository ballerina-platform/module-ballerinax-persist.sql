CREATE DATABASE test;

\c test;

CREATE TABLE Building (
    buildingCode VARCHAR(36) PRIMARY KEY,
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    postalCode VARCHAR(50),
    type VARCHAR(50)
);

CREATE TABLE Workspace (
    workspaceId VARCHAR(36) PRIMARY KEY,
    workspaceType VARCHAR(10),
    locationBuildingCode VARCHAR(36),
    FOREIGN KEY (locationBuildingCode) REFERENCES Building(buildingCode)
);

CREATE TABLE Department (
    deptNo VARCHAR(36) PRIMARY KEY,
    deptName VARCHAR(30)
);

CREATE TABLE Employee (
    empNo VARCHAR(36) PRIMARY KEY,
    firstName VARCHAR(30),
    lastName VARCHAR(30),
    birthDate DATE,
    gender VARCHAR(6) CHECK (gender IN ('MALE', 'FEMALE')) NOT NULL,
    hireDate DATE,
    departmentDeptNo VARCHAR(36),
    workspaceWorkspaceId VARCHAR(36),
    FOREIGN KEY (departmentDeptNo) REFERENCES Department(deptNo),
    FOREIGN KEY (workspaceWorkspaceId) REFERENCES Workspace(workspaceId)
);

CREATE TABLE OrderItem (
    orderId VARCHAR(36),
    itemId VARCHAR(30),
    quantity INTEGER,
    notes VARCHAR(255),
    PRIMARY KEY(orderId, itemId)
);

CREATE TABLE AllTypes (
	id INT NOT NULL,
	booleanType BOOLEAN NOT NULL,
	intType INT NOT NULL,
	floatType FLOAT NOT NULL,
	decimalType DECIMAL(10, 2) NOT NULL,
	stringType VARCHAR(191) NOT NULL,
	byteArrayType BYTEA NOT NULL,
	dateType DATE NOT NULL,
	timeOfDayType TIME NOT NULL,
	civilType TIMESTAMP NOT NULL,
	booleanTypeOptional BOOLEAN,
	intTypeOptional INT,
	floatTypeOptional FLOAT,
	decimalTypeOptional DECIMAL(10, 2),
	stringTypeOptional VARCHAR(191),
	dateTypeOptional DATE,
	timeOfDayTypeOptional TIME,
	civilTypeOptional TIMESTAMP,
	enumType VARCHAR(10) CHECK (enumType IN ('TYPE_1', 'TYPE_2', 'TYPE_3', 'TYPE_4')) NOT NULL,
	enumTypeOptional VARCHAR(10) CHECK (enumTypeOptional IN ('TYPE_1', 'TYPE_2', 'TYPE_3', 'TYPE_4')),
	PRIMARY KEY(id)
);

CREATE TABLE FloatIdRecord (
	id FLOAT NOT NULL,
	randomField VARCHAR(191) NOT NULL,
	PRIMARY KEY(id)
);

CREATE TABLE StringIdRecord (
	id VARCHAR(191) NOT NULL,
	randomField VARCHAR(191) NOT NULL,
	PRIMARY KEY(id)
);

CREATE TABLE DecimalIdRecord (
	id DECIMAL(10, 2) NOT NULL,
	randomField VARCHAR(191) NOT NULL,
	PRIMARY KEY(id)
);

CREATE TABLE BooleanIdRecord (
	id BOOLEAN NOT NULL,
	randomField VARCHAR(191) NOT NULL,
	PRIMARY KEY(id)
);

CREATE TABLE IntIdRecord (
	id INT NOT NULL,
	randomField VARCHAR(191) NOT NULL,
	PRIMARY KEY(id)
);

CREATE TABLE AllTypesIdRecord (
	booleanType BOOLEAN NOT NULL,
	intType INT NOT NULL,
	floatType FLOAT NOT NULL,
	decimalType DECIMAL(10, 2) NOT NULL,
	stringType VARCHAR(191) NOT NULL,
	randomField VARCHAR(191) NOT NULL,
	PRIMARY KEY(booleanType, intType, floatType, decimalType, stringType)
);

CREATE TABLE CompositeAssociationRecord (
	id VARCHAR(191) NOT NULL,
	randomField VARCHAR(191) NOT NULL,
	alltypesidrecordBooleanType BOOLEAN NOT NULL,
	alltypesidrecordIntType INT NOT NULL,
	alltypesidrecordFloatType FLOAT NOT NULL,
	alltypesidrecordDecimalType DECIMAL(10, 2) NOT NULL,
	alltypesidrecordStringType VARCHAR(191) NOT NULL,
	FOREIGN KEY(alltypesidrecordBooleanType, alltypesidrecordIntType, alltypesidrecordFloatType, alltypesidrecordDecimalType, alltypesidrecordStringType) REFERENCES AllTypesIdRecord(booleanType, intType, floatType, decimalType, stringType),
	PRIMARY KEY(id)
);
