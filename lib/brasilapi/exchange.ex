defmodule Brasilapi.Exchange do
  @moduledoc """
  Exchange Rate module for BrasilAPI.

  This module provides the main interface for currency exchange rate
  functionality, allowing users to get available currencies and
  exchange rates between Real and other currencies.
  """

  alias Brasilapi.Exchange.API

  @doc """
  Gets all available currencies for exchange rate queries.

  Delegates to `Brasilapi.Exchange.API.get_currencies/0`.
  """
  defdelegate get_currencies(), to: API

  @doc """
  Gets the exchange rate between Real and another currency for a specific date.

  Delegates to `Brasilapi.Exchange.API.get_exchange_rate/2`.
  """
  defdelegate get_exchange_rate(currency, date), to: API
end