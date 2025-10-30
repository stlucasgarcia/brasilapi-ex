defmodule Brasilapi.Cptec.City do
  @moduledoc """
  Struct representing a city from CPTEC city search.
  """

  @type t :: %__MODULE__{
          nome: String.t(),
          estado: String.t(),
          id: integer()
        }

  @derive Jason.Encoder
  defstruct [:nome, :estado, :id]

  @doc """
  Creates a City struct from a map.

  ## Examples

      iex> Brasilapi.Cptec.City.from_map(%{"nome" => "São Paulo", "estado" => "SP", "id" => 244})
      %Brasilapi.Cptec.City{nome: "São Paulo", estado: "SP", id: 244}

  """
  @spec from_map(map()) :: t()
  def from_map(%{} = map) do
    %__MODULE__{
      nome: Map.get(map, "nome"),
      estado: Map.get(map, "estado"),
      id: Map.get(map, "id")
    }
  end
end
