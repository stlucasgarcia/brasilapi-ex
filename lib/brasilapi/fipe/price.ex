defmodule Brasilapi.Fipe.Price do
  @moduledoc """
  Struct representing vehicle price information from the FIPE table.
  """

  @type t :: %__MODULE__{
          valor: String.t(),
          marca: String.t(),
          modelo: String.t(),
          ano_modelo: integer(),
          combustivel: String.t(),
          codigo_fipe: String.t(),
          mes_referencia: String.t(),
          tipo_veiculo: integer(),
          sigla_combustivel: String.t(),
          data_consulta: String.t()
        }

  defstruct [
    :valor,
    :marca,
    :modelo,
    :ano_modelo,
    :combustivel,
    :codigo_fipe,
    :mes_referencia,
    :tipo_veiculo,
    :sigla_combustivel,
    :data_consulta
  ]

  @doc """
  Creates a Price struct from a map.
  Supports both string and atom keys.
  """
  @spec from_map(map()) :: t()
  def from_map(%{} = map) do
    %__MODULE__{
      valor: Map.get(map, "valor"),
      marca: Map.get(map, "marca"),
      modelo: Map.get(map, "modelo"),
      ano_modelo: Map.get(map, "anoModelo"),
      combustivel: Map.get(map, "combustivel"),
      codigo_fipe: Map.get(map, "codigoFipe"),
      mes_referencia: Map.get(map, "mesReferencia"),
      tipo_veiculo: Map.get(map, "tipoVeiculo"),
      sigla_combustivel: Map.get(map, "siglaCombustivel"),
      data_consulta: Map.get(map, "dataConsulta")
    }
  end
end
