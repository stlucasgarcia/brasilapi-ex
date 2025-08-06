defmodule Brasilapi.CepTest do
  use ExUnit.Case, async: false

  alias Brasilapi.Cep
  alias Brasilapi.Cep.Address

  setup do
    original_base_url = Application.get_env(:brasilapi, :base_url)

    bypass = Bypass.open()
    base_url = "http://localhost:#{bypass.port}/api"

    Application.put_env(:brasilapi, :base_url, base_url)

    on_exit(fn ->
      if original_base_url do
        Application.put_env(:brasilapi, :base_url, original_base_url)
      else
        Application.delete_env(:brasilapi, :base_url)
      end
    end)

    {:ok, bypass: bypass, base_url: base_url}
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
end
