defmodule Brasilapi.Cptec.OceanForecast do
  @moduledoc """
  Struct representing an ocean/wave forecast for a city.
  Contains the city information and an array of daily wave data.
  """

  alias Brasilapi.Cptec.DailyWaves

  @type t :: %__MODULE__{
          cidade: String.t(),
          estado: String.t(),
          atualizado_em: String.t(),
          ondas: list(DailyWaves.t())
        }

  @derive Jason.Encoder
  defstruct [:cidade, :estado, :atualizado_em, :ondas]

  @doc """
  Creates an OceanForecast struct from a map.

  ## Examples

      iex> Brasilapi.Cptec.OceanForecast.from_map(%{
      ...>   "cidade" => "Rio de Janeiro",
      ...>   "estado" => "RJ",
      ...>   "atualizado_em" => "2021-01-27",
      ...>   "ondas" => [%{"data" => "2021-01-27", "ondas_data" => []}]
      ...> })
      %Brasilapi.Cptec.OceanForecast{cidade: "Rio de Janeiro", estado: "RJ", atualizado_em: "2021-01-27", ondas: [%Brasilapi.Cptec.DailyWaves{...}]}

  """
  @spec from_map(map()) :: t()
  def from_map(%{} = map) do
    %__MODULE__{
      cidade: Map.get(map, "cidade"),
      estado: Map.get(map, "estado"),
      atualizado_em: Map.get(map, "atualizado_em"),
      ondas: map |> Map.get("ondas", []) |> Enum.map(&DailyWaves.from_map/1)
    }
  end
end
