defmodule Brasilapi.Ibge.MunicipalityTest do
  use ExUnit.Case
  doctest Brasilapi.Ibge.Municipality

  alias Brasilapi.Ibge.Municipality

  describe "from_map/1" do
    test "creates a Municipality struct from a map with string keys" do
      map = %{
        "nome" => "Tubarão",
        "codigo_ibge" => "421870705"
      }

      municipality = Municipality.from_map(map)

      assert %Municipality{
               nome: "Tubarão",
               codigo_ibge: "421870705"
             } = municipality
    end

    test "returns struct with nil values for missing keys" do
      map = %{}

      municipality = Municipality.from_map(map)

      assert %Municipality{
               nome: nil,
               codigo_ibge: nil
             } = municipality
    end
  end
end
