defmodule Brasilapi.RatesTest do
  use ExUnit.Case, async: false

  alias Brasilapi.Rates
  alias Brasilapi.Rates.Rate
  alias Brasilapi.BypassHelpers

  setup do
    BypassHelpers.setup_bypass_for_base_url()
  end

  describe "get_all/0 delegation" do
    test "delegates to API.get_all/0", %{bypass: bypass} do
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

      assert {:ok, [rate1, rate2]} = Rates.get_all()
      assert %Rate{nome: "CDI", valor: 14.9} = rate1
      assert %Rate{nome: "SELIC", valor: 15} = rate2
    end
  end

  describe "get_by_acronym/1 delegation" do
    test "delegates to API.get_by_acronym/1", %{bypass: bypass} do
      expected_response = %{
        "nome" => "CDI",
        "valor" => 14.9
      }

      Bypass.expect(bypass, "GET", "/api/taxas/v1/CDI", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, rate} = Rates.get_by_acronym("CDI")
      assert %Rate{nome: "CDI", valor: 14.9} = rate
    end
  end
end
