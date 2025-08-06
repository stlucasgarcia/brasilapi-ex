defmodule Brasilapi.Cep do
  @moduledoc """
  Cep domain module for BrasilAPI.

  This module provides the main interface for CEP-related functionality.
  """

  alias Brasilapi.Cep.API

  @doc """
  Fetches information about a CEP using the v2 endpoint with multiple providers.

  Delegates to `Brasilapi.Cep.API.get_by_cep/1`.
  """
  defdelegate get_by_cep(cep), to: API
end
