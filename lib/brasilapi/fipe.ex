defmodule Brasilapi.Fipe do
  @moduledoc """
  FIPE domain module for BrasilAPI.

  Provides functions to fetch vehicle prices and information from the FIPE table
  (Fundação Instituto de Pesquisas Econômicas).
  """

  alias Brasilapi.Fipe.API

  @doc """
  Retrieves vehicle brands for a given vehicle type.

  Delegates to `Brasilapi.Fipe.API.get_brands/2`.
  """
  defdelegate get_brands(vehicle_type \\ nil, opts \\ []), to: API

  @doc """
  Retrieves the price of a vehicle based on its FIPE code.

  Delegates to `Brasilapi.Fipe.API.get_price/2`.
  """
  defdelegate get_price(fipe_code, opts \\ []), to: API

  @doc """
  Retrieves reference tables for vehicle pricing.

  Delegates to `Brasilapi.Fipe.API.get_reference_tables/0`.
  """
  defdelegate get_reference_tables(), to: API

  @doc """
  Retrieves vehicles for a given vehicle type and brand code.

  Delegates to `Brasilapi.Fipe.API.get_vehicles/3`.
  """
  defdelegate get_vehicles(vehicle_type, brand_code, opts \\ []), to: API
end
