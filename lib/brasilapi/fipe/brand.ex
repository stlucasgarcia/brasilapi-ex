defmodule Brasilapi.Fipe.Brand do
  @moduledoc """
  Struct representing a vehicle brand in the FIPE table.
  """

  @type t :: %__MODULE__{
          nome: String.t(),
          valor: String.t()
        }

  defstruct [:nome, :valor]

  @doc """
  Creates a Brand struct from a map.
  Supports both string and atom keys.
  """
  @spec from_map(map()) :: t()
  def from_map(%{} = map) do
    %__MODULE__{
      nome: Map.get(map, "nome"),
      valor: Map.get(map, "valor")
    }
  end
end
