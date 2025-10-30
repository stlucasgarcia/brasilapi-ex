defmodule Brasilapi.Cptec.CityForecast do
  @moduledoc """
  Struct representing a city weather forecast.
  Contains the city information and an array of climate data for multiple days.
  """

  alias Brasilapi.Cptec.ClimateData

  @type t :: %__MODULE__{
          cidade: String.t(),
          estado: String.t(),
          atualizado_em: String.t(),
          clima: list(ClimateData.t())
        }

  @derive Jason.Encoder
  defstruct [:cidade, :estado, :atualizado_em, :clima]

  @doc """
  Creates a CityForecast struct from a map.

  ## Examples

      iex> Brasilapi.Cptec.CityForecast.from_map(%{
      ...>   "cidade" => "São Paulo",
      ...>   "estado" => "SP",
      ...>   "atualizado_em" => "2021-01-27",
      ...>   "clima" => [%{"data" => "2021-01-27", "min" => 18, "max" => 28}]
      ...> })
      %Brasilapi.Cptec.CityForecast{cidade: "São Paulo", estado: "SP", atualizado_em: "2021-01-27", clima: [%Brasilapi.Cptec.ClimateData{...}]}

  """
  @spec from_map(map()) :: t()
  def from_map(%{} = map) do
    %__MODULE__{
      cidade: Map.get(map, "cidade"),
      estado: Map.get(map, "estado"),
      atualizado_em: Map.get(map, "atualizado_em"),
      clima: map |> Map.get("clima", []) |> Enum.map(&ClimateData.from_map/1)
    }
  end
end
