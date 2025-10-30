defmodule Brasilapi.Ncm do
  @moduledoc """
  NCM domain module for BrasilAPI.

  This module provides the main interface for NCM (Nomenclatura Comum do Mercosul)
  functionality - the product classification system used for taxation and foreign
  trade control.
  """

  alias Brasilapi.Ncm.API

  @doc """
  Fetches all NCM codes.

  Delegates to `Brasilapi.Ncm.API.get_ncms/0`.
  """
  defdelegate get_ncms(), to: API

  @doc """
  Searches for NCM codes using a code or description keyword.

  Delegates to `Brasilapi.Ncm.API.search_ncms/1`.
  """
  defdelegate search_ncms(query), to: API

  @doc """
  Fetches detailed information for a specific NCM code.

  Delegates to `Brasilapi.Ncm.API.get_ncm_by_code/1`.
  """
  defdelegate get_ncm_by_code(code), to: API
end
