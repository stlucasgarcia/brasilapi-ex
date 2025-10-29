defmodule Brasilapi.Fipe.API do
  @moduledoc """
  Client for BrasilAPI FIPE endpoints.

  Provides functions to fetch vehicle prices and information from the FIPE table
  (Fundação Instituto de Pesquisas Econômicas).
  """

  alias Brasilapi.Client
  alias Brasilapi.Fipe.{Brand, Price, ReferenceTable, Vehicle}

  @valid_vehicle_types ["caminhoes", "carros", "motos"]

  @doc """
  Lists vehicle brands by type.

  Returns a list of brands for a specific vehicle type or all types if not specified.

  ## Parameters

    * `vehicle_type` - Vehicle type: "caminhoes", "carros", "motos", or nil for all types
    * `opts` - Keyword list of options:
      * `:tabela_referencia` - Reference table code (optional)

  ## Examples

      iex> Brasilapi.Fipe.API.get_brands("carros")
      {:ok, [
        %Brasilapi.Fipe.Brand{
          nome: "AGRALE",
          valor: "102"
        },
        # ... more brands
      ]}

      iex> Brasilapi.Fipe.API.get_brands("carros", tabela_referencia: 295)
      {:ok, [%Brasilapi.Fipe.Brand{}, ...]}

      iex> Brasilapi.Fipe.API.get_brands(nil)
      {:ok, [%Brasilapi.Fipe.Brand{}, ...]}

  ## API Reference
    https://brasilapi.com.br/docs#tag/FIPE/paths/~1fipe~1marcas~1v1~1%7BtipoVeiculo%7D/get
  """
  @spec get_brands(String.t() | nil, keyword()) :: {:ok, [Brand.t()]} | {:error, map()}
  def get_brands(vehicle_type \\ nil, opts \\ [])

  def get_brands(vehicle_type, opts) when is_nil(vehicle_type) or vehicle_type == "" do
    url = build_url("/fipe/marcas/v1", opts)

    with {:ok, brands} when is_list(brands) <- Client.get(url) do
      {:ok, Enum.map(brands, &Brand.from_map/1)}
    end
  end

  def get_brands(vehicle_type, opts) when is_binary(vehicle_type) do
    with {:ok, _} <- validate_vehicle_type(vehicle_type),
         url <- build_url("/fipe/marcas/v1/#{vehicle_type}", opts),
         {:ok, brands} when is_list(brands) <- Client.get(url) do
      {:ok, Enum.map(brands, &Brand.from_map/1)}
    end
  end

  def get_brands(_vehicle_type, _opts) do
    {:error, %{message: "Vehicle type must be a string or nil"}}
  end

  @doc """
  Gets vehicle price by FIPE code.

  Returns detailed price information for a specific vehicle according to the FIPE table.

  ## Parameters

    * `fipe_code` - FIPE code in format XXXXXX-X (e.g., "001004-9")
    * `opts` - Keyword list of options:
      * `:tabela_referencia` - Reference table code (optional)

  ## Examples

      iex> Brasilapi.Fipe.API.get_price("001004-9")
      {:ok, [
        %Brasilapi.Fipe.Price{
          valor: "R$ 6.022,00",
          marca: "Fiat",
          modelo: "Palio EX 1.0 mpi 2p",
          ano_modelo: 1998,
          combustivel: "Álcool",
          codigo_fipe: "001004-9",
          mes_referencia: "junho de 2021 ",
          tipo_veiculo: 1,
          sigla_combustivel: "Á",
          data_consulta: "segunda-feira, 7 de junho de 2021 23:05"
        }
      ]}

      iex> Brasilapi.Fipe.API.get_price("001004-9", tabela_referencia: 295)
      {:ok, [%Brasilapi.Fipe.Price{}, ...]}

  ## API Reference
    https://brasilapi.com.br/docs#tag/FIPE/paths/~1fipe~1preco~1v1~1%7BcodigoFipe%7D/get
  """
  @spec get_price(String.t(), keyword()) :: {:ok, [Price.t()]} | {:error, map()}
  def get_price(fipe_code, opts \\ [])

  def get_price(fipe_code, opts) when is_binary(fipe_code) do
    with {:ok, _} <- validate_fipe_code(fipe_code),
         url <- build_url("/fipe/preco/v1/#{fipe_code}", opts),
         {:ok, prices} when is_list(prices) <- Client.get(url) do
      {:ok, Enum.map(prices, &Price.from_map/1)}
    end
  end

  def get_price(_fipe_code, _opts) do
    {:error, %{message: "FIPE code must be a string"}}
  end

  @doc """
  Lists all available FIPE reference tables.

  Returns a list of all reference tables with their codes and months.

  ## Examples

      iex> Brasilapi.Fipe.API.get_reference_tables()
      {:ok, [
        %Brasilapi.Fipe.ReferenceTable{
          codigo: 271,
          mes: "junho/2021 "
        },
        # ... more tables
      ]}

  ## API Reference
    https://brasilapi.com.br/docs#tag/FIPE/paths/~1fipe~1tabelas~1v1/get
  """
  @spec get_reference_tables() :: {:ok, [ReferenceTable.t()]} | {:error, map()}
  def get_reference_tables do
    with {:ok, tables} when is_list(tables) <- Client.get("/fipe/tabelas/v1") do
      {:ok, Enum.map(tables, &ReferenceTable.from_map/1)}
    end
  end

  @doc """
  Lists vehicles by brand and type.

  Returns a list of vehicle models for a specific brand and vehicle type.

  ## Parameters

    * `vehicle_type` - Vehicle type: "caminhoes", "carros", or "motos" (required)
    * `brand_code` - Brand code from get_brands/2 (required, integer or string)
    * `opts` - Keyword list of options:
      * `:tabela_referencia` - Reference table code (optional)

  ## Examples

      iex> Brasilapi.Fipe.API.get_vehicles("carros", 1)
      {:ok, [
        %Brasilapi.Fipe.Vehicle{
          modelo: "Palio EX 1.0 mpi 2p"
        },
        # ... more vehicles
      ]}

      iex> Brasilapi.Fipe.API.get_vehicles("carros", "1", tabela_referencia: 295)
      {:ok, [%Brasilapi.Fipe.Vehicle{}, ...]}

  ## API Reference
    https://brasilapi.com.br/docs#tag/FIPE/paths/~1fipe~1veiculos~1v1~1%7BtipoVeiculo%7D~1%7BcodigoMarca%7D/get
  """
  @spec get_vehicles(String.t(), String.t() | integer(), keyword()) ::
          {:ok, [Vehicle.t()]} | {:error, map()}
  def get_vehicles(vehicle_type, brand_code, opts \\ [])

  def get_vehicles(vehicle_type, brand_code, opts)
      when is_binary(vehicle_type) and (is_binary(brand_code) or is_integer(brand_code)) do
    normalized_brand_code = normalize_code(brand_code)

    with {:ok, _} <- validate_vehicle_type(vehicle_type),
         url <- build_url("/fipe/veiculos/v1/#{vehicle_type}/#{normalized_brand_code}", opts),
         {:ok, vehicles} when is_list(vehicles) <- Client.get(url) do
      {:ok, Enum.map(vehicles, &Vehicle.from_map/1)}
    end
  end

  def get_vehicles(_vehicle_type, _brand_code, _opts) do
    {:error,
     %{message: "Vehicle type must be a string and brand code must be a string or integer"}}
  end

  # Private functions

  @spec validate_vehicle_type(String.t()) :: {:ok, String.t()} | {:error, map()}
  defp validate_vehicle_type(vehicle_type) do
    if vehicle_type in @valid_vehicle_types do
      {:ok, vehicle_type}
    else
      {:error,
       %{
         message:
           "Invalid vehicle type: #{vehicle_type}. Valid types are: #{Enum.join(@valid_vehicle_types, ", ")}"
       }}
    end
  end

  @spec validate_fipe_code(String.t()) :: {:ok, String.t()} | {:error, map()}
  defp validate_fipe_code(fipe_code) do
    # Basic validation - FIPE code format: XXXXXX-X
    if Regex.match?(~r/^[0-9]{6}-[0-9]$/, fipe_code) do
      {:ok, fipe_code}
    else
      {:error,
       %{message: "Invalid FIPE code format. Must be in format XXXXXX-X (e.g., 001004-9)"}}
    end
  end

  @spec normalize_code(String.t() | integer()) :: String.t()
  defp normalize_code(code) when is_integer(code), do: Integer.to_string(code)
  defp normalize_code(code) when is_binary(code), do: code

  @spec build_url(String.t(), keyword()) :: String.t()
  defp build_url(base_path, opts) do
    case Keyword.get(opts, :tabela_referencia) do
      nil -> base_path
      tabela_referencia -> "#{base_path}?tabela_referencia=#{tabela_referencia}"
    end
  end
end
