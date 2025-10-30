defmodule Brasilapi do
  @moduledoc """
  A simple Elixir client for BrasilAPI.

  BrasilAPI is a public API that provides access to various Brazilian data
  such as postal codes, states, cities, banks, and more.

  ## Examples

      # Get all banks
      {:ok, banks} = Brasilapi.get_banks()

      # Get a specific bank by code
      {:ok, bank} = Brasilapi.get_bank_by_code(1)

      # Get all currencies
      {:ok, currencies} = Brasilapi.get_exchange_currencies()

      # Get exchange rate
      {:ok, exchange_rate} = Brasilapi.get_exchange_rate("USD", "2025-02-13")

      # Get CEP information
      {:ok, cep_data} = Brasilapi.get_cep("89010025")

      # Get CNPJ information
      {:ok, company} = Brasilapi.get_cnpj("19131243000197")

      # Get all brokerage firms
      {:ok, brokers} = Brasilapi.get_brokers()

      # Get specific brokerage firm by CNPJ
      {:ok, broker} = Brasilapi.get_broker_by_cnpj("02332886000104")

      # Get DDD information
      {:ok, ddd_info} = Brasilapi.get_ddd(11)

      # Get national holidays
      {:ok, holidays} = Brasilapi.get_holidays(2021)

      # Get FIPE vehicle brands
      {:ok, brands} = Brasilapi.get_fipe_brands("carros")

      # Get FIPE vehicle price
      {:ok, prices} = Brasilapi.get_fipe_price("001004-9")

      # Get FIPE reference tables
      {:ok, tables} = Brasilapi.get_fipe_reference_tables()

      # Get FIPE vehicles by brand
      {:ok, vehicles} = Brasilapi.get_fipe_vehicles("carros", 1)

      # Get all Brazilian states
      {:ok, states} = Brasilapi.get_states()

      # Get specific state information
      {:ok, state} = Brasilapi.get_state("SP")

      # Get municipalities for a state
      {:ok, municipalities} = Brasilapi.get_municipalities("SC")

      # Get book information by ISBN
      {:ok, book} = Brasilapi.get_book("9788545702870")

      # Get all NCM codes
      {:ok, ncms} = Brasilapi.get_ncms()

      # Search NCM codes
      {:ok, ncms} = Brasilapi.search_ncms("xampu")

      # Get specific NCM by code
      {:ok, ncm} = Brasilapi.get_ncm_by_code("33051000")

      # Get PIX participants
      {:ok, participants} = Brasilapi.get_pix_participants()

      # Get domain information
      {:ok, domain} = Brasilapi.get_domain_info("brasilapi.com.br")

      # Get all tax rates
      {:ok, rates} = Brasilapi.get_rates()

      # Get a specific tax rate
      {:ok, rate} = Brasilapi.get_rate_by_acronym("CDI")

      # List all CPTEC cities
      {:ok, all_cities} = Brasilapi.list_cptec_cities()

      # Search for cities in CPTEC
      {:ok, cities} = Brasilapi.search_cptec_cities("São Paulo")

      # Get current weather for all capitals
      {:ok, weather} = Brasilapi.get_capitals_weather()

      # Get airport weather
      {:ok, airport_weather} = Brasilapi.get_airport_weather("SBGR")

      # Get city weather forecast
      {:ok, forecast} = Brasilapi.get_city_forecast(244)

      # Get city weather forecast for 6 days
      {:ok, forecast} = Brasilapi.get_city_forecast(244, 6)

      # Get ocean forecast
      {:ok, ocean_forecast} = Brasilapi.get_ocean_forecast(241)

      # Get ocean forecast for 3 days
      {:ok, ocean_forecast} = Brasilapi.get_ocean_forecast(241, 3)

  """

  alias Brasilapi.{
    Banks,
    Brokers,
    Cep,
    Cnpj,
    Cptec,
    Ddd,
    Exchange,
    Fipe,
    Holidays,
    Ibge,
    Isbn,
    Ncm,
    Pix,
    Rates,
    RegistroBr
  }

  # BANKS

  @doc """
  Get all banks from BrasilAPI.

  ## API Reference
    https://brasilapi.com.br/docs#tag/BANKS/paths/~1banks~1v1/get
  """
  defdelegate get_banks(), to: Banks

  @doc """
  Get a specific bank by its code.

  ## API Reference
    https://brasilapi.com.br/docs#tag/BANKS/paths/~1banks~1v1~1%7Bcode%7D/get
  """
  defdelegate get_bank_by_code(code), to: Banks

  # CAMBIO (Exchange)

  @doc """
  Get all available currencies for exchange rate queries.

  ## API Reference
    https://brasilapi.com.br/docs#tag/CAMBIO/paths/~1cambio~1v1~1moedas/get
  """
  defdelegate get_exchange_currencies(), to: Exchange

  @doc """
  Get the exchange rate between Real and another currency for a specific date.

  ## API Reference
    https://brasilapi.com.br/docs#tag/CAMBIO/paths/~1cambio~1v1~1cotacao~1%7Bmoeda%7D~1%7Bdata%7D/get
  """
  defdelegate get_exchange_rate(currency, date), to: Exchange

  # CEP

  @doc """
  Get CEP (postal code) information.

  By default uses the v2 endpoint which includes geolocation data.
  You can use the v1 endpoint by passing `version: :v1` in the options.

  ## Options
    * `:version` - API version to use (`:v1` or `:v2`). Defaults to `:v2`.

  ## API Reference
    * V2: https://brasilapi.com.br/docs#tag/CEP-V2/paths/~1cep~1v2~1%7Bcep%7D/get
    * V1: https://brasilapi.com.br/docs#tag/CEP/paths/~1cep~1v1~1%7Bcep%7D/get
  """
  defdelegate get_cep(cep, opts \\ []), to: Cep, as: :get_by_cep

  # CNPJ

  @doc """
  Get company information by CNPJ.

  ## API Reference
    https://brasilapi.com.br/docs#tag/CNPJ/paths/~1cnpj~1v1~1%7Bcnpj%7D/get
  """
  defdelegate get_cnpj(cnpj), to: Cnpj, as: :get_by_cnpj

  # CPTEC

  @doc """
  List all cities available in CPTEC services.

  Returns a complete listing of all cities with their CPTEC codes.
  The city code (id) is used in other CPTEC endpoints for weather and ocean forecasts.

  Note: The CPTEC web service can be unstable. If you don't find a specific city
  in the complete listing, try searching by part of its name using `search_cptec_cities/1`.

  ## API Reference
    https://brasilapi.com.br/docs#tag/CPTEC/operation/listcities(/cptec/v1/cidade)
  """
  defdelegate list_cptec_cities(), to: Cptec, as: :list_cities

  @doc """
  Search for cities by name to get their CPTEC codes.

  Returns a list of cities matching the search term. The city code (id) is used
  in other CPTEC endpoints for weather and ocean forecasts.

  ## API Reference
    https://brasilapi.com.br/docs#tag/CPTEC/operation/searchcities(/cptec/v1/cidade/:cityName)
  """
  defdelegate search_cptec_cities(city_name), to: Cptec, as: :search_cities

  @doc """
  Get current weather conditions for all Brazilian state capitals.

  Returns meteorological data from airport weather stations in each capital city.

  ## API Reference
    https://brasilapi.com.br/docs#tag/CPTEC/operation/Condi%C3%A7%C3%B5esatuaisnascapitais(/cptec/v1/clima/capital)
  """
  defdelegate get_capitals_weather(), to: Cptec

  @doc """
  Get current weather conditions at a specific airport by ICAO code.

  The ICAO code must be 4 uppercase letters (e.g., "SBGR", "SBAR").

  ## API Reference
    https://brasilapi.com.br/docs#tag/CPTEC/operation/airportcurrentcondicao(/cptec/v1/clima/aeroporto/:icaoCode)
  """
  defdelegate get_airport_weather(icao_code), to: Cptec

  @doc """
  Get weather forecast for a city.

  Supports both 1-day and multi-day forecasts (up to 6 days).
  Use the city code obtained from `search_cptec_cities/1`.

  ## API Reference
    https://brasilapi.com.br/docs#tag/CPTEC/operation/climapredictionwithoutdays(/cptec/v1/clima/previsao/:cityCode)
    https://brasilapi.com.br/docs#tag/CPTEC/operation/upto14daysprediction(/cptec/v1/clima/previsao/:cityCode/:days)
  """
  defdelegate get_city_forecast(city_code), to: Cptec
  defdelegate get_city_forecast(city_code, days), to: Cptec

  @doc """
  Get ocean/wave forecast for a coastal city.

  Supports both 1-day and multi-day forecasts (up to 6 days).
  Use the city code obtained from `search_cptec_cities/1`.

  ## API Reference
    https://brasilapi.com.br/docs#tag/CPTEC/operation/ondaspredictionwithoutdays(/cptec/v1/ondas/:cityCode)
    https://brasilapi.com.br/docs#tag/CPTEC/operation/ondaspredictionupto6days(/cptec/v1/ondas/:cityCode/:days)
  """
  defdelegate get_ocean_forecast(city_code), to: Cptec
  defdelegate get_ocean_forecast(city_code, days), to: Cptec

  # Corretoras (Brokers)

  @doc """
  Get all active brokerage firms registered with CVM.

  ## API Reference
    https://brasilapi.com.br/docs#tag/Corretoras/paths/~1cvm~1corretoras~1v1/get
  """
  defdelegate get_brokers(), to: Brokers

  @doc """
  Get a specific brokerage firm by its CNPJ from CVM records.

  ## API Reference
    https://brasilapi.com.br/docs#tag/Corretoras/paths/~1cvm~1corretoras~1v1~1%7Bcnpj%7D/get
  """
  defdelegate get_broker_by_cnpj(cnpj), to: Brokers

  # DDD

  @doc """
  Get DDD (area code) information including state and cities.

  ## API Reference
    https://brasilapi.com.br/docs#tag/DDD/paths/~1ddd~1v1~1%7Bddd%7D/get
  """
  defdelegate get_ddd(ddd), to: Ddd, as: :get_by_ddd

  # Feriados Nacionais (National Holidays)

  @doc """
  Get national holidays for a specific year.

  ## API Reference
    https://brasilapi.com.br/docs#tag/Feriados-Nacionais/paths/~1feriados~1v1~1%7Bano%7D/get
  """
  defdelegate get_holidays(year), to: Holidays, as: :get_by_year

  # FIPE

  @doc """
  Get vehicle brands by type from FIPE table.

  Returns a list of brands for a specific vehicle type or all types.

  ## API Reference
    https://brasilapi.com.br/docs#tag/FIPE/paths/~1fipe~1marcas~1v1~1%7BtipoVeiculo%7D/get
  """
  defdelegate get_fipe_brands(vehicle_type \\ nil, opts \\ []), to: Fipe, as: :get_brands

  @doc """
  Get vehicle price by FIPE code.

  Returns detailed price information for a specific vehicle according to the FIPE table.

  ## API Reference
    https://brasilapi.com.br/docs#tag/FIPE/paths/~1fipe~1preco~1v1~1%7BcodigoFipe%7D/get
  """
  defdelegate get_fipe_price(fipe_code, opts \\ []), to: Fipe, as: :get_price

  @doc """
  Get all available FIPE reference tables.

  Returns a list of all reference tables with their codes and months.

  ## API Reference
    https://brasilapi.com.br/docs#tag/FIPE/paths/~1fipe~1tabelas~1v1/get
  """
  defdelegate get_fipe_reference_tables(), to: Fipe, as: :get_reference_tables

  @doc """
  Get vehicles by brand and type from FIPE table.

  Returns a list of vehicle models for a specific brand and vehicle type.

  ## API Reference
    https://brasilapi.com.br/docs#tag/FIPE/paths/~1fipe~1veiculos~1v1~1%7BtipoVeiculo%7D~1%7BcodigoMarca%7D/get
  """
  defdelegate get_fipe_vehicles(vehicle_type, brand_code, opts \\ []),
    to: Fipe,
    as: :get_vehicles

  # IBGE

  @doc """
  Get all Brazilian states.

  Returns information about all states including their regions.

  ## API Reference
    https://brasilapi.com.br/docs#tag/IBGE/paths/~1ibge~1uf~1v1/get
  """
  defdelegate get_states(), to: Ibge

  @doc """
  Get information about a specific state by code or abbreviation.

  ## API Reference
    https://brasilapi.com.br/docs#tag/IBGE/paths/~1ibge~1uf~1v1~1%7Bcode%7D/get
  """
  defdelegate get_state(code), to: Ibge

  @doc """
  Get municipalities for a given state.

  Returns a list of municipalities for the specified state (UF).
  Optionally accepts a list of data providers.

  ## API Reference
    https://brasilapi.com.br/docs#tag/IBGE/paths/~1ibge~1municipios~1v1~1%7BsiglaUF%7D?providers=dados-abertos-br,gov,wikipedia/get
  """
  defdelegate get_municipalities(uf, opts \\ []), to: Ibge

  # ISBN

  @doc """
  Get book information by ISBN from multiple providers.

  ## API Reference
    https://brasilapi.com.br/docs#tag/ISBN/paths/~1isbn~1v1~1%7Bisbn%7D/get
  """
  defdelegate get_book(isbn, opts \\ []), to: Isbn

  # NCM

  @doc """
  Get all NCM (Nomenclatura Comum do Mercosul) codes.

  ## API Reference
    https://brasilapi.com.br/docs#tag/NCM/paths/~1ncm~1v1/get
  """
  defdelegate get_ncms(), to: Ncm

  @doc """
  Search NCM codes using a code or description keyword.

  ## API Reference
    https://brasilapi.com.br/docs#tag/NCM/paths/~1ncm~1v1?search=%7Bcode%7D/get
  """
  defdelegate search_ncms(query), to: Ncm

  @doc """
  Get detailed information for a specific NCM code.

  ## API Reference
    https://brasilapi.com.br/docs#tag/NCM/paths/~1ncm~1v1~1%7Bcode%7D/get
  """
  defdelegate get_ncm_by_code(code), to: Ncm

  # PIX

  @doc """
  Get all PIX participants.

  ## API Reference
    https://brasilapi.com.br/docs#tag/PIX/paths/~1pix~1v1~1participants/get
  """
  defdelegate get_pix_participants(), to: Pix, as: :get_participants

  # REGISTRO BR

  @doc """
  Get Brazilian domain (.br) registration information.

  ## API Reference
    https://brasilapi.com.br/docs#tag/REGISTRO-BR/paths/~1registrobr~1v1~1%7Bdomain%7D/get
  """
  defdelegate get_domain_info(domain), to: RegistroBr, as: :get_domain_info

  # TAXAS (Rates)

  @doc """
  Get all available tax rates and indices.

  ## API Reference
    https://brasilapi.com.br/docs#tag/TAXAS/paths/~1taxas~1v1/get
  """
  defdelegate get_rates(), to: Rates, as: :get_rates

  @doc """
  Get a specific tax rate or index by its name/acronym.

  ## API Reference
    https://brasilapi.com.br/docs#tag/TAXAS/paths/~1taxas~1v1~1%7Bsigla%7D/get
  """
  defdelegate get_rate_by_acronym(acronym), to: Rates, as: :get_rates_by_acronym
end
