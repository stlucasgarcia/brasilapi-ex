defmodule Brasilapi.Exchange.DailyExchangeRateTest do
  use ExUnit.Case

  alias Brasilapi.Exchange.DailyExchangeRate
  alias Brasilapi.Exchange.ExchangeRate

  describe "from_map/1" do
    test "creates ExchangeRate struct from valid map" do
      map = %{
        "cotacoes" => [
          %{
            "paridade_compra" => 1,
            "paridade_venda" => 1,
            "cotacao_compra" => 5.7624,
            "cotacao_venda" => 5.763,
            "data_hora_cotacao" => "2025-02-13 13:03:25.722",
            "tipo_boletim" => "INTERMEDIÁRIO"
          }
        ],
        "moeda" => "USD",
        "data" => "2025-02-13"
      }

      result = DailyExchangeRate.from_map(map)

      assert %DailyExchangeRate{
               moeda: "USD",
               data: "2025-02-13"
             } = result

      assert is_list(result.cotacoes)
      assert length(result.cotacoes) == 1

      [exchange_rate | _] = result.cotacoes

      assert %ExchangeRate{
               paridade_compra: 1,
               paridade_venda: 1,
               cotacao_compra: 5.7624,
               cotacao_venda: 5.763,
               data_hora_cotacao: "2025-02-13 13:03:25.722",
               tipo_boletim: "INTERMEDIÁRIO"
             } = exchange_rate
    end

    test "creates ExchangeRate struct with different values" do
      map = %{
        "cotacoes" => [
          %{
            "paridade_compra" => 1,
            "paridade_venda" => 1,
            "cotacao_compra" => 6.2,
            "cotacao_venda" => 6.3,
            "data_hora_cotacao" => "2025-02-14 13:03:25.722",
            "tipo_boletim" => "INTERMEDIÁRIO"
          }
        ],
        "moeda" => "EUR",
        "data" => "2025-02-14"
      }

      result = DailyExchangeRate.from_map(map)

      assert %DailyExchangeRate{
               moeda: "EUR",
               data: "2025-02-14"
             } = result

      assert is_list(result.cotacoes)
      assert length(result.cotacoes) == 1

      [exchange_rate | _] = result.cotacoes

      assert %ExchangeRate{
               paridade_compra: 1,
               paridade_venda: 1,
               cotacao_compra: 6.2,
               cotacao_venda: 6.3,
               data_hora_cotacao: "2025-02-14 13:03:25.722",
               tipo_boletim: "INTERMEDIÁRIO"
             } = exchange_rate
    end

    test "creates ExchangeRate struct with nil values for missing fields" do
      map = %{
        "moeda" => "GBP"
      }

      result = DailyExchangeRate.from_map(map)

      assert %DailyExchangeRate{
               cotacoes: [],
               moeda: "GBP",
               data: nil
             } = result
    end
  end

  describe "Jason.Encoder" do
    test "encodes ExchangeRate struct to JSON" do
      exchange_rate = %ExchangeRate{
        paridade_compra: 1,
        paridade_venda: 1,
        cotacao_compra: 5.0,
        cotacao_venda: 5.1,
        data_hora_cotacao: "2025-02-13 13:03:25.722",
        tipo_boletim: "INTERMEDIÁRIO"
      }

      daily_exchange_rate = %DailyExchangeRate{
        cotacoes: [exchange_rate],
        moeda: "USD",
        data: "2025-02-13"
      }

      json_string = Jason.encode!(daily_exchange_rate)
      decoded = Jason.decode!(json_string)

      assert %{
               "cotacoes" => [
                 %{
                   "paridade_compra" => 1,
                   "paridade_venda" => 1,
                   "cotacao_compra" => 5.0,
                   "cotacao_venda" => 5.1,
                   "data_hora_cotacao" => "2025-02-13 13:03:25.722",
                   "tipo_boletim" => "INTERMEDIÁRIO"
                 }
               ],
               "moeda" => "USD",
               "data" => "2025-02-13"
             } = decoded
    end
  end
end
