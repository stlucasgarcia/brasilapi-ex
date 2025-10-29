defmodule Brasilapi.Holidays.Holiday do
  @moduledoc """
  Struct representing a national holiday.
  """

  @type t :: %__MODULE__{
          date: String.t(),
          name: String.t(),
          type: String.t(),
          full_name: String.t() | nil
        }

  defstruct [:date, :name, :type, :full_name]

  @doc """
  Creates a Holiday struct from a map.
  Supports both string and atom keys.
  """
  @spec from_map(map()) :: t()
  def from_map(%{} = map) do
    %__MODULE__{
      date: Map.get(map, "date"),
      name: Map.get(map, "name"),
      type: Map.get(map, "type"),
      full_name: Map.get(map, "full_name", nil)
    }
  end
end
