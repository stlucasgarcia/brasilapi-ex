<div align="center">
<h1><img src="https://raw.githubusercontent.com/BrasilAPI/BrasilAPI/main/public/brasilapi-logo-small.png" /></h1>

</div>

Brasil API lookup library for Elixir with an easy-to-use API for brazilian data.

## Features
 - [ ] **Bank**
 - [ ] **Câmbio**
 - [ ] **CEP V2**
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

```elixir
# get all banks
{:ok, banks} = Brasilapi.Bank.all()
# banks =>
# [%Brasilapi.Bank{ispb: "00000000", name: "BCO DO BRASIL S.A.", code: 1, full_name: "Banco do Brasil S.A."},
#  %Brasilapi.Bank{ispb: "00000208", name: "BRB - BCO DE BRASILIA S.A.", code: 70, full_name: "BRB - BANCO DE BRASILIA S.A."},
#  ...]

# find bank by code
{:ok, bank} = Brasilapi.Bank.find_by_code(77)
# bank => %Brasilapi.Bank{ispb: "00416968", name: "BANCO INTER", code: 77, full_name: "Banco Inter S.A."}

# find company by cnpj
{:ok, company} = Brasilapi.Company.find_by_cnpj("60316817000103")
# company =>
# %Brasilapi.Company{uf: "SP",
#   cep: "04543907",
#   qsa: [%Brasilapi.QSA{pais: "ESTADOS UNIDOS", ...}]}

# find address by zip code
{:ok, address} = Brasilapi.Address.find_by_zip_code("64001100")
# address => %Brasilapi.Address{cep: "64001100", state: "PI", city: "Teresina", neighborhood: "Centro", street: "Praça Pedro II", service: "correios"}

# find address with location by zip code
{:ok, address} = Brasilapi.Address.find_by_zip_code("80060000", location: true)
# address =>
# %Brasilapi.Address{cep: "80060000",
#   state: "PR",
#   location: %Brasilapi.Location{type: "Point", coordinates: %Brasilapi.Coordinates{longitude: "-49.2614791", latitude: "-25.427253"}}}

# get state and cities by area code
{:ok, area_code_data} = Brasilapi.Address.state_and_cities_by_area_code("89")
# area_code_data =>
# %Brasilapi.AreaCode{state: "PI",
#   cities: ["MASSÂPE DO PIAUÍ", ..., "ACAUÃ"]}

# get all CVM brokers
{:ok, brokers} = Brasilapi.CVM.all()
# brokers =>
# [%Brasilapi.CVM.Broker{cnpj: "76621457000185",
#    type: "CORRETORAS", ...}]

# find CVM broker by CNPJ
{:ok, broker} = Brasilapi.CVM.find_by_cnpj("74014747000135")
# broker =>
# %Brasilapi.CVM.Broker{cnpj: "74014747000135",
#   type: "CORRETORAS", ...}

# get brazilian national holidays by year
{:ok, holidays} = Brasilapi.Holiday.by_year(2024)
# holidays =>
# [%Brasilapi.Holiday{date: ~D[2024-01-01], name: "Confraternização mundial", type: "national"},
#  ...
#  %Brasilapi.Holiday{date: ~D[2024-12-25], name: "Natal", type: "national"}]

# get states from ibge
{:ok, states} = Brasilapi.IBGE.states()
# states =>
# [%Brasilapi.IBGE.State{id: 11,
#    sigla: "RO",
#    nome: "Rondônia",
#    regiao: %Brasilapi.IBGE.Region{id: 1, sigla: "N", nome: "Norte"}},
#    ...
#   %Brasilapi.IBGE.State{id: 53,
#    sigla: "DF",
#    nome: "Distrito Federal",
#    regiao: %Brasilapi.IBGE.Region{id: 5, sigla: "CO", nome: "Centro-Oeste"}}]

# find state by abbreviation from ibge
{:ok, state} = Brasilapi.IBGE.find_state_by_code("PI")
# state =>
# %Brasilapi.IBGE.State{id: 22,
#   sigla: "PI",
#   nome: "Piauí",
#   regiao: %Brasilapi.IBGE.Region{id: 2, sigla: "NE", nome: "Nordeste"}}

# find state by code from ibge
{:ok, state} = Brasilapi.IBGE.find_state_by_code(53)
# state =>
# %Brasilapi.IBGE.State{id: 53,
#   sigla: "DF",
#   nome: "Distrito Federal",
#   regiao: %Brasilapi.IBGE.Region{id: 5, sigla: "CO", nome: "Centro-Oeste"}}

# get cities by state abbreviation from ibge
{:ok, cities} = Brasilapi.IBGE.cities_by_state("CE")
# cities =>
# [%Brasilapi.IBGE.City{nome: "ABAIARA", codigo_ibge: "2300101"},
#  ...
#  %Brasilapi.IBGE.City{nome: "VÁRZEA ALEGRE", codigo_ibge: "2314003"},
#  %Brasilapi.IBGE.City{nome: "VIÇOSA DO CEARÁ", codigo_ibge: "2314102"}]
```

