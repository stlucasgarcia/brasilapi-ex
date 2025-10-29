defmodule Brasilapi.Brokers.BrokerTest do
  use ExUnit.Case, async: true

  alias Brasilapi.Brokers.Broker

  describe "from_map/1" do
    test "converts a complete map to a Broker struct" do
      data = %{
        "cnpj" => "12345678000195",
        "nome_social" => "SAMPLE BROKER S.A.",
        "nome_comercial" => "SAMPLE BROKER",
        "bairro" => "CENTRO",
        "cep" => "01010000",
        "codigo_cvm" => "1234",
        "complemento" => "SALA 100",
        "data_inicio_situacao" => "2020-01-01",
        "data_patrimonio_liquido" => "2023-12-31",
        "data_registro" => "2019-06-15",
        "email" => "contact@example.com",
        "logradouro" => "RUA EXEMPLO 123",
        "municipio" => "SAO PAULO",
        "pais" => "BRASIL",
        "status" => "ATIVA",
        "telefone" => "1155555555",
        "type" => "CORRETORA",
        "uf" => "SP",
        "valor_patrimonio_liquido" => "5000000.00"
      }

      broker = Broker.from_map(data)

      assert %Broker{
               cnpj: "12345678000195",
               nome_social: "SAMPLE BROKER S.A.",
               nome_comercial: "SAMPLE BROKER",
               bairro: "CENTRO",
               cep: "01010000",
               codigo_cvm: "1234",
               complemento: "SALA 100",
               data_inicio_situacao: "2020-01-01",
               data_patrimonio_liquido: "2023-12-31",
               data_registro: "2019-06-15",
               email: "contact@example.com",
               logradouro: "RUA EXEMPLO 123",
               municipio: "SAO PAULO",
               pais: "BRASIL",
               status: "ATIVA",
               telefone: "1155555555",
               type: "CORRETORA",
               uf: "SP",
               valor_patrimonio_liquido: "5000000.00"
             } = broker
    end

    test "converts a minimal map to a Broker struct with defaults" do
      data = %{
        "cnpj" => "98765432000100",
        "nome_social" => "MINIMAL BROKER",
        "codigo_cvm" => "5678"
      }

      broker = Broker.from_map(data)

      assert %Broker{
               cnpj: "98765432000100",
               nome_social: "MINIMAL BROKER",
               codigo_cvm: "5678",
               nome_comercial: nil,
               bairro: nil,
               cep: nil,
               complemento: nil,
               data_inicio_situacao: nil,
               data_patrimonio_liquido: nil,
               data_registro: nil,
               email: nil,
               logradouro: nil,
               municipio: nil,
               pais: nil,
               status: nil,
               telefone: nil,
               type: nil,
               uf: nil,
               valor_patrimonio_liquido: nil
             } = broker
    end

    test "handles nil and empty string values correctly" do
      data = %{
        "cnpj" => "11111111000111",
        "nome_social" => "TEST BROKER",
        "codigo_cvm" => "0001",
        "nome_comercial" => nil,
        "pais" => "",
        "complemento" => nil,
        "email" => ""
      }

      broker = Broker.from_map(data)

      assert %Broker{
               cnpj: "11111111000111",
               nome_social: "TEST BROKER",
               codigo_cvm: "0001",
               nome_comercial: nil,
               pais: "",
               complemento: nil,
               email: ""
             } = broker
    end
  end
end
