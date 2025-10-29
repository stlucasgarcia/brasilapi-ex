defmodule Brasilapi.Fipe.Vehicle do
  @moduledoc """
  Struct representing a vehicle model in the FIPE table.
  """

  @type t :: %__MODULE__{
          modelo: String.t()
        }

  defstruct [:modelo]

  @doc """
  Creates a Vehicle struct from a map.
  Supports both string and atom keys.
  """
  @spec from_map(map()) :: t()
  def from_map(%{} = map) do
    %__MODULE__{
      modelo: Map.get(map, "modelo")
    }
  end
end
