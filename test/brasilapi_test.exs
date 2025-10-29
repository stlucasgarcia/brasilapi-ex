defmodule BrasilapiTest do
  use ExUnit.Case, async: false
  doctest Brasilapi

  alias Brasilapi.Cep.Address
  alias Brasilapi.Cnpj.Company
  alias Brasilapi.Ddd.Info
  alias Brasilapi.Holidays.Holiday
  alias Brasilapi.BypassHelpers

  setup do
    BypassHelpers.setup_bypass_for_base_url()
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

  describe "get_ddd/1" do
    test "delegates to Ddd.get_by_ddd/1", %{bypass: bypass} do
      response_body = %{
        "state" => "SP",
        "cities" => [
          "EMBU",
          "VÁRZEA PAULISTA",
          "SÃO PAULO"
        ]
      }

      Bypass.expect(bypass, "GET", "/api/ddd/v1/11", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, %Info{} = ddd_info} = Brasilapi.get_ddd(11)
      assert ddd_info.state == "SP"
      assert ddd_info.cities == ["EMBU", "VÁRZEA PAULISTA", "SÃO PAULO"]
    end
  end

  describe "get_holidays/1" do
    test "delegates to Feriados.get_by_year/1", %{bypass: bypass} do
      response_body = [
        %{
          "date" => "2021-01-01",
          "name" => "Confraternização mundial",
          "type" => "national"
        },
        %{
          "date" => "2021-04-21",
          "name" => "Tiradentes",
          "type" => "national"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/feriados/v1/2021", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, holidays} = Brasilapi.get_holidays(2021)
      assert is_list(holidays)
      assert length(holidays) == 2

      [holiday1, holiday2] = holidays
      assert %Holiday{} = holiday1
      assert holiday1.date == "2021-01-01"
      assert holiday1.name == "Confraternização mundial"

      assert %Holiday{} = holiday2
      assert holiday2.date == "2021-04-21"
      assert holiday2.name == "Tiradentes"
    end
  end
end
