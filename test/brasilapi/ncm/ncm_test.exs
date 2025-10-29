defmodule Brasilapi.Ncm.NcmTest do
  use ExUnit.Case
  doctest Brasilapi.Ncm.Ncm

  alias Brasilapi.Ncm.Ncm

  describe "from_map/1" do
    test "creates Ncm struct from complete map with string keys" do
      map = %{
        "codigo" => "3305.10.00",
        "descricao" => "- Xampus",
        "data_inicio" => "2022-04-01",
        "data_fim" => "9999-12-31",
        "tipo_ato" => "Res Camex",
        "numero_ato" => "000272",
        "ano_ato" => "2021"
      }

      result = Ncm.from_map(map)

      assert %Ncm{
               codigo: "3305.10.00",
               descricao: "- Xampus",
               data_inicio: "2022-04-01",
               data_fim: "9999-12-31",
               tipo_ato: "Res Camex",
               numero_ato: "000272",
               ano_ato: "2021"
             } = result
    end

    test "creates Ncm struct from empty map" do
      result = Ncm.from_map(%{})

      assert %Ncm{
               codigo: nil,
               descricao: nil,
               data_inicio: nil,
               data_fim: nil,
               tipo_ato: nil,
               numero_ato: nil,
               ano_ato: nil
             } = result
    end

    test "creates Ncm struct with nil values" do
      map = %{
        "codigo" => nil,
        "descricao" => nil,
        "data_inicio" => nil,
        "data_fim" => nil,
        "tipo_ato" => nil,
        "numero_ato" => nil,
        "ano_ato" => nil
      }

      result = Ncm.from_map(map)

      assert %Ncm{
               codigo: nil,
               descricao: nil,
               data_inicio: nil,
               data_fim: nil,
               tipo_ato: nil,
               numero_ato: nil,
               ano_ato: nil
             } = result
    end
  end
end
