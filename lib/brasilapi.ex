defmodule Brasilapi do
  @moduledoc """
  A simple Elixir client for BrasilAPI.

  BrasilAPI is a public API that provides access to various Brazilian data
  such as postal codes, states, cities, banks, and more.

  ## Examples

      # Get all banks
      {:ok, banks} = Brasilapi.get_all_banks()

      # Get a specific bank by code
      {:ok, bank} = Brasilapi.get_bank_by_code(1)

      # Get CEP information
      {:ok, cep_data} = Brasilapi.get_cep("89010025")

      # Get CNPJ information
      {:ok, company} = Brasilapi.get_cnpj("19131243000197")

      # Get DDD information
      {:ok, ddd_info} = Brasilapi.get_ddd(11)

  """

  alias Brasilapi.{Banks, Cep, Cnpj, Ddd}

  @doc """
  Get all banks from BrasilAPI.
  """
  defdelegate get_all_banks(), to: Banks, as: :get_all

  @doc """
  Get a specific bank by its code.
  """
  defdelegate get_bank_by_code(code), to: Banks, as: :get_by_code

  @doc """
  Get CEP (postal code) information using the v2 endpoint.
  """
  defdelegate get_cep(cep), to: Cep, as: :get_by_cep

  @doc """
  Get company information by CNPJ.
  """
  defdelegate get_cnpj(cnpj), to: Cnpj, as: :get_by_cnpj

  @doc """
  Get DDD (area code) information including state and cities.
  """
  defdelegate get_ddd(ddd), to: Ddd, as: :get_by_ddd
end
