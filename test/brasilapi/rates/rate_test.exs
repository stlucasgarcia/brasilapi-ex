defmodule Brasilapi.Rates.RateTest do
  use ExUnit.Case

  alias Brasilapi.Rates.Rate

  describe "from_map/1" do
    test "creates Rate struct from valid map" do
      map = %{
        "nome" => "CDI",
        "valor" => 14.9
      }

      result = Rate.from_map(map)

      assert %Rate{
               nome: "CDI",
               valor: 14.9
             } = result
    end

    test "creates Rate struct with different values" do
      map = %{
        "nome" => "SELIC",
        "valor" => 15
      }

      result = Rate.from_map(map)

      assert %Rate{
               nome: "SELIC",
               valor: 15
             } = result
    end
  end

  describe "Jason.Encoder" do
    test "encodes Rate struct to JSON" do
      rate = %Rate{
        nome: "CDI",
        valor: 14.9
      }

      json_string = Jason.encode!(rate)
      decoded = Jason.decode!(json_string)

      assert %{
               "nome" => "CDI",
               "valor" => 14.9
             } = decoded
    end
  end
end
