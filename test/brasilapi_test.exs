defmodule BrasilapiTest do
  use ExUnit.Case, async: false
  doctest Brasilapi

  alias Brasilapi.Cep.Address
  alias Brasilapi.Cnpj.Company

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

  test "module exists and has proper structure" do
    assert is_atom(Brasilapi)
  end

  describe "get_cep/1" do
    test "delegates to Cep.get_by_cep/1", %{bypass: bypass} do
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

      assert {:ok, %Address{} = cep_data} = Brasilapi.get_cep("89010025")
      assert cep_data.cep == "89010025"
    end
  end

  describe "get_cnpj/1" do
    test "delegates to Cnpj.get_by_cnpj/1", %{bypass: bypass} do
      response_body = %{
        "cnpj" => "12345678000195",
        "razao_social" => "ACME INC",
        "nome_fantasia" => "ACME CORPORATION",
        "uf" => "CA",
        "municipio" => "SAMPLE CITY",
        "situacao_cadastral" => 2,
        "descricao_situacao_cadastral" => "ATIVA"
      }

      Bypass.expect(bypass, "GET", "/api/cnpj/v1/12345678000195", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, %Company{} = company} = Brasilapi.get_cnpj("12345678000195")
      assert company.cnpj == "12345678000195"
      assert company.razao_social == "ACME INC"
    end
  end
end
