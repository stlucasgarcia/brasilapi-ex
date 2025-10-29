defmodule Brasilapi.Cnpj.API do
  @moduledoc """
  Client for BrasilAPI CNPJ endpoints.

  Provides functions to fetch information about Brazilian companies by CNPJ.
  """

  alias Brasilapi.{Client}
  alias Brasilapi.Cnpj.Company
  alias Brasilapi.Utils.Cnpj

  @doc """
  Fetches information about a company by its CNPJ.

  ## Parameters

    * `cnpj` - The CNPJ number (string or integer)

  ## Examples

      iex> Brasilapi.Cnpj.API.get_by_cnpj("11000000000197")
      {:ok, %Brasilapi.Cnpj.Company{cnpj: "11000000000197", razao_social: "ACME INC"}}

      iex> Brasilapi.Cnpj.API.get_by_cnpj("00000000000000")
      {:error, %{status: 404, message: "Not found"}}

  ## API Reference
    https://brasilapi.com.br/docs#tag/CNPJ/paths/~1cnpj~1v1~1%7Bcnpj%7D/get
  """
  @spec get_by_cnpj(String.t() | integer()) :: {:ok, Company.t()} | {:error, map()}
  def get_by_cnpj(cnpj) do
    with {:ok, cnpj_string} <- Cnpj.sanitize_and_validate(cnpj),
         {:ok, %{} = company} <- Client.get("/cnpj/v1/#{cnpj_string}") do
      {:ok, Company.from_map(company)}
    end
  end
end
