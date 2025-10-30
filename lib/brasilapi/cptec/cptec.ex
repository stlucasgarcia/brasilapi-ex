defmodule Brasilapi.Cptec do
  @moduledoc """
  CPTEC domain module for BrasilAPI.

  Provides functions for accessing weather forecasts, current conditions,
  and ocean forecasts from CPTEC (Centro de Previsão de Tempo e Estudos Climáticos).

  ## Available Functions

    - `list_cities/0` - List all cities available in CPTEC services
    - `search_cities/1` - Search for cities by name to get CPTEC city codes
    - `get_capitals_weather/0` - Get current weather conditions for all state capitals
    - `get_airport_weather/1` - Get current weather conditions at a specific airport
    - `get_city_forecast/1` - Get weather forecast for a city (1 day)
    - `get_city_forecast/2` - Get weather forecast for a city (1-6 days)
    - `get_ocean_forecast/1` - Get ocean/wave forecast for a coastal city (1 day)
    - `get_ocean_forecast/2` - Get ocean/wave forecast for a coastal city (1-6 days)

  """

  alias Brasilapi.Cptec.API

  @doc """
  Lists all cities available in CPTEC services.

  Delegates to `Brasilapi.Cptec.API.list_cities/0`.
  """
  defdelegate list_cities(), to: API

  @doc """
  Searches for cities by name.

  Delegates to `Brasilapi.Cptec.API.search_cities/1`.
  """
  defdelegate search_cities(city_name), to: API

  @doc """
  Fetches current weather conditions for all Brazilian state capitals.

  Delegates to `Brasilapi.Cptec.API.get_capitals_weather/0`.
  """
  defdelegate get_capitals_weather(), to: API

  @doc """
  Fetches current weather conditions at a specific airport.

  Delegates to `Brasilapi.Cptec.API.get_airport_weather/1`.
  """
  defdelegate get_airport_weather(icao_code), to: API

  @doc """
  Fetches weather forecast for a city.

  Delegates to `Brasilapi.Cptec.API.get_city_forecast/1` or `Brasilapi.Cptec.API.get_city_forecast/2`.
  """
  defdelegate get_city_forecast(city_code), to: API
  defdelegate get_city_forecast(city_code, days), to: API

  @doc """
  Fetches ocean forecast for a coastal city.

  Delegates to `Brasilapi.Cptec.API.get_ocean_forecast/1` or `Brasilapi.Cptec.API.get_ocean_forecast/2`.
  """
  defdelegate get_ocean_forecast(city_code), to: API
  defdelegate get_ocean_forecast(city_code, days), to: API
end
