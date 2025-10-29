defmodule Brasilapi.Fipe.ReferenceTable do
  @moduledoc """
  Struct representing a FIPE reference table.
  """

  @type t :: %__MODULE__{
          codigo: integer(),
          mes: String.t()
        }

  defstruct [:codigo, :mes]

  @doc """
  Creates a ReferenceTable struct from a map.
  Supports both string and atom keys.
  """
  @spec from_map(map()) :: t()
  def from_map(%{} = map) do
    %__MODULE__{
      codigo: Map.get(map, "codigo"),
      mes: Map.get(map, "mes")
    }
  end
end
