defmodule Brasilapi.CepTest do
  use ExUnit.Case, async: false

  alias Brasilapi.Cep
  alias Brasilapi.Cep.Address
  alias Brasilapi.BypassHelpers

  setup do
    BypassHelpers.setup_bypass_for_base_url()
  end

  describe "get_by_cep/1" do
    test "delegates to API.get_by_cep/1", %{bypass: bypass} do
      response_body = %{
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

      Bypass.expect(bypass, "GET", "/api/cep/v2/89010025", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, %Address{} = cep_data} = Cep.get_by_cep("89010025")
      assert cep_data.cep == "89010025"
    end

    test "delegates error handling to API.get_by_cep/1", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/cep/v2/00000000", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(404, Jason.encode!(%{"error" => "CEP not found"}))
      end)

      assert {:error, %{status: 404, message: "Not found"}} = Cep.get_by_cep("00000000")
    end
  end

  describe "get_by_cep/2 with version option" do
    test "delegates to API.get_by_cep/2 with v1 option", %{bypass: bypass} do
      response_body = %{
        "cep" => "89010025",
        "state" => "SC",
        "city" => "Blumenau",
        "neighborhood" => "Centro",
        "street" => "Rua Doutor Luiz de Freitas Melro",
        "service" => "open-cep"
      }

      Bypass.expect(bypass, "GET", "/api/cep/v1/89010025", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, %Address{} = cep_data} = Cep.get_by_cep("89010025", version: :v1)
      assert cep_data.cep == "89010025"
      assert cep_data.service == "open-cep"
      assert cep_data.location == nil
    end

    test "delegates to API.get_by_cep/2 with v2 option", %{bypass: bypass} do
      response_body = %{
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

      Bypass.expect(bypass, "GET", "/api/cep/v2/89010025", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, %Address{} = cep_data} = Cep.get_by_cep("89010025", version: :v2)
      assert cep_data.location == %{type: "Point", coordinates: %{}}
    end

    test "defaults to v2 when no version specified", %{bypass: bypass} do
      response_body = %{
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

      Bypass.expect(bypass, "GET", "/api/cep/v2/89010025", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, %Address{} = cep_data} = Cep.get_by_cep("89010025", [])
      assert cep_data.location == %{type: "Point", coordinates: %{}}
    end
  end
end
