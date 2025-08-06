defmodule Brasilapi.Banks do
  @moduledoc """
  Banks domain module for BrasilAPI.

  This module provides the main interface for banks-related functionality.
  """

  alias Brasilapi.Banks.API

  @doc """
  Fetches information about all Brazilian banks.

  Delegates to `Brasilapi.Banks.API.get_all/0`.
  """
  defdelegate get_all(), to: API

  @doc """
  Fetches information about a specific bank by its code.

  Delegates to `Brasilapi.Banks.API.get_by_code/1`.
  """
  defdelegate get_by_code(code), to: API
end
