defmodule Brasilapi.Brokers.APITest do
  use ExUnit.Case, async: false

  alias Brasilapi.Brokers.API
  alias Brasilapi.Brokers.Broker
  alias Brasilapi.BypassHelpers

  setup do
    BypassHelpers.setup_bypass_for_base_url()
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

  describe "get_broker_by_cnpj/1" do
    test "returns broker on success with CNPJ string", %{bypass: bypass} do
      expected_response = %{
        "bairro" => "LEBLON",
        "cep" => "22440032",
        "cnpj" => "02332886000104",
        "codigo_cvm" => "3247",
        "complemento" => "SALA 201",
        "data_inicio_situacao" => "1998-02-10",
        "data_patrimonio_liquido" => "2021-12-31",
        "data_registro" => "1997-12-05",
        "email" => "juridico.regulatorio@xpi.com.br",
        "logradouro" => "AVENIDA ATAULFO DE PAIVA 153",
        "municipio" => "RIO DE JANEIRO",
        "nome_social" => "XP INVESTIMENTOS CCTVM S.A.",
        "nome_comercial" => "XP INVESTIMENTOS",
        "pais" => "",
        "status" => "EM FUNCIONAMENTO NORMAL",
        "telefone" => "30272237",
        "type" => "CORRETORAS",
        "uf" => "RJ",
        "valor_patrimonio_liquido" => "5514593491.29"
      }

      Bypass.expect(bypass, "GET", "/api/cvm/corretoras/v1/02332886000104", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, broker} = API.get_broker_by_cnpj("02332886000104")

      assert %Broker{
               bairro: "LEBLON",
               cep: "22440032",
               cnpj: "02332886000104",
               codigo_cvm: "3247",
               complemento: "SALA 201",
               data_inicio_situacao: "1998-02-10",
               data_patrimonio_liquido: "2021-12-31",
               data_registro: "1997-12-05",
               email: "juridico.regulatorio@xpi.com.br",
               logradouro: "AVENIDA ATAULFO DE PAIVA 153",
               municipio: "RIO DE JANEIRO",
               nome_social: "XP INVESTIMENTOS CCTVM S.A.",
               nome_comercial: "XP INVESTIMENTOS",
               pais: "",
               status: "EM FUNCIONAMENTO NORMAL",
               telefone: "30272237",
               type: "CORRETORAS",
               uf: "RJ",
               valor_patrimonio_liquido: "5514593491.29"
             } = broker
    end

    test "handles formatted CNPJ string", %{bypass: bypass} do
      expected_response = %{
        "bairro" => "LEBLON",
        "cep" => "22440032",
        "cnpj" => "02332886000104",
        "codigo_cvm" => "3247",
        "complemento" => "SALA 201",
        "data_inicio_situacao" => "1998-02-10",
        "data_patrimonio_liquido" => "2021-12-31",
        "data_registro" => "1997-12-05",
        "email" => "juridico.regulatorio@xpi.com.br",
        "logradouro" => "AVENIDA ATAULFO DE PAIVA 153",
        "municipio" => "RIO DE JANEIRO",
        "nome_social" => "XP INVESTIMENTOS CCTVM S.A.",
        "nome_comercial" => "XP INVESTIMENTOS",
        "pais" => "",
        "status" => "EM FUNCIONAMENTO NORMAL",
        "telefone" => "30272237",
        "type" => "CORRETORAS",
        "uf" => "RJ",
        "valor_patrimonio_liquido" => "5514593491.29"
      }

      Bypass.expect(bypass, "GET", "/api/cvm/corretoras/v1/02332886000104", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, broker} = API.get_broker_by_cnpj("02.332.886/0001-04")

      assert %Broker{
               cnpj: "02332886000104",
               nome_social: "XP INVESTIMENTOS CCTVM S.A.",
               codigo_cvm: "3247"
             } = broker
    end

    test "handles CNPJ as integer", %{bypass: bypass} do
      expected_response = %{
        "bairro" => "LEBLON",
        "cep" => "22440032",
        "cnpj" => "02332886000104",
        "codigo_cvm" => "3247",
        "complemento" => "SALA 201",
        "data_inicio_situacao" => "1998-02-10",
        "data_patrimonio_liquido" => "2021-12-31",
        "data_registro" => "1997-12-05",
        "email" => "juridico.regulatorio@xpi.com.br",
        "logradouro" => "AVENIDA ATAULFO DE PAIVA 153",
        "municipio" => "RIO DE JANEIRO",
        "nome_social" => "XP INVESTIMENTOS CCTVM S.A.",
        "nome_comercial" => "XP INVESTIMENTOS",
        "pais" => "",
        "status" => "EM FUNCIONAMENTO NORMAL",
        "telefone" => "30272237",
        "type" => "CORRETORAS",
        "uf" => "RJ",
        "valor_patrimonio_liquido" => "5514593491.29"
      }

      Bypass.expect(bypass, "GET", "/api/cvm/corretoras/v1/02332886000104", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, broker} = API.get_broker_by_cnpj(2_332_886_000_104)

      assert %Broker{
               cnpj: "02332886000104",
               nome_social: "XP INVESTIMENTOS CCTVM S.A.",
               codigo_cvm: "3247"
             } = broker
    end

    test "returns error on API failure - CNPJ not found", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/cvm/corretoras/v1/00000000000000", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(
          404,
          Jason.encode!(%{error: "Não foi encontrado este CNPJ na listagem da CVM."})
        )
      end)

      assert {:error, %{status: 404}} = API.get_broker_by_cnpj("00000000000000")
    end

    test "returns error on server error", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/cvm/corretoras/v1/02332886000104", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(500, Jason.encode!(%{error: "Internal server error"}))
      end)

      assert {:error, %{status: 500}} = API.get_broker_by_cnpj("02332886000104")
    end

    test "handles connection failure", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %{message: _}} = API.get_broker_by_cnpj("02332886000104")
    end

    test "returns error for invalid CNPJ format - too short" do
      assert {:error, %{message: "Invalid CNPJ format. Must be 14 digits."}} =
               API.get_broker_by_cnpj("123")
    end

    test "returns error for invalid CNPJ format - too long" do
      assert {:error, %{message: "Invalid CNPJ format. Must be 14 digits."}} =
               API.get_broker_by_cnpj("123456789012345")
    end

    test "returns error for invalid CNPJ format - contains letters" do
      assert {:error, %{message: "Invalid CNPJ format. Must be 14 digits."}} =
               API.get_broker_by_cnpj("1234567890123A")
    end

    test "returns error for invalid CNPJ type" do
      assert {:error, %{message: "CNPJ must be a string or integer"}} =
               API.get_broker_by_cnpj(:invalid)
    end

    test "handles CNPJ with leading zeros as integer", %{bypass: bypass} do
      # This tests the integer path where leading zeros are preserved
      expected_response = %{
        "cnpj" => "00000000000191",
        "nome_social" => "TEST BROKER",
        "codigo_cvm" => "0001"
      }

      Bypass.expect(bypass, "GET", "/api/cvm/corretoras/v1/00000000000191", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, broker} = API.get_broker_by_cnpj(191)

      assert %Broker{
               cnpj: "00000000000191",
               nome_social: "TEST BROKER",
               codigo_cvm: "0001"
             } = broker
    end

    test "handles empty pais field", %{bypass: bypass} do
      expected_response = %{
        "bairro" => "CENTRO",
        "cep" => "01010000",
        "cnpj" => "11111111111111",
        "codigo_cvm" => "1234",
        "complemento" => "",
        "data_inicio_situacao" => "2020-01-01",
        "data_patrimonio_liquido" => "2023-12-31",
        "data_registro" => "2019-06-15",
        "email" => "contato@test.com.br",
        "logradouro" => "RUA TESTE, 123",
        "municipio" => "SAO PAULO",
        "nome_social" => "TEST BROKER S.A.",
        "nome_comercial" => "TEST BROKER",
        "pais" => "",
        "status" => "ATIVA",
        "telefone" => "11999999999",
        "type" => "CORRETORA",
        "uf" => "SP",
        "valor_patrimonio_liquido" => "1000000.00"
      }

      Bypass.expect(bypass, "GET", "/api/cvm/corretoras/v1/11111111111111", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, broker} = API.get_broker_by_cnpj("11111111111111")

      assert %Broker{
               cnpj: "11111111111111",
               nome_social: "TEST BROKER S.A.",
               pais: ""
             } = broker
    end
  end
end
