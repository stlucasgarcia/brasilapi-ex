defmodule Brasilapi.Cptec.DailyWaves do
  @moduledoc """
  Struct representing daily wave data containing hourly wave conditions.
  """

  alias Brasilapi.Cptec.HourlyWaves

  @type t :: %__MODULE__{
          data: String.t(),
          ondas_data: list(HourlyWaves.t())
        }

  @derive Jason.Encoder
  defstruct [:data, :ondas_data]

  @doc """
  Creates a DailyWaves struct from a map.

  ## Examples

      iex> Brasilapi.Cptec.DailyWaves.from_map(%{
      ...>   "data" => "2021-01-27",
      ...>   "ondas_data" => [%{"vento" => 15.5, "altura_onda" => 1.2}]
      ...> })
      %Brasilapi.Cptec.DailyWaves{data: "2021-01-27", ondas_data: [%Brasilapi.Cptec.HourlyWaves{...}]}

  """
  @spec from_map(map()) :: t()
  def from_map(%{} = map) do
    %__MODULE__{
      data: Map.get(map, "data"),
      ondas_data: map |> Map.get("ondas_data", []) |> Enum.map(&HourlyWaves.from_map/1)
    }
  end
end
