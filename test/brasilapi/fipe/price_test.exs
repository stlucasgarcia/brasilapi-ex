defmodule Brasilapi.Fipe.PriceTest do
  use ExUnit.Case
  doctest Brasilapi.Fipe.Price

  alias Brasilapi.Fipe.Price

  describe "from_map/1" do
    test "creates a Price struct from a map with string keys" do
      map = %{
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

      price = Price.from_map(map)

      assert %Price{
               valor: "R$ 6.022,00",
               marca: "Fiat",
               modelo: "Palio EX 1.0 mpi 2p",
               ano_modelo: 1998,
               combustivel: "Álcool",
               codigo_fipe: "001004-9",
               mes_referencia: "junho de 2021 ",
               tipo_veiculo: 1,
               sigla_combustivel: "Á",
               data_consulta: "segunda-feira, 7 de junho de 2021 23:05"
             } = price
    end

    test "returns struct with nil values for missing keys" do
      map = %{}

      price = Price.from_map(map)

      assert %Price{
               valor: nil,
               marca: nil,
               modelo: nil,
               ano_modelo: nil,
               combustivel: nil,
               codigo_fipe: nil,
               mes_referencia: nil,
               tipo_veiculo: nil,
               sigla_combustivel: nil,
               data_consulta: nil
             } = price
    end
  end
end
