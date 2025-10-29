defmodule Brasilapi.Ibge do
  @moduledoc """
  IBGE domain module for BrasilAPI.

  Provides functions to fetch information about Brazilian states and municipalities
  from IBGE (Instituto Brasileiro de Geografia e Estatística).
  """

  alias Brasilapi.Ibge.API

  @doc """
  Retrieves a list of all Brazilian states.

  Delegates to `Brasilapi.Ibge.API.get_states/0`.
  """
  defdelegate get_states(), to: API

  @doc """
  Retrieves information about a specific Brazilian state by its code.

  Delegates to `Brasilapi.Ibge.API.get_state/1`.
  """
  defdelegate get_state(code), to: API

  @doc """
  Retrieves a list of municipalities for a given Brazilian state (UF).

  Delegates to `Brasilapi.Ibge.API.get_municipalities/2`.
  """
  defdelegate get_municipalities(uf, opts \\ []), to: API
end
