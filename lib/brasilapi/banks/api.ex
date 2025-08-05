defmodule Brasilapi.Banks.API do
  @moduledoc """
  Client for BrasilAPI Banks endpoints.

  Provides functions to fetch information about Brazilian banks.
  """

  alias Brasilapi.{Client}
  alias Brasilapi.Banks.Bank

  @doc """
  Fetches information about all Brazilian banks. We filter out any banks that do not have the code or ispb fields.

  ## Examples

      iex> Brasilapi.Banks.API.get_all()
      {:ok, [%Brasilapi.Banks.Bank{ispb: "00000000", name: "BCO DO BRASIL S.A.", code: 1, full_name: "Banco do Brasil S.A."}]}

      iex> Brasilapi.Banks.API.get_all()
      {:error, %{reason: :timeout}}

  """
  @spec get_all() :: {:ok, [Bank.t()]} | {:error, map()}
  def get_all do
    with {:ok, banks} when is_list(banks) <- Client.get("/banks/v1") do
      valid_banks =
        banks
        |> Enum.filter(&valid_bank_data?/1)
        |> Enum.map(&Bank.from_map/1)

      {:ok, valid_banks}
    end
  end

  @doc """
  Fetches information about a specific bank by its code.

  ## Parameters

    * `code` - The bank code (integer)

  ## Examples

      iex> Brasilapi.Banks.API.get_by_code(1)
      {:ok, %Brasilapi.Banks.Bank{ispb: "00000000", name: "BCO DO BRASIL S.A.", code: 1, full_name: "Banco do Brasil S.A."}}

      iex> Brasilapi.Banks.API.get_by_code(999999)
      {:error, %{status: 404, message: "Not found"}}

  """
  @spec get_by_code(integer() | String.t()) :: {:ok, Bank.t()} | {:error, map()}
  def get_by_code(code) when is_binary(code) or is_integer(code) do
    with {:ok, %{} = bank} <- Client.get("/banks/v1/#{code}") do
      {:ok, Bank.from_map(bank)}
    end
  end

  def get_by_code(_code) do
    {:error, %{message: "Code must be an integer or string"}}
  end

  # Private functions

  # Validates that bank data has the minimum required fields
  defp valid_bank_data?(%{"code" => code, "ispb" => ispb})
       when not is_nil(code) and is_binary(ispb) and ispb != "" do
    true
  end

  defp valid_bank_data?(_), do: false
end
