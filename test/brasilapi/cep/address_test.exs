defmodule Brasilapi.Cep.AddressTest do
  use ExUnit.Case
  doctest Brasilapi.Cep.Address

  alias Brasilapi.Cep.Address

  describe "from_map/1" do
    test "creates Address struct from complete map" do
      map = %{
        "cep" => "89010025",
        "state" => "SC",
        "city" => "Blumenau",
        "neighborhood" => "Centro",
        "street" => "Rua Doutor Luiz de Freitas Melro",
        "service" => "viacep",
        "location" => %{
          "type" => "Point",
          "coordinates" => %{"lat" => -26.9166, "lng" => -49.0713}
        }
      }

      result = Address.from_map(map)

      assert %Address{
               cep: "89010025",
               state: "SC",
               city: "Blumenau",
               neighborhood: "Centro",
               street: "Rua Doutor Luiz de Freitas Melro",
               service: "viacep",
               location: %{
                 type: "Point",
                 coordinates: %{"lat" => -26.9166, "lng" => -49.0713}
               }
             } = result
    end

    test "creates Address struct from map with empty location coordinates" do
      map = %{
        "cep" => "89010025",
        "state" => "SC",
        "city" => "Blumenau",
        "neighborhood" => "Centro",
        "street" => "Rua Doutor Luiz de Freitas Melro",
        "service" => "viacep",
        "location" => %{
          "type" => "Point",
          "coordinates" => %{}
        }
      }

      result = Address.from_map(map)

      assert %Address{
               cep: "89010025",
               state: "SC",
               city: "Blumenau",
               neighborhood: "Centro",
               street: "Rua Doutor Luiz de Freitas Melro",
               service: "viacep",
               location: %{
                 type: "Point",
                 coordinates: %{}
               }
             } = result
    end

    test "creates Address struct from map without location" do
      map = %{
        "cep" => "89010025",
        "state" => "SC",
        "city" => "Blumenau",
        "neighborhood" => "Centro",
        "street" => "Rua Doutor Luiz de Freitas Melro",
        "service" => "viacep"
      }

      result = Address.from_map(map)

      assert %Address{
               cep: "89010025",
               state: "SC",
               city: "Blumenau",
               neighborhood: "Centro",
               street: "Rua Doutor Luiz de Freitas Melro",
               service: "viacep",
               location: nil
             } = result
    end

    test "creates Address struct from map with nil location" do
      map = %{
        "cep" => "89010025",
        "state" => "SC",
        "city" => "Blumenau",
        "neighborhood" => "Centro",
        "street" => "Rua Doutor Luiz de Freitas Melro",
        "service" => "viacep",
        "location" => nil
      }

      result = Address.from_map(map)

      assert %Address{
               cep: "89010025",
               state: "SC",
               city: "Blumenau",
               neighborhood: "Centro",
               street: "Rua Doutor Luiz de Freitas Melro",
               service: "viacep",
               location: nil
             } = result
    end

    test "creates Address struct from map with invalid location" do
      map = %{
        "cep" => "89010025",
        "state" => "SC",
        "city" => "Blumenau",
        "neighborhood" => "Centro",
        "street" => "Rua Doutor Luiz de Freitas Melro",
        "service" => "viacep",
        "location" => "invalid"
      }

      result = Address.from_map(map)

      assert %Address{
               cep: "89010025",
               state: "SC",
               city: "Blumenau",
               neighborhood: "Centro",
               street: "Rua Doutor Luiz de Freitas Melro",
               service: "viacep",
               location: nil
             } = result
    end

    test "creates Address struct from empty map" do
      result = Address.from_map(%{})

      assert %Address{
               cep: nil,
               state: nil,
               city: nil,
               neighborhood: nil,
               street: nil,
               service: nil,
               location: nil
             } = result
    end
  end
end
