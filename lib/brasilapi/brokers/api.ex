defmodule Brasilapi.Brokers.API do
  @moduledoc """
  Client for BrasilAPI Brokers (Brokerage Firms) endpoints.

  Provides functions to fetch information about CVM-registered brokerage firms.
  """

  alias Brasilapi.Client
  alias Brasilapi.Brokers.Broker
  alias Brasilapi.Utils.Cnpj

  @doc """
  Fetches all active brokerage firms registered with CVM.

  Returns a list of all active brokers with complete registration information
  including CNPJ, names, addresses, contact information, and financial data.

  ## Examples

      iex> Brasilapi.Brokers.API.get_brokers()
      {:ok, [%Brasilapi.Brokers.Broker{cnpj: "00000000000191", nome_social: "CORRETORA EXEMPLO S.A.", ...}]}

      iex> Brasilapi.Brokers.API.get_brokers()
      {:error, %{status: 500, message: "Internal server error"}}

  ## API Reference
    https://brasilapi.com.br/docs#tag/Corretoras/paths/~1cvm~1corretoras~1v1/get
  """
  @spec get_brokers() :: {:ok, [Broker.t()]} | {:error, map()}
  def get_brokers do
    with {:ok, brokers_data} when is_list(brokers_data) <- Client.get("/cvm/corretoras/v1"),
         do: {:ok, Enum.map(brokers_data, &Broker.from_map/1)}
  end

  @doc """
  Fetches a specific brokerage firm by its CNPJ from CVM records.

  Returns detailed information about a specific broker registered with CVM
  including all registration data, financial information, and contact details.

  ## Parameters

    * `cnpj` - The CNPJ number (string or integer, with or without formatting)

  ## Examples

      iex> Brasilapi.Brokers.API.get_broker_by_cnpj("02332886000104")
      {:ok, %Brasilapi.Brokers.Broker{cnpj: "02332886000104", nome_social: "XP INVESTIMENTOS CCTVM S.A.", ...}}

      iex> Brasilapi.Brokers.API.get_broker_by_cnpj("02.332.886/0001-04")
      {:ok, %Brasilapi.Brokers.Broker{cnpj: "02332886000104", nome_social: "XP INVESTIMENTOS CCTVM S.A.", ...}}

      iex> Brasilapi.Brokers.API.get_broker_by_cnpj(2332886000104)
      {:ok, %Brasilapi.Brokers.Broker{cnpj: "02332886000104", nome_social: "XP INVESTIMENTOS CCTVM S.A.", ...}}

      iex> Brasilapi.Brokers.API.get_broker_by_cnpj("00000000000000")
      {:error, %{status: 404, message: "Não foi encontrado este CNPJ na listagem da CVM."}}

  ## API Reference
    https://brasilapi.com.br/docs#tag/Corretoras/paths/~1cvm~1corretoras~1v1~1%7Bcnpj%7D/get
  """
  @spec get_broker_by_cnpj(String.t() | integer()) :: {:ok, Broker.t()} | {:error, map()}
  def get_broker_by_cnpj(cnpj) do
    with {:ok, cnpj_string} <- Cnpj.sanitize_and_validate(cnpj),
         {:ok, %{} = broker_data} <- Client.get("/cvm/corretoras/v1/#{cnpj_string}") do
      {:ok, Broker.from_map(broker_data)}
    end
  end
end
