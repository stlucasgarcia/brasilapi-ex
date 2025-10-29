defmodule Brasilapi.Exchange.API do
  @moduledoc """
  Client for BrasilAPI Exchange Rate endpoints.

  Provides functions to fetch currency information and exchange rates
  between Real and other currencies from the Central Bank of Brazil.
  """

  alias Brasilapi.Client
  alias Brasilapi.Exchange.{Currency, DailyExchangeRate}

  @doc """
  Fetches all available currencies that can be used for exchange rate queries.

  ## Examples

      iex> Brasilapi.Exchange.API.get_exchange_currencies()
      {:ok, [%Brasilapi.Exchange.Currency{simbolo: "USD", nome: "Dólar dos Estados Unidos", tipo_moeda: "A"}]}

      iex> Brasilapi.Exchange.API.get_exchange_currencies()
      {:error, %{status: 500, message: "Internal server error"}}

  """
  @spec get_exchange_currencies() :: {:ok, [Currency.t()]} | {:error, map()}
  def get_exchange_currencies do
    with {:ok, currencies_data} when is_list(currencies_data) <- Client.get("/cambio/v1/moedas"),
         do: {:ok, Enum.map(currencies_data, &Currency.from_map/1)}
  end

  @doc """
  Fetches the exchange rate between Real and another currency for a specific date.

  For weekends and holidays, the returned date will be the last available business day.
  Data is available from November 28, 1984 onwards.

  ## Parameters

    * `currency` - The target currency symbol (string). Available: AUD, CAD, CHF, DKK, EUR, GBP, JPY, SEK, USD
    * `date` - The desired date. Accepts Date/DateTime/NaiveDateTime structs or strings in YYYY-MM-DD format

  ## Examples

      iex> Brasilapi.Exchange.API.get_exchange_rate("USD", "2025-02-13")
      {:ok, %Brasilapi.Exchange.DailyExchangeRate{moeda: "USD", data: "2025-02-13", cotacoes: [...]}}

      iex> Brasilapi.Exchange.API.get_exchange_rate("USD", ~D[2025-02-13])
      {:ok, %Brasilapi.Exchange.DailyExchangeRate{moeda: "USD", data: "2025-02-13", cotacoes: [...]}}

      iex> Brasilapi.Exchange.API.get_exchange_rate("USD", ~U[2025-02-13 14:30:00Z])
      {:ok, %Brasilapi.Exchange.DailyExchangeRate{moeda: "USD", data: "2025-02-13", cotacoes: [...]}}

      iex> Brasilapi.Exchange.API.get_exchange_rate("INVALID", "2025-02-13")
      {:error, %{status: 404, message: "Not found"}}

  """
  @spec get_exchange_rate(String.t(), String.t() | Date.t() | DateTime.t() | NaiveDateTime.t()) ::
          {:ok, DailyExchangeRate.t()} | {:error, map()}
  def get_exchange_rate(currency, date) when is_binary(currency) do
    with {:ok, formatted_date} <- format_date(date),
         {:ok, %{} = exchange_data} <-
           Client.get("/cambio/v1/cotacao/#{currency}/#{formatted_date}"),
         do: {:ok, DailyExchangeRate.from_map(exchange_data)}
  end

  def get_exchange_rate(_currency, _date) do
    {:error, %{message: "Currency must be a string and date must be a valid date"}}
  end

  @spec format_date(String.t() | Date.t() | DateTime.t() | NaiveDateTime.t()) ::
          {:ok, String.t()} | {:error, map()}
  defp format_date(%Date{} = date) do
    {:ok, Date.to_string(date)}
  end

  defp format_date(%DateTime{} = datetime) do
    {:ok, DateTime.to_date(datetime) |> Date.to_string()}
  end

  defp format_date(%NaiveDateTime{} = naive_datetime) do
    {:ok, NaiveDateTime.to_date(naive_datetime) |> Date.to_string()}
  end

  defp format_date(date_string) when is_binary(date_string) do
    case String.match?(date_string, ~r/^\d{4}-\d{2}-\d{2}$/) do
      true ->
        case Date.from_iso8601(date_string) do
          {:ok, _date} ->
            {:ok, date_string}

          {:error, _} ->
            {:error, %{message: "Invalid date. Must be a valid date in YYYY-MM-DD format"}}
        end

      false ->
        {:error, %{message: "Invalid date format. Must be YYYY-MM-DD"}}
    end
  end

  defp format_date(_) do
    {:error,
     %{
       message:
         "Date must be a Date, DateTime, NaiveDateTime struct or string in YYYY-MM-DD format"
     }}
  end
end
