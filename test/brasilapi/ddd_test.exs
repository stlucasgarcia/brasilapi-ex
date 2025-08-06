defmodule Brasilapi.DddTest do
  use ExUnit.Case
  doctest Brasilapi.Ddd

  alias Brasilapi.Ddd
  alias Brasilapi.Ddd.Info

  setup do
    original_base_url = Application.get_env(:brasilapi, :base_url)

    bypass = Bypass.open()
    base_url = "http://localhost:#{bypass.port}/api"

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
