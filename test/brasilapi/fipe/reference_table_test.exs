defmodule Brasilapi.Fipe.ReferenceTableTest do
  use ExUnit.Case
  doctest Brasilapi.Fipe.ReferenceTable

  alias Brasilapi.Fipe.ReferenceTable

  describe "from_map/1" do
    test "creates a ReferenceTable struct from a map with string keys" do
      map = %{
        "codigo" => 271,
        "mes" => "junho/2021 "
      }

      table = ReferenceTable.from_map(map)

      assert %ReferenceTable{
               codigo: 271,
               mes: "junho/2021 "
             } = table
    end

    test "returns struct with nil values for missing keys" do
      map = %{}

      table = ReferenceTable.from_map(map)

      assert %ReferenceTable{
               codigo: nil,
               mes: nil
             } = table
    end
  end
end
