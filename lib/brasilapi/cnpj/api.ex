defmodule Brasilapi.Cnpj.API do
  @moduledoc """
  Client for BrasilAPI CNPJ endpoints.

  Provides functions to fetch information about Brazilian companies by CNPJ.
  """

  alias Brasilapi.{Client}
  alias Brasilapi.Cnpj.Company

  @doc """
  Fetches information about a company by its CNPJ.

  ## Parameters

    * `cnpj` - The CNPJ number (string or integer)

  ## Examples

      iex> Brasilapi.Cnpj.API.get_by_cnpj("11000000000197")
      {:ok, %Brasilapi.Cnpj.Company{cnpj: "11000000000197", razao_social: "ACME INC"}}

      iex> Brasilapi.Cnpj.API.get_by_cnpj("00000000000000")
      {:error, %{status: 404, message: "Not found"}}

  """
  @spec get_by_cnpj(String.t() | integer()) :: {:ok, Company.t()} | {:error, map()}
  def get_by_cnpj(cnpj) when is_binary(cnpj) or is_integer(cnpj) do
    with {:ok, cnpj_string} <- sanitize_and_validate_cnpj(cnpj),
         {:ok, %{} = company} <- Client.get("/cnpj/v1/#{cnpj_string}") do
      {:ok, Company.from_map(company)}
    end
  end

  def get_by_cnpj(_cnpj) do
    {:error, %{message: "CNPJ must be a string or integer"}}
  end

  # Private functions

  # Sanitizes and validates CNPJ in one step
  defp sanitize_and_validate_cnpj(cnpj) when is_integer(cnpj) do
    cnpj
    |> Integer.to_string()
    |> String.pad_leading(14, "0")
    |> sanitize_and_validate_cnpj()
  end

  defp sanitize_and_validate_cnpj(cnpj) when is_binary(cnpj) do
    # First sanitize by removing formatting
    sanitized = String.replace(cnpj, ~r/[^\d]/, "")

    # Check if length is exactly 14 digits
    case String.length(sanitized) do
      14 -> {:ok, sanitized}
      _ -> {:error, %{message: "Invalid CNPJ format. Must be 14 digits."}}
    end
  end
end
