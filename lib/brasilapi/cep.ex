defmodule Brasilapi.Cep do
  @moduledoc """
  Cep domain module for BrasilAPI.

  This module provides the main interface for CEP-related functionality.
  """

  alias Brasilapi.Cep.API

  @doc """
  Fetches information about a CEP.

  By default uses the v2 endpoint. You can specify `:v1` or `:v2` using the version option.

  Delegates to `Brasilapi.Cep.API.get_by_cep/2`.
  """
  def get_by_cep(cep, opts \\ []), do: API.get_by_cep(cep, opts)
end
