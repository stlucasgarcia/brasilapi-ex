defmodule Brasilapi.FipeTest do
  use ExUnit.Case
  doctest Brasilapi.Fipe

  alias Brasilapi.Fipe
  alias Brasilapi.Fipe.{Brand, Price, ReferenceTable, Vehicle}
  alias Brasilapi.BypassHelpers

  setup do
    BypassHelpers.setup_bypass_for_base_url()
  end

  describe "get_brands/2" do
    test "delegates to API.get_brands/2", %{bypass: bypass} do
      response_body = [
        %{
          "nome" => "AGRALE",
          "valor" => "102"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/fipe/marcas/v1/carros", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, [brand]} = Fipe.get_brands("carros")
      assert %Brand{nome: "AGRALE", valor: "102"} = brand
    end
  end

  describe "get_price/2" do
    test "delegates to API.get_price/2", %{bypass: bypass} do
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

      assert {:ok, [price]} = Fipe.get_price("001004-9")
      assert %Price{marca: "Fiat", modelo: "Palio EX 1.0 mpi 2p"} = price
    end
  end

  describe "get_reference_tables/0" do
    test "delegates to API.get_reference_tables/0", %{bypass: bypass} do
      response_body = [
        %{
          "codigo" => 271,
          "mes" => "junho/2021 "
        }
      ]

      Bypass.expect(bypass, "GET", "/api/fipe/tabelas/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, [table]} = Fipe.get_reference_tables()
      assert %ReferenceTable{codigo: 271, mes: "junho/2021 "} = table
    end
  end

  describe "get_vehicles/3" do
    test "delegates to API.get_vehicles/3", %{bypass: bypass} do
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

      assert {:ok, [vehicle]} = Fipe.get_vehicles("carros", 21)
      assert %Vehicle{modelo: "Palio EX 1.0 mpi 2p"} = vehicle
    end
  end
end
