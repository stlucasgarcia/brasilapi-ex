defmodule Brasilapi.Exchange.Currency do
  @moduledoc """
  Represents a currency available for exchange rate queries.
  """

  @type t :: %__MODULE__{
          simbolo: String.t(),
          nome: String.t(),
          tipo_moeda: String.t()
        }

  @derive Jason.Encoder
  defstruct [
    :simbolo,
    :nome,
    :tipo_moeda
  ]

  @doc """
  Creates a Currency struct from API response data.
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      simbolo: Map.get(map, "simbolo"),
      nome: Map.get(map, "nome"),
      tipo_moeda: Map.get(map, "tipo_moeda")
    }
  end
end
