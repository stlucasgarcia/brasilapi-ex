defmodule Brasilapi.Exchange.DailyExchangeRate do
  @moduledoc """
  Represents daily exchange rate information for a specific currency and date.
  """

  alias Brasilapi.Exchange.ExchangeRate

  @type t :: %__MODULE__{
          cotacoes: [ExchangeRate.t()],
          moeda: String.t(),
          data: String.t()
        }

  @derive Jason.Encoder
  defstruct [
    :cotacoes,
    :moeda,
    :data
  ]

  @doc """
  Creates a DailyExchangeRate struct from API response data.
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    cotacoes =
      case Map.get(map, "cotacoes") do
        cotacoes_list when is_list(cotacoes_list) ->
          Enum.map(cotacoes_list, &ExchangeRate.from_map/1)

        _ ->
          []
      end

    %__MODULE__{
      cotacoes: cotacoes,
      moeda: Map.get(map, "moeda"),
      data: Map.get(map, "data")
    }
  end
end
