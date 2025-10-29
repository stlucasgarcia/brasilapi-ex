defmodule Brasilapi.Ibge.Municipality do
  @moduledoc """
  Struct representing a Brazilian municipality (município).
  """

  @type t :: %__MODULE__{
          nome: String.t(),
          codigo_ibge: String.t()
        }

  defstruct [:nome, :codigo_ibge]

  @doc """
  Creates a Municipality struct from a map.
  Supports both string and atom keys.
  """
  @spec from_map(map()) :: t()
  def from_map(%{} = map) do
    %__MODULE__{
      nome: Map.get(map, "nome"),
      codigo_ibge: Map.get(map, "codigo_ibge")
    }
  end
end
