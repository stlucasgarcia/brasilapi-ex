defmodule Brasilapi do
  @moduledoc """
  A simple Elixir client for BrasilAPI.

  BrasilAPI is a public API that provides access to various Brazilian data
  such as postal codes, states, cities, banks, and more.

  ## Examples

      # Get all banks
      {:ok, banks} = Brasilapi.get_banks()

      # Get a specific bank by code
      {:ok, bank} = Brasilapi.get_bank_by_code(1)

      # Get CEP information
      {:ok, cep_data} = Brasilapi.get_cep("89010025")

      # Get CNPJ information
      {:ok, company} = Brasilapi.get_cnpj("19131243000197")

      # Get DDD information
      {:ok, ddd_info} = Brasilapi.get_ddd(11)

      # Get national holidays
      {:ok, holidays} = Brasilapi.get_holidays(2021)

      # Get all tax rates
      {:ok, rates} = Brasilapi.get_rates()

      # Get a specific tax rate
      {:ok, rate} = Brasilapi.get_rate_by_acronym("CDI")

      # Get PIX participants
      {:ok, participants} = Brasilapi.get_pix_participants()

      # Get domain information
      {:ok, domain} = Brasilapi.get_domain_info("brasilapi.com.br")

      # Get all currencies
      {:ok, currencies} = Brasilapi.get_exchange_currencies()

      # Get exchange rate
      {:ok, exchange_rate} = Brasilapi.get_exchange_rate("USD", "2025-02-13")

      # Get all brokerage firms
      {:ok, brokers} = Brasilapi.get_brokers()

      # Get specific brokerage firm by CNPJ
      {:ok, broker} = Brasilapi.get_broker_by_cnpj("02332886000104")

      # Get book information by ISBN
      {:ok, book} = Brasilapi.get_book("9788545702870")

  """

  alias Brasilapi.{
    Banks,
    Brokers,
    Cep,
    Cnpj,
    Ddd,
    Exchange,
    Holidays,
    Isbn,
    Pix,
    Rates,
    RegistroBr
  }

  @doc """
  Get all banks from BrasilAPI.

  ## API Reference
    https://brasilapi.com.br/docs#tag/BANKS/paths/~1banks~1v1/get
  """
  defdelegate get_banks(), to: Banks

  @doc """
  Get a specific bank by its code.

  ## API Reference
    https://brasilapi.com.br/docs#tag/BANKS/paths/~1banks~1v1~1%7Bcode%7D/get
  """
  defdelegate get_bank_by_code(code), to: Banks

  @doc """
  Get CEP (postal code) information using the v2 endpoint.

  ## API Reference
    https://brasilapi.com.br/docs#tag/CEP-V2/paths/~1cep~1v2~1%7Bcep%7D/get
  """
  defdelegate get_cep(cep), to: Cep, as: :get_by_cep

  @doc """
  Get company information by CNPJ.

  ## API Reference
    https://brasilapi.com.br/docs#tag/CNPJ/paths/~1cnpj~1v1~1%7Bcnpj%7D/get
  """
  defdelegate get_cnpj(cnpj), to: Cnpj, as: :get_by_cnpj

  @doc """
  Get DDD (area code) information including state and cities.

  ## API Reference
    https://brasilapi.com.br/docs#tag/DDD/paths/~1ddd~1v1~1%7Bddd%7D/get
  """
  defdelegate get_ddd(ddd), to: Ddd, as: :get_by_ddd

  @doc """
  Get national holidays for a specific year.

  ## API Reference
    https://brasilapi.com.br/docs#tag/Feriados-Nacionais/paths/~1feriados~1v1~1%7Bano%7D/get
  """
  defdelegate get_holidays(year), to: Holidays, as: :get_by_year

  @doc """
  Get all available tax rates and indices.

  ## API Reference
    https://brasilapi.com.br/docs#tag/TAXAS/paths/~1taxas~1v1/get
  """
  defdelegate get_rates(), to: Rates, as: :get_all

  @doc """
  Get a specific tax rate or index by its name/acronym.

  ## API Reference
    https://brasilapi.com.br/docs#tag/TAXAS/paths/~1taxas~1v1~1%7Bsigla%7D/get
  """
  defdelegate get_rate_by_acronym(acronym), to: Rates, as: :get_by_acronym

  @doc """
  Get all PIX participants.

  ## API Reference
    https://brasilapi.com.br/docs#tag/PIX/paths/~1pix~1v1~1participants/get
  """
  defdelegate get_pix_participants(), to: Pix, as: :get_participants

  @doc """
  Get Brazilian domain (.br) registration information.

  ## API Reference
    https://brasilapi.com.br/docs#tag/REGISTRO-BR/paths/~1registrobr~1v1~1%7Bdomain%7D/get
  """
  defdelegate get_domain_info(domain), to: RegistroBr, as: :get_domain_info

  @doc """
  Get all available currencies for exchange rate queries.

  ## API Reference
    https://brasilapi.com.br/docs#tag/CAMBIO/paths/~1cambio~1v1~1moedas/get
  """
  defdelegate get_exchange_currencies(), to: Exchange

  @doc """
  Get the exchange rate between Real and another currency for a specific date.

  ## API Reference
    https://brasilapi.com.br/docs#tag/CAMBIO/paths/~1cambio~1v1~1cotacao~1%7Bmoeda%7D~1%7Bdata%7D/get
  """
  defdelegate get_exchange_rate(currency, date), to: Exchange

  @doc """
  Get all active brokerage firms registered with CVM.

  ## API Reference
    https://brasilapi.com.br/docs#tag/Corretoras/paths/~1cvm~1corretoras~1v1/get
  """
  defdelegate get_brokers(), to: Brokers

  @doc """
  Get a specific brokerage firm by its CNPJ from CVM records.

  ## API Reference
    https://brasilapi.com.br/docs#tag/Corretoras/paths/~1cvm~1corretoras~1v1~1%7Bcnpj%7D/get
  """
  defdelegate get_broker_by_cnpj(cnpj), to: Brokers

  @doc """
  Get book information by ISBN from multiple providers.

  ## API Reference
  https://brasilapi.com.br/docs#tag/ISBN/paths/~1isbn~1v1~1%7Bisbn%7D/get
  """
  defdelegate get_book(isbn, opts \\ []), to: Isbn
end
