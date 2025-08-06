defmodule Brasilapi.Pix.ParticipantTest do
  use ExUnit.Case

  alias Brasilapi.Pix.Participant

  describe "from_map/1" do
    test "creates Participant struct from valid map" do
      map = %{
        "ispb" => "360305",
        "nome" => "CAIXA ECONOMICA FEDERAL",
        "nome_reduzido" => "CAIXA ECONOMICA FEDERAL",
        "modalidade_participacao" => "PDCT",
        "tipo_participacao" => "DRCT",
        "inicio_operacao" => "2020-11-03T09:30:00.000Z"
      }

      result = Participant.from_map(map)

      assert %Participant{
               ispb: "360305",
               nome: "CAIXA ECONOMICA FEDERAL",
               nome_reduzido: "CAIXA ECONOMICA FEDERAL",
               modalidade_participacao: "PDCT",
               tipo_participacao: "DRCT",
               inicio_operacao: "2020-11-03T09:30:00.000Z"
             } = result
    end

    test "creates Participant struct with different values" do
      map = %{
        "ispb" => "00000000",
        "nome" => "BANCO TESTE",
        "nome_reduzido" => "BCO TESTE",
        "modalidade_participacao" => "DRCT",
        "tipo_participacao" => "DRCT",
        "inicio_operacao" => "2020-10-01T10:00:00.000Z"
      }

      result = Participant.from_map(map)

      assert %Participant{
               ispb: "00000000",
               nome: "BANCO TESTE",
               nome_reduzido: "BCO TESTE",
               modalidade_participacao: "DRCT",
               tipo_participacao: "DRCT",
               inicio_operacao: "2020-10-01T10:00:00.000Z"
             } = result
    end
  end

  describe "Jason.Encoder" do
    test "encodes Participant struct to JSON" do
      participant = %Participant{
        ispb: "360305",
        nome: "CAIXA ECONOMICA FEDERAL",
        nome_reduzido: "CAIXA ECONOMICA FEDERAL",
        modalidade_participacao: "PDCT",
        tipo_participacao: "DRCT",
        inicio_operacao: "2020-11-03T09:30:00.000Z"
      }

      json_string = Jason.encode!(participant)
      decoded = Jason.decode!(json_string)

      assert %{
               "ispb" => "360305",
               "nome" => "CAIXA ECONOMICA FEDERAL",
               "nome_reduzido" => "CAIXA ECONOMICA FEDERAL",
               "modalidade_participacao" => "PDCT",
               "tipo_participacao" => "DRCT",
               "inicio_operacao" => "2020-11-03T09:30:00.000Z"
             } = decoded
    end
  end
end
