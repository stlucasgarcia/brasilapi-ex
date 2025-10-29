defmodule Brasilapi.Ncm.API do
  @moduledoc """
  Client for BrasilAPI NCM endpoints.

  Provides functions to fetch information about NCM (Nomenclatura Comum do Mercosul) codes,
  which is the product classification system used for taxation and foreign trade control.
  """

  alias Brasilapi.{Client}
  alias Brasilapi.Ncm.Ncm

  @doc """
  Fetches all NCM codes.

  Returns a complete list of all registered NCM codes including their descriptions
  and validity information.

  ## Examples

      iex> Brasilapi.Ncm.API.get_ncms()
      {:ok, [
        %Brasilapi.Ncm.Ncm{
          codigo: "3305.10.00",
          descricao: "- Xampus",
          data_inicio: "2022-04-01",
          data_fim: "9999-12-31",
          tipo_ato: "Res Camex",
          numero_ato: "000272",
          ano_ato: "2021"
        },
        # ... more NCMs
      ]}

  ## API Reference
    https://brasilapi.com.br/docs#tag/NCM/paths/~1ncm~1v1/get
  """
  @spec get_ncms() :: {:ok, [Ncm.t()]} | {:error, map()}
  def get_ncms do
    with {:ok, ncms} when is_list(ncms) <- Client.get("/ncm/v1") do
      {:ok, Enum.map(ncms, &Ncm.from_map/1)}
    end
  end

  @doc """
  Searches for NCM codes using a code or description keyword.

  Allows searching for NCM codes using partial code matches or keywords in the description.
  Useful for finding NCMs related to a specific product.

  ## Parameters

    * `query` - Search term (partial code or keyword in description)

  ## Examples

      iex> Brasilapi.Ncm.API.search_ncms("xampu")
      {:ok, [
        %Brasilapi.Ncm.Ncm{
          codigo: "3305.10.00",
          descricao: "- Xampus",
          data_inicio: "2022-04-01",
          data_fim: "9999-12-31",
          tipo_ato: "Res Camex",
          numero_ato: "000272",
          ano_ato: "2021"
        }
      ]}

      iex> Brasilapi.Ncm.API.search_ncms("3305")
      {:ok, [%Brasilapi.Ncm.Ncm{codigo: "3305.10.00", ...}]}

  ## API Reference
    https://brasilapi.com.br/docs#tag/NCM/paths/~1ncm~1v1?search=%7Bcode%7D/get
  """
  @spec search_ncms(String.t()) :: {:ok, [Ncm.t()]} | {:error, map()}
  def search_ncms(query) when is_binary(query) do
    query_string = URI.encode_query(%{search: query})

    with {:ok, ncms} when is_list(ncms) <- Client.get("/ncm/v1?#{query_string}") do
      {:ok, Enum.map(ncms, &Ncm.from_map/1)}
    end
  end

  def search_ncms(_query) do
    {:error, %{message: "Search query must be a string"}}
  end

  @doc """
  Fetches detailed information for a specific NCM code.

  Returns detailed information for a specific NCM code, including description,
  validity dates, and information about the legal act that created it.

  ## Parameters

    * `code` - NCM code to search for. Can be formatted (e.g., "3305.10.00") or not (e.g., "33051000")

  ## Examples

      iex> Brasilapi.Ncm.API.get_ncm_by_code("33051000")
      {:ok, %Brasilapi.Ncm.Ncm{
        codigo: "3305.10.00",
        descricao: "- Xampus",
        data_inicio: "2022-04-01",
        data_fim: "9999-12-31",
        tipo_ato: "Res Camex",
        numero_ato: "000272",
        ano_ato: "2021"
      }}

      iex> Brasilapi.Ncm.API.get_ncm_by_code("3305.10.00")
      {:ok, %Brasilapi.Ncm.Ncm{codigo: "3305.10.00", ...}}

      iex> Brasilapi.Ncm.API.get_ncm_by_code("99999999")
      {:error, %{status: 404, message: "Not found"}}

  ## API Reference
    https://brasilapi.com.br/docs#tag/NCM/paths/~1ncm~1v1~1%7Bcode%7D/get
  """
  @spec get_ncm_by_code(String.t() | integer()) :: {:ok, Ncm.t()} | {:error, map()}
  def get_ncm_by_code(code) when is_binary(code) or is_integer(code) do
    normalized_code = normalize_code(code)

    with {:ok, ncm} when is_map(ncm) <- Client.get("/ncm/v1/#{normalized_code}") do
      {:ok, Ncm.from_map(ncm)}
    end
  end

  def get_ncm_by_code(_code) do
    {:error, %{message: "Code must be a string or integer"}}
  end

  # Private functions

  @spec normalize_code(String.t() | integer()) :: String.t()
  defp normalize_code(code) when is_integer(code) do
    Integer.to_string(code)
  end

  defp normalize_code(code) when is_binary(code) do
    code
  end
end
