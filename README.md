<div align="center">
<h1><img src="https://raw.githubusercontent.com/BrasilAPI/BrasilAPI/main/public/brasilapi-logo-small.png" /></h1>

</div>

Brasil API lookup library for Elixir with an easy-to-use API for brazilian data.

## Features
 - [x] **Bancos**
 - [ ] **Câmbio**
 - [x] **CEP V2**
 - [ ] **CNPJ**
 - [ ] **Corretoras**
 - [ ] **CPTEC**
 - [ ] **DDD**
 - [ ] **Feriados Nacionais**
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

### Banks (Bancos)

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
{:ok, cep_data} = Brasilapi.get_cep("89010025")
# cep_data =>
# %Brasilapi.Cep.CepData{
#   cep: "89010025",
#   state: "SC",
#   city: "Blumenau",
#   neighborhood: "Centro",
#   street: "Rua Doutor Luiz de Freitas Melro",
#   service: "viacep",
#   location: %{type: "Point", coordinates: %{}}
# }

# CEP can be provided as string or integer, with or without formatting
{:ok, cep_data} = Brasilapi.get_cep("89010-025")  # formatted
{:ok, cep_data} = Brasilapi.get_cep(89010025)     # integer
{:ok, cep_data} = Brasilapi.get_cep("89010025")   # string

# Error handling
{:error, %{status: 404, message: "Not found"}} = Brasilapi.get_cep("00000000")
{:error, %{message: "CEP must be exactly 8 digits"}} = Brasilapi.get_cep("123")
```

## Response Types with Structs

For better type safety and developer experience, BrasilAPI provides struct definitions for all response types. You can use these structs to work with typed data instead of raw maps:

```elixir
# Bank struct
{:ok, %Brasilapi.Banks.Bank{} = bank} = Brasilapi.get_bank_by_code(1)
# bank => %Brasilapi.Banks.Bank{ispb: "00000000", name: "BCO DO BRASIL S.A.", code: 1, full_name: "Banco do Brasil S.A."}

# CEP struct
{:ok, %Brasilapi.Cep.CepData{} = cep_data} = Brasilapi.get_cep("89010025")
# cep_data => %Brasilapi.Cep.CepData{cep: "89010025", state: "SC", city: "Blumenau", neighborhood: "Centro", street: "Rua Doutor Luiz de Freitas Melro", service: "viacep", location: %{type: "Point", coordinates: %{}}}
```

### Available Structs

- `Brasilapi.Banks.Bank` - Bank information
- `Brasilapi.Cep.CepData` - CEP/Address information with location data

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

Bug reports and pull requests are welcome on GitHub at https://github.com/stlucasgarcia/brasilapi. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/stlucasgarcia/brasilapi/blob/main/CODE_OF_CONDUCT.md).

## License

The library is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Brasilapi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/stlucasgarcia/brasilapi/blob/main/CODE_OF_CONDUCT.md).
