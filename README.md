<div align="center">
<h1><img src="https://raw.githubusercontent.com/BrasilAPI/BrasilAPI/main/public/brasilapi-logo-small.png" /></h1>

</div>

Brasil API lookup library for Elixir with an easy-to-use API for brazilian data including banks, postal codes (CEP), company information (CNPJ), area codes (DDD), and national holidays.

## Features

- [x] **Bancos**
- [x] **Câmbio**
- [x] **CEP V2**
- [x] **CNPJ**
- [x] **Corretoras**
- [ ] **CPTEC**
- [x] **DDD**
- [x] **Feriados Nacionais**
- [ ] **FIPE**
- [ ] **IBGE**
- [x] **ISBN**
- [ ] **NCM**
- [x] **PIX**
- [x] **Registros BR**
- [x] **Rates**

## Installation

Add `brasilapi` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:brasilapi, "~> 0.1.5"}
  ]
end
```

Then run:

    $ mix deps.get

## Usage

### Bancos (Banks)

```elixir
# Get all banks
{:ok, banks} = Brasilapi.get_all_banks()
# banks =>
# [%Brasilapi.Banks.Bank{ispb: "00000000", name: "BCO DO BRASIL S.A.", code: 1, full_name: "Banco do Brasil S.A."},
#  %Brasilapi.Banks.Bank{ispb: "00000208", name: "BCO ORIGINAL S.A.", code: 212, full_name: "Banco Original S.A."},
#  ...]

# Find bank by code
{:ok, bank} = Brasilapi.get_bank_by_code(1)
# bank => %Brasilapi.Banks.Bank{ispb: "00000000", name: "BCO DO BRASIL S.A.", code: 1, full_name: "Banco do Brasil S.A."}
```

### CEP V2 (Postal Codes)

```elixir
# Find address by CEP (postal code) - supports multiple providers with fallback
{:ok, address} = Brasilapi.get_cep("89010025")
# address =>
# %Brasilapi.Cep.Address{
#   cep: "89010025",
#   state: "SC",
#   city: "Blumenau",
#   neighborhood: "Centro",
#   street: "Rua Doutor Luiz de Freitas Melro",
#   service: "viacep",
#   location: %{type: "Point", coordinates: %{}}
# }

# CEP can be provided as string or integer, with or without formatting
{:ok, address} = Brasilapi.get_cep("89010-025")  # formatted
{:ok, address} = Brasilapi.get_cep(89010025)     # integer
{:ok, address} = Brasilapi.get_cep("89010025")   # string

# Error handling
{:error, %{status: 404, message: "Not found"}} = Brasilapi.get_cep("00000000")
{:error, %{message: "CEP must be exactly 8 digits"}} = Brasilapi.get_cep("123")
```

### CNPJ (Company Registry)

```elixir
# Find company information by CNPJ
{:ok, company} = Brasilapi.get_cnpj("11000000000197")
# company =>
# %Brasilapi.Cnpj.Company{
#   cnpj: "11000000000197",
#   razao_social: "ACME INC",
#   nome_fantasia: "ACME CORPORATION",
#   uf: "SP",
#   municipio: "SAO PAULO",
#   situacao_cadastral: 2,
#   descricao_situacao_cadastral: "ATIVA",
#   cnae_fiscal: 6201500,
#   cnae_fiscal_descricao: "Desenvolvimento de programas de computador sob encomenda",
#   capital_social: 100000,
#   # ... many more fields available
# }

# CNPJ can be provided as string or integer, with or without formatting
{:ok, company} = Brasilapi.get_cnpj("11.000.000/0001-97")  # formatted
{:ok, company} = Brasilapi.get_cnpj(11000000000197)        # integer
{:ok, company} = Brasilapi.get_cnpj("11000000000197")      # string

# Error handling
{:error, %{status: 404, message: "Not found"}} = Brasilapi.get_cnpj("00000000000000")
{:error, %{message: "Invalid CNPJ format. Must be 14 digits."}} = Brasilapi.get_cnpj("123")
```

### DDD (Area Codes)

```elixir
# Get DDD information (area codes) - includes state and list of cities
{:ok, ddd_info} = Brasilapi.get_ddd(11)
# ddd_info =>
# %Brasilapi.Ddd.Info{
#   state: "SP",
#   cities: [
#     "EMBU",
#     "VÁRZEA PAULISTA",
#     "VARGEM GRANDE PAULISTA",
#     "SÃO PAULO",
#     # ... more cities
#   ]
# }

