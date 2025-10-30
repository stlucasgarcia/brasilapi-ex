defmodule Brasilapi.Cptec.AirportConditions do
  @moduledoc """
  Struct representing current weather conditions at an airport.
  Used for both capital weather and specific airport weather data.
  """

  @type t :: %__MODULE__{
          codigo_icao: String.t(),
          atualizado_em: String.t(),
          pressao_atmosferica: String.t(),
          visibilidade: String.t(),
          vento: integer(),
          direcao_vento: integer(),
          umidade: integer(),
          condicao: String.t(),
          condicao_desc: String.t(),
          temp: number()
        }

  @derive Jason.Encoder
  defstruct [
    :codigo_icao,
    :atualizado_em,
    :pressao_atmosferica,
    :visibilidade,
    :vento,
    :direcao_vento,
    :umidade,
    :condicao,
    :condicao_desc,
    :temp
  ]

  @doc """
  Creates an AirportConditions struct from a map.

  ## Examples

      iex> Brasilapi.Cptec.AirportConditions.from_map(%{
      ...>   "codigo_icao" => "SBGR",
      ...>   "atualizado_em" => "2021-01-27T15:00:00.974Z",
      ...>   "temp" => 28
      ...> })
      %Brasilapi.Cptec.AirportConditions{codigo_icao: "SBGR", atualizado_em: "2021-01-27T15:00:00.974Z", temp: 28}

  """
  @spec from_map(map()) :: t()
  def from_map(%{} = map) do
    %__MODULE__{
      codigo_icao: Map.get(map, "codigo_icao"),
      atualizado_em: Map.get(map, "atualizado_em"),
      pressao_atmosferica: Map.get(map, "pressao_atmosferica"),
      visibilidade: Map.get(map, "visibilidade"),
      vento: Map.get(map, "vento"),
      direcao_vento: Map.get(map, "direcao_vento"),
      umidade: Map.get(map, "umidade"),
      condicao: Map.get(map, "condicao"),
      condicao_desc: Map.get(map, "condicao_Desc"),
      temp: Map.get(map, "temp")
    }
  end
end
