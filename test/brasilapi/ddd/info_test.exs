defmodule Brasilapi.Ddd.InfoTest do
  use ExUnit.Case
  doctest Brasilapi.Ddd.Info

  alias Brasilapi.Ddd.Info

  describe "from_map/1" do
    test "creates Info struct from complete map" do
      map = %{
        "state" => "SP",
        "cities" => [
          "EMBU",
          "VÁRZEA PAULISTA",
          "VARGEM GRANDE PAULISTA",
          "SÃO PAULO"
        ]
      }

      result = Info.from_map(map)

      assert %Info{
               state: "SP",
               cities: [
                 "EMBU",
                 "VÁRZEA PAULISTA",
                 "VARGEM GRANDE PAULISTA",
                 "SÃO PAULO"
               ]
             } = result
    end

    test "creates Info struct from map with empty cities list" do
      map = %{
        "state" => "SP",
        "cities" => []
      }

      result = Info.from_map(map)

      assert %Info{
               state: "SP",
               cities: []
             } = result
    end

    test "creates Info struct from map without cities field" do
      map = %{
        "state" => "SP"
      }

      result = Info.from_map(map)

      assert %Info{
               state: "SP",
               cities: []
             } = result
    end

    test "creates Info struct from map without state field" do
      map = %{
        "cities" => ["SÃO PAULO", "CAMPINAS"]
      }

      result = Info.from_map(map)

      assert %Info{
               state: nil,
               cities: ["SÃO PAULO", "CAMPINAS"]
             } = result
    end

    test "creates Info struct from empty map" do
      result = Info.from_map(%{})

      assert %Info{
               state: nil,
               cities: []
             } = result
    end

    test "creates Info struct with empty cities's field" do
      map = %{
        "state" => "RJ",
        "cities" => []
      }

      result = Info.from_map(map)

      assert %Info{
               state: "RJ",
               cities: []
             } = result
    end
  end
end
