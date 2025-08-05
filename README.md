<div align="center">
<h1><img src="https://raw.githubusercontent.com/BrasilAPI/BrasilAPI/main/public/brasilapi-logo-small.png" /></h1>

</div>

Brasil API lookup library for Elixir with an easy-to-use API for brazilian data.

## Features
 - [ ] **Bank**
 - [ ] **CEP (Zip code)**
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
Brasilapi.Bank.all()
# =>
# [%{"ispb" => "00000000", "name" => "BCO DO BRASIL S.A.", "code" => 1, "fullName" => "Banco do Brasil S.A."},
#  %{"ispb" => "00000208", "name" => "BRB - BCO DE BRASILIA S.A.", "code" => 70, "fullName" => "BRB - BANCO DE BRASILIA S.A."},
#  ...]

# find bank by code
Brasilapi.Bank.find_by_code(77)
# => %{"ispb" => "00416968", "name" => "BANCO INTER", "code" => 77, "fullName" => "Banco Inter S.A."}

# find company by cnpj
Brasilapi.Company.find_by_cnpj("60316817000103")
# =>
# %{"uf" => "SP",
#   "cep" => "04543907",
#   "qsa" =>
#     [%{"pais" => "ESTADOS UNIDOS",
#     ...}

# find address by zip code
Brasilapi.Address.find_by_zip_code("64001100")
# => %{"cep" => "64001100", "state" => "PI", "city" => "Teresina", "neighborhood" => "Centro", "street" => "Praça Pedro II", "service" => "correios"}

# find address with location by zip code
Brasilapi.Address.find_by_zip_code("80060000", location: true)
# =>
# %{"cep" => "80060000",
#   "state" => "PR",
#   ...
#   "location" => %{"type" => "Point", "coordinates" => %{"longitude" => "-49.2614791", "latitude" => "-25.427253"}}}

# get state and cities by area code
Brasilapi.Address.state_and_cities_by_area_code("89")
# =>
# %{"state" => "PI",
#   "cities" =>
#   ["MASSÂPE DO PIAUÍ",
#    ...,
#    "ACAUÃ"
#   ]}

# get all CVM brokers
Brasilapi.CVM.all()
# =>
# [%{"cnpj" => "76621457000185",
#    "type" => "CORRETORAS",
#    ...}]

# find CVM broker by CNPJ
Brasilapi.CVM.find_by_cnpj("74014747000135")
# =>
# %{"cnpj" => "74014747000135",
#   "type" => "CORRETORAS",
#   ...}

# get brazilian national holidays by year
Brasilapi.Holiday.by_year(2024)
# =>
# [%{"date" => "2024-01-01", "name" => "Confraternização mundial", "type" => "national"},
#  ...
#  %{"date" => "2024-12-25", "name" => "Natal", "type" => "national"}]

# get states from ibge
Brasilapi.IBGE.states()
# =>
# [%{"id" => 11,
#    "sigla" => "RO"
#    "nome" => "Rondônia",
#    "regiao" => %{"id" => 1, "sigla" => "N", "nome" => "Norte"}},
#    ...
#   %{"id" => 53,
#    "sigla" => "DF",
#    "nome" => "Distrito Federal",
#    "regiao" => %{"id" => 5, "sigla" => "CO", "nome" => "Centro-Oeste"}}]

# find state by abbreviation from ibge
Brasilapi.IBGE.find_state_by_code("PI")
# =>
# %{"id" => 22,
#   "sigla" => "PI",
#   "nome" => "Piauí",
#   "regiao" => %{"id" => 2, "sigla" => "NE", "nome" => "Nordeste"}}

# find state by code from ibge
Brasilapi.IBGE.find_state_by_code(53)
# =>
# %{"id" => 53,
#   "sigla" => "DF",
#   "nome" => "Distrito Federal",
#   "regiao" => %{"id" => 5, "sigla" => "CO", "nome" => "Centro-Oeste"}}

# get cities by state abbreviation from ibge
Brasilapi.IBGE.cities_by_state("CE")
# =>
# [%{"nome" => "ABAIARA", "codigo_ibge" => "2300101"},
#  ...
#  %{"nome" => "VÁRZEA ALEGRE", "codigo_ibge" => "2314003"},
#  %{"nome" => "VIÇOSA DO CEARÁ", "codigo_ibge" => "2314102"}]
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/stlucasgarcia/brasilapi. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/stlucasgarcia/brasilapi/blob/main/CODE_OF_CONDUCT.md).

## License

The library is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Brasilapi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/stlucasgarcia/brasilapi/blob/main/CODE_OF_CONDUCT.md).