# DDD can be provided as string or integer
{:ok, ddd_info} = Brasilapi.get_ddd("11")  # string
{:ok, ddd_info} = Brasilapi.get_ddd(11)    # integer

# Error handling
{:error, %{status: 404, message: "DDD não encontrado"}} = Brasilapi.get_ddd(99)
{:error, %{message: "DDD must be exactly 2 digits"}} = Brasilapi.get_ddd("123")
```

### Feriados Nacionais (National Holidays)

```elixir
# Get national holidays for a specific year
{:ok, holidays} = Brasilapi.get_holidays(2021)
# holidays =>
# [
#   %Brasilapi.Feriados.Holiday{
#     date: "2021-01-01",
#     name: "Confraternização mundial",
#     type: "national",
#     full_name: nil
#   },
#   %Brasilapi.Feriados.Holiday{
#     date: "2021-04-21",
#     name: "Tiradentes",
#     type: "national",
#     full_name: nil
#   },
#   # ... more holidays
# ]

# Year can be provided as string or integer
{:ok, holidays} = Brasilapi.get_holidays("2021")  # string
{:ok, holidays} = Brasilapi.get_holidays(2021)    # integer

# Error handling
{:error, %{status: 404, message: "Ano fora do intervalo suportado."}} = Brasilapi.get_holidays(1900)
{:error, %{message: "Year must be a valid positive integer"}} = Brasilapi.get_holidays("invalid")
```

### Rates (Tax Rates and Official Indices)

```elixir
# Get all available tax rates and indices
{:ok, rates} = Brasilapi.get_all_rates()
# rates =>
# [
#   %Brasilapi.Rates.Rate{nome: "CDI", valor: 13.65},
#   %Brasilapi.Rates.Rate{nome: "SELIC", valor: 13.75},
#   %Brasilapi.Rates.Rate{nome: "IPCA", valor: 4.62},
#   # ... more rates and indices
# ]

# Get a specific tax rate by its name/acronym
{:ok, rate} = Brasilapi.get_rate_by_acronym("CDI")
# rate => %Brasilapi.Rates.Rate{nome: "CDI", valor: 13.65}

{:ok, rate} = Brasilapi.get_rate_by_acronym("SELIC")
# rate => %Brasilapi.Rates.Rate{nome: "SELIC", valor: 13.75}

# Error handling
{:error, %{status: 404, message: "Not found"}} = Brasilapi.get_rate_by_acronym("INVALID_RATE")
{:error, %{message: "Acronym must be a string"}} = Brasilapi.get_rate_by_acronym(123)
```

### PIX (Brazilian Instant Payment System)

```elixir
# Get all PIX participants
{:ok, participants} = Brasilapi.get_pix_participants()
# participants =>
# [
#   %Brasilapi.Pix.Participant{
#     ispb: "360305",
#     nome: "CAIXA ECONOMICA FEDERAL",
#     nome_reduzido: "CAIXA ECONOMICA FEDERAL",
#     modalidade_participacao: "PDCT",
#     tipo_participacao: "DRCT",
#     inicio_operacao: "2020-11-03T09:30:00.000Z"
#   },
#   %Brasilapi.Pix.Participant{
#     ispb: "00000000",
#     nome: "BANCO DO BRASIL S.A.",
#     nome_reduzido: "BCO DO BRASIL S.A.",
#     modalidade_participacao: "DRCT",
#     tipo_participacao: "DRCT",
#     inicio_operacao: "2020-10-16T08:00:00.000Z"
#   },
#   # ... more participants
# ]

# Error handling
{:error, %{status: 500, message: "Server error"}} = Brasilapi.get_pix_participants()  # when API is down
```

### Exchange (Currency Exchange Rates)

```elixir
# Get all available currencies
{:ok, currencies} = Brasilapi.get_currencies()
# currencies =>
# [%Brasilapi.Exchange.Currency{simbolo: "USD", nome: "Dólar dos Estados Unidos", tipo_moeda: "A"},
#  %Brasilapi.Exchange.Currency{simbolo: "EUR", nome: "Euro", tipo_moeda: "A"},
#  ...]

# Get exchange rate for a specific currency and date
{:ok, daily_exchange_rate} = Brasilapi.get_exchange_rate("USD", "2025-02-13")

# Also accepts Date/DateTime/NaiveDateTime structs
{:ok, daily_exchange_rate} = Brasilapi.get_exchange_rate("USD", ~D[2025-02-13])
{:ok, daily_exchange_rate} = Brasilapi.get_exchange_rate("USD", ~U[2025-02-13 14:30:00Z])
{:ok, daily_exchange_rate} = Brasilapi.get_exchange_rate("USD", ~N[2025-02-13 14:30:00])

