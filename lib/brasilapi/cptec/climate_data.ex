defmodule Brasilapi.Cptec.ClimateData do
  @moduledoc """
  Struct representing daily climate/weather forecast data.
  """

  @type t :: %__MODULE__{
          data: String.t(),
          condicao: String.t(),
          min: integer(),
          max: integer(),
          indice_uv: number(),
          condicao_desc: String.t()
        }

  @derive Jason.Encoder
  defstruct [:data, :condicao, :min, :max, :indice_uv, :condicao_desc]

  @doc """
  Creates a ClimateData struct from a map.

  ## Examples

      iex> Brasilapi.Cptec.ClimateData.from_map(%{
      ...>   "data" => "2021-01-27",
      ...>   "condicao" => "ps",
      ...>   "min" => 18,
      ...>   "max" => 28,
      ...>   "indice_uv" => 11.5,
      ...>   "condicao_desc" => "Predomínio de Sol"
      ...> })
      %Brasilapi.Cptec.ClimateData{data: "2021-01-27", condicao: "ps", min: 18, max: 28, indice_uv: 11.5, condicao_desc: "Predomínio de Sol"}

  """
  @spec from_map(map()) :: t()
  def from_map(%{} = map) do
    %__MODULE__{
      data: Map.get(map, "data"),
      condicao: Map.get(map, "condicao"),
      min: Map.get(map, "min"),
      max: Map.get(map, "max"),
      indice_uv: Map.get(map, "indice_uv"),
      condicao_desc: Map.get(map, "condicao_desc")
    }
  end
end
