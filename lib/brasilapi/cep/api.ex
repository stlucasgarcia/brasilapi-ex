defmodule Brasilapi.Cep.API do
  @moduledoc """
  Client for BrasilAPI CEP endpoints.

  Provides functions to fetch information about Brazilian postal codes (CEP)
  using the v2 endpoint with multiple providers for fallback.
  """

  alias Brasilapi.{Client}
  alias Brasilapi.Cep.Address

  @doc """
  Fetches information about a CEP (postal code) using the v2 endpoint.

  The v2 endpoint provides geolocation data and uses multiple providers
  for better reliability. Coordinates are sourced from OpenStreetMap.

  ## Parameters

    * `cep` - The CEP (postal code) as string or integer. Must be 8 digits.

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

      iex> Brasilapi.Cep.API.get_by_cep("00000000")
      {:error, %{status: 404, message: "Not found"}}

  """
  @spec get_by_cep(String.t() | integer()) :: {:ok, Address.t()} | {:error, map()}
  def get_by_cep(cep) when is_binary(cep) or is_integer(cep) do
    with {:ok, normalized_cep} <- validate_and_normalize_cep(cep),
         {:ok, %{} = cep_data} <- Client.get("/cep/v2/#{normalized_cep}"),
         do: {:ok, Address.from_map(cep_data)}
  end

  def get_by_cep(_cep) do
    {:error, %{message: "CEP must be a string or integer"}}
  end

  # Private functions

  @spec validate_and_normalize_cep(String.t() | integer()) ::
          {:ok, String.t()} | {:error, String.t()}
  defp validate_and_normalize_cep(cep) when is_integer(cep) do
    cep
    |> Integer.to_string()
    |> String.pad_leading(8, "0")
    |> validate_and_normalize_cep
  end

  defp validate_and_normalize_cep(cep) when is_binary(cep) do
    digits_only = String.replace(cep, ~r/\D/, "")

    cond do
      digits_only == "" ->
        {:error, %{message: "CEP must contain only digits"}}

      byte_size(digits_only) != 8 ->
        {:error, %{message: "CEP must be exactly 8 digits"}}

      true ->
        {:ok, digits_only}
    end
  end
end
