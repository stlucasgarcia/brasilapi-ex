defmodule Brasilapi.Cptec.API do
  @moduledoc """
  Client for BrasilAPI CPTEC (Centro de Previsão de Tempo e Estudos Climáticos) endpoints.

  Provides access to weather forecasts, current conditions, and ocean forecasts from CPTEC.
  """

  alias Brasilapi.Client
  alias Brasilapi.Cptec.{AirportConditions, City, CityForecast, OceanForecast}

  @doc """
  Lists all cities available in CPTEC services.

  Returns a complete listing of all cities with their CPTEC codes.
  The CPTEC code is used in other endpoints for weather and ocean forecasts.

  Note: The CPTEC web service can be unstable. If you don't find a specific city
  in the complete listing, try searching by part of its name using `search_cities/1`.

  ## Examples

      iex> Brasilapi.Cptec.API.list_cities()
      {:ok, [%Brasilapi.Cptec.City{nome: "São Paulo", estado: "SP", id: 244}, ...]}

  ## API Reference
    https://brasilapi.com.br/docs#tag/CPTEC/operation/listcities(/cptec/v1/cidade)

  """
  @spec list_cities() :: {:ok, list(City.t())} | {:error, map()}
  def list_cities do
    with {:ok, cities} when is_list(cities) <- Client.get("/cptec/v1/cidade") do
      {:ok, Enum.map(cities, &City.from_map/1)}
    end
  end

  @doc """
  Searches for cities by name.

  Returns a list of cities matching the search term along with their CPTEC codes.
  The CPTEC code is used in other endpoints for weather and ocean forecasts.

  ## Parameters

    - `city_name`: Name or partial name of the city to search for (string)

  ## Examples

      iex> Brasilapi.Cptec.API.search_cities("São Paulo")
      {:ok, [%Brasilapi.Cptec.City{nome: "São Paulo", estado: "SP", id: 244}]}

      iex> Brasilapi.Cptec.API.search_cities("Chiforímpola")
      {:ok, [%Brasilapi.Cptec.City{nome: "São Benedito", estado: "CE", id: 4750}]}

  ## API Reference
    https://brasilapi.com.br/docs#tag/CPTEC/operation/searchcities(/cptec/v1/cidade/:cityName)
  """
  @spec search_cities(String.t()) :: {:ok, list(City.t())} | {:error, map()}
  def search_cities(city_name) when is_binary(city_name) do
    encoded_name = URI.encode(city_name)

    with {:ok, cities} when is_list(cities) <- Client.get("/cptec/v1/cidade/#{encoded_name}") do
      {:ok, Enum.map(cities, &City.from_map/1)}
    end
  end

  def search_cities(_city_name) do
    {:error, %{message: "City name must be a string"}}
  end

  @doc """
  Fetches current weather conditions for all Brazilian state capitals.

  Returns meteorological data from airport weather stations in each capital city.

  ## Examples

      iex> Brasilapi.Cptec.API.get_capitals_weather()
      {:ok, [%Brasilapi.Cptec.AirportConditions{codigo_icao: "SBGR", temp: 28, ...}, ...]}

  ## API Reference
    https://brasilapi.com.br/docs#tag/CPTEC/operation/Condi%C3%A7%C3%B5esatuaisnascapitais(/cptec/v1/clima/capital)
  """
  @spec get_capitals_weather() :: {:ok, list(AirportConditions.t())} | {:error, map()}
  def get_capitals_weather do
    with {:ok, conditions} when is_list(conditions) <- Client.get("/cptec/v1/clima/capital") do
      {:ok, Enum.map(conditions, &AirportConditions.from_map/1)}
    end
  end

  @doc """
  Fetches current weather conditions at a specific airport.

  Returns meteorological data from the weather station at the specified airport.

  ## Parameters

    - `icao_code`: ICAO airport code (4 uppercase letters, e.g., "SBGR", "SBAR")

  ## Examples

      iex> Brasilapi.Cptec.API.get_airport_weather("SBGR")
      {:ok, %Brasilapi.Cptec.AirportConditions{codigo_icao: "SBGR", temp: 28, ...}}

      iex> Brasilapi.Cptec.API.get_airport_weather("invalid")
      {:error, %{message: "ICAO code must be exactly 4 uppercase letters"}}

  ## API Reference
    https://brasilapi.com.br/docs#tag/CPTEC/operation/airportcurrentcondicao(/cptec/v1/clima/aeroporto/:icaoCode)
  """
  @spec get_airport_weather(String.t()) :: {:ok, AirportConditions.t()} | {:error, map()}
  def get_airport_weather(icao_code) when is_binary(icao_code) do
    with {:ok, normalized_code} <- validate_icao_code(icao_code),
         {:ok, %{} = conditions} <- Client.get("/cptec/v1/clima/aeroporto/#{normalized_code}") do
      {:ok, AirportConditions.from_map(conditions)}
    end
  end

  def get_airport_weather(_icao_code) do
    {:error, %{message: "ICAO code must be a string"}}
  end

  @doc """
  Fetches weather forecast for a city (1 day by default).

  Returns the weather forecast for the specified city code.

  ## Parameters

    - `city_code`: City code obtained from `search_cities/1` (integer)

  ## Examples

      iex> Brasilapi.Cptec.API.get_city_forecast(244)
      {:ok, %Brasilapi.Cptec.CityForecast{cidade: "São Paulo", estado: "SP", clima: [...]}}

  ## API Reference
    https://brasilapi.com.br/docs#tag/CPTEC/operation/climapredictionwithoutdays(/cptec/v1/clima/previsao/:cityCode)
  """
  @spec get_city_forecast(integer()) :: {:ok, CityForecast.t()} | {:error, map()}
  def get_city_forecast(city_code) when is_integer(city_code) do
    with {:ok, %{} = forecast} <- Client.get("/cptec/v1/clima/previsao/#{city_code}") do
      {:ok, CityForecast.from_map(forecast)}
    end
  end

  def get_city_forecast(_city_code) do
    {:error, %{message: "City code must be an integer"}}
  end

  @doc """
  Fetches weather forecast for a city for multiple days (up to 6 days).

  Returns the weather forecast for the specified city code for the given number of days.

  ## Parameters

    - `city_code`: City code obtained from `search_cities/1` (integer)
    - `days`: Number of days for the forecast (1-6)

  ## Examples

      iex> Brasilapi.Cptec.API.get_city_forecast(244, 3)
      {:ok, %Brasilapi.Cptec.CityForecast{cidade: "São Paulo", estado: "SP", clima: [...]}}

      iex> Brasilapi.Cptec.API.get_city_forecast(244, 7)
      {:error, %{message: "Days parameter must be between 1 and 6"}}

  ## API Reference
    https://brasilapi.com.br/docs#tag/CPTEC/operation/upto14daysprediction(/cptec/v1/clima/previsao/:cityCode/:days)
  """
  @spec get_city_forecast(integer(), integer()) :: {:ok, CityForecast.t()} | {:error, map()}
  def get_city_forecast(city_code, days) when is_integer(city_code) and is_integer(days) do
    with {:ok, validated_days} <- validate_days(days),
         {:ok, %{} = forecast} <-
           Client.get("/cptec/v1/clima/previsao/#{city_code}/#{validated_days}") do
      {:ok, CityForecast.from_map(forecast)}
    end
  end

  def get_city_forecast(_city_code, _days) do
    {:error, %{message: "City code and days must be integers"}}
  end

  @doc """
  Fetches ocean forecast for a coastal city (1 day by default).

  Returns the ocean/wave forecast for the specified city code.

  ## Parameters

    - `city_code`: City code obtained from `search_cities/1` (integer)

  ## Examples

      iex> Brasilapi.Cptec.API.get_ocean_forecast(241)
      {:ok, %Brasilapi.Cptec.OceanForecast{cidade: "Rio de Janeiro", estado: "RJ", ondas: [...]}}

  ## API Reference
    https://brasilapi.com.br/docs#tag/CPTEC/operation/ondaspredictionwithoutdays(/cptec/v1/ondas/:cityCode)
  """
  @spec get_ocean_forecast(integer()) :: {:ok, OceanForecast.t()} | {:error, map()}
  def get_ocean_forecast(city_code) when is_integer(city_code) do
    with {:ok, %{} = forecast} <- Client.get("/cptec/v1/ondas/#{city_code}") do
      {:ok, OceanForecast.from_map(forecast)}
    end
  end

  def get_ocean_forecast(_city_code) do
    {:error, %{message: "City code must be an integer"}}
  end

  @doc """
  Fetches ocean forecast for a coastal city for multiple days (up to 6 days).

  Returns the ocean/wave forecast for the specified city code for the given number of days.

  ## Parameters

    - `city_code`: City code obtained from `search_cities/1` (integer)
    - `days`: Number of days for the forecast (1-6)

  ## Examples

      iex> Brasilapi.Cptec.API.get_ocean_forecast(241, 3)
      {:ok, %Brasilapi.Cptec.OceanForecast{cidade: "Rio de Janeiro", estado: "RJ", ondas: [...]}}

      iex> Brasilapi.Cptec.API.get_ocean_forecast(241, 7)
      {:error, %{message: "Days parameter must be between 1 and 6"}}

  ## API Reference
    https://brasilapi.com.br/docs#tag/CPTEC/operation/ondaspredictionupto6days(/cptec/v1/ondas/:cityCode/:days)
  """
  @spec get_ocean_forecast(integer(), integer()) :: {:ok, OceanForecast.t()} | {:error, map()}
  def get_ocean_forecast(city_code, days) when is_integer(city_code) and is_integer(days) do
    with {:ok, validated_days} <- validate_days(days),
         {:ok, %{} = forecast} <- Client.get("/cptec/v1/ondas/#{city_code}/#{validated_days}") do
      {:ok, OceanForecast.from_map(forecast)}
    end
  end

  def get_ocean_forecast(_city_code, _days) do
    {:error, %{message: "City code and days must be integers"}}
  end

  # Private validation functions

  @doc false
  defp validate_icao_code(icao_code) when is_binary(icao_code) do
    normalized = String.upcase(icao_code)

    if Regex.match?(~r/^[A-Z]{4}$/, normalized) do
      {:ok, normalized}
    else
      {:error, %{message: "ICAO code must be exactly 4 uppercase letters"}}
    end
  end

  @doc false
  defp validate_days(days) when is_integer(days) and days >= 1 and days <= 6 do
    {:ok, days}
  end

  defp validate_days(_days) do
    {:error, %{message: "Days parameter must be between 1 and 6"}}
  end
end
