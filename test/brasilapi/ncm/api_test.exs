defmodule Brasilapi.Ncm.APITest do
  use ExUnit.Case, async: false

  alias Brasilapi.Ncm.{API, Ncm}
  alias Brasilapi.BypassHelpers

  setup do
    BypassHelpers.setup_bypass_for_base_url()
  end

  describe "get_ncms/0" do
    test "fetches all NCM codes successfully", %{bypass: bypass} do
      response_body = [
        %{
          "codigo" => "3305.10.00",
          "descricao" => "- Xampus",
          "data_inicio" => "2022-04-01",
          "data_fim" => "9999-12-31",
          "tipo_ato" => "Res Camex",
          "numero_ato" => "000272",
          "ano_ato" => "2021"
        },
        %{
          "codigo" => "3305.20.00",
          "descricao" => "- Preparações para ondulação ou alisamento, permanentes, dos cabelos",
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

      assert {:ok, ncms} = API.get_ncms()
      assert is_list(ncms)
      assert length(ncms) == 2

      [ncm1, ncm2] = ncms

      assert %Ncm{} = ncm1
      assert ncm1.codigo == "3305.10.00"
      assert ncm1.descricao == "- Xampus"
      assert ncm1.data_inicio == "2022-04-01"
      assert ncm1.tipo_ato == "Res Camex"

      assert %Ncm{} = ncm2
      assert ncm2.codigo == "3305.20.00"
    end

    test "returns empty list when no NCMs found", %{bypass: bypass} do
      response_body = []

      Bypass.expect(bypass, "GET", "/api/ncm/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, ncms} = API.get_ncms()
      assert ncms == []
    end

    test "returns error on server error", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/ncm/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(500, Jason.encode!(%{"error" => "Internal server error"}))
      end)

      assert {:error, %{status: 500, message: "Server error"}} = API.get_ncms()
    end

    test "returns error on network failure", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %{reason: :econnrefused, message: "Network error"}} = API.get_ncms()
    end
  end

  describe "search_ncms/1" do
    test "searches NCMs with string query", %{bypass: bypass} do
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

      assert {:ok, ncms} = API.search_ncms("xampu")
      assert is_list(ncms)
      assert length(ncms) == 1

      [ncm] = ncms
      assert %Ncm{} = ncm
      assert ncm.codigo == "3305.10.00"
      assert ncm.descricao == "- Xampus"
    end

    test "searches NCMs with partial code", %{bypass: bypass} do
      response_body = [
        %{
          "codigo" => "3305.10.00",
          "descricao" => "- Xampus",
          "data_inicio" => "2022-04-01",
          "data_fim" => "9999-12-31",
          "tipo_ato" => "Res Camex",
          "numero_ato" => "000272",
          "ano_ato" => "2021"
        },
        %{
          "codigo" => "3305.20.00",
          "descricao" => "- Preparações para ondulação",
          "data_inicio" => "2022-04-01",
          "data_fim" => "9999-12-31",
          "tipo_ato" => "Res Camex",
          "numero_ato" => "000272",
          "ano_ato" => "2021"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/ncm/v1", fn conn ->
        assert conn.query_string == "search=3305"

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, ncms} = API.search_ncms("3305")
      assert length(ncms) == 2
    end

    test "returns empty list when no results found", %{bypass: bypass} do
      response_body = []

      Bypass.expect(bypass, "GET", "/api/ncm/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, ncms} = API.search_ncms("nonexistent")
      assert ncms == []
    end

    test "returns error for invalid query type" do
      assert {:error, %{message: "Search query must be a string"}} = API.search_ncms(123)
      assert {:error, %{message: "Search query must be a string"}} = API.search_ncms(nil)
      assert {:error, %{message: "Search query must be a string"}} = API.search_ncms(%{})
    end

    test "returns error on server error", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/ncm/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(500, Jason.encode!(%{"error" => "Server error"}))
      end)

      assert {:error, %{status: 500, message: "Server error"}} = API.search_ncms("test")
    end
  end

  describe "get_ncm_by_code/1" do
    test "fetches NCM by code with string", %{bypass: bypass} do
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

      assert {:ok, ncm} = API.get_ncm_by_code("33051000")
      assert %Ncm{} = ncm
      assert ncm.codigo == "3305.10.00"
      assert ncm.descricao == "- Xampus"
      assert ncm.data_inicio == "2022-04-01"
      assert ncm.data_fim == "9999-12-31"
      assert ncm.tipo_ato == "Res Camex"
      assert ncm.numero_ato == "000272"
      assert ncm.ano_ato == "2021"
    end

    test "fetches NCM by code with formatted string", %{bypass: bypass} do
      response_body = %{
        "codigo" => "3305.10.00",
        "descricao" => "- Xampus",
        "data_inicio" => "2022-04-01",
        "data_fim" => "9999-12-31",
        "tipo_ato" => "Res Camex",
        "numero_ato" => "000272",
        "ano_ato" => "2021"
      }

      Bypass.expect(bypass, "GET", "/api/ncm/v1/3305.10.00", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, ncm} = API.get_ncm_by_code("3305.10.00")
      assert %Ncm{} = ncm
      assert ncm.codigo == "3305.10.00"
    end

    test "fetches NCM by code with integer", %{bypass: bypass} do
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

      assert {:ok, ncm} = API.get_ncm_by_code(33_051_000)
      assert %Ncm{} = ncm
      assert ncm.codigo == "3305.10.00"
    end

    test "returns error for invalid code type" do
      assert {:error, %{message: "Code must be a string or integer"}} =
               API.get_ncm_by_code(nil)

      assert {:error, %{message: "Code must be a string or integer"}} =
               API.get_ncm_by_code(%{})

      assert {:error, %{message: "Code must be a string or integer"}} =
               API.get_ncm_by_code([])
    end

    test "returns error when NCM not found", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/ncm/v1/99999999", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(404, Jason.encode!(%{"error" => "NCM not found"}))
      end)

      assert {:error, %{status: 404, message: "Not found"}} =
               API.get_ncm_by_code("99999999")
    end

    test "returns error on server error", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/ncm/v1/33051000", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(500, Jason.encode!(%{"error" => "Server error"}))
      end)

      assert {:error, %{status: 500, message: "Server error"}} =
               API.get_ncm_by_code("33051000")
    end

    test "returns error on network failure", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %{reason: :econnrefused, message: "Network error"}} =
               API.get_ncm_by_code("33051000")
    end
  end
end
