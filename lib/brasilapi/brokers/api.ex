defmodule Brasilapi.Brokers.API do
  @moduledoc """
  Client for BrasilAPI Brokers (Brokerage Firms) endpoints.

  Provides functions to fetch information about CVM-registered brokerage firms.
  """

  alias Brasilapi.Client
  alias Brasilapi.Brokers.Broker

  @doc """
  Fetches all active brokerage firms registered with CVM.

  Returns a list of all active brokers with complete registration information
  including CNPJ, names, addresses, contact information, and financial data.

  ## Examples

      iex> Brasilapi.Brokers.API.get_brokers()
      {:ok, [%Brasilapi.Brokers.Broker{cnpj: "00000000000191", nome_social: "CORRETORA EXEMPLO S.A.", ...}]}

      iex> Brasilapi.Brokers.API.get_brokers()
      {:error, %{status: 500, message: "Internal server error"}}

  """
  @spec get_brokers() :: {:ok, [Broker.t()]} | {:error, map()}
  def get_brokers do
    with {:ok, brokers_data} when is_list(brokers_data) <- Client.get("/cvm/corretoras/v1"),
         do: {:ok, Enum.map(brokers_data, &Broker.from_map/1)}
  end
end
