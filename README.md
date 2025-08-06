<div align="center">
<h1><img src="https://raw.githubusercontent.com/BrasilAPI/BrasilAPI/main/public/brasilapi-logo-small.png" /></h1>

</div>

Brasil API lookup library for Elixir with an easy-to-use API for brazilian data including banks, postal codes (CEP), company information (CNPJ), area codes (DDD), and national holidays.

## Features
 - [x] **Bancos**
 - [ ] **Câmbio**
 - [x] **CEP V2**
 - [x] **CNPJ**
 - [ ] **Corretoras**
 - [ ] **CPTEC**
 - [x] **DDD**
 - [x] **Feriados Nacionais**
 - [ ] **FIPE**
 - [ ] **IBGE**
 - [ ] **ISBN**
 - [ ] **NCM**
 - [ ] **PIX**
 - [ ] **Registros BR**
 - [ ] **Taxas**

## Installation

Add `brasilapi` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:brasilapi, "~> 0.1.0"}
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

## Response Types with Structs

For better type safety and developer experience, BrasilAPI provides struct definitions for all response types. You can use these structs to work with typed data instead of raw maps:

```elixir
# Bank struct
{:ok, %Brasilapi.Banks.Bank{} = bank} = Brasilapi.get_bank_by_code(1)
# bank => %Brasilapi.Banks.Bank{ispb: "00000000", name: "BCO DO BRASIL S.A.", code: 1, full_name: "Banco do Brasil S.A."}

# Address struct
{:ok, %Brasilapi.Cep.Address{} = address} = Brasilapi.get_cep("89010025")
# address => %Brasilapi.Cep.Address{cep: "89010025", state: "SC", city: "Blumenau", neighborhood: "Centro", street: "Rua Doutor Luiz de Freitas Melro", service: "viacep", location: %{type: "Point", coordinates: %{}}}

# Company struct
{:ok, %Brasilapi.Cnpj.Company{} = company} = Brasilapi.get_cnpj("11000000000197")
# company => %Brasilapi.Cnpj.Company{cnpj: "11000000000197", razao_social: "ACME INC", nome_fantasia: "ACME CORPORATION", uf: "SP", municipio: "SAO PAULO", situacao_cadastral: 2, descricao_situacao_cadastral: "ATIVA", ...}

# DDD info struct
{:ok, %Brasilapi.Ddd.Info{} = ddd_info} = Brasilapi.get_ddd(11)
# ddd_info => %Brasilapi.Ddd.Info{state: "SP", cities: ["EMBU", "VÁRZEA PAULISTA", "SÃO PAULO", ...]}

# Holiday struct
{:ok, holidays} = Brasilapi.get_holidays(2021)
[%Brasilapi.Feriados.Holiday{} = holiday | _] = holidays
# holiday => %Brasilapi.Feriados.Holiday{date: "2021-01-01", name: "Confraternização mundial", type: "national", full_name: nil}
```

### Available Structs

- `Brasilapi.Banks.Bank` - Bank information
- `Brasilapi.Cep.Address` - CEP/Address information with location data
- `Brasilapi.Cnpj.Company` - Company information with comprehensive business data
- `Brasilapi.Ddd.Info` - DDD/Area code information with state and cities
- `Brasilapi.Feriados.Holiday` - National holiday information with date, name, and type

## Configuration

You can configure the BrasilAPI client with custom settings:

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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/stlucasgarcia/brasilapi-ex. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/stlucasgarcia/brasilapi/blob/main/CODE_OF_CONDUCT.md).

## License

The library is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Brasilapi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/stlucasgarcia/brasilapi/blob/main/CODE_OF_CONDUCT.md).