# daily_exchange_rate =>
# %Brasilapi.Exchange.DailyExchangeRate{
#   moeda: "USD",
#   data: "2025-02-13",
#   cotacoes: [
#     %Brasilapi.Exchange.ExchangeRate{
#       paridade_compra: 1,
#       paridade_venda: 1,
#       cotacao_compra: 5.7624,
#       cotacao_venda: 5.763,
#       data_hora_cotacao: "2025-02-13 13:03:25.722",
#       tipo_boletim: "INTERMEDIÁRIO"
#     }
#   ]
# }

# Available currencies: AUD, CAD, CHF, DKK, EUR, GBP, JPY, SEK, USD
# Data available from November 28, 1984 onwards
# For weekends and holidays, returns last available business day
# Date accepts: String (YYYY-MM-DD), Date, DateTime, NaiveDateTime

# Error handling
{:error, %{status: 404, message: "Not found"}} = Brasilapi.get_exchange_rate("INVALID", "2025-02-13")
{:error, %{message: "Invalid date format. Must be YYYY-MM-DD"}} = Brasilapi.get_exchange_rate("USD", "invalid-date")
{:error, %{message: "Currency must be a string and date must be a valid date"}} = Brasilapi.get_exchange_rate(123, "2025-02-13")
```

### RegistroBR (Brazilian Domain Registration)

```elixir
# Get domain information for .br domains
{:ok, domain} = Brasilapi.get_domain_info("brasilapi.com.br")
# domain =>
# %Brasilapi.RegistroBr.Domain{
#   status_code: 2,
#   status: "REGISTERED",
#   fqdn: "brasilapi.com.br",
#   hosts: ["bob.ns.cloudflare.com", "lily.ns.cloudflare.com"],
#   publication_status: "published",
#   expires_at: "2022-09-23T00:00:00-03:00",
#   suggestions: ["agr.br", "app.br", "art.br", "blog.br", "dev.br", ...]
# }

# Check if domain is available
{:ok, domain} = Brasilapi.get_domain_info("available-domain.com.br")
# domain.status => "AVAILABLE"
# domain.suggestions => ["net.br", "org.br", "edu.br", ...]

# Error handling
{:error, %{status: 400, message: "Bad request"}} = Brasilapi.get_domain_info("invalid-domain")
{:error, %{message: "Domain must be a string"}} = Brasilapi.get_domain_info(123)
```

### Brokers (Brokerage Firms)

```elixir
# Get all active brokerage firms registered with CVM
{:ok, brokers} = Brasilapi.get_brokers()
# brokers =>
# [%Brasilapi.Brokers.Broker{
#    cnpj: "00000000000191",
#    nome_social: "CORRETORA EXEMPLO S.A.",
#    nome_comercial: "CORRETORA EXEMPLO",
#    bairro: "CENTRO",
#    cep: "01010000",
#    codigo_cvm: "12345",
#    complemento: "ANDAR 10",
#    data_inicio_situacao: "2020-01-01",
#    data_patrimonio_liquido: "2023-12-31",
#    data_registro: "2019-06-15",
#    email: "contato@exemplo.com.br",
#    logradouro: "RUA EXEMPLO, 123",
#    municipio: "SAO PAULO",
#    pais: "BRASIL",
#    status: "ATIVA",
#    telefone: "11999999999",
#    type: "CORRETORA",
#    uf: "SP",
#    valor_patrimonio_liquido: "50000000.00"
#  },
#  # ... more brokers
# ]

# Get specific brokerage firm by CNPJ
{:ok, broker} = Brasilapi.get_broker_by_cnpj("02332886000104")
# broker =>
# %Brasilapi.Brokers.Broker{
#   bairro: "LEBLON",
#   cep: "22440032",
#   cnpj: "02332886000104",
#   codigo_cvm: "3247",
#   complemento: "SALA 201",
#   data_inicio_situacao: "1998-02-10",
#   data_patrimonio_liquido: "2021-12-31",
#   data_registro: "1997-12-05",
#   email: "juridico.regulatorio@xpi.com.br",
#   logradouro: "AVENIDA ATAULFO DE PAIVA 153",
#   municipio: "RIO DE JANEIRO",
#   nome_social: "XP INVESTIMENTOS CCTVM S.A.",
#   nome_comercial: "XP INVESTIMENTOS",
#   pais: "",
#   status: "EM FUNCIONAMENTO NORMAL",
#   telefone: "30272237",
#   type: "CORRETORAS",
#   uf: "RJ",
#   valor_patrimonio_liquido: "5514593491.29"
# }

