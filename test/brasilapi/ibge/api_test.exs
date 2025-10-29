defmodule Brasilapi.Ibge.APITest do
  use ExUnit.Case, async: false

  alias Brasilapi.Ibge.{API, Municipality, Region, State}
  alias Brasilapi.BypassHelpers

  setup do
    BypassHelpers.setup_bypass_for_base_url()
  end

  describe "get_states/0" do
    test "fetches all states successfully", %{bypass: bypass} do
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
        },
        %{
          "id" => 43,
          "sigla" => "RS",
          "nome" => "Rio Grande do Sul",
          "regiao" => %{
            "id" => 4,
            "sigla" => "S",
            "nome" => "Sul"
          }
        }
      ]

      Bypass.expect(bypass, "GET", "/api/ibge/uf/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, states} = API.get_states()
      assert is_list(states)
      assert length(states) == 2

      [state1, state2] = states

      assert %State{} = state1
      assert state1.id == 35
      assert state1.sigla == "SP"
      assert state1.nome == "São Paulo"
      assert %Region{} = state1.regiao
      assert state1.regiao.sigla == "SE"

      assert %State{} = state2
      assert state2.id == 43
      assert state2.sigla == "RS"
    end

    test "returns empty list when no states found", %{bypass: bypass} do
      response_body = []

      Bypass.expect(bypass, "GET", "/api/ibge/uf/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, states} = API.get_states()
      assert states == []
    end

    test "returns error on server error", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/ibge/uf/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(500, Jason.encode!(%{"error" => "Internal server error"}))
      end)

      assert {:error, %{status: 500, message: "Server error"}} = API.get_states()
    end

    test "returns error on network failure", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %{reason: :econnrefused, message: "Network error"}} = API.get_states()
    end
  end

  describe "get_state/1" do
    test "fetches state by string code (sigla)", %{bypass: bypass} do
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

      assert {:ok, state} = API.get_state("SP")
      assert %State{} = state
      assert state.id == 35
      assert state.sigla == "SP"
      assert state.nome == "São Paulo"
      assert %Region{} = state.regiao
      assert state.regiao.id == 3
      assert state.regiao.sigla == "SE"
      assert state.regiao.nome == "Sudeste"
    end

    test "fetches state by integer code", %{bypass: bypass} do
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

      Bypass.expect(bypass, "GET", "/api/ibge/uf/v1/35", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, state} = API.get_state(35)
      assert %State{} = state
      assert state.id == 35
      assert state.sigla == "SP"
    end

    test "returns error for invalid code type" do
      assert {:error, %{message: "Code must be a string or integer"}} = API.get_state(nil)
      assert {:error, %{message: "Code must be a string or integer"}} = API.get_state(%{})
      assert {:error, %{message: "Code must be a string or integer"}} = API.get_state([])
    end

    test "returns error when state not found", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/ibge/uf/v1/XX", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(404, Jason.encode!(%{"error" => "State not found"}))
      end)

      assert {:error, %{status: 404, message: "Not found"}} = API.get_state("XX")
    end

    test "returns error on server error", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/ibge/uf/v1/SP", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(500, Jason.encode!(%{"error" => "Server error"}))
      end)

      assert {:error, %{status: 500, message: "Server error"}} = API.get_state("SP")
    end

    test "returns error on network failure", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %{reason: :econnrefused, message: "Network error"}} = API.get_state("SP")
    end
  end

  describe "get_municipalities/2" do
    test "fetches municipalities without providers", %{bypass: bypass} do
      response_body = [
        %{
          "nome" => "Tubarão",
          "codigo_ibge" => "421870705"
        },
        %{
          "nome" => "Tunápolis",
          "codigo_ibge" => "421875605"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/ibge/municipios/v1/SC", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, municipalities} = API.get_municipalities("SC")
      assert is_list(municipalities)
      assert length(municipalities) == 2

      [mun1, mun2] = municipalities

      assert %Municipality{} = mun1
      assert mun1.nome == "Tubarão"
      assert mun1.codigo_ibge == "421870705"

      assert %Municipality{} = mun2
      assert mun2.nome == "Tunápolis"
      assert mun2.codigo_ibge == "421875605"
    end

    test "fetches municipalities with providers", %{bypass: bypass} do
      response_body = [
        %{
          "nome" => "São Paulo",
          "codigo_ibge" => "3550308"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/ibge/municipios/v1/SP", fn conn ->
        assert conn.query_string == "providers=gov%2Cwikipedia"

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, municipalities} = API.get_municipalities("SP", providers: ["gov", "wikipedia"])
      assert is_list(municipalities)
      assert length(municipalities) == 1

      [mun] = municipalities
      assert %Municipality{} = mun
      assert mun.nome == "São Paulo"
    end

    test "returns empty list when no municipalities found", %{bypass: bypass} do
      response_body = []

      Bypass.expect(bypass, "GET", "/api/ibge/municipios/v1/SC", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, municipalities} = API.get_municipalities("SC")
      assert municipalities == []
    end

    test "returns error for invalid providers" do
      assert {:error,
              %{
                message:
                  "Invalid providers: invalid-provider. Valid providers are: dados-abertos-br, gov, wikipedia"
              }} = API.get_municipalities("SP", providers: ["invalid-provider"])
    end

    test "returns error for invalid providers type" do
      assert {:error, %{message: "Providers must be a list of strings"}} =
               API.get_municipalities("SP", providers: "not-a-list")
    end

    test "returns error for invalid UF type" do
      assert {:error, %{message: "UF must be a string"}} = API.get_municipalities(123)
      assert {:error, %{message: "UF must be a string"}} = API.get_municipalities(nil)
    end

    test "returns error when state not found", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/ibge/municipios/v1/XX", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(404, Jason.encode!(%{"error" => "State not found"}))
      end)

      assert {:error, %{status: 404, message: "Not found"}} = API.get_municipalities("XX")
    end

    test "returns error on server error", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/ibge/municipios/v1/SP", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(500, Jason.encode!(%{"error" => "Server error"}))
      end)

      assert {:error, %{status: 500, message: "Server error"}} = API.get_municipalities("SP")
    end

    test "returns error on network failure", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %{reason: :econnrefused, message: "Network error"}} =
               API.get_municipalities("SP")
    end
  end
end
