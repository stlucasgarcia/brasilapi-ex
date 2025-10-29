defmodule Brasilapi.Fipe.VehicleTest do
  use ExUnit.Case
  doctest Brasilapi.Fipe.Vehicle

  alias Brasilapi.Fipe.Vehicle

  describe "from_map/1" do
    test "creates a Vehicle struct from a map with string keys" do
      map = %{
        "modelo" => "Palio EX 1.0 mpi 2p"
      }

      vehicle = Vehicle.from_map(map)

      assert %Vehicle{
               modelo: "Palio EX 1.0 mpi 2p"
             } = vehicle
    end

    test "returns struct with nil values for missing keys" do
      map = %{}

      vehicle = Vehicle.from_map(map)

      assert %Vehicle{
               modelo: nil
             } = vehicle
    end
  end
end
