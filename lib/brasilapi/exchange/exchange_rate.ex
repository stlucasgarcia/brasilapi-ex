defmodule Brasilapi.Exchange.ExchangeRate do
  @moduledoc """
  Represents a single exchange rate quotation with buy/sell rates and metadata.
  """

  @type t :: %__MODULE__{
          paridade_compra: number(),
          paridade_venda: number(),
          cotacao_compra: float(),
          cotacao_venda: float(),
          data_hora_cotacao: String.t(),
          tipo_boletim: String.t()
        }

  @derive Jason.Encoder
  defstruct [
    :paridade_compra,
    :paridade_venda,
    :cotacao_compra,
    :cotacao_venda,
    :data_hora_cotacao,
    :tipo_boletim
  ]

  @doc """
  Creates an ExchangeRate struct from API response data.
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      paridade_compra: Map.get(map, "paridade_compra"),
      paridade_venda: Map.get(map, "paridade_venda"),
      cotacao_compra: Map.get(map, "cotacao_compra"),
      cotacao_venda: Map.get(map, "cotacao_venda"),
      data_hora_cotacao: Map.get(map, "data_hora_cotacao"),
      tipo_boletim: Map.get(map, "tipo_boletim")
    }
  end
end
