defmodule Brasilapi.Ddd.APITest do
  use ExUnit.Case, async: false

  alias Brasilapi.Ddd.{API, Info}
  alias Brasilapi.BypassHelpers

  setup do
    BypassHelpers.setup_bypass_for_base_url()
  end

  describe "get_by_ddd/1" do
    test "fetches DDD data with string DDD", %{bypass: bypass} do
      response_body = %{
        "state" => "SP",
        "cities" => [
          "EMBU",
          "VÁRZEA PAULISTA",
          "VARGEM GRANDE PAULISTA",
          "SÃO PAULO"
        ]
      }

      Bypass.expect(bypass, "GET", "/api/ddd/v1/11", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, %Info{} = ddd_data} = API.get_by_ddd("11")
      assert ddd_data.state == "SP"
      assert ddd_data.cities == ["EMBU", "VÁRZEA PAULISTA", "VARGEM GRANDE PAULISTA", "SÃO PAULO"]
    end

    test "fetches DDD data with integer DDD", %{bypass: bypass} do
      response_body = %{
        "state" => "SP",
        "cities" => [
          "EMBU",
          "VÁRZEA PAULISTA",
          "SÃO PAULO"
        ]
      }

      Bypass.expect(bypass, "GET", "/api/ddd/v1/11", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, %Info{} = ddd_data} = API.get_by_ddd(11)
      assert ddd_data.state == "SP"
    end

    test "pads single digit DDD with leading zero", %{bypass: bypass} do
      response_body = %{
        "state" => "RJ",
        "cities" => ["RIO DE JANEIRO"]
      }

      Bypass.expect(bypass, "GET", "/api/ddd/v1/01", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, %Info{} = ddd_data} = API.get_by_ddd(1)
      assert ddd_data.state == "RJ"
    end

    test "removes non-digit characters from DDD", %{bypass: bypass} do
      response_body = %{
        "state" => "SP",
        "cities" => ["SÃO PAULO"]
      }

      Bypass.expect(bypass, "GET", "/api/ddd/v1/11", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, %Info{} = ddd_data} = API.get_by_ddd("(11)")
      assert ddd_data.state == "SP"
    end

    test "returns error for invalid DDD format" do
      assert {:error, %{message: "DDD must be exactly 2 digits"}} = API.get_by_ddd("1")
      assert {:error, %{message: "DDD must be exactly 2 digits"}} = API.get_by_ddd("123")
      assert {:error, %{message: "DDD must contain only digits"}} = API.get_by_ddd("")
    end

    test "returns error for DDD with non-digit characters after normalization" do
      assert {:error, %{message: "DDD must contain only digits"}} = API.get_by_ddd("ab")
      assert {:error, %{message: "DDD must contain only digits"}} = API.get_by_ddd("--")
    end

    test "returns error for invalid DDD type" do
      assert {:error, %{message: "DDD must be a string or integer"}} = API.get_by_ddd(nil)
      assert {:error, %{message: "DDD must be a string or integer"}} = API.get_by_ddd([])
      assert {:error, %{message: "DDD must be a string or integer"}} = API.get_by_ddd(%{})
    end

    test "returns error when API returns 404", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/ddd/v1/99", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(404, Jason.encode!(%{"error" => "DDD não encontrado"}))
      end)

      assert {:error, %{status: 404, message: "Not found"}} = API.get_by_ddd(99)
    end

    test "returns error when API returns server error", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/ddd/v1/11", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(500, Jason.encode!(%{"error" => "Internal server error"}))
      end)

      assert {:error, %{status: 500, message: "Server error"}} = API.get_by_ddd("11")
    end

    test "returns error when network fails", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %{reason: :econnrefused, message: "Network error"}} =
               API.get_by_ddd("11")
    end
  end
end
