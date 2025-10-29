defmodule Brasilapi.Cnpj.APITest do
  use ExUnit.Case, async: false

  alias Brasilapi.Cnpj.{API, Company}
  alias Brasilapi.BypassHelpers

  setup do
    BypassHelpers.setup_bypass_for_base_url()
  end

  describe "get_by_cnpj/1" do
    test "returns company on successful response", %{bypass: bypass} do
      expected_response = %{
        "uf" => "SP",
        "cep" => "12345678",
        "qsa" => [%{"nome_socio" => "John Doe"}],
        "cnpj" => "12345678000195",
        "pais" => nil,
        "email" => nil,
        "porte" => "DEMAIS",
        "bairro" => "CENTRO",
        "numero" => "123",
        "ddd_fax" => "",
        "municipio" => "SAMPLE CITY",
        "logradouro" => "MAIN STREET 123",
        "cnae_fiscal" => 6_201_500,
        "codigo_pais" => nil,
        "complemento" => "SUITE 100",
        "codigo_porte" => 5,
        "razao_social" => "ACME INC",
        "nome_fantasia" => "ACME CORPORATION",
        "capital_social" => 100_000,
        "ddd_telefone_1" => "1155555555",
        "ddd_telefone_2" => "",
        "opcao_pelo_mei" => nil,
        "descricao_porte" => "",
        "codigo_municipio" => 1234,
        "cnaes_secundarios" => [%{"codigo" => 123, "descricao" => "Sample Activity"}],
        "natureza_juridica" => "Sociedade Empresária Limitada",
        "regime_tributario" => [%{"dt_opcao_mei" => "2020-01-01"}],
        "situacao_especial" => "",
        "opcao_pelo_simples" => nil,
        "situacao_cadastral" => 2,
        "data_opcao_pelo_mei" => nil,
        "data_exclusao_do_mei" => nil,
        "cnae_fiscal_descricao" => "Desenvolvimento de programas de computador sob encomenda",
        "codigo_municipio_ibge" => 1_234_567,
        "data_inicio_atividade" => "2020-01-15",
        "data_situacao_especial" => nil,
        "data_opcao_pelo_simples" => nil,
        "data_situacao_cadastral" => "2020-01-15",
        "nome_cidade_no_exterior" => "",
        "codigo_natureza_juridica" => 2062,
        "data_exclusao_do_simples" => nil,
        "motivo_situacao_cadastral" => 0,
        "ente_federativo_responsavel" => "",
        "identificador_matriz_filial" => 1,
        "qualificacao_do_responsavel" => 16,
        "descricao_situacao_cadastral" => "ATIVA",
        "descricao_tipo_de_logradouro" => "RUA",
        "descricao_motivo_situacao_cadastral" => "SEM MOTIVO",
        "descricao_identificador_matriz_filial" => "MATRIZ"
      }

      Bypass.expect(bypass, "GET", "/api/cnpj/v1/12345678000195", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, company} = API.get_by_cnpj("12345678000195")

      assert %Company{
               cnpj: "12345678000195",
               razao_social: "ACME INC",
               nome_fantasia: "ACME CORPORATION",
               uf: "SP",
               municipio: "SAMPLE CITY",
               situacao_cadastral: 2,
               descricao_situacao_cadastral: "ATIVA"
             } = company
    end

    test "returns error on 404 response", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/cnpj/v1/00000000000000", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(404, Jason.encode!(%{"error" => "CNPJ not found"}))
      end)

      assert {:error, %{status: 404, message: "Not found"}} = API.get_by_cnpj("00000000000000")
    end

    test "returns error on non-200 response", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/cnpj/v1/12345678000195", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(500, Jason.encode!(%{"error" => "Internal server error"}))
      end)

      assert {:error, %{status: 500, message: "Server error"}} = API.get_by_cnpj("12345678000195")
    end

    test "returns error on network failure", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %{reason: :econnrefused, message: "Network error"}} =
               API.get_by_cnpj("12345678000195")
    end

    test "accepts integer CNPJ", %{bypass: bypass} do
      expected_response = %{
        "cnpj" => "12345678000195",
        "razao_social" => "ACME INC"
      }

      Bypass.expect(bypass, "GET", "/api/cnpj/v1/12345678000195", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, company} = API.get_by_cnpj(12_345_678_000_195)

      assert %Company{
               cnpj: "12345678000195",
               razao_social: "ACME INC"
             } = company
    end

    test "sanitizes CNPJ with formatting characters", %{bypass: bypass} do
      expected_response = %{
        "cnpj" => "12345678000195",
        "razao_social" => "ACME INC"
      }

      Bypass.expect(bypass, "GET", "/api/cnpj/v1/12345678000195", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      # Test with formatted CNPJ
      assert {:ok, company} = API.get_by_cnpj("12.345.678/0001-95")

      assert %Company{
               cnpj: "12345678000195",
               razao_social: "ACME INC"
             } = company
    end

    test "accepts exact 14 digit CNPJ", %{bypass: bypass} do
      expected_response = %{
        "cnpj" => "11000000000197",
        "razao_social" => "TEST COMPANY"
      }

      Bypass.expect(bypass, "GET", "/api/cnpj/v1/11000000000197", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      # Test with exact 14 digit CNPJ
      assert {:ok, company} = API.get_by_cnpj("11000000000197")

      assert %Company{
               cnpj: "11000000000197",
               razao_social: "TEST COMPANY"
             } = company
    end

    test "returns error for invalid CNPJ format" do
      # Test with too short CNPJ (after sanitization)
      assert {:error, %{message: "Invalid CNPJ format. Must be 14 digits."}} =
               API.get_by_cnpj("123")

      # Test with too long CNPJ (after sanitization)
      assert {:error, %{message: "Invalid CNPJ format. Must be 14 digits."}} =
               API.get_by_cnpj("123456789012345")

      # Test with non-numeric characters that can't be sanitized
      assert {:error, %{message: "Invalid CNPJ format. Must be 14 digits."}} =
               API.get_by_cnpj("abcd1234567890")
    end

    test "returns error for invalid CNPJ type" do
      assert {:error, %{message: "CNPJ must be a string or integer"}} = API.get_by_cnpj(nil)
      assert {:error, %{message: "CNPJ must be a string or integer"}} = API.get_by_cnpj(%{})
      assert {:error, %{message: "CNPJ must be a string or integer"}} = API.get_by_cnpj([])
    end
  end
end
