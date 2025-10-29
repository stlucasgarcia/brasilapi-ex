defmodule Brasilapi.DddTest do
  use ExUnit.Case
  doctest Brasilapi.Ddd

  alias Brasilapi.Ddd
  alias Brasilapi.Ddd.Info
  alias Brasilapi.BypassHelpers

  setup do
    BypassHelpers.setup_bypass_for_base_url()
  end

  describe "get_by_ddd/1" do
    test "delegates to API.get_by_ddd/1", %{bypass: bypass} do
      response_body = %{
        "state" => "SP",
        "cities" => ["SÃO PAULO", "CAMPINAS"]
      }

      Bypass.expect(bypass, "GET", "/api/ddd/v1/11", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, %Info{} = info} = Ddd.get_by_ddd(11)
      assert info.state == "SP"
      assert info.cities == ["SÃO PAULO", "CAMPINAS"]
    end
  end
end
