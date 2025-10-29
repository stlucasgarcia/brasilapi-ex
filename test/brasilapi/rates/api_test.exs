defmodule Brasilapi.Rates.APITest do
  use ExUnit.Case, async: false

  alias Brasilapi.Rates.API
  alias Brasilapi.Rates.Rate
  alias Brasilapi.BypassHelpers

  setup do
    BypassHelpers.setup_bypass_for_base_url()
  end

  describe "get_rates/0" do
    test "returns list of tax rates when successful", %{bypass: bypass} do
      expected_response = [
        %{
          "nome" => "CDI",
          "valor" => 14.9
        },
        %{
          "nome" => "SELIC",
          "valor" => 15
        }
      ]

      Bypass.expect(bypass, "GET", "/api/taxas/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, rates} = API.get_rates()
      assert length(rates) == 2
      assert [%Rate{nome: "CDI", valor: 14.9}, %Rate{nome: "SELIC", valor: 15}] = rates
    end

    test "returns error when request fails", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/taxas/v1", fn conn ->
        Plug.Conn.resp(conn, 500, "Internal Server Error")
      end)

      assert {:error, %{status: 500, message: "Server error"}} = API.get_rates()
    end

    test "returns error when connection fails", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %{reason: :econnrefused, message: "Network error"}} = API.get_rates()
    end
  end

  describe "get_rates_by_acronym/1" do
    test "returns tax rate when found", %{bypass: bypass} do
      expected_response = %{
        "nome" => "CDI",
        "valor" => 14.9
      }

      Bypass.expect(bypass, "GET", "/api/taxas/v1/CDI", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, rate} = API.get_rates_by_acronym("CDI")
      assert %Rate{nome: "CDI", valor: 14.9} = rate
    end

    test "returns error when tax rate not found", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/taxas/v1/INVALID", fn conn ->
        Plug.Conn.resp(conn, 404, "Not Found")
      end)

      assert {:error, %{status: 404, message: "Not found"}} = API.get_rates_by_acronym("INVALID")
    end

    test "returns error for invalid acronym parameter" do
      assert {:error, %{message: "Acronym must be a string"}} = API.get_rates_by_acronym(123)
      assert {:error, %{message: "Acronym must be a string"}} = API.get_rates_by_acronym(nil)
    end

    test "returns error when connection fails", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %{reason: :econnrefused, message: "Network error"}} =
               API.get_rates_by_acronym("CDI")
    end
  end
end
