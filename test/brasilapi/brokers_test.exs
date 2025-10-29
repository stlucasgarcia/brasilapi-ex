defmodule Brasilapi.BrokersTest do
  use ExUnit.Case, async: false

  alias Brasilapi.Brokers
  alias Brasilapi.Brokers.Broker

  setup do
    # Store original base_url to restore later
    original_base_url = Application.get_env(:brasilapi, :base_url)

    bypass = Bypass.open()
    base_url = "http://localhost:#{bypass.port}/api"

    # Override the base URL for testing
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