# CNPJ can be provided as string or integer, with or without formatting
{:ok, broker} = Brasilapi.get_broker_by_cnpj("02.332.886/0001-04")  # formatted
{:ok, broker} = Brasilapi.get_broker_by_cnpj(2332886000104)         # integer
{:ok, broker} = Brasilapi.get_broker_by_cnpj("02332886000104")      # string

# Error handling
{:error, %{status: 500, message: "Internal server error"}} = Brasilapi.get_brokers()  # when API is down
{:error, %{status: 404, message: "Não foi encontrado este CNPJ na listagem da CVM."}} = Brasilapi.get_broker_by_cnpj("00000000000000")
{:error, %{message: "Invalid CNPJ format. Must be 14 digits."}} = Brasilapi.get_broker_by_cnpj("123")
```

### ISBN (International Standard Book Number)

```elixir
# Get book information by ISBN (supports both ISBN-10 and ISBN-13)
{:ok, book} = Brasilapi.get_book("9788545702870")
# book =>
# %Brasilapi.Isbn.Book{
#   isbn: "9788545702870",
#   title: "Akira",
#   subtitle: nil,
#   authors: [
#     "KATSUHIRO OTOMO",
#     "DRIK SADA",
#     "CASSIUS MEDAUAR",
#     "MARCELO DEL GRECO",
#     "DENIS TAKATA"
#   ],
#   publisher: "Japorama Editora e Comunicação",
#   synopsis: "Um dos marcos da ficção científica oriental que revolucionou...",
#   dimensions: %Brasilapi.Isbn.Dimensions{
#     width: 17.5,
#     height: 25.7,
#     unit: "CENTIMETER"
#   },
#   year: 2017,
#   format: "PHYSICAL",
#   page_count: 364,
#   subjects: ["Cartoons; caricaturas e quadrinhos", "mangá", "motocicleta", "gangue", "Delinquência"],
#   location: "SÃO PAULO, SP",
#   retail_price: nil,
#   cover_url: nil,
#   provider: "cbl"
# }

# ISBN can be provided in multiple formats
{:ok, book} = Brasilapi.get_book("978-85-457-0287-0")  # ISBN-13 with dashes
{:ok, book} = Brasilapi.get_book("9788545702870")      # ISBN-13 without dashes
{:ok, book} = Brasilapi.get_book("85-457-0287-6")      # ISBN-10 with dashes
{:ok, book} = Brasilapi.get_book("8545702876")         # ISBN-10 without dashes

# Specify providers for faster results (optional)
{:ok, book} = Brasilapi.get_book("9788545702870", providers: ["cbl"])
{:ok, book} = Brasilapi.get_book("9788545702870", providers: ["cbl", "google-books"])

# Available providers: "cbl", "mercado-editorial", "open-library", "google-books"
# If no providers specified, uses all providers and returns fastest response

# Error handling
{:error, %{status: 404, message: "Not found"}} = Brasilapi.get_book("1234567890123")
{:error, %{status: 400, message: "Bad request"}} = Brasilapi.get_book("invalid-isbn")
{:error, %{message: "Invalid ISBN format. Must be 10 or 13 digits."}} = Brasilapi.get_book("123")
{:error, %{message: "Invalid providers: invalid. Valid providers are: cbl, mercado-editorial, open-library, google-books"}} = Brasilapi.get_book("9788545702870", providers: ["invalid"])
```

## Response Types with Structs

For better type safety and developer experience, BrasilAPI provides struct definitions for all response types. You can use these structs to work with typed data instead of raw maps:

```elixir
# Bank struct
{:ok, %Brasilapi.Banks.Bank{} = bank} = Brasilapi.get_bank_by_code(1)
# bank => %Brasilapi.Banks.Bank{ispb: "00000000", name: "BCO DO BRASIL S.A.", code: 1, full_name: "Banco do Brasil S.A."}

# Broker struct
{:ok, brokers} = Brasilapi.get_brokers()
[%Brasilapi.Brokers.Broker{} = broker | _] = brokers
# broker => %Brasilapi.Brokers.Broker{cnpj: "00000000000191", nome_social: "CORRETORA EXEMPLO S.A.", nome_comercial: "CORRETORA EXEMPLO", codigo_cvm: "12345", status: "ATIVA", ...}

