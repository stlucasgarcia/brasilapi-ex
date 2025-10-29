defmodule Brasilapi.Holidays do
  @moduledoc """
  Holidays domain module for BrasilAPI.

  This module provides the main interface for national holidays functionality.
  """

  alias Brasilapi.Holidays.API

  @doc """
  Fetches information about national holidays for a specific year.

  Delegates to `Brasilapi.Holidays.API.get_by_year/1`.
  """
  defdelegate get_by_year(year), to: API
end
