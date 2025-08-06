defmodule Brasilapi.Ddd do
  @moduledoc """
  DDD domain module for BrasilAPI.

  This module provides the main interface for DDD-related functionality.
  """

  alias Brasilapi.Ddd.API

  @doc """
  Fetches information about a DDD (area code).

  Delegates to `Brasilapi.Ddd.API.get_by_ddd/1`.
  """
  defdelegate get_by_ddd(ddd), to: API
end