# Address struct
{:ok, %Brasilapi.Cep.Address{} = address} = Brasilapi.get_cep("89010025")
# address => %Brasilapi.Cep.Address{cep: "89010025", state: "SC", city: "Blumenau", neighborhood: "Centro", street: "Rua Doutor Luiz de Freitas Melro", service: "viacep", location: %{type: "Point", coordinates: %{}}}

# Company struct
{:ok, %Brasilapi.Cnpj.Company{} = company} = Brasilapi.get_cnpj("11000000000197")
# company => %Brasilapi.Cnpj.Company{cnpj: "11000000000197", razao_social: "ACME INC", nome_fantasia: "ACME CORPORATION", uf: "SP", municipio: "SAO PAULO", situacao_cadastral: 2, descricao_situacao_cadastral: "ATIVA", ...}

# Book struct
{:ok, %Brasilapi.Isbn.Book{} = book} = Brasilapi.get_book("9788545702870")
# book => %Brasilapi.Isbn.Book{isbn: "9788545702870", title: "Akira", authors: ["KATSUHIRO OTOMO", ...], publisher: "Japorama Editora e Comunicação", year: 2017, ...}

# DDD info struct
{:ok, %Brasilapi.Ddd.Info{} = ddd_info} = Brasilapi.get_ddd(11)
# ddd_info => %Brasilapi.Ddd.Info{state: "SP", cities: ["EMBU", "VÁRZEA PAULISTA", "SÃO PAULO", ...]}

# Holiday struct
{:ok, holidays} = Brasilapi.get_holidays(2021)
[%Brasilapi.Feriados.Holiday{} = holiday | _] = holidays
# holiday => %Brasilapi.Feriados.Holiday{date: "2021-01-01", name: "Confraternização mundial", type: "national", full_name: nil}

# Tax rate struct
{:ok, %Brasilapi.Rates.Rate{} = rate} = Brasilapi.get_rate_by_acronym("CDI")
# rate => %Brasilapi.Rates.Rate{nome: "CDI", valor: 13.65}

# PIX participant struct
{:ok, participants} = Brasilapi.get_pix_participants()
[%Brasilapi.Pix.Participant{} = participant | _] = participants
# participant => %Brasilapi.Pix.Participant{ispb: "360305", nome: "CAIXA ECONOMICA FEDERAL", nome_reduzido: "CAIXA ECONOMICA FEDERAL", modalidade_participacao: "PDCT", tipo_participacao: "DRCT", inicio_operacao: "2020-11-03T09:30:00.000Z"}

# RegistroBR domain struct
{:ok, %Brasilapi.RegistroBr.Domain{} = domain} = Brasilapi.get_domain_info("brasilapi.com.br")
# domain => %Brasilapi.RegistroBr.Domain{status_code: 2, status: "REGISTERED", fqdn: "brasilapi.com.br", hosts: ["bob.ns.cloudflare.com", "lily.ns.cloudflare.com"], publication_status: "published", expires_at: "2022-09-23T00:00:00-03:00", suggestions: ["agr.br", "app.br", ...]}

# Exchange currency struct
{:ok, currencies} = Brasilapi.get_currencies()
[%Brasilapi.Exchange.Currency{} = currency | _] = currencies
# currency => %Brasilapi.Exchange.Currency{simbolo: "USD", nome: "Dólar dos Estados Unidos", tipo_moeda: "A"}

