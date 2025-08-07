defmodule Brasilapi.ExchangeTest do
  use ExUnit.Case, async: false

  alias Brasilapi.Exchange
  alias Brasilapi.Exchange.Currency
  alias Brasilapi.Exchange.DailyExchangeRate

  setup do
    # Store original base_url to restore later
    original_base_url = Application.get_env(:brasilapi, :base_url)

    bypass = Bypass.open()
    base_url = "http://localhost:#{bypass.port}/api"

    # Override the base URL for testing
    Application.put_env(:brasilapi, :base_url, base_url)

    on_exit(fn ->
      if original_base_url do
        Application.put_env(:brasilapi, :base_url, original_base_url)
      else
        Application.delete_env(:brasilapi, :base_url)
      end
    end)

    {:ok, bypass: bypass, base_url: base_url}
  end

  describe "get_currencies/0 delegation" do
    test "delegates to API.get_currencies/0", %{bypass: bypass} do
      expected_response = [
        %{
          "simbolo" => "USD",
          "nome" => "Dólar dos Estados Unidos",
          "tipo_moeda" => "A"
        },
        %{
          "simbolo" => "EUR",
          "nome" => "Euro",
          "tipo_moeda" => "A"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/cambio/v1/moedas", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, currencies} = Exchange.get_currencies()

      assert [
               %Currency{simbolo: "USD", nome: "Dólar dos Estados Unidos", tipo_moeda: "A"},
               %Currency{simbolo: "EUR", nome: "Euro", tipo_moeda: "A"}
             ] = currencies
    end
  end

  describe "get_exchange_rate/2 delegation" do
    test "delegates to API.get_exchange_rate/2", %{bypass: bypass} do
      expected_response = %{
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

      Bypass.expect(bypass, "GET", "/api/cambio/v1/cotacao/USD/2025-02-13", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, exchange_rate} = Exchange.get_exchange_rate("USD", "2025-02-13")

      assert %DailyExchangeRate{
               moeda: "USD",
               data: "2025-02-13"
             } = exchange_rate

      assert is_list(exchange_rate.cotacoes)
    end
  end
end