## Response Types with Structs

For better type safety and developer experience, BrasilAPI provides struct definitions for all response types. You can use these structs to work with typed data instead of raw maps:

```elixir
# Bank struct
{:ok, %Brasilapi.Bank{} = bank} = Brasilapi.Bank.find_by_code(77)
# bank => %Brasilapi.Bank{ispb: "00416968", name: "BANCO INTER", code: 77, full_name: "Banco Inter S.A."}

# Address struct
{:ok, %Brasilapi.Address{} = address} = Brasilapi.Address.find_by_zip_code("64001100")
# address => %Brasilapi.Address{cep: "64001100", state: "PI", city: "Teresina", neighborhood: "Centro", street: "Praça Pedro II", service: "correios"}

# Company struct
{:ok, %Brasilapi.Company{} = company} = Brasilapi.Company.find_by_cnpj("60316817000103")
# company => %Brasilapi.Company{uf: "SP", cep: "04543907", qsa: [%Brasilapi.QSA{pais: "ESTADOS UNIDOS", ...}]}

# Holiday struct
{:ok, holidays} = Brasilapi.Holiday.by_year(2024)
# holidays => [%Brasilapi.Holiday{date: ~D[2024-01-01], name: "Confraternização mundial", type: "national"}, ...]

# IBGE State struct
{:ok, %Brasilapi.IBGE.State{} = state} = Brasilapi.IBGE.find_state_by_code("PI")
# state => %Brasilapi.IBGE.State{id: 22, sigla: "PI", nome: "Piauí", regiao: %Brasilapi.IBGE.Region{...}}

# IBGE City struct
{:ok, cities} = Brasilapi.IBGE.cities_by_state("CE")
# cities => [%Brasilapi.IBGE.City{nome: "ABAIARA", codigo_ibge: "2300101"}, ...]
```

### Available Structs

- `Brasilapi.Bank` - Bank information
- `Brasilapi.Address` - Address/CEP information
- `Brasilapi.Location` - Location data with coordinates
- `Brasilapi.Coordinates` - Longitude and latitude coordinates
- `Brasilapi.AreaCode` - Area code data with state and cities
- `Brasilapi.Company` - Company/CNPJ information
- `Brasilapi.QSA` - Company partners information
- `Brasilapi.CVM.Broker` - CVM broker information
- `Brasilapi.Holiday` - National holiday information
- `Brasilapi.IBGE.State` - IBGE state information
- `Brasilapi.IBGE.Region` - IBGE region information
- `Brasilapi.IBGE.City` - IBGE city information

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/stlucasgarcia/brasilapi. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/stlucasgarcia/brasilapi/blob/main/CODE_OF_CONDUCT.md).

## License

The library is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Brasilapi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/stlucasgarcia/brasilapi/blob/main/CODE_OF_CONDUCT.md).
