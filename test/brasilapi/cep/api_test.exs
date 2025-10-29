defmodule Brasilapi.Cep.APITest do
  use ExUnit.Case, async: false

  alias Brasilapi.Cep.{API, Address}
  alias Brasilapi.BypassHelpers

  setup do
    BypassHelpers.setup_bypass_for_base_url()
  end

  describe "get_by_cep/1" do
    test "fetches CEP data with string CEP", %{bypass: bypass} do
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

      assert {:ok, %Address{} = cep_data} = API.get_by_cep("89010025")
      assert cep_data.cep == "89010025"
      assert cep_data.state == "SC"
      assert cep_data.city == "Blumenau"
      assert cep_data.neighborhood == "Centro"
      assert cep_data.street == "Rua Doutor Luiz de Freitas Melro"
      assert cep_data.service == "viacep"
      assert cep_data.location == %{type: "Point", coordinates: %{}}
    end

    test "fetches CEP data with integer CEP", %{bypass: bypass} do
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

      assert {:ok, %Address{} = cep_data} = API.get_by_cep(89_010_025)
      assert cep_data.cep == "89010025"
    end

    test "fetches CEP data with formatted CEP (removes non-digits)", %{bypass: bypass} do
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

      assert {:ok, %Address{} = cep_data} = API.get_by_cep("89010-025")
      assert cep_data.cep == "89010025"
    end

    test "pads short CEP with leading zeros", %{bypass: bypass} do
      response_body = %{
        "cep" => "01234567",
        "state" => "SP",
        "city" => "São Paulo",
        "neighborhood" => "Centro",
        "street" => "Rua Exemplo",
        "service" => "viacep",
        "location" => %{
          "type" => "Point",
          "coordinates" => %{}
        }
      }

      Bypass.expect(bypass, "GET", "/api/cep/v2/01234567", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, %Address{} = cep_data} = API.get_by_cep(1_234_567)
      assert cep_data.cep == "01234567"
    end

    test "returns error for invalid CEP format" do
      assert {:error, %{message: "CEP must be exactly 8 digits"}} = API.get_by_cep("123")
      assert {:error, %{message: "CEP must be exactly 8 digits"}} = API.get_by_cep("123456789")
    end

    test "returns error for CEP with non-digit characters after normalization" do
      assert {:error, %{message: "CEP must contain only digits"}} = API.get_by_cep("abcd-efgh")
    end

    test "returns error for invalid CEP type" do
      assert {:error, %{message: "CEP must be a string or integer"}} = API.get_by_cep(nil)
      assert {:error, %{message: "CEP must be a string or integer"}} = API.get_by_cep([])
      assert {:error, %{message: "CEP must be a string or integer"}} = API.get_by_cep(%{})
    end

    test "returns error when API returns 404", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/cep/v2/00000000", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(404, Jason.encode!(%{"error" => "CEP not found"}))
      end)

      assert {:error, %{status: 404, message: "Not found"}} = API.get_by_cep("00000000")
    end

    test "returns error when API returns server error", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/cep/v2/89010025", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(500, Jason.encode!(%{"error" => "Internal server error"}))
      end)

      assert {:error, %{status: 500, message: "Server error"}} = API.get_by_cep("89010025")
    end

    test "returns error when network fails", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %{reason: :econnrefused, message: "Network error"}} =
               API.get_by_cep("89010025")
    end
  end
end
