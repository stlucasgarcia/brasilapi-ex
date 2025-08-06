defmodule Brasilapi.RegistroBr do
  @moduledoc """
  RegistroBR domain module for BrasilAPI.

  This module provides the main interface for Brazilian domain registration
  functionality from registro.br, allowing users to check the status and
  information of .br domains.
  """

  alias Brasilapi.RegistroBr.API

  @doc """
  Fetches information about a Brazilian domain (.br).

  Delegates to `Brasilapi.RegistroBr.API.get_domain_info/1`.
  """
  defdelegate get_domain_info(domain), to: API
end
