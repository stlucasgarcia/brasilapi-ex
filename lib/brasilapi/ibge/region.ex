defmodule Brasilapi.Ibge.Region do
  @moduledoc """
  Struct representing a Brazilian region.
  """

  @type t :: %__MODULE__{
          id: integer(),
          sigla: String.t(),
          nome: String.t()
        }

  defstruct [:id, :sigla, :nome]

  @doc """
  Creates a Region struct from a map.
  Supports both string and atom keys.
  """
  @spec from_map(map()) :: t()
  def from_map(%{} = map) do
    %__MODULE__{
      id: Map.get(map, "id"),
      sigla: Map.get(map, "sigla"),
      nome: Map.get(map, "nome")
    }
  end
end
