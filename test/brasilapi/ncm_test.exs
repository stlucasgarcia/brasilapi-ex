defmodule Brasilapi.NcmTest do
  use ExUnit.Case
  doctest Brasilapi.Ncm

  alias Brasilapi.Ncm
  alias Brasilapi.Ncm.Ncm, as: NcmStruct
  alias Brasilapi.BypassHelpers

  setup do
    BypassHelpers.setup_bypass_for_base_url()
  end

  describe "get_ncms/0" do
    test "delegates to API.get_ncms/0", %{bypass: bypass} do
      response_body = [
        %{
          "codigo" => "3305.10.00",
          "descricao" => "- Xampus",
          "data_inicio" => "2022-04-01",
          "data_fim" => "9999-12-31",
          "tipo_ato" => "Res Camex",
          "numero_ato" => "000272",
          "ano_ato" => "2021"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/ncm/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, [ncm]} = Ncm.get_ncms()
      assert %NcmStruct{codigo: "3305.10.00", descricao: "- Xampus"} = ncm
    end
  end

  describe "search/1" do
    test "delegates to API.search/1", %{bypass: bypass} do
      response_body = [
        %{
          "codigo" => "3305.10.00",
          "descricao" => "- Xampus",
          "data_inicio" => "2022-04-01",
          "data_fim" => "9999-12-31",
          "tipo_ato" => "Res Camex",
          "numero_ato" => "000272",
          "ano_ato" => "2021"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/ncm/v1", fn conn ->
        assert conn.query_string == "search=xampu"

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, [ncm]} = Ncm.search_ncms("xampu")
      assert %NcmStruct{codigo: "3305.10.00", descricao: "- Xampus"} = ncm
    end
  end

  describe "get_ncm_by_code/1" do
    test "delegates to API.get_ncm_by_code/1", %{bypass: bypass} do
      response_body = %{
        "codigo" => "3305.10.00",
        "descricao" => "- Xampus",
        "data_inicio" => "2022-04-01",
        "data_fim" => "9999-12-31",
        "tipo_ato" => "Res Camex",
        "numero_ato" => "000272",
        "ano_ato" => "2021"
      }

      Bypass.expect(bypass, "GET", "/api/ncm/v1/33051000", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, ncm} = Ncm.get_ncm_by_code("33051000")
      assert %NcmStruct{codigo: "3305.10.00", descricao: "- Xampus"} = ncm
    end
  end
end
