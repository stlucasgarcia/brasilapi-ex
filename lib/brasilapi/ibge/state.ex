defmodule Brasilapi.Ibge.State do
  @moduledoc """
  Struct representing a Brazilian state (Unidade Federativa).
  """

  alias Brasilapi.Ibge.Region

  @type t :: %__MODULE__{
          id: integer(),
          sigla: String.t(),
          nome: String.t(),
          regiao: Region.t() | nil
        }

  defstruct [:id, :sigla, :nome, :regiao]

  @doc """
  Creates a State struct from a map.
  Supports both string and atom keys.
  """
  @spec from_map(map()) :: t()
  def from_map(%{} = map) do
    regiao =
      case Map.get(map, "regiao") do
        nil -> nil
        %{} = regiao_map -> Region.from_map(regiao_map)
        _ -> nil
      end

    %__MODULE__{
      id: Map.get(map, "id"),
      sigla: Map.get(map, "sigla"),
      nome: Map.get(map, "nome"),
      regiao: regiao
    }
  end
end
