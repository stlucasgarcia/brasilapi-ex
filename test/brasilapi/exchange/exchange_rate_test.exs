defmodule Brasilapi.Exchange.ExchangeRateTest do
  use ExUnit.Case

  alias Brasilapi.Exchange.ExchangeRate

  describe "from_map/1" do
    test "creates ExchangeRate struct from valid map" do
      map = %{
        "paridade_compra" => 1,
        "paridade_venda" => 1,
        "cotacao_compra" => 5.7702,
        "cotacao_venda" => 5.7708,
        "data_hora_cotacao" => "2025-02-13 10:04:26.424",
        "tipo_boletim" => "ABERTURA"
      }

      result = ExchangeRate.from_map(map)

      assert %ExchangeRate{
               paridade_compra: 1,
               paridade_venda: 1,
               cotacao_compra: 5.7702,
               cotacao_venda: 5.7708,
               data_hora_cotacao: "2025-02-13 10:04:26.424",
               tipo_boletim: "ABERTURA"
             } = result
    end

    test "creates ExchangeRate struct with different values" do
      map = %{
        "paridade_compra" => 2,
        "paridade_venda" => 2,
        "cotacao_compra" => 6.1234,
        "cotacao_venda" => 6.1240,
        "data_hora_cotacao" => "2025-02-13 14:30:15.123",
        "tipo_boletim" => "INTERMEDIÁRIO"
      }

      result = ExchangeRate.from_map(map)

      assert %ExchangeRate{
               paridade_compra: 2,
               paridade_venda: 2,
               cotacao_compra: 6.1234,
               cotacao_venda: 6.1240,
               data_hora_cotacao: "2025-02-13 14:30:15.123",
               tipo_boletim: "INTERMEDIÁRIO"
             } = result
    end

    test "creates ExchangeRate struct with nil values for missing fields" do
      map = %{
        "paridade_compra" => 1
      }

      result = ExchangeRate.from_map(map)

      assert %ExchangeRate{
               paridade_compra: 1,
               paridade_venda: nil,
               cotacao_compra: nil,
               cotacao_venda: nil,
               data_hora_cotacao: nil,
               tipo_boletim: nil
             } = result
    end
  end

  describe "Jason.Encoder" do
    test "encodes ExchangeRate struct to JSON" do
      exchange_rate = %ExchangeRate{
        paridade_compra: 1,
        paridade_venda: 1,
        cotacao_compra: 5.7702,
        cotacao_venda: 5.7708,
        data_hora_cotacao: "2025-02-13 10:04:26.424",
        tipo_boletim: "ABERTURA"
      }

      json_string = Jason.encode!(exchange_rate)
      decoded = Jason.decode!(json_string)

      assert %{
               "paridade_compra" => 1,
               "paridade_venda" => 1,
               "cotacao_compra" => 5.7702,
               "cotacao_venda" => 5.7708,
               "data_hora_cotacao" => "2025-02-13 10:04:26.424",
               "tipo_boletim" => "ABERTURA"
             } = decoded
    end
  end
end
