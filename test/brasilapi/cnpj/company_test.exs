defmodule Brasilapi.Cnpj.CompanyTest do
  use ExUnit.Case, async: true

  alias Brasilapi.Cnpj.Company

  describe "from_map/1" do
    test "converts a complete map to a Company struct" do
      data = %{
        "uf" => "SP",
        "cep" => "12345678",
        "qsa" => [%{"nome_socio" => "John Doe", "qualificacao_socio" => "Sócio"}],
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

      company = Company.from_map(data)

      assert %Company{
               uf: "SP",
               cep: "12345678",
               qsa: [%{"nome_socio" => "John Doe", "qualificacao_socio" => "Sócio"}],
               cnpj: "12345678000195",
               pais: nil,
               email: nil,
               porte: "DEMAIS",
               bairro: "CENTRO",
               numero: "123",
               ddd_fax: "",
               municipio: "SAMPLE CITY",
               logradouro: "MAIN STREET 123",
               cnae_fiscal: 6_201_500,
               codigo_pais: nil,
               complemento: "SUITE 100",
               codigo_porte: 5,
               razao_social: "ACME INC",
               nome_fantasia: "ACME CORPORATION",
               capital_social: 100_000,
               ddd_telefone_1: "1155555555",
               ddd_telefone_2: "",
               opcao_pelo_mei: nil,
               descricao_porte: "",
               codigo_municipio: 1234,
               cnaes_secundarios: [%{"codigo" => 123, "descricao" => "Sample Activity"}],
               natureza_juridica: "Sociedade Empresária Limitada",
               regime_tributario: [%{"dt_opcao_mei" => "2020-01-01"}],
               situacao_especial: "",
               opcao_pelo_simples: nil,
               situacao_cadastral: 2,
               data_opcao_pelo_mei: nil,
               data_exclusao_do_mei: nil,
               cnae_fiscal_descricao: "Desenvolvimento de programas de computador sob encomenda",
               codigo_municipio_ibge: 1_234_567,
               data_inicio_atividade: "2020-01-15",
               data_situacao_especial: nil,
               data_opcao_pelo_simples: nil,
               data_situacao_cadastral: "2020-01-15",
               nome_cidade_no_exterior: "",
               codigo_natureza_juridica: 2062,
               data_exclusao_do_simples: nil,
               motivo_situacao_cadastral: 0,
               ente_federativo_responsavel: "",
               identificador_matriz_filial: 1,
               qualificacao_do_responsavel: 16,
               descricao_situacao_cadastral: "ATIVA",
               descricao_tipo_de_logradouro: "RUA",
               descricao_motivo_situacao_cadastral: "SEM MOTIVO",
               descricao_identificador_matriz_filial: "MATRIZ"
             } = company
    end

    test "converts a minimal map to a Company struct with defaults" do
      data = %{
        "cnpj" => "12345678000195",
        "razao_social" => "ACME INC"
      }

      company = Company.from_map(data)

      assert %Company{
               cnpj: "12345678000195",
               razao_social: "ACME INC",
               qsa: [],
               cnaes_secundarios: [],
               regime_tributario: []
             } = company
    end

    test "handles nil values correctly" do
      data = %{
        "cnpj" => "12345678000195",
        "razao_social" => "ACME INC",
        "qsa" => nil,
        "cnaes_secundarios" => nil,
        "regime_tributario" => nil
      }

      company = Company.from_map(data)

      assert %Company{
               cnpj: "12345678000195",
               razao_social: "ACME INC",
               qsa: [],
               cnaes_secundarios: [],
               regime_tributario: []
             } = company
    end
  end
end