# Daily exchange rate struct
{:ok, %Brasilapi.Exchange.DailyExchangeRate{} = daily_exchange_rate} = Brasilapi.get_exchange_rate("USD", "2025-02-13")
# daily_exchange_rate => %Brasilapi.Exchange.DailyExchangeRate{moeda: "USD", data: "2025-02-13", cotacoes: [%Brasilapi.Exchange.ExchangeRate{paridade_compra: 1, paridade_venda: 1, cotacao_compra: 5.7624, cotacao_venda: 5.763, ...}]}
```

### Available Structs

- `Brasilapi.Banks.Bank` - Bank information
- `Brasilapi.Brokers.Broker` - CVM-registered brokerage firm information with comprehensive registration and financial data
- `Brasilapi.Cep.Address` - CEP/Address information with location data
- `Brasilapi.Cnpj.Company` - Company information with comprehensive business data
- `Brasilapi.Ddd.Info` - DDD/Area code information with state and cities
- `Brasilapi.Feriados.Holiday` - National holiday information with date, name, and type
- `Brasilapi.Isbn.Book` - Book information with title, authors, publisher, synopsis, dimensions, and metadata
- `Brasilapi.Isbn.Dimensions` - Book dimensions with width, height, and unit measurements
- `Brasilapi.Pix.Participant` - PIX participant information with ISPB, names, and participation details
- `Brasilapi.Rates.Rate` - Tax rates and official indices with name and value
- `Brasilapi.RegistroBr.Domain` - Brazilian domain registration information with status, hosts, and suggestions
- `Brasilapi.Exchange.Currency` - Currency information with symbol, name, and type
- `Brasilapi.Exchange.DailyExchangeRate` - Daily exchange rate information with currency, date, and list of quotations
- `Brasilapi.Exchange.ExchangeRate` - Individual exchange rate quotation with buy/sell rates, parity, date/time, and bulletin type

## CNPJ Validation and Formatting

BrasilAPI-Ex (this library) provides convenient CNPJ handling with lightweight validation and automatic formatting:

### Validation Approach

- **Lightweight validation**: Only checks for 14-digit length and numeric characters
- **No checksum validation**: Does not validate actual CNPJ checksums
- **Format flexibility**: Accepts integers, formatted strings, and plain strings
- **Automatic formatting**: Converts all inputs to clean 14-digit strings

### Supported CNPJ Formats

```elixir
# All of these are equivalent and valid:
Brasilapi.get_cnpj("11000000000197")        # Plain string
Brasilapi.get_cnpj("11.000.000/0001-97")    # Formatted string
Brasilapi.get_cnpj(11000000000197)          # Integer
Brasilapi.get_cnpj("11-000-000-0001-97")    # Custom formatting

# Integers with leading zeros are automatically padded:
Brasilapi.get_cnpj(197)  # Becomes "00000000000197"
```

### Full CNPJ Validation

For complete CNPJ validation including checksum verification, consider using a dedicated library such as [brcpfcnpj](https://hex.pm/packages/brcpfcnpj):

```elixir
# Add to your dependencies for full validation
{:brcpfcnpj, "~> 1.0"}

# Use before calling BrasilAPI
if Brcpfcnpj.cnpj_valid?("11.000.000/0001-97") do
  {:ok, company} = Brasilapi.get_cnpj("11.000.000/0001-97")
else
  {:error, "Invalid CNPJ checksum"}
end
```

## Configuration

You can configure the BrasilAPI client with custom settings (you usually don't need to change these):

```elixir
# In your config/config.exs
config :brasilapi,
  base_url: "https://brasilapi.com.br/api",
  timeout: 30_000,
  retry_attempts: 3,
  req_options: []
```

### Configuration Options

- `base_url` - Base URL for BrasilAPI (default: "https://brasilapi.com.br/api")
- `timeout` - Request timeout in milliseconds (default: 30,000)
- `retry_attempts` - Number of retry attempts for failed requests (default: 3)
- `req_options` - Additional options passed to the Req HTTP client (default: [])

## Roadmap to v1.0.0

I am working towards a stable 1.0.0 release with improved consistency and comprehensive API coverage. Here's what's planned:

### 🔧 API Consistency & Naming

- **Standardize English naming patterns**: All module names, function names, and public APIs will use consistent English naming while preserving Portuguese field names from the original BrasilAPI responses in documentation for reference
- **Normalize function naming**: Migrate from `get_all_{resource}()` pattern to `get_{resources}()` pattern for better consistency:
  - `get_all_banks()` → `get_banks()`
  - `get_all_rates()` → `get_rates()`
  - Similar patterns across all resource types
- **BrasilAPI documentation**: Include the URL to the official BrasilAPI documentation for each endpoint in the function docs for easy reference

### 🚀 Complete API Coverage

Implement all remaining BrasilAPI endpoints to provide comprehensive access to Brazilian data:

### 📚 Enhanced Documentation

- Complete API documentation with Portuguese field references
- Comprehensive examples for all endpoints

### Extras

- Add validation and formatting for CNPJ and CPF using the [`brcpfcnpj`](https://hex.pm/packages/brcpfcnpj) package (if available and enabled in the configuration). Otherwise, fall back to our custom lightweight implementation.
- Implement changelog for tracking changes and versions
- Implement CI/CD pipeline for automated testing

Contributions welcome!

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/stlucasgarcia/brasilapi-ex. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/stlucasgarcia/brasilapi/blob/main/CODE_OF_CONDUCT.md).

## License

The library is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Brasilapi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/stlucasgarcia/brasilapi/blob/main/CODE_OF_CONDUCT.md).
