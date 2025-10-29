defmodule Brasilapi.Fipe.BrandTest do
  use ExUnit.Case
  doctest Brasilapi.Fipe.Brand

  alias Brasilapi.Fipe.Brand

  describe "from_map/1" do
    test "creates a Brand struct from a map with string keys" do
      map = %{
        "nome" => "AGRALE",
        "valor" => "102"
      }

      brand = Brand.from_map(map)

      assert %Brand{
               nome: "AGRALE",
               valor: "102"
             } = brand
    end

    test "returns struct with nil values for missing keys" do
      map = %{}

      brand = Brand.from_map(map)

      assert %Brand{
               nome: nil,
               valor: nil
             } = brand
    end
  end
end
