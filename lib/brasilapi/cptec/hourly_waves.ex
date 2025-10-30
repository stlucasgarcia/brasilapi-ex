defmodule Brasilapi.Cptec.HourlyWaves do
  @moduledoc """
  Struct representing hourly wave conditions for ocean forecast.
  """

  @type t :: %__MODULE__{
          vento: number(),
          direcao_vento: String.t(),
          direcao_vento_desc: String.t(),
          altura_onda: number(),
          direcao_onda: String.t(),
          direcao_onda_desc: String.t(),
          agitacao: String.t(),
          hora: String.t()
        }

  @derive Jason.Encoder
  defstruct [
    :vento,
    :direcao_vento,
    :direcao_vento_desc,
    :altura_onda,
    :direcao_onda,
    :direcao_onda_desc,
    :agitacao,
    :hora
  ]

  @doc """
  Creates a HourlyWaves struct from a map.

  ## Examples

      iex> Brasilapi.Cptec.HourlyWaves.from_map(%{
      ...>   "vento" => 15.5,
      ...>   "direcao_vento" => "S",
      ...>   "altura_onda" => 1.2,
      ...>   "hora" => "00h Z"
      ...> })
      %Brasilapi.Cptec.HourlyWaves{vento: 15.5, direcao_vento: "S", altura_onda: 1.2, hora: "00h Z"}

  """
  @spec from_map(map()) :: t()
  def from_map(%{} = map) do
    %__MODULE__{
      vento: Map.get(map, "vento"),
      direcao_vento: Map.get(map, "direcao_vento"),
      direcao_vento_desc: Map.get(map, "direcao_vento_desc"),
      altura_onda: Map.get(map, "altura_onda"),
      direcao_onda: Map.get(map, "direcao_onda"),
      direcao_onda_desc: Map.get(map, "direcao_onda_desc"),
      agitacao: Map.get(map, "agitacao"),
      hora: Map.get(map, "hora")
    }
  end
end
