defmodule Brasilapi.Cep.API do
  @moduledoc """
  Client for BrasilAPI CEP endpoints.

  Provides functions to fetch information about Brazilian postal codes (CEP)
  using v1 or v2 endpoints with multiple providers for fallback.
  """

  alias Brasilapi.Cep.Address
  alias Brasilapi.Client
  alias Brasilapi.Utils.Digits

  @doc """
  Fetches information about a CEP (postal code).

  By default, uses the v2 endpoint which provides geolocation data and uses
  multiple providers for better reliability. You can explicitly request v1
  using the `version` option.

  ## Parameters

    * `cep` - The CEP (postal code) as string or integer. Must be 8 digits.
    * `opts` - Optional keyword list with:
      * `:version` - API version to use (`:v1` or `:v2`). Defaults to `:v2`.

  ## Examples

      iex> Brasilapi.Cep.API.get_by_cep("89010025")
      {:ok, %Brasilapi.Cep.Address{
        cep: "89010025",
        state: "SC",
        city: "Blumenau",
        neighborhood: "Centro",
        street: "Rua Doutor Luiz de Freitas Melro",
        service: "viacep",
        location: %{type: "Point", coordinates: %{}}
      }}

      iex> Brasilapi.Cep.API.get_by_cep("89010025", version: :v1)
      {:ok, %Brasilapi.Cep.Address{
        cep: "89010025",
        state: "SC",
        city: "Blumenau",
        neighborhood: "Centro",
        street: "Rua Doutor Luiz de Freitas Melro",
        service: "open-cep",
        location: nil
      }}

      iex> Brasilapi.Cep.API.get_by_cep("00000000")
      {:error, %{status: 404, message: "Not found"}}

  ## API Reference
    * V2: https://brasilapi.com.br/docs#tag/CEP-V2/paths/~1cep~1v2~1%7Bcep%7D/get
    * V1: https://brasilapi.com.br/docs#tag/CEP/paths/~1cep~1v1~1%7Bcep%7D/get
  """
  @spec get_by_cep(String.t() | integer(), keyword()) :: {:ok, Address.t()} | {:error, map()}
  def get_by_cep(cep, opts \\ [])

  def get_by_cep(cep, opts) when is_binary(cep) or is_integer(cep) do
    version = Keyword.get(opts, :version, :v2)
    endpoint = get_endpoint(version)

    with {:ok, normalized_cep} <- validate_and_normalize_cep(cep),
         do: Client.get_one("#{endpoint}/#{normalized_cep}", &Address.from_map/1)
  end

  def get_by_cep(_cep, _opts) do
    {:error, %{message: "CEP must be a string or integer"}}
  end

  # Private functions

  @spec get_endpoint(atom()) :: String.t()
  defp get_endpoint(:v1), do: "/cep/v1"
  defp get_endpoint(_), do: "/cep/v2"

  @spec validate_and_normalize_cep(String.t() | integer()) ::
          {:ok, String.t()} | {:error, map()}
  defp validate_and_normalize_cep(cep) do
    case Digits.normalize_exact(cep, 8) do
      {:error, :empty} ->
        {:error, %{message: "CEP must contain only digits"}}

      {:error, :invalid_length} ->
        {:error, %{message: "CEP must be exactly 8 digits"}}

      {:ok, digits} ->
        {:ok, digits}
    end
  end
end
