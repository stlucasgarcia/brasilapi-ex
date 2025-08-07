defmodule Brasilapi.Exchange.CurrencyTest do
  use ExUnit.Case

  alias Brasilapi.Exchange.Currency

  describe "from_map/1" do
    test "creates Currency struct from valid map" do
      map = %{
        "simbolo" => "USD",
        "nome" => "Dólar dos Estados Unidos",
        "tipo_moeda" => "A"
      }

      result = Currency.from_map(map)

      assert %Currency{
               simbolo: "USD",
               nome: "Dólar dos Estados Unidos",
               tipo_moeda: "A"
             } = result
    end

    test "creates Currency struct with different values" do
      map = %{
        "simbolo" => "EUR",
        "nome" => "Euro",
        "tipo_moeda" => "A"
      }

      result = Currency.from_map(map)

      assert %Currency{
               simbolo: "EUR",
               nome: "Euro",
               tipo_moeda: "A"
             } = result
    end

    test "creates Currency struct with nil values for missing fields" do
      map = %{
        "simbolo" => "GBP"
      }

      result = Currency.from_map(map)

      assert %Currency{
               simbolo: "GBP",
               nome: nil,
               tipo_moeda: nil
             } = result
    end
  end

  describe "Jason.Encoder" do
    test "encodes Currency struct to JSON" do
      currency = %Currency{
        simbolo: "USD",
        nome: "Dólar dos Estados Unidos",
        tipo_moeda: "A"
      }

      json_string = Jason.encode!(currency)
      decoded = Jason.decode!(json_string)

      assert %{
               "simbolo" => "USD",
               "nome" => "Dólar dos Estados Unidos",
               "tipo_moeda" => "A"
             } = decoded
    end
  end
end
