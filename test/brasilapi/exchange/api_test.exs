defmodule Brasilapi.Exchange.APITest do
  use ExUnit.Case, async: false

  alias Brasilapi.Exchange.API
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

  describe "get_currencies/0" do
    test "returns list of currencies on success", %{bypass: bypass} do
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

      assert {:ok, currencies} = API.get_currencies()

      assert [
               %Currency{simbolo: "USD", nome: "Dólar dos Estados Unidos", tipo_moeda: "A"},
               %Currency{simbolo: "EUR", nome: "Euro", tipo_moeda: "A"}
             ] = currencies
    end

    test "returns error on API failure", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/cambio/v1/moedas", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(500, Jason.encode!(%{error: "Internal server error"}))
      end)

      assert {:error, %{status: 500}} = API.get_currencies()
    end

    test "handles connection failure", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %{message: _}} = API.get_currencies()
    end
  end

  describe "get_exchange_rate/2" do
    test "returns exchange rate on success with YYYY-MM-DD format", %{bypass: bypass} do
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

      assert {:ok, exchange_rate} = API.get_exchange_rate("USD", "2025-02-13")

      assert %DailyExchangeRate{
               moeda: "USD",
               data: "2025-02-13"
             } = exchange_rate

      assert is_list(exchange_rate.cotacoes)
      assert length(exchange_rate.cotacoes) == 1
    end

    test "handles Date struct", %{bypass: bypass} do
      expected_response = %{
        "cotacoes" => [],
        "moeda" => "USD",
        "data" => "2025-02-13"
      }

      Bypass.expect(bypass, "GET", "/api/cambio/v1/cotacao/USD/2025-02-13", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      date = ~D[2025-02-13]
      assert {:ok, exchange_rate} = API.get_exchange_rate("USD", date)

      assert %DailyExchangeRate{
               moeda: "USD",
               data: "2025-02-13"
             } = exchange_rate
    end

    test "handles DateTime struct", %{bypass: bypass} do
      expected_response = %{
        "cotacoes" => [],
        "moeda" => "USD",
        "data" => "2025-02-13"
      }

      Bypass.expect(bypass, "GET", "/api/cambio/v1/cotacao/USD/2025-02-13", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      datetime = ~U[2025-02-13 14:30:00Z]
      assert {:ok, exchange_rate} = API.get_exchange_rate("USD", datetime)

      assert %DailyExchangeRate{
               moeda: "USD",
               data: "2025-02-13"
             } = exchange_rate
    end

    test "handles NaiveDateTime struct", %{bypass: bypass} do
      expected_response = %{
        "cotacoes" => [],
        "moeda" => "USD",
        "data" => "2025-02-13"
      }

      Bypass.expect(bypass, "GET", "/api/cambio/v1/cotacao/USD/2025-02-13", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      naive_datetime = ~N[2025-02-13 14:30:00]
      assert {:ok, exchange_rate} = API.get_exchange_rate("USD", naive_datetime)

      assert %DailyExchangeRate{
               moeda: "USD",
               data: "2025-02-13"
             } = exchange_rate
    end

    test "returns error for invalid date format string" do
      assert {:error, %{message: "Invalid date format. Must be YYYY-MM-DD"}} =
               API.get_exchange_rate("USD", "invalid-date")
    end

    test "returns error for invalid date value" do
      assert {:error, %{message: "Invalid date. Must be a valid date in YYYY-MM-DD format"}} =
               API.get_exchange_rate("USD", "2025-02-30")
    end

    test "returns error for invalid date type" do
      assert {:error, %{message: message}} = API.get_exchange_rate("USD", 123)
      assert String.contains?(message, "Date must be a Date, DateTime, NaiveDateTime struct or string")
    end

    test "returns error on API failure", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/cambio/v1/cotacao/INVALID/2025-02-13", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(404, Jason.encode!(%{error: "Currency not found"}))
      end)

      assert {:error, %{status: 404}} = API.get_exchange_rate("INVALID", "2025-02-13")
    end

    test "handles connection failure", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %{message: _}} = API.get_exchange_rate("USD", "2025-02-13")
    end

    test "returns error for invalid currency parameter" do
      assert {:error, %{message: "Currency must be a string and date must be a valid date"}} =
               API.get_exchange_rate(123, "2025-02-13")
    end
  end
end