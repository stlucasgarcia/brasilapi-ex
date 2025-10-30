defmodule Brasilapi.Cptec.APITest do
  use ExUnit.Case, async: false

  alias Brasilapi.Cptec.{
    API,
    AirportConditions,
    City,
    CityForecast,
    ClimateData,
    DailyWaves,
    HourlyWaves,
    OceanForecast
  }

  alias Brasilapi.BypassHelpers

  setup do
    BypassHelpers.setup_bypass_for_base_url()
  end

  describe "list_cities/0" do
    test "successfully lists all cities", %{bypass: bypass} do
      response_body = [
        %{"nome" => "São Paulo", "estado" => "SP", "id" => 244},
        %{"nome" => "Rio de Janeiro", "estado" => "RJ", "id" => 241},
        %{"nome" => "Belo Horizonte", "estado" => "MG", "id" => 220}
      ]

      Bypass.expect(bypass, "GET", "/api/cptec/v1/cidade", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, cities} = API.list_cities()
      assert length(cities) == 3
      assert [%City{} | _] = cities
      assert Enum.any?(cities, fn city -> city.nome == "São Paulo" && city.id == 244 end)
      assert Enum.any?(cities, fn city -> city.nome == "Rio de Janeiro" && city.id == 241 end)
    end

    test "returns error when API fails", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/cptec/v1/cidade", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(500, Jason.encode!(%{"message" => "Internal Server Error"}))
      end)

      assert {:error, %{status: 500}} = API.list_cities()
    end
  end

  describe "search_cities/1" do
    test "successfully searches cities with valid name", %{bypass: bypass} do
      response_body = [
        %{"nome" => "São Paulo", "estado" => "SP", "id" => 244},
        %{"nome" => "São Paulo do Potengi", "estado" => "RN", "id" => 5100}
      ]

      # City name will be URL encoded: "São Paulo" -> "S%C3%A3o%20Paulo"
      Bypass.expect(bypass, "GET", "/api/cptec/v1/cidade/S%C3%A3o%20Paulo", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, cities} = API.search_cities("São Paulo")
      assert length(cities) == 2
      assert [%City{} | _] = cities
      assert Enum.any?(cities, fn city -> city.nome == "São Paulo" && city.estado == "SP" end)
    end

    test "returns error for non-string city name" do
      assert {:error, %{message: "City name must be a string"}} = API.search_cities(123)
    end

    test "returns error when API returns 404", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/cptec/v1/cidade/InvalidCity", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(404, Jason.encode!(%{"message" => "Not found"}))
      end)

      assert {:error, %{status: 404}} = API.search_cities("InvalidCity")
    end
  end

  describe "get_capitals_weather/0" do
    test "successfully fetches weather for all capitals", %{bypass: bypass} do
      response_body = [
        %{
          "codigo_icao" => "SBGR",
          "atualizado_em" => "2021-01-27T15:00:00.974Z",
          "pressao_atmosferica" => "1014",
          "visibilidade" => "9000",
          "vento" => 29,
          "direcao_vento" => 90,
          "umidade" => 74,
          "condicao" => "ps",
          "condicao_Desc" => "Predomínio de Sol",
          "temp" => 28
        },
        %{
          "codigo_icao" => "SBAR",
          "atualizado_em" => "2021-01-27T15:00:00.974Z",
          "pressao_atmosferica" => "1012",
          "visibilidade" => "8000",
          "vento" => 25,
          "direcao_vento" => 80,
          "umidade" => 70,
          "condicao" => "pc",
          "condicao_Desc" => "Parcialmente Nublado",
          "temp" => 26
        }
      ]

      Bypass.expect(bypass, "GET", "/api/cptec/v1/clima/capital", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, conditions} = API.get_capitals_weather()
      assert length(conditions) == 2
      assert [%AirportConditions{} | _] = conditions

      first_condition = List.first(conditions)
      assert first_condition.codigo_icao == "SBGR"
      assert first_condition.temp == 28
      assert first_condition.umidade == 74
    end
  end

  describe "get_airport_weather/1" do
    test "successfully fetches weather with valid ICAO code", %{bypass: bypass} do
      response_body = %{
        "codigo_icao" => "SBGR",
        "atualizado_em" => "2021-01-27T15:00:00.974Z",
        "pressao_atmosferica" => "1014",
        "visibilidade" => "9000",
        "vento" => 29,
        "direcao_vento" => 90,
        "umidade" => 74,
        "condicao" => "ps",
        "condicao_Desc" => "Predomínio de Sol",
        "temp" => 28
      }

      Bypass.expect(bypass, "GET", "/api/cptec/v1/clima/aeroporto/SBGR", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, %AirportConditions{} = conditions} = API.get_airport_weather("SBGR")
      assert conditions.codigo_icao == "SBGR"
      assert conditions.temp == 28
    end

    test "normalizes lowercase ICAO code to uppercase", %{bypass: bypass} do
      response_body = %{
        "codigo_icao" => "SBGR",
        "atualizado_em" => "2021-01-27T15:00:00.974Z",
        "temp" => 28
      }

      Bypass.expect(bypass, "GET", "/api/cptec/v1/clima/aeroporto/SBGR", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, %AirportConditions{}} = API.get_airport_weather("sbgr")
    end

    test "returns error for invalid ICAO code format" do
      assert {:error, %{message: "ICAO code must be exactly 4 uppercase letters"}} =
               API.get_airport_weather("SB")

      assert {:error, %{message: "ICAO code must be exactly 4 uppercase letters"}} =
               API.get_airport_weather("SBGR1")

      assert {:error, %{message: "ICAO code must be exactly 4 uppercase letters"}} =
               API.get_airport_weather("1234")
    end

    test "returns error for non-string ICAO code" do
      assert {:error, %{message: "ICAO code must be a string"}} = API.get_airport_weather(1234)
    end
  end

  describe "get_city_forecast/1" do
    test "successfully fetches 1-day forecast", %{bypass: bypass} do
      response_body = %{
        "cidade" => "São Paulo",
        "estado" => "SP",
        "atualizado_em" => "2021-01-27",
        "clima" => [
          %{
            "data" => "2021-01-27",
            "condicao" => "ps",
            "min" => 18,
            "max" => 28,
            "indice_uv" => 11.5,
            "condicao_desc" => "Predomínio de Sol"
          }
        ]
      }

      Bypass.expect(bypass, "GET", "/api/cptec/v1/clima/previsao/244", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, %CityForecast{} = forecast} = API.get_city_forecast(244)
      assert forecast.cidade == "São Paulo"
      assert forecast.estado == "SP"
      assert length(forecast.clima) == 1

      [climate_data] = forecast.clima
      assert %ClimateData{} = climate_data
      assert climate_data.min == 18
      assert climate_data.max == 28
      assert climate_data.indice_uv == 11.5
    end

    test "returns error for non-integer city code" do
      assert {:error, %{message: "City code must be an integer"}} =
               API.get_city_forecast("244")
    end
  end

  describe "get_city_forecast/2" do
    test "successfully fetches multi-day forecast", %{bypass: bypass} do
      response_body = %{
        "cidade" => "São Paulo",
        "estado" => "SP",
        "atualizado_em" => "2021-01-27",
        "clima" => [
          %{
            "data" => "2021-01-27",
            "condicao" => "ps",
            "min" => 18,
            "max" => 28,
            "indice_uv" => 11.5,
            "condicao_desc" => "Predomínio de Sol"
          },
          %{
            "data" => "2021-01-28",
            "condicao" => "pc",
            "min" => 19,
            "max" => 29,
            "indice_uv" => 12.0,
            "condicao_desc" => "Parcialmente Nublado"
          },
          %{
            "data" => "2021-01-29",
            "condicao" => "n",
            "min" => 17,
            "max" => 25,
            "indice_uv" => 8.0,
            "condicao_desc" => "Nublado"
          }
        ]
      }

      Bypass.expect(bypass, "GET", "/api/cptec/v1/clima/previsao/244/3", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, %CityForecast{} = forecast} = API.get_city_forecast(244, 3)
      assert forecast.cidade == "São Paulo"
      assert length(forecast.clima) == 3
    end

    test "returns error when days is less than 1" do
      assert {:error, %{message: "Days parameter must be between 1 and 6"}} =
               API.get_city_forecast(244, 0)
    end

    test "returns error when days is greater than 6" do
      assert {:error, %{message: "Days parameter must be between 1 and 6"}} =
               API.get_city_forecast(244, 7)
    end

    test "returns error when days is not an integer" do
      assert {:error, %{message: "City code and days must be integers"}} =
               API.get_city_forecast(244, "3")
    end

    test "accepts valid days from 1 to 6", %{bypass: bypass} do
      response_body = %{
        "cidade" => "São Paulo",
        "estado" => "SP",
        "atualizado_em" => "2021-01-27",
        "clima" => []
      }

      for days <- 1..6 do
        Bypass.expect(bypass, "GET", "/api/cptec/v1/clima/previsao/244/#{days}", fn conn ->
          conn
          |> Plug.Conn.put_resp_header("content-type", "application/json")
          |> Plug.Conn.resp(200, Jason.encode!(response_body))
        end)

        assert {:ok, %CityForecast{}} = API.get_city_forecast(244, days)
      end
    end
  end

  describe "get_ocean_forecast/1" do
    test "successfully fetches 1-day ocean forecast", %{bypass: bypass} do
      response_body = %{
        "cidade" => "Rio de Janeiro",
        "estado" => "RJ",
        "atualizado_em" => "2021-01-27",
        "ondas" => [
          %{
            "data" => "2021-01-27",
            "ondas_data" => [
              %{
                "vento" => 15.5,
                "direcao_vento" => "S",
                "direcao_vento_desc" => "Sul",
                "altura_onda" => 1.2,
                "direcao_onda" => "SE",
                "direcao_onda_desc" => "Sudeste",
                "agitacao" => "Fraco",
                "hora" => "00h Z"
              }
            ]
          }
        ]
      }

      Bypass.expect(bypass, "GET", "/api/cptec/v1/ondas/241", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, %OceanForecast{} = forecast} = API.get_ocean_forecast(241)
      assert forecast.cidade == "Rio de Janeiro"
      assert forecast.estado == "RJ"
      assert length(forecast.ondas) == 1

      [daily_waves] = forecast.ondas
      assert %DailyWaves{} = daily_waves
      assert daily_waves.data == "2021-01-27"
      assert length(daily_waves.ondas_data) == 1

      [hourly_waves] = daily_waves.ondas_data
      assert %HourlyWaves{} = hourly_waves
      assert hourly_waves.vento == 15.5
      assert hourly_waves.altura_onda == 1.2
    end

    test "returns error for non-integer city code" do
      assert {:error, %{message: "City code must be an integer"}} =
               API.get_ocean_forecast("241")
    end
  end

  describe "get_ocean_forecast/2" do
    test "successfully fetches multi-day ocean forecast", %{bypass: bypass} do
      response_body = %{
        "cidade" => "Rio de Janeiro",
        "estado" => "RJ",
        "atualizado_em" => "2021-01-27",
        "ondas" => [
          %{
            "data" => "2021-01-27",
            "ondas_data" => [
              %{
                "vento" => 15.5,
                "direcao_vento" => "S",
                "direcao_vento_desc" => "Sul",
                "altura_onda" => 1.2,
                "direcao_onda" => "SE",
                "direcao_onda_desc" => "Sudeste",
                "agitacao" => "Fraco",
                "hora" => "00h Z"
              }
            ]
          },
          %{
            "data" => "2021-01-28",
            "ondas_data" => [
              %{
                "vento" => 18.0,
                "direcao_vento" => "S",
                "direcao_vento_desc" => "Sul",
                "altura_onda" => 1.5,
                "direcao_onda" => "SE",
                "direcao_onda_desc" => "Sudeste",
                "agitacao" => "Moderado",
                "hora" => "00h Z"
              }
            ]
          }
        ]
      }

      Bypass.expect(bypass, "GET", "/api/cptec/v1/ondas/241/2", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, %OceanForecast{} = forecast} = API.get_ocean_forecast(241, 2)
      assert forecast.cidade == "Rio de Janeiro"
      assert length(forecast.ondas) == 2
    end

    test "returns error when days is less than 1" do
      assert {:error, %{message: "Days parameter must be between 1 and 6"}} =
               API.get_ocean_forecast(241, 0)
    end

    test "returns error when days is greater than 6" do
      assert {:error, %{message: "Days parameter must be between 1 and 6"}} =
               API.get_ocean_forecast(241, 7)
    end

    test "returns error when days is not an integer" do
      assert {:error, %{message: "City code and days must be integers"}} =
               API.get_ocean_forecast(241, "2")
    end

    test "accepts valid days from 1 to 6", %{bypass: bypass} do
      response_body = %{
        "cidade" => "Rio de Janeiro",
        "estado" => "RJ",
        "atualizado_em" => "2021-01-27",
        "ondas" => []
      }

      for days <- 1..6 do
        Bypass.expect(bypass, "GET", "/api/cptec/v1/ondas/241/#{days}", fn conn ->
          conn
          |> Plug.Conn.put_resp_header("content-type", "application/json")
          |> Plug.Conn.resp(200, Jason.encode!(response_body))
        end)

        assert {:ok, %OceanForecast{}} = API.get_ocean_forecast(241, days)
      end
    end
  end
end
