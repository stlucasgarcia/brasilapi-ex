defmodule Brasilapi.BrokersTest do
  use ExUnit.Case, async: false

  alias Brasilapi.Brokers
  alias Brasilapi.Brokers.Broker
  alias Brasilapi.BypassHelpers

  setup do
    BypassHelpers.setup_bypass_for_base_url()
  end

  describe "get_brokers/0 delegation" do
    test "delegates to API.get_brokers/0", %{bypass: bypass} do
      expected_response = [
        %{
          "cnpj" => "12345678000195",
          "nome_social" => "SAMPLE BROKER S.A.",
          "nome_comercial" => "SAMPLE BROKER",
          "codigo_cvm" => "1234",
          "status" => "ATIVA",
          "type" => "CORRETORA",
          "municipio" => "SAO PAULO",
          "uf" => "SP"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/cvm/corretoras/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, [broker]} = Brokers.get_brokers()

      assert %Broker{
               cnpj: "12345678000195",
               nome_social: "SAMPLE BROKER S.A.",
               nome_comercial: "SAMPLE BROKER",
               codigo_cvm: "1234"
             } = broker
    end
  end

  describe "get_broker_by_cnpj/1 delegation" do
    test "delegates to API.get_broker_by_cnpj/1", %{bypass: bypass} do
      expected_response = %{
        "cnpj" => "12345678000195",
        "nome_social" => "SAMPLE BROKER S.A.",
        "nome_comercial" => "SAMPLE BROKER",
        "codigo_cvm" => "1234",
        "bairro" => "CENTRO",
        "cep" => "01010000",
        "complemento" => "SALA 100",
        "data_registro" => "2020-01-15",
        "email" => "contact@example.com",
        "logradouro" => "RUA EXEMPLO 123",
        "municipio" => "SAO PAULO",
        "pais" => "BRASIL",
        "status" => "ATIVA",
        "telefone" => "1155555555",
        "type" => "CORRETORA",
        "uf" => "SP"
      }

      Bypass.expect(bypass, "GET", "/api/cvm/corretoras/v1/12345678000195", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, broker} = Brokers.get_broker_by_cnpj("12345678000195")

      assert %Broker{
               cnpj: "12345678000195",
               nome_social: "SAMPLE BROKER S.A.",
               codigo_cvm: "1234",
               municipio: "SAO PAULO"
             } = broker
    end
  end
end
