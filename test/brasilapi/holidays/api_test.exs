defmodule Brasilapi.Holidays.APITest do
  use ExUnit.Case, async: false

  alias Brasilapi.Holidays.{API, Holiday}
  alias Brasilapi.BypassHelpers

  setup do
    BypassHelpers.setup_bypass_for_base_url()
  end

  describe "get_by_year/1" do
    test "fetches holidays data with string year", %{bypass: bypass} do
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
        },
        %{
          "date" => "2021-09-07",
          "name" => "Independência do Brasil",
          "type" => "national"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/feriados/v1/2021", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, holidays} = API.get_by_year("2021")
      assert is_list(holidays)
      assert length(holidays) == 3

      [holiday1, holiday2, holiday3] = holidays

      assert %Holiday{} = holiday1
      assert holiday1.date == "2021-01-01"
      assert holiday1.name == "Confraternização mundial"
      assert holiday1.type == "national"

      assert %Holiday{} = holiday2
      assert holiday2.date == "2021-04-21"
      assert holiday2.name == "Tiradentes"
      assert holiday2.type == "national"

      assert %Holiday{} = holiday3
      assert holiday3.date == "2021-09-07"
      assert holiday3.name == "Independência do Brasil"
      assert holiday3.type == "national"
    end

    test "fetches holidays data with integer year", %{bypass: bypass} do
      response_body = [
        %{
          "date" => "2022-01-01",
          "name" => "Confraternização mundial",
          "type" => "national"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/feriados/v1/2022", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, holidays} = API.get_by_year(2022)
      assert is_list(holidays)
      assert length(holidays) == 1

      [holiday] = holidays
      assert %Holiday{} = holiday
      assert holiday.date == "2022-01-01"
    end

    test "fetches holidays with full_name field", %{bypass: bypass} do
      response_body = [
        %{
          "date" => "2021-12-25",
          "name" => "Natal",
          "type" => "national",
          "full_name" => "Nascimento de Jesus Cristo"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/feriados/v1/2021", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, holidays} = API.get_by_year(2021)
      assert is_list(holidays)
      assert length(holidays) == 1

      [holiday] = holidays
      assert %Holiday{} = holiday
      assert holiday.date == "2021-12-25"
      assert holiday.name == "Natal"
      assert holiday.type == "national"
      assert holiday.full_name == "Nascimento de Jesus Cristo"
    end

    test "returns empty list when no holidays found", %{bypass: bypass} do
      response_body = []

      Bypass.expect(bypass, "GET", "/api/feriados/v1/2020", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, holidays} = API.get_by_year(2020)
      assert holidays == []
    end

    test "returns error for invalid year format" do
      assert {:error, %{message: "Year must be a valid positive integer"}} =
               API.get_by_year("abc")

      assert {:error, %{message: "Year must be a valid positive integer"}} =
               API.get_by_year("20a1")

      assert {:error, %{message: "Year must be a valid positive integer"}} = API.get_by_year("")
    end

    test "returns error for negative year" do
      assert {:error, %{message: "Year must be a valid positive integer"}} =
               API.get_by_year("-2021")

      assert {:error, %{message: "Year must be a valid positive integer"}} =
               API.get_by_year(-2021)
    end

    test "returns error for zero year" do
      assert {:error, %{message: "Year must be a valid positive integer"}} = API.get_by_year(0)
      assert {:error, %{message: "Year must be a valid positive integer"}} = API.get_by_year("0")
    end

    test "handles years with whitespace", %{bypass: bypass} do
      response_body = [
        %{
          "date" => "2021-01-01",
          "name" => "Confraternização mundial",
          "type" => "national"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/feriados/v1/2021", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, holidays} = API.get_by_year(" 2021 ")
      assert length(holidays) == 1
    end

    test "returns error for decimal years" do
      assert {:error, %{message: "Year must be a valid positive integer"}} =
               API.get_by_year("2021.5")
    end

    test "returns error for years with special characters" do
      assert {:error, %{message: "Year must be a valid positive integer"}} =
               API.get_by_year("2021!")

      assert {:error, %{message: "Year must be a valid positive integer"}} =
               API.get_by_year("20-21")
    end

    test "returns error for invalid year type" do
      assert {:error, %{message: "Year must be a string or integer"}} = API.get_by_year(nil)
      assert {:error, %{message: "Year must be a string or integer"}} = API.get_by_year([])
      assert {:error, %{message: "Year must be a string or integer"}} = API.get_by_year(%{})
    end

    test "returns error when API returns 404", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/feriados/v1/1900", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(404, Jason.encode!(%{"error" => "Ano fora do intervalo suportado."}))
      end)

      assert {:error, %{status: 404, message: "Not found"}} = API.get_by_year(1900)
    end

    test "returns error when API returns server error", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/feriados/v1/2021", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(500, Jason.encode!(%{"error" => "Erro inesperado."}))
      end)

      assert {:error, %{status: 500, message: "Server error"}} = API.get_by_year("2021")
    end

    test "returns error when network fails", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %{reason: :econnrefused, message: "Network error"}} =
               API.get_by_year("2021")
    end

    test "fetches complete year of Brazilian holidays", %{bypass: bypass} do
      # Real Brazilian holidays for 2023 to make tests more accurate
      response_body = [
        %{"date" => "2023-01-01", "name" => "Confraternização mundial", "type" => "national"},
        %{"date" => "2023-02-20", "name" => "Carnaval", "type" => "national"},
        %{"date" => "2023-02-21", "name" => "Carnaval", "type" => "national"},
        %{"date" => "2023-04-07", "name" => "Paixão de Cristo", "type" => "national"},
        %{"date" => "2023-04-21", "name" => "Tiradentes", "type" => "national"},
        %{"date" => "2023-05-01", "name" => "Dia do Trabalhador", "type" => "national"},
        %{"date" => "2023-09-07", "name" => "Independência do Brasil", "type" => "national"},
        %{
          "date" => "2023-10-12",
          "name" => "Nossa Senhora Aparecida",
          "type" => "national",
          "full_name" => "Padroeira do Brasil"
        },
        %{"date" => "2023-11-02", "name" => "Finados", "type" => "national"},
        %{"date" => "2023-11-15", "name" => "Proclamação da República", "type" => "national"},
        %{"date" => "2023-12-25", "name" => "Natal", "type" => "national"}
      ]

      Bypass.expect(bypass, "GET", "/api/feriados/v1/2023", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, holidays} = API.get_by_year(2023)
      assert length(holidays) == 11

      # Verify fixed holidays are present
      new_year = Enum.find(holidays, &(&1.date == "2023-01-01"))
      assert new_year.name == "Confraternização mundial"
      assert new_year.type == "national"

      christmas = Enum.find(holidays, &(&1.date == "2023-12-25"))
      assert christmas.name == "Natal"
      assert christmas.type == "national"

      # Verify holiday with full_name
      aparecida = Enum.find(holidays, &(&1.date == "2023-10-12"))
      assert aparecida.name == "Nossa Senhora Aparecida"
      assert aparecida.full_name == "Padroeira do Brasil"

      # Verify moveable holidays (Carnaval, Easter-based)
      carnaval = Enum.filter(holidays, &(&1.name == "Carnaval"))
      assert length(carnaval) == 2

      good_friday = Enum.find(holidays, &(&1.date == "2023-04-07"))
      assert good_friday.name == "Paixão de Cristo"
    end
  end
end
