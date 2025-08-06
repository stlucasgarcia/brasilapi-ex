defmodule Brasilapi.RegistroBr.API do
  @moduledoc """
  Client for BrasilAPI RegistroBR endpoints.

  Provides functions to fetch information about Brazilian domain registrations (.br)
  from the official registro.br system.
  """

  alias Brasilapi.Client
  alias Brasilapi.RegistroBr.Domain

  @doc """
  Fetches information about a Brazilian domain (.br) including its status,
  hosts, expiration date, and alternative domain suggestions.

  ## Parameters

    * `domain` - The domain name to check (string)

  ## Examples

      iex> Brasilapi.RegistroBr.API.get_domain_info("brasilapi.com.br")
      {:ok, %Brasilapi.RegistroBr.Domain{status_code: 2, status: "REGISTERED", fqdn: "brasilapi.com.br"}}

      iex> Brasilapi.RegistroBr.API.get_domain_info("nonexistentdomain.com.br")
      {:error, %{status: 400, message: "Bad request"}}

  """
  @spec get_domain_info(String.t()) :: {:ok, Domain.t()} | {:error, map()}
  def get_domain_info(domain) when is_binary(domain) do
    with {:ok, %{} = domain_data} <- Client.get("/registrobr/v1/#{domain}"),
         do: {:ok, Domain.from_map(domain_data)}
  end

  def get_domain_info(_domain) do
    {:error, %{message: "Domain must be a string"}}
  end
end
