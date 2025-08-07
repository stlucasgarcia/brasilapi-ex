defmodule Brasilapi.Brokers.APITest do
  use ExUnit.Case, async: false

  alias Brasilapi.Brokers.API
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

  describe "get_brokers/0" do
    test "returns list of brokers on success", %{bypass: bypass} do
      expected_response = [
        %{
          "cnpj" => "00000000000191",
          "nome_social" => "CORRETORA EXEMPLO S.A.",
          "nome_comercial" => "CORRETORA EXEMPLO",
          "bairro" => "CENTRO",
          "cep" => "01010000",
          "codigo_cvm" => "12345",
          "complemento" => "ANDAR 10",
          "data_inicio_situacao" => "2020-01-01",
          "data_patrimonio_liquido" => "2023-12-31",
          "data_registro" => "2019-06-15",
          "email" => "contato@exemplo.com.br",
          "logradouro" => "RUA EXEMPLO, 123",
          "municipio" => "SAO PAULO",
          "pais" => "BRASIL",
          "status" => "ATIVA",
          "telefone" => "11999999999",
          "type" => "CORRETORA",
          "uf" => "SP",
          "valor_patrimonio_liquido" => "50000000.00"
        },
        %{
          "cnpj" => "11111111111111",
          "nome_social" => "OUTRA CORRETORA LTDA.",
          "nome_comercial" => "OUTRA CORRETORA",
          "bairro" => "VILA OLIMPIA",
          "cep" => "04551000",
          "codigo_cvm" => "67890",
          "complemento" => "SALA 501",
          "data_inicio_situacao" => "2021-03-15",
          "data_patrimonio_liquido" => "2023-12-31",
          "data_registro" => "2020-11-20",
          "email" => "info@outracorretora.com.br",
          "logradouro" => "AV BRIGADEIRO FARIA LIMA, 456",
          "municipio" => "SAO PAULO",
          "pais" => "BRASIL",
          "status" => "ATIVA",
          "telefone" => "11888888888",
          "type" => "CORRETORA",
          "uf" => "SP",
          "valor_patrimonio_liquido" => "75000000.00"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/cvm/corretoras/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, brokers} = API.get_brokers()

      assert [
               %Broker{
                 cnpj: "00000000000191",
                 nome_social: "CORRETORA EXEMPLO S.A.",
                 nome_comercial: "CORRETORA EXEMPLO",
                 bairro: "CENTRO",
                 cep: "01010000",
                 codigo_cvm: "12345",
                 complemento: "ANDAR 10",
                 data_inicio_situacao: "2020-01-01",
                 data_patrimonio_liquido: "2023-12-31",
                 data_registro: "2019-06-15",
                 email: "contato@exemplo.com.br",
                 logradouro: "RUA EXEMPLO, 123",
                 municipio: "SAO PAULO",
                 pais: "BRASIL",
                 status: "ATIVA",
                 telefone: "11999999999",
                 type: "CORRETORA",
                 uf: "SP",
                 valor_patrimonio_liquido: "50000000.00"
               },
               %Broker{
                 cnpj: "11111111111111",
                 nome_social: "OUTRA CORRETORA LTDA.",
                 nome_comercial: "OUTRA CORRETORA",
                 bairro: "VILA OLIMPIA",
                 cep: "04551000",
                 codigo_cvm: "67890",
                 complemento: "SALA 501",
                 data_inicio_situacao: "2021-03-15",
                 data_patrimonio_liquido: "2023-12-31",
                 data_registro: "2020-11-20",
                 email: "info@outracorretora.com.br",
                 logradouro: "AV BRIGADEIRO FARIA LIMA, 456",
                 municipio: "SAO PAULO",
                 pais: "BRASIL",
                 status: "ATIVA",
                 telefone: "11888888888",
                 type: "CORRETORA",
                 uf: "SP",
                 valor_patrimonio_liquido: "75000000.00"
               }
             ] = brokers

      assert length(brokers) == 2
    end

    test "returns error on API failure", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/cvm/corretoras/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(500, Jason.encode!(%{error: "Internal server error"}))
      end)

      assert {:error, %{status: 500}} = API.get_brokers()
    end

    test "handles connection failure", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %{message: _}} = API.get_brokers()
    end

    test "handles empty response", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/cvm/corretoras/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!([]))
      end)

      assert {:ok, []} = API.get_brokers()
    end

    test "handles broker with minimal data", %{bypass: bypass} do
      minimal_broker = %{
        "cnpj" => "22222222222222",
        "nome_social" => "MINIMAL BROKER",
        "codigo_cvm" => "00001"
      }

      Bypass.expect(bypass, "GET", "/api/cvm/corretoras/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!([minimal_broker]))
      end)

      assert {:ok, [broker]} = API.get_brokers()

      assert %Broker{
               cnpj: "22222222222222",
               nome_social: "MINIMAL BROKER",
               codigo_cvm: "00001",
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

    test "handles broker with null values", %{bypass: bypass} do
      broker_with_nulls = %{
        "cnpj" => "33333333333333",
        "nome_social" => "NULL BROKER",
        "nome_comercial" => nil,
        "bairro" => nil,
        "cep" => "00000000",
        "codigo_cvm" => "00002",
        "complemento" => nil,
        "data_inicio_situacao" => nil,
        "data_patrimonio_liquido" => nil,
        "data_registro" => "2023-01-01",
        "email" => nil,
        "logradouro" => "RUA TESTE",
        "municipio" => "RIO DE JANEIRO",
        "pais" => "BRASIL",
        "status" => nil,
        "telefone" => nil,
        "type" => nil,
        "uf" => "RJ",
        "valor_patrimonio_liquido" => nil
      }

      Bypass.expect(bypass, "GET", "/api/cvm/corretoras/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!([broker_with_nulls]))
      end)

      assert {:ok, [broker]} = API.get_brokers()

      assert %Broker{
               cnpj: "33333333333333",
               nome_social: "NULL BROKER",
               nome_comercial: nil,
               bairro: nil,
               cep: "00000000",
               codigo_cvm: "00002",
               complemento: nil,
               data_inicio_situacao: nil,
               data_patrimonio_liquido: nil,
               data_registro: "2023-01-01",
               email: nil,
               logradouro: "RUA TESTE",
               municipio: "RIO DE JANEIRO",
               pais: "BRASIL",
               status: nil,
               telefone: nil,
               type: nil,
               uf: "RJ",
               valor_patrimonio_liquido: nil
             } = broker
    end
  end
end
