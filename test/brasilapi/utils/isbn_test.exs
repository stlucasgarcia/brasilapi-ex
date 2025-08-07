defmodule Brasilapi.Utils.IsbnTest do
  use ExUnit.Case, async: true

  alias Brasilapi.Utils.Isbn

  doctest Brasilapi.Utils.Isbn

  describe "sanitize_and_validate/1" do
    test "accepts valid ISBN-13 string without formatting" do
      assert {:ok, "9788545702870"} = Isbn.sanitize_and_validate("9788545702870")
    end

    test "accepts valid ISBN-13 string with formatting" do
      assert {:ok, "9788545702870"} = Isbn.sanitize_and_validate("978-85-457-0287-0")
    end

    test "accepts valid ISBN-10 string without formatting" do
      assert {:ok, "8545702876"} = Isbn.sanitize_and_validate("8545702876")
    end

    test "accepts valid ISBN-10 string with formatting" do
      assert {:ok, "8545702876"} = Isbn.sanitize_and_validate("85-457-0287-6")
    end

    test "handles mixed formatting characters" do
      assert {:ok, "9788545702870"} = Isbn.sanitize_and_validate("978 85 457 0287 0")
      assert {:ok, "9788545702870"} = Isbn.sanitize_and_validate("978_85_457_0287_0")
      assert {:ok, "8545702876"} = Isbn.sanitize_and_validate("85 457 0287 6")
    end

    test "returns error for too short ISBN string" do
      assert {:error, %{message: "Invalid ISBN format. Must be 10 or 13 digits."}} =
               Isbn.sanitize_and_validate("123")
    end

    test "returns error for too long ISBN string" do
      assert {:error, %{message: "Invalid ISBN format. Must be 10 or 13 digits."}} =
               Isbn.sanitize_and_validate("12345678901234")
    end

    test "returns error for 11 or 12 digit ISBN" do
      assert {:error, %{message: "Invalid ISBN format. Must be 10 or 13 digits."}} =
               Isbn.sanitize_and_validate("12345678901")

      assert {:error, %{message: "Invalid ISBN format. Must be 10 or 13 digits."}} =
               Isbn.sanitize_and_validate("123456789012")
    end

    test "returns error for ISBN containing letters" do
      assert {:error, %{message: "Invalid ISBN format. Must be 10 or 13 digits."}} =
               Isbn.sanitize_and_validate("978854570287A")
    end

    test "returns error for invalid type" do
      assert {:error, %{message: "ISBN must be a string"}} =
               Isbn.sanitize_and_validate(9_788_545_702_870)

      assert {:error, %{message: "ISBN must be a string"}} =
               Isbn.sanitize_and_validate(:invalid)

      assert {:error, %{message: "ISBN must be a string"}} =
               Isbn.sanitize_and_validate(nil)
    end

    test "handles empty string" do
      assert {:error, %{message: "Invalid ISBN format. Must be 10 or 13 digits."}} =
               Isbn.sanitize_and_validate("")
    end

    test "handles string with only formatting characters" do
      assert {:error, %{message: "Invalid ISBN format. Must be 10 or 13 digits."}} =
               Isbn.sanitize_and_validate("--")
    end
  end

  describe "format/1" do
    test "formats valid ISBN-13 string" do
      assert "978-85-457-0287-0" = Isbn.format("9788545702870")
    end

    test "formats valid ISBN-10 string" do
      assert "85-457-0287-6" = Isbn.format("8545702876")
    end

    test "formats any 13-digit string" do
      assert "123-45-678-9012-3" = Isbn.format("1234567890123")
    end

    test "formats any 10-digit string" do
      assert "12-345-6789-0" = Isbn.format("1234567890")
    end
  end

  describe "valid_format?/1" do
    test "returns true for valid ISBN-13 string" do
      assert Isbn.valid_format?("9788545702870")
    end

    test "returns true for valid ISBN-10 string" do
      assert Isbn.valid_format?("8545702876")
    end

    test "returns false for invalid format" do
      refute Isbn.valid_format?("123")
      refute Isbn.valid_format?("12345678901234")
      refute Isbn.valid_format?("12345678901")
      refute Isbn.valid_format?("123456789012")
      refute Isbn.valid_format?("978854570287A")
      refute Isbn.valid_format?("978-85-457-0287-0")
    end

    test "returns false for non-string types" do
      refute Isbn.valid_format?(9_788_545_702_870)
      refute Isbn.valid_format?(nil)
      refute Isbn.valid_format?(:invalid)
    end

    test "returns false for empty string" do
      refute Isbn.valid_format?("")
    end
  end

  describe "remove_formatting/1" do
    test "removes standard ISBN-13 formatting" do
      assert "9788545702870" = Isbn.remove_formatting("978-85-457-0287-0")
    end

    test "removes standard ISBN-10 formatting" do
      assert "8545702876" = Isbn.remove_formatting("85-457-0287-6")
    end

    test "removes various formatting characters" do
      assert "9788545702870" = Isbn.remove_formatting("978 85 457 0287 0")
      assert "9788545702870" = Isbn.remove_formatting("978_85_457_0287_0")
      assert "8545702876" = Isbn.remove_formatting("85 457 0287 6")
    end

    test "handles string without formatting" do
      assert "9788545702870" = Isbn.remove_formatting("9788545702870")
      assert "8545702876" = Isbn.remove_formatting("8545702876")
    end

    test "handles mixed characters" do
      assert "9788545702870" = Isbn.remove_formatting("978abc85def457ghi0287jkl0")
    end

    test "handles empty string" do
      assert "" = Isbn.remove_formatting("")
    end

    test "handles string with only formatting characters" do
      assert "" = Isbn.remove_formatting("- _")
    end
  end
end
