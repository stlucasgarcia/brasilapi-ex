defmodule Brasilapi.Ncm.Ncm do
  @moduledoc """
  Struct representing an NCM (Nomenclatura Comum do Mercosul) code.

  NCM is the product classification system used for taxation and foreign trade control purposes.
  """

  @type t :: %__MODULE__{
          codigo: String.t(),
          descricao: String.t(),
          data_inicio: String.t(),
          data_fim: String.t(),
          tipo_ato: String.t(),
          numero_ato: String.t(),
          ano_ato: String.t()
        }

  defstruct [:codigo, :descricao, :data_inicio, :data_fim, :tipo_ato, :numero_ato, :ano_ato]

  @doc """
  Creates an NCM struct from a map.
  Supports both string and atom keys.
  """
  @spec from_map(map()) :: t()
  def from_map(%{} = map) do
    %__MODULE__{
      codigo: Map.get(map, "codigo"),
      descricao: Map.get(map, "descricao"),
      data_inicio: Map.get(map, "data_inicio"),
      data_fim: Map.get(map, "data_fim"),
      tipo_ato: Map.get(map, "tipo_ato"),
      numero_ato: Map.get(map, "numero_ato"),
      ano_ato: Map.get(map, "ano_ato")
    }
  end
end
