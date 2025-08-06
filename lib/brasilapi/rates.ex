defmodule Brasilapi.Rates do
  @moduledoc """
  Rates domain module for BrasilAPI.

  This module provides the main interface for tax rates and official indices
  functionality from the Brazilian financial system.
  """

  alias Brasilapi.Rates.API

  @doc """
  Fetches information about all available tax rates and indices.

  Delegates to `Brasilapi.Rates.API.get_all/0`.
  """
  defdelegate get_all(), to: API

  @doc """
  Fetches information about a specific tax rate or index by its name/acronym.

  Delegates to `Brasilapi.Rates.API.get_by_acronym/1`.
  """
  defdelegate get_by_acronym(acronym), to: API
end
