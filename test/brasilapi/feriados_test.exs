defmodule Brasilapi.FeriadosTest do
  use ExUnit.Case
  doctest Brasilapi.Feriados

  alias Brasilapi.Feriados
  alias Brasilapi.Feriados.Holiday

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

  describe "get_by_year/1" do
    test "delegates to API.get_by_year/1", %{bypass: bypass} do
      response_body = [
        %{
          "date" => "2021-01-01",
          "name" => "Confraternização mundial",
          "type" => "national"
        },
        %{
          "date" => "2021-04-21",
          "name" => "Tiradentes",
          "type" => "national"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/feriados/v1/2021", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, holidays} = Feriados.get_by_year(2021)
      assert is_list(holidays)
      assert length(holidays) == 2

      [holiday1, holiday2] = holidays
      assert %Holiday{} = holiday1
      assert holiday1.date == "2021-01-01"
      assert holiday1.name == "Confraternização mundial"

      assert %Holiday{} = holiday2
      assert holiday2.date == "2021-04-21"
      assert holiday2.name == "Tiradentes"
    end
  end
end
