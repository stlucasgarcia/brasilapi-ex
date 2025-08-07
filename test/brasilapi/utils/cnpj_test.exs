defmodule Brasilapi.Utils.CnpjTest do
  use ExUnit.Case, async: true

  alias Brasilapi.Utils.Cnpj

  doctest Brasilapi.Utils.Cnpj

  describe "sanitize_and_validate/1" do
    test "accepts valid CNPJ string without formatting" do
      assert {:ok, "11000000000197"} = Cnpj.sanitize_and_validate("11000000000197")
    end

    test "accepts valid CNPJ string with formatting" do
      assert {:ok, "11000000000197"} = Cnpj.sanitize_and_validate("11.000.000/0001-97")
    end

    test "accepts CNPJ as integer" do
      assert {:ok, "11000000000197"} = Cnpj.sanitize_and_validate(11_000_000_000_197)
    end

    test "handles CNPJ with leading zeros as integer" do
      assert {:ok, "00000000000191"} = Cnpj.sanitize_and_validate(191)
    end

    test "pads short integer CNPJs with leading zeros" do
      assert {:ok, "00000000000001"} = Cnpj.sanitize_and_validate(1)
    end

    test "handles mixed formatting" do
      assert {:ok, "11000000000197"} = Cnpj.sanitize_and_validate("11.000.000/0001-97")
      assert {:ok, "11000000000197"} = Cnpj.sanitize_and_validate("11 000 000 0001 97")
      assert {:ok, "11000000000197"} = Cnpj.sanitize_and_validate("11-000-000-0001-97")
    end

    test "returns error for too short CNPJ string" do
      assert {:error, %{message: "Invalid CNPJ format. Must be 14 digits."}} =
               Cnpj.sanitize_and_validate("123")
    end

    test "returns error for too long CNPJ string" do
      assert {:error, %{message: "Invalid CNPJ format. Must be 14 digits."}} =
               Cnpj.sanitize_and_validate("123456789012345")
    end

    test "returns error for CNPJ containing letters" do
      assert {:error, %{message: "Invalid CNPJ format. Must be 14 digits."}} =
               Cnpj.sanitize_and_validate("1234567890123A")
    end

    test "returns error for invalid type" do
      assert {:error, %{message: "CNPJ must be a string or integer"}} =
               Cnpj.sanitize_and_validate(:invalid)

      assert {:error, %{message: "CNPJ must be a string or integer"}} =
               Cnpj.sanitize_and_validate(nil)

      assert {:error, %{message: "CNPJ must be a string or integer"}} =
               Cnpj.sanitize_and_validate(12.34)
    end

    test "handles empty string" do
      assert {:error, %{message: "Invalid CNPJ format. Must be 14 digits."}} =
               Cnpj.sanitize_and_validate("")
    end

    test "handles string with only formatting characters" do
      assert {:error, %{message: "Invalid CNPJ format. Must be 14 digits."}} =
               Cnpj.sanitize_and_validate("..//-")
    end
  end

  describe "format/1" do
    test "formats valid 14-digit CNPJ string" do
      assert "11.000.000/0001-97" = Cnpj.format("11000000000197")
    end

    test "formats CNPJ with leading zeros" do
      assert "00.000.000/0001-91" = Cnpj.format("00000000000191")
    end

    test "formats any 14-digit string" do
      assert "12.345.678/9012-34" = Cnpj.format("12345678901234")
    end
  end

  describe "valid_format?/1" do
    test "returns true for valid 14-digit string" do
      assert Cnpj.valid_format?("11000000000197")
      assert Cnpj.valid_format?("00000000000191")
    end

    test "returns false for invalid format" do
      refute Cnpj.valid_format?("123")
      refute Cnpj.valid_format?("123456789012345")
      refute Cnpj.valid_format?("1234567890123A")
      refute Cnpj.valid_format?("11.000.000/0001-97")
    end

    test "returns false for non-string types" do
      refute Cnpj.valid_format?(11_000_000_000_197)
      refute Cnpj.valid_format?(nil)
      refute Cnpj.valid_format?(:invalid)
    end

    test "returns false for empty string" do
      refute Cnpj.valid_format?("")
    end
  end

  describe "remove_formatting/1" do
    test "removes standard CNPJ formatting" do
      assert "11000000000197" = Cnpj.remove_formatting("11.000.000/0001-97")
    end

    test "removes various formatting characters" do
      assert "11000000000197" = Cnpj.remove_formatting("11 000 000 0001 97")
      assert "11000000000197" = Cnpj.remove_formatting("11-000-000-0001-97")
      assert "11000000000197" = Cnpj.remove_formatting("11_000_000_0001_97")
    end

    test "handles string without formatting" do
      assert "11000000000197" = Cnpj.remove_formatting("11000000000197")
    end

    test "handles mixed characters" do
      assert "11000000000197" = Cnpj.remove_formatting("11.000abc000/0001xyz97")
    end

    test "handles empty string" do
      assert "" = Cnpj.remove_formatting("")
    end

    test "handles string with only formatting characters" do
      assert "" = Cnpj.remove_formatting(".//-_")
    end
  end
end
