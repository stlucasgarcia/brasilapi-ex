defmodule Brasilapi.Cnpj do
  @moduledoc """
  CNPJ domain module for BrasilAPI.

  This module provides the main interface for CNPJ-related functionality.
  """

  alias Brasilapi.Cnpj.API

  @doc """
  Fetches information about a company by its CNPJ.

  Delegates to `Brasilapi.Cnpj.API.get_by_cnpj/1`.
  """
  defdelegate get_by_cnpj(cnpj), to: API
end
