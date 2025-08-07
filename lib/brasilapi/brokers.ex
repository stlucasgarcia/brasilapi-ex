defmodule Brasilapi.Brokers do
  @moduledoc """
  Brokers (Brokerage Firms) module for BrasilAPI.

  This module provides the main interface for CVM (Securities and Exchange Commission of Brazil)
  registered brokerage firms, allowing users to get information about active brokers.
  """

  alias Brasilapi.Brokers.API

  @doc """
  Gets all active brokerage firms registered with CVM.

  Delegates to `Brasilapi.Brokers.API.get_brokers/0`.
  """
  defdelegate get_brokers(), to: API
end
