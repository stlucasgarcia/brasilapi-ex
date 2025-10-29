defmodule Brasilapi.Rates.API do
  @moduledoc """
  Client for BrasilAPI Rates endpoints.

  Provides functions to fetch information about Brazilian tax rates and official indices.
  """

  alias Brasilapi.Client
  alias Brasilapi.Rates.Rate

  @doc """
  Fetches information about all available tax rates and indices.

  ## Examples

      iex> Brasilapi.Rates.API.get_rates()
      {:ok, [%Brasilapi.Rates.Rate{nome: "CDI", valor: 14.9}]}

      iex> Brasilapi.Rates.API.get_rates()
      {:error, %{reason: :timeout}}

  ## API Reference
    https://brasilapi.com.br/docs#tag/TAXAS/paths/~1taxas~1v1/get
  """
  @spec get_rates() :: {:ok, [Rate.t()]} | {:error, map()}
  def get_rates do
    with {:ok, taxas} when is_list(taxas) <- Client.get("/taxas/v1") do
      parsed_taxas = Enum.map(taxas, &Rate.from_map/1)
      {:ok, parsed_taxas}
    end
  end

  @doc """
  Fetches information about a specific tax rate or index by its name/acronym.

  ## Parameters

    * `acronym` - The tax rate or index name/acronym (string)

  ## Examples

      iex> Brasilapi.Rates.API.get_rates_by_acronym("CDI")
      {:ok, %Brasilapi.Taxas.Rate{nome: "CDI", valor: 14.9}}

      iex> Brasilapi.Rates.API.get_rates_by_acronym("INVALID")
      {:error, %{status: 404, message: "Not found"}}

  ## API Reference
    https://brasilapi.com.br/docs#tag/TAXAS/paths/~1taxas~1v1~1%7Bsigla%7D/get
  """
  @spec get_rates_by_acronym(String.t()) :: {:ok, Rate.t()} | {:error, map()}
  def get_rates_by_acronym(acronym) when is_binary(acronym) do
    with {:ok, %{} = taxa} <- Client.get("/taxas/v1/#{acronym}"),
         do: {:ok, Rate.from_map(taxa)}
  end

  def get_rates_by_acronym(_acronym) do
    {:error, %{message: "Acronym must be a string"}}
  end
end
