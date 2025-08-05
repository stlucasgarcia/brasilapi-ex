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

  """

  alias Brasilapi.Banks

  @doc """
  Get all banks from BrasilAPI.
  """
  defdelegate get_all_banks(), to: Banks, as: :get_all

  @doc """
  Get a specific bank by its code.
  """
  defdelegate get_bank_by_code(code), to: Banks, as: :get_by_code
end
