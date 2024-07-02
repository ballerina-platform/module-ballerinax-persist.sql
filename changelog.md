# Changelog
This file contains all the notable changes done to the Ballerina Persist SQL package through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- [Added support for PostgreSQL as a datasource](https://github.com/ballerina-platform/ballerina-library/issues/5829)
- [Added support for advanced SQL annotations](https://github.com/ballerina-platform/ballerina-library/issues/6013)
- [Added compiler plugin validations for new advanced SQL database annotations](https://github.com/ballerina-platform/ballerina-library/issues/6068)

### Changed
- [Fix class cast exception when executing query with non-global variable](https://github.com/ballerina-platform/persist-tools/issues/311)
- [Updated update query and delete query to support alias table names](https://github.com/ballerina-platform/ballerina-library/issues/6013)
- [Fix the bulk insert failure in sql modules](https://github.com/ballerina-platform/ballerina-library/issues/6563)

## [1.2.0] - 2023-09-18

### Added
- [Added support for executing native queries](https://github.com/ballerina-platform/ballerina-standard-library/issues/4546)

## [1.1.0] - 2023-06-30

### Added
- [Added support for MSSQL as a datasource](https://github.com/ballerina-platform/ballerina-standard-library/issues/4506)

### Changed
- [Updated error messages to be consistent across all data sources](https://github.com/ballerina-platform/ballerina-standard-library/issues/4360)
- [Escaped table and column names when executing queries](https://github.com/ballerina-platform/ballerina-standard-library/issues/4571)

## [1.0.0] - 2023-06-01

### Added
- [Initial release](https://github.com/ballerina-platform/ballerina-standard-library/issues/4488)
