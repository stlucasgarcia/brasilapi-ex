defmodule Brasilapi.Ibge.API do
  @moduledoc """
  Client for BrasilAPI IBGE endpoints.

  Provides functions to fetch information about Brazilian states and municipalities
  from IBGE (Instituto Brasileiro de Geografia e Estatística).
  """

  alias Brasilapi.{Client}
  alias Brasilapi.Ibge.{Municipality, State}

  @valid_providers ["dados-abertos-br", "gov", "wikipedia"]

  @doc """
  Fetches all Brazilian states.

  Returns information about all states including their regions.

  ## Examples

      iex> Brasilapi.Ibge.API.get_states()
      {:ok, [
        %Brasilapi.Ibge.State{
          id: 35,
          sigla: "SP",
          nome: "São Paulo",
          regiao: %Brasilapi.Ibge.Region{
            id: 3,
            sigla: "SE",
            nome: "Sudeste"
          }
        },
        # ... more states
      ]}

  ## API Reference
    https://brasilapi.com.br/docs#tag/IBGE/paths/~1ibge~1uf~1v1/get
  """
  @spec get_states() :: {:ok, [State.t()]} | {:error, map()}
  def get_states do
    with {:ok, states} when is_list(states) <- Client.get("/ibge/uf/v1") do
      {:ok, Enum.map(states, &State.from_map/1)}
    end
  end

  @doc """
  Fetches information about a specific state by code or abbreviation.

  ## Parameters

    * `code` - State code (integer) or abbreviation/sigla (string, e.g., "SP", "RJ")

  ## Examples

      iex> Brasilapi.Ibge.API.get_state("SP")
      {:ok, %Brasilapi.Ibge.State{
        id: 35,
        sigla: "SP",
        nome: "São Paulo",
        regiao: %Brasilapi.Ibge.Region{
          id: 3,
          sigla: "SE",
          nome: "Sudeste"
        }
      }}

      iex> Brasilapi.Ibge.API.get_state(35)
      {:ok, %Brasilapi.Ibge.State{id: 35, sigla: "SP", ...}}

      iex> Brasilapi.Ibge.API.get_state("XX")
      {:error, %{status: 404, message: "Not found"}}

  ## API Reference
    https://brasilapi.com.br/docs#tag/IBGE/paths/~1ibge~1uf~1v1~1%7Bcode%7D/get
  """
  @spec get_state(String.t() | integer()) :: {:ok, State.t()} | {:error, map()}
  def get_state(code) when is_binary(code) or is_integer(code) do
    normalized_code = normalize_code(code)

    with {:ok, state} when is_map(state) <- Client.get("/ibge/uf/v1/#{normalized_code}") do
      {:ok, State.from_map(state)}
    end
  end

  def get_state(_code) do
    {:error, %{message: "Code must be a string or integer"}}
  end

  @doc """
  Fetches municipalities for a given state.

  Returns a list of municipalities for the specified state (UF).
  Optionally accepts a list of data providers.

  ## Parameters

    * `uf` - State abbreviation (e.g., "SP", "RJ", "SC")
    * `opts` - Keyword list of options:
      * `:providers` - List of provider names (optional)

  Available providers: #{inspect(@valid_providers)}

  ## Examples

      iex> Brasilapi.Ibge.API.get_municipalities("SC")
      {:ok, [
        %Brasilapi.Ibge.Municipality{
          nome: "Tubarão",
          codigo_ibge: "421870705"
        },
        %Brasilapi.Ibge.Municipality{
          nome: "Tunápolis",
          codigo_ibge: "421875605"
        },
        # ... more municipalities
      ]}

      iex> Brasilapi.Ibge.API.get_municipalities("SP", providers: ["gov", "wikipedia"])
      {:ok, [%Brasilapi.Ibge.Municipality{}, ...]}

      iex> Brasilapi.Ibge.API.get_municipalities("XX")
      {:error, %{status: 404, message: "Not found"}}

  ## API Reference
    https://brasilapi.com.br/docs#tag/IBGE/paths/~1ibge~1municipios~1v1~1%7BsiglaUF%7D?providers=dados-abertos-br,gov,wikipedia/get
  """
  @spec get_municipalities(String.t(), keyword()) ::
          {:ok, [Municipality.t()]} | {:error, map()}
  def get_municipalities(uf, opts \\ []) when is_binary(uf) do
    with {:ok, providers} <- validate_providers(opts[:providers]),
         url <- build_municipalities_url(uf, providers),
         {:ok, municipalities} when is_list(municipalities) <- Client.get(url) do
      {:ok, Enum.map(municipalities, &Municipality.from_map/1)}
    end
  end

  def get_municipalities(_uf, _opts) do
    {:error, %{message: "UF must be a string"}}
  end

  # Private functions

  @spec normalize_code(String.t() | integer()) :: String.t()
  defp normalize_code(code) when is_integer(code) do
    Integer.to_string(code)
  end

  defp normalize_code(code) when is_binary(code) do
    code
  end

  @spec validate_providers(nil | list()) :: {:ok, list()} | {:error, map()}
  defp validate_providers(nil), do: {:ok, []}
  defp validate_providers([]), do: {:ok, []}

  defp validate_providers(providers) when is_list(providers) do
    invalid_providers = Enum.reject(providers, &(&1 in @valid_providers))

    if Enum.empty?(invalid_providers) do
      {:ok, providers}
    else
      {:error,
       %{
         message:
           "Invalid providers: #{Enum.join(invalid_providers, ", ")}. Valid providers are: #{Enum.join(@valid_providers, ", ")}"
       }}
    end
  end

  defp validate_providers(_providers) do
    {:error, %{message: "Providers must be a list of strings"}}
  end

  @spec build_municipalities_url(String.t(), list()) :: String.t()
  defp build_municipalities_url(uf, []) do
    "/ibge/municipios/v1/#{uf}"
  end

  defp build_municipalities_url(uf, providers) when is_list(providers) do
    query_string = URI.encode_query(%{providers: Enum.join(providers, ",")})
    "/ibge/municipios/v1/#{uf}?#{query_string}"
  end
end
