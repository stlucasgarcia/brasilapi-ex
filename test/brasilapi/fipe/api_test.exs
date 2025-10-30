defmodule Brasilapi.Fipe.APITest do
  use ExUnit.Case, async: false

  alias Brasilapi.Fipe.{API, Brand, Price, ReferenceTable, Vehicle}
  alias Brasilapi.BypassHelpers

  setup do
    BypassHelpers.setup_bypass_for_base_url()
  end

  describe "get_brands/2" do
    test "fetches brands for specific vehicle type", %{bypass: bypass} do
      response_body = [
        %{
          "nome" => "AGRALE",
          "valor" => "102"
        },
        %{
          "nome" => "FIAT",
          "valor" => "21"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/fipe/marcas/v1/carros", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, brands} = API.get_brands("carros")
      assert is_list(brands)
      assert length(brands) == 2

      [brand1, brand2] = brands
      assert %Brand{} = brand1
      assert brand1.nome == "AGRALE"
      assert brand1.valor == "102"

      assert %Brand{} = brand2
      assert brand2.nome == "FIAT"
    end

    test "fetches all brands when vehicle_type is nil", %{bypass: bypass} do
      response_body = [
        %{
          "nome" => "AGRALE",
          "valor" => "102"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/fipe/marcas/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, brands} = API.get_brands(nil)
      assert is_list(brands)
      assert length(brands) == 1
    end

    test "fetches brands with tabela_referencia option", %{bypass: bypass} do
      response_body = [
        %{
          "nome" => "AGRALE",
          "valor" => "102"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/fipe/marcas/v1/carros", fn conn ->
        assert conn.query_string == "tabela_referencia=295"

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, brands} = API.get_brands("carros", tabela_referencia: 295)
      assert is_list(brands)
    end

    test "returns error for invalid vehicle type" do
      assert {:error,
              %{
                message:
                  "Invalid vehicle type: invalid. Valid types are: caminhoes, carros, motos"
              }} =
               API.get_brands("invalid")
    end

    test "returns error for invalid vehicle type parameter type" do
      assert {:error, %{message: "Vehicle type must be a string or nil"}} = API.get_brands(123)
    end

    test "returns error on server error", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/fipe/marcas/v1/carros", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(500, Jason.encode!(%{"error" => "Server error"}))
      end)

      assert {:error, %{status: 500, message: "Server error"}} = API.get_brands("carros")
    end

    test "returns error on network failure", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %{reason: :econnrefused, message: "Network error"}} =
               API.get_brands("carros")
    end
  end

  describe "get_price/2" do
    test "fetches price by FIPE code", %{bypass: bypass} do
      response_body = [
        %{
          "valor" => "R$ 6.022,00",
          "marca" => "Fiat",
          "modelo" => "Palio EX 1.0 mpi 2p",
          "anoModelo" => 1998,
          "combustivel" => "Álcool",
          "codigoFipe" => "001004-9",
          "mesReferencia" => "junho de 2021 ",
          "tipoVeiculo" => 1,
          "siglaCombustivel" => "Á",
          "dataConsulta" => "segunda-feira, 7 de junho de 2021 23:05"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/fipe/preco/v1/001004-9", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, prices} = API.get_price("001004-9")
      assert is_list(prices)
      assert length(prices) == 1

      [price] = prices
      assert %Price{} = price
      assert price.valor == "R$ 6.022,00"
      assert price.marca == "Fiat"
      assert price.modelo == "Palio EX 1.0 mpi 2p"
      assert price.ano_modelo == 1998
      assert price.combustivel == "Álcool"
      assert price.codigo_fipe == "001004-9"
    end

    test "fetches price with tabela_referencia option", %{bypass: bypass} do
      response_body = [
        %{
          "valor" => "R$ 6.022,00",
          "marca" => "Fiat",
          "modelo" => "Palio EX 1.0 mpi 2p",
          "anoModelo" => 1998,
          "combustivel" => "Álcool",
          "codigoFipe" => "001004-9",
          "mesReferencia" => "junho de 2021 ",
          "tipoVeiculo" => 1,
          "siglaCombustivel" => "Á",
          "dataConsulta" => "segunda-feira, 7 de junho de 2021 23:05"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/fipe/preco/v1/001004-9", fn conn ->
        assert conn.query_string == "tabela_referencia=295"

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, prices} = API.get_price("001004-9", tabela_referencia: 295)
      assert is_list(prices)
    end

    test "returns error for invalid FIPE code format" do
      assert {:error,
              %{message: "Invalid FIPE code format. Must be in format XXXXXX-X (e.g., 001004-9)"}} =
               API.get_price("invalid")

      assert {:error,
              %{message: "Invalid FIPE code format. Must be in format XXXXXX-X (e.g., 001004-9)"}} =
               API.get_price("123456")

      assert {:error,
              %{message: "Invalid FIPE code format. Must be in format XXXXXX-X (e.g., 001004-9)"}} =
               API.get_price("1234567-8")
    end

    test "returns error for invalid parameter type" do
      assert {:error, %{message: "FIPE code must be a string"}} = API.get_price(123)
      assert {:error, %{message: "FIPE code must be a string"}} = API.get_price(nil)
    end

    test "returns error on server error", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/fipe/preco/v1/001004-9", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(500, Jason.encode!(%{"error" => "Server error"}))
      end)

      assert {:error, %{status: 500, message: "Server error"}} = API.get_price("001004-9")
    end

    test "returns error on network failure", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %{reason: :econnrefused, message: "Network error"}} =
               API.get_price("001004-9")
    end
  end

  describe "get_reference_tables/0" do
    test "fetches all reference tables", %{bypass: bypass} do
      response_body = [
        %{
          "codigo" => 271,
          "mes" => "junho/2021 "
        },
        %{
          "codigo" => 270,
          "mes" => "maio/2021 "
        }
      ]

      Bypass.expect(bypass, "GET", "/api/fipe/tabelas/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, tables} = API.get_reference_tables()
      assert is_list(tables)
      assert length(tables) == 2

      [table1, table2] = tables
      assert %ReferenceTable{} = table1
      assert table1.codigo == 271
      assert table1.mes == "junho/2021 "

      assert %ReferenceTable{} = table2
      assert table2.codigo == 270
    end

    test "returns empty list when no tables found", %{bypass: bypass} do
      response_body = []

      Bypass.expect(bypass, "GET", "/api/fipe/tabelas/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, tables} = API.get_reference_tables()
      assert tables == []
    end

    test "returns error on server error", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/fipe/tabelas/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(500, Jason.encode!(%{"error" => "Server error"}))
      end)

      assert {:error, %{status: 500, message: "Server error"}} = API.get_reference_tables()
    end

    test "returns error on network failure", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %{reason: :econnrefused, message: "Network error"}} =
               API.get_reference_tables()
    end
  end

  describe "get_vehicles/3" do
    test "fetches vehicles by vehicle type and brand code with integer", %{bypass: bypass} do
      response_body = [
        %{
          "modelo" => "Palio EX 1.0 mpi 2p"
        },
        %{
          "modelo" => "Uno Mille 1.0"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/fipe/veiculos/v1/carros/21", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, vehicles} = API.get_vehicles("carros", 21)
      assert is_list(vehicles)
      assert length(vehicles) == 2

      [vehicle1, vehicle2] = vehicles
      assert %Vehicle{} = vehicle1
      assert vehicle1.modelo == "Palio EX 1.0 mpi 2p"

      assert %Vehicle{} = vehicle2
      assert vehicle2.modelo == "Uno Mille 1.0"
    end

    test "fetches vehicles with string brand code", %{bypass: bypass} do
      response_body = [
        %{
          "modelo" => "Palio EX 1.0 mpi 2p"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/fipe/veiculos/v1/carros/21", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, vehicles} = API.get_vehicles("carros", "21")
      assert is_list(vehicles)
      assert length(vehicles) == 1
    end

    test "fetches vehicles with tabela_referencia option", %{bypass: bypass} do
      response_body = [
        %{
          "modelo" => "Palio EX 1.0 mpi 2p"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/fipe/veiculos/v1/carros/21", fn conn ->
        assert conn.query_string == "tabela_referencia=295"

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, vehicles} = API.get_vehicles("carros", 21, tabela_referencia: 295)
      assert is_list(vehicles)
    end

    test "returns empty list when no vehicles found", %{bypass: bypass} do
      response_body = []

      Bypass.expect(bypass, "GET", "/api/fipe/veiculos/v1/carros/21", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, vehicles} = API.get_vehicles("carros", 21)
      assert vehicles == []
    end

    test "returns error for invalid vehicle type" do
      assert {:error,
              %{
                message:
                  "Invalid vehicle type: invalid. Valid types are: caminhoes, carros, motos"
              }} =
               API.get_vehicles("invalid", 21)
    end

    test "returns error for invalid parameter types" do
      assert {:error,
              %{
                message:
                  "Vehicle type must be a string and brand code must be a string or integer"
              }} = API.get_vehicles(123, 21)

      assert {:error,
              %{
                message:
                  "Vehicle type must be a string and brand code must be a string or integer"
              }} = API.get_vehicles("carros", nil)
    end

    test "returns error on server error", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/fipe/veiculos/v1/carros/21", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(500, Jason.encode!(%{"error" => "Server error"}))
      end)

      assert {:error, %{status: 500, message: "Server error"}} = API.get_vehicles("carros", 21)
    end

    test "returns error on network failure", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %{reason: :econnrefused, message: "Network error"}} =
               API.get_vehicles("carros", 21)
    end
  end
end
