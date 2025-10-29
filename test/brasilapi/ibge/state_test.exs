defmodule Brasilapi.Ibge.StateTest do
  use ExUnit.Case
  doctest Brasilapi.Ibge.State

  alias Brasilapi.Ibge.{Region, State}

  describe "from_map/1" do
    test "creates a State struct from a map with string keys and nested region" do
      map = %{
        "id" => 35,
        "sigla" => "SP",
        "nome" => "São Paulo",
        "regiao" => %{
          "id" => 3,
          "sigla" => "SE",
          "nome" => "Sudeste"
        }
      }

      state = State.from_map(map)

      assert %State{
               id: 35,
               sigla: "SP",
               nome: "São Paulo",
               regiao: %Region{
                 id: 3,
                 sigla: "SE",
                 nome: "Sudeste"
               }
             } = state
    end

    test "creates a State struct with nil region when region is missing" do
      map = %{
        "id" => 35,
        "sigla" => "SP",
        "nome" => "São Paulo"
      }

      state = State.from_map(map)

      assert %State{
               id: 35,
               sigla: "SP",
               nome: "São Paulo",
               regiao: nil
             } = state
    end

    test "returns struct with nil values for missing keys" do
      map = %{}

      state = State.from_map(map)

      assert %State{
               id: nil,
               sigla: nil,
               nome: nil,
               regiao: nil
             } = state
    end
  end
end
