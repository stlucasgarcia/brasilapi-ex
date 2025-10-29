defmodule Brasilapi.IbgeTest do
  use ExUnit.Case
  doctest Brasilapi.Ibge

  alias Brasilapi.Ibge
  alias Brasilapi.Ibge.{Municipality, Region, State}
  alias Brasilapi.BypassHelpers

  setup do
    BypassHelpers.setup_bypass_for_base_url()
  end

  describe "get_states/0" do
    test "delegates to API.get_states/0", %{bypass: bypass} do
      response_body = [
        %{
          "id" => 35,
          "sigla" => "SP",
          "nome" => "São Paulo",
          "regiao" => %{
            "id" => 3,
            "sigla" => "SE",
            "nome" => "Sudeste"
          }
        }
      ]

      Bypass.expect(bypass, "GET", "/api/ibge/uf/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, [state]} = Ibge.get_states()
      assert %State{sigla: "SP", nome: "São Paulo"} = state
    end
  end

  describe "get_state/1" do
    test "delegates to API.get_state/1", %{bypass: bypass} do
      response_body = %{
        "id" => 35,
        "sigla" => "SP",
        "nome" => "São Paulo",
        "regiao" => %{
          "id" => 3,
          "sigla" => "SE",
          "nome" => "Sudeste"
        }
      }

      Bypass.expect(bypass, "GET", "/api/ibge/uf/v1/SP", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, state} = Ibge.get_state("SP")
      assert %State{sigla: "SP", nome: "São Paulo"} = state
      assert %Region{sigla: "SE", nome: "Sudeste"} = state.regiao
    end
  end

  describe "get_municipalities/2" do
    test "delegates to API.get_municipalities/2 without options", %{bypass: bypass} do
      response_body = [
        %{
          "nome" => "Tubarão",
          "codigo_ibge" => "421870705"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/ibge/municipios/v1/SC", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, [municipality]} = Ibge.get_municipalities("SC")
      assert %Municipality{nome: "Tubarão", codigo_ibge: "421870705"} = municipality
    end

    test "delegates to API.get_municipalities/2 with options", %{bypass: bypass} do
      response_body = [
        %{
          "nome" => "São Paulo",
          "codigo_ibge" => "3550308"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/ibge/municipios/v1/SP", fn conn ->
        assert conn.query_string == "providers=gov"

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, [municipality]} = Ibge.get_municipalities("SP", providers: ["gov"])
      assert %Municipality{nome: "São Paulo"} = municipality
    end
  end
end
