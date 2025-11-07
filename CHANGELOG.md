# Changelog

## [Unreleased]

### Fixed

- Fixed `UndefinedFunctionError` for `Mix.env/0` at runtime by evaluating environment at compile time in `lib/brasilapi/config.ex:45`
- Mix is no longer required at runtime, making the library work correctly in production releases

## [1.0.0] - 2025-10-30

### Added

- CEP V1 API support with dedicated version parameter
- CPTEC (Centro de Previsão de Tempo e Estudos Climáticos) weather API
  - List and search cities
  - Get current weather for capitals
  - Get weather by airport ICAO code
  - City weather forecasts (1-6 days)
  - Ocean/wave forecasts for coastal cities
- Fipe (Fundação Instituto de Pesquisas Econômicas) vehicle pricing API
  - Get brands by vehicle type (cars, motorcycles, trucks)
  - Get vehicle prices by FIPE code
  - List reference tables
  - Search vehicles by brand and type
- IBGE (Instituto Brasileiro de Geografia e Estatística) geographic data
  - List all Brazilian states
  - Get specific state information
  - Get municipalities by state with provider options
- NCM (Nomenclatura Comum do Mercosul) product classification
  - Get all NCM codes
  - Search NCM codes by keyword or partial code
  - Get specific NCM by code

### Changed

- Upgraded dependencies to latest versions
- Refactored API modules to follow BrasilAPI order
- Renamed functions for better consistency and clarity
- Added BrasilAPI reference documentation links

### Fixed

- Documentation improvements and corrections
- Test coverage improvements for Brokers and ISBN modules

## [0.1.5] - 2025-08-07

### Added

- ISBN (International Standard Book Number) book lookup support
  - Search books by ISBN-10 or ISBN-13
  - Support for multiple providers (cbl, mercado-editorial, open-library, google-books)
  - Book structs with comprehensive metadata including dimensions, authors, and synopsis
- Brokers (CVM-registered brokerage firms) API
  - List all active brokerage firms
  - Get specific broker by CNPJ
  - Comprehensive broker data including registration dates and equity values
- Exchange Rate API with full support for currency conversions
  - Get all available currencies
  - Get exchange rates by currency and date
  - Support for Date, DateTime, and NaiveDateTime structs
  - Historical data from November 28, 1984 onwards

### Fixed

- Query parameter bug in ISBN API get request
- Formatting and indentation improvements in Exchange modules

## [0.1.4] - 2025-08-06

### Added

- RegistroBR domain lookup API
  - Check Brazilian (.br) domain availability
  - Get domain registration information
  - Get domain suggestions
- PIX (Brazilian Instant Payment System) participants API
  - List all PIX participants with registration details
- Rates (Tax Rates and Official Indices) API
  - Get all available tax rates (CDI, SELIC, IPCA, etc.)
  - Get specific rate by acronym

## [0.1.3] - 2025-08-05

### Added

- National Holidays (Feriados Nacionais) API
  - Get holidays for specific years
  - Support for string and integer year parameters
- DDD (Area Code) lookup API
  - Get state and cities by area code
  - Support for string and integer DDD parameters

### Changed

- Updated README with dependency version bump
- Improved documentation structure

## [0.1.1] - 2025-08-05

### Added

- CNPJ (Company Registry) lookup support
  - Get company information by CNPJ
  - Support for formatted and unformatted CNPJ
  - Comprehensive company data including registration status and activities
- CEP V2 API support
  - Enhanced address lookup with geolocation data
  - Multiple provider support with automatic fallback
  - Address struct with location coordinates

### Changed

- Refactored CEP and Banks API functions to use `with` statements for better error handling
- Updated project description to include banks data

## 0.1.0 - 2025-08-05

### Added

- Initial release of BrasilAPI Elixir client
- Banks API client
  - List all banks
  - Get bank by code
- CEP (Postal Code) API client
  - Address lookup by postal code
  - Support for formatted and unformatted CEP
- HTTP client with Req library
  - Configurable base URL, timeout, and retry attempts
  - Automatic error handling and response parsing
  - Retry support for transient failures
- Configuration module for client customization
- Comprehensive test suite with Bypass
- Documentation with ExDoc
- Package metadata for Hex publishing
- MIT License
- Code of Conduct

### Infrastructure

- Elixir 1.18 support
- Req ~> 0.5.0 for HTTP requests
- Jason ~> 1.4 for JSON parsing
- ExDoc for documentation
- Bypass for HTTP testing
- Credo for code quality
