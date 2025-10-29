defmodule Brasilapi.Ibge.RegionTest do
  use ExUnit.Case
  doctest Brasilapi.Ibge.Region

  alias Brasilapi.Ibge.Region

  describe "from_map/1" do
    test "creates a Region struct from a map with string keys" do
      map = %{
        "id" => 3,
        "sigla" => "SE",
        "nome" => "Sudeste"
      }

      region = Region.from_map(map)

      assert %Region{
               id: 3,
               sigla: "SE",
               nome: "Sudeste"
             } = region
    end

    test "returns struct with nil values for missing keys" do
      map = %{}

      region = Region.from_map(map)

      assert %Region{
               id: nil,
               sigla: nil,
               nome: nil
             } = region
    end
  end
end
