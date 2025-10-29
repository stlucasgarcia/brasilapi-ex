defmodule Brasilapi.Holidays.API do
  @moduledoc """
  Client for BrasilAPI Holidays endpoints.

  Provides functions to fetch information about Brazilian national holidays
  for a specific year. Calculates movable holidays based on Easter and
  includes fixed holidays.
  """

  alias Brasilapi.{Client}
  alias Brasilapi.Holidays.Holiday

  @doc """
  Fetches national holidays for a specific year.

  Lists national holidays for the given year. Calculates movable holidays
  based on Easter and adds fixed holidays.

  ## Parameters

    * `year` - The year as string or integer. Must be within supported range.

  ## Examples

      iex> Brasilapi.Holidays.API.get_by_year(2021)
      {:ok, [
        %Brasilapi.Holidays.Holiday{
          date: "2021-01-01",
          name: "Confraternização mundial",
          type: "national",
          full_name: nil
        },
        # ... more holidays
      ]}

      iex> Brasilapi.Holidays.API.get_by_year(1900)
      {:error, %{status: 404, message: "Ano fora do intervalo suportado."}}

  ## API Reference
    https://brasilapi.com.br/docs#tag/Feriados-Nacionais/paths/~1feriados~1v1~1%7Bano%7D/get
  """
  @spec get_by_year(String.t() | integer()) :: {:ok, [Holiday.t()]} | {:error, map()}
  def get_by_year(year) when is_binary(year) or is_integer(year) do
    with {:ok, normalized_year} <- validate_and_normalize_year(year),
         {:ok, holidays_data} when is_list(holidays_data) <-
           Client.get("/feriados/v1/#{normalized_year}") do
      {:ok, Enum.map(holidays_data, &Holiday.from_map/1)}
    end
  end

  def get_by_year(_year) do
    {:error, %{message: "Year must be a string or integer"}}
  end

  # Private functions

  @spec validate_and_normalize_year(String.t() | integer()) ::
          {:ok, String.t()} | {:error, map()}
  defp validate_and_normalize_year(year) when is_integer(year) do
    if year > 0 do
      {:ok, Integer.to_string(year)}
    else
      {:error, %{message: "Year must be a valid positive integer"}}
    end
  end

  defp validate_and_normalize_year(year) when is_binary(year) do
    year = String.trim(year)

    case Integer.parse(year) do
      {year_int, ""} when year_int > 0 ->
        {:ok, Integer.to_string(year_int)}

      _ ->
        {:error, %{message: "Year must be a valid positive integer"}}
    end
  end
end
