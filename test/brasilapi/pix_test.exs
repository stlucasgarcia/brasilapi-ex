defmodule Brasilapi.PixTest do
  use ExUnit.Case, async: false

  alias Brasilapi.Pix
  alias Brasilapi.Pix.Participant

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

  describe "get_participants/0 delegation" do
    test "delegates to API.get_participants/0", %{bypass: bypass} do
      expected_response = [
        %{
          "ispb" => "360305",
          "nome" => "CAIXA ECONOMICA FEDERAL",
          "nome_reduzido" => "CAIXA ECONOMICA FEDERAL",
          "modalidade_participacao" => "PDCT",
          "tipo_participacao" => "DRCT",
          "inicio_operacao" => "2020-11-03T09:30:00.000Z"
        },
        %{
          "ispb" => "00000000",
          "nome" => "BANCO TESTE",
          "nome_reduzido" => "BCO TESTE",
          "modalidade_participacao" => "DRCT",
          "tipo_participacao" => "DRCT",
          "inicio_operacao" => "2020-10-01T10:00:00.000Z"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/pix/v1/participants", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, [participant1, participant2]} = Pix.get_participants()
      assert %Participant{ispb: "360305", nome: "CAIXA ECONOMICA FEDERAL"} = participant1
      assert %Participant{ispb: "00000000", nome: "BANCO TESTE"} = participant2
    end
  end
end
