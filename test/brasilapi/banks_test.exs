defmodule Brasilapi.BanksTest do
  use ExUnit.Case, async: false

  alias Brasilapi.Banks
  alias Brasilapi.Banks.Bank
  alias Brasilapi.BypassHelpers

  setup do
    BypassHelpers.setup_bypass_for_base_url()
  end

  describe "get_banks/0 delegation" do
    test "delegates to API.get_banks/0", %{bypass: bypass} do
      expected_response = [
        %{
          "ispb" => "00000000",
          "name" => "BCO DO BRASIL S.A.",
          "code" => 1,
          "fullName" => "Banco do Brasil S.A."
        }
      ]

      Bypass.expect(bypass, "GET", "/api/banks/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, [bank]} = Banks.get_banks()
      assert %Bank{ispb: "00000000", name: "BCO DO BRASIL S.A."} = bank
    end
  end

  describe "get_bank_by_code/1 delegation" do
    test "delegates to API.get_bank_by_code/1", %{bypass: bypass} do
      expected_response = %{
        "ispb" => "00000000",
        "name" => "BCO DO BRASIL S.A.",
        "code" => 1,
        "fullName" => "Banco do Brasil S.A."
      }

      Bypass.expect(bypass, "GET", "/api/banks/v1/1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, bank} = Banks.get_bank_by_code(1)
      assert %Bank{ispb: "00000000", name: "BCO DO BRASIL S.A."} = bank
    end
  end
end
