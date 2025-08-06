defmodule Brasilapi.Ddd.API do
  @moduledoc """
  Client for BrasilAPI DDD endpoints.

  Provides functions to fetch information about Brazilian area codes (DDD)
  including the state and cities that use the specified area code.
  """

  alias Brasilapi.{Client}
  alias Brasilapi.Ddd.Info

  @doc """
  Fetches information about a DDD (area code).

  DDD means "Discagem Direta à Distância" (Direct Distance Dialing). It's an
  automatic telephone connection system between different national urban areas.
  The DDD is a 2-digit code that identifies the main cities in the country.

  ## Parameters

    * `ddd` - The DDD (area code) as string or integer. Must be 2 digits.

  ## Examples

      iex> Brasilapi.Ddd.API.get_by_ddd(11)
      {:ok, %Brasilapi.Ddd.Info{
        state: "SP",
        cities: ["EMBU", "VÁRZEA PAULISTA", "SÃO PAULO"]
      }}

      iex> Brasilapi.Ddd.API.get_by_ddd(99)
      {:error, %{status: 404, message: "DDD não encontrado"}}

  """
  @spec get_by_ddd(String.t() | integer()) :: {:ok, Info.t()} | {:error, map()}
  def get_by_ddd(ddd) when is_binary(ddd) or is_integer(ddd) do
    with {:ok, normalized_ddd} <- validate_and_normalize_ddd(ddd),
         {:ok, %{} = ddd_data} <- Client.get("/ddd/v1/#{normalized_ddd}"),
         do: {:ok, Info.from_map(ddd_data)}
  end

  def get_by_ddd(_ddd) do
    {:error, %{message: "DDD must be a string or integer"}}
  end

  # Private functions

  @spec validate_and_normalize_ddd(String.t() | integer()) ::
          {:ok, String.t()} | {:error, map()}
  defp validate_and_normalize_ddd(ddd) when is_integer(ddd) do
    ddd
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
    |> validate_and_normalize_ddd
  end

  defp validate_and_normalize_ddd(ddd) when is_binary(ddd) do
    digits_only = String.replace(ddd, ~r/\D/, "")

    cond do
      digits_only == "" ->
        {:error, %{message: "DDD must contain only digits"}}

      byte_size(digits_only) != 2 ->
        {:error, %{message: "DDD must be exactly 2 digits"}}

      true ->
        {:ok, digits_only}
    end
  end
end
