defmodule Brasilapi.HolidaysTest do
  use ExUnit.Case
  doctest Brasilapi.Holidays

  alias Brasilapi.Holidays
  alias Brasilapi.Holidays.Holiday
  alias Brasilapi.BypassHelpers

  setup do
    BypassHelpers.setup_bypass_for_base_url()
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

      assert {:ok, holidays} = Holidays.get_by_year(2021)
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
