defmodule Brasilapi.RatesTest do
  use ExUnit.Case, async: false

  alias Brasilapi.Rates
  alias Brasilapi.Rates.Rate

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
