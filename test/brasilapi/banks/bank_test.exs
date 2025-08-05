defmodule Brasilapi.Banks.BankTest do
  use ExUnit.Case, async: true

  alias Brasilapi.Banks.Bank

  describe "from_map/1" do
    test "creates Bank struct from API response map" do
      api_response = %{
        "ispb" => "00000000",
        "name" => "BCO DO BRASIL S.A.",
        "code" => 1,
        "fullName" => "Banco do Brasil S.A."
      }

      expected_bank = %Bank{
        ispb: "00000000",
        name: "BCO DO BRASIL S.A.",
        code: 1,
        full_name: "Banco do Brasil S.A."
      }

      assert Bank.from_map(api_response) == expected_bank
    end
  end

  describe "struct" do
    test "has correct fields" do
      bank = %Bank{
        ispb: "12345678",
        name: "Test Bank",
        code: 123,
        full_name: "Test Bank S.A."
      }

      assert bank.ispb == "12345678"
      assert bank.name == "Test Bank"
      assert bank.code == 123
      assert bank.full_name == "Test Bank S.A."
    end
  end
end