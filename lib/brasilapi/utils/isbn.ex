defmodule Brasilapi.Utils.Isbn do
  @moduledoc """
  Utilities for ISBN (International Standard Book Number) handling.

  This module provides functions to validate, sanitize, and format ISBN numbers
  for use across the BrasilAPI client library.

  ## ISBN Formats

  Supports both ISBN-10 (obsolete) and ISBN-13 (current) formats:
  - ISBN-10: 10 digits (e.g., "8545702876")
  - ISBN-13: 13 digits (e.g., "9788545702870")
  - Both formats accept dashes for formatting (e.g., "978-85-457-0287-0")

  ## Validation Approach

  This module provides **lightweight validation**:
  - Only validates 10 or 13-digit length and numeric characters
  - Accepts formatted strings with dashes and plain strings
  - Automatically removes dashes for clean ISBN strings

  For complete ISBN validation with checksum verification, use a dedicated library.
  """

  @doc """
  Sanitizes and validates an ISBN number.

  Accepts ISBN as string (formatted or unformatted) in both ISBN-10 and ISBN-13 formats.
  Returns a sanitized ISBN string if valid, or an error if invalid.

  ## Parameters

    * `isbn` - ISBN as string

  ## Examples

      iex> Brasilapi.Utils.Isbn.sanitize_and_validate("978-85-457-0287-0")
      {:ok, "9788545702870"}

      iex> Brasilapi.Utils.Isbn.sanitize_and_validate("9788545702870")
      {:ok, "9788545702870"}

      iex> Brasilapi.Utils.Isbn.sanitize_and_validate("85-457-0287-6")
      {:ok, "8545702876"}

      iex> Brasilapi.Utils.Isbn.sanitize_and_validate("8545702876")
      {:ok, "8545702876"}

      iex> Brasilapi.Utils.Isbn.sanitize_and_validate("123")
      {:error, %{message: "Invalid ISBN format. Must be 10 or 13 digits."}}

      iex> Brasilapi.Utils.Isbn.sanitize_and_validate("12345678901234")
      {:error, %{message: "Invalid ISBN format. Must be 10 or 13 digits."}}

  """
  @spec sanitize_and_validate(String.t()) :: {:ok, String.t()} | {:error, map()}
  def sanitize_and_validate(isbn) when is_binary(isbn) do
    # First sanitize by removing formatting characters (dashes, spaces)
    sanitized = String.replace(isbn, ~r/[^\d]/, "")

    # Check if length is 10 or 13 digits
    case String.length(sanitized) do
      10 -> {:ok, sanitized}
      13 -> {:ok, sanitized}
      _ -> {:error, %{message: "Invalid ISBN format. Must be 10 or 13 digits."}}
    end
  end

  def sanitize_and_validate(_isbn) do
    {:error, %{message: "ISBN must be a string"}}
  end

  @doc """
  Formats an ISBN string with standard formatting.

  Takes a 10 or 13-digit ISBN string and applies standard formatting with dashes.

  ## Parameters

    * `isbn` - 10 or 13-digit ISBN string

  ## Examples

      iex> Brasilapi.Utils.Isbn.format("9788545702870")
      "978-85-457-0287-0"

      iex> Brasilapi.Utils.Isbn.format("8545702876")
      "85-457-0287-6"

  """
  @spec format(String.t()) :: String.t()
  def format(isbn) when is_binary(isbn) and byte_size(isbn) == 13 do
    # ISBN-13 format: 978-85-457-0287-0
    <<prefix::binary-size(3), group::binary-size(2), publisher::binary-size(3),
      title::binary-size(4), check::binary-size(1)>> = isbn

    "#{prefix}-#{group}-#{publisher}-#{title}-#{check}"
  end

  def format(isbn) when is_binary(isbn) and byte_size(isbn) == 10 do
    # ISBN-10 format: 85-457-0287-6
    <<group::binary-size(2), publisher::binary-size(3), title::binary-size(4),
      check::binary-size(1)>> = isbn

    "#{group}-#{publisher}-#{title}-#{check}"
  end

  @doc """
  Validates if an ISBN string contains only digits and has correct length.

  This is a simpler validation that only checks format without sanitization.

  ## Parameters

    * `isbn` - ISBN string to validate

  ## Examples

      iex> Brasilapi.Utils.Isbn.valid_format?("9788545702870")
      true

      iex> Brasilapi.Utils.Isbn.valid_format?("8545702876")
      true

      iex> Brasilapi.Utils.Isbn.valid_format?("123")
      false

      iex> Brasilapi.Utils.Isbn.valid_format?("12345678901234")
      false

  """
  @spec valid_format?(String.t()) :: boolean()
  def valid_format?(isbn) when is_binary(isbn) do
    String.match?(isbn, ~r/^(\d{10}|\d{13})$/)
  end

  def valid_format?(_), do: false

  @doc """
  Removes all formatting from an ISBN string, keeping only digits.

  ## Parameters

    * `isbn` - Formatted or unformatted ISBN string

  ## Examples

      iex> Brasilapi.Utils.Isbn.remove_formatting("978-85-457-0287-0")
      "9788545702870"

      iex> Brasilapi.Utils.Isbn.remove_formatting("9788545702870")
      "9788545702870"

  """
  @spec remove_formatting(String.t()) :: String.t()
  def remove_formatting(isbn) when is_binary(isbn) do
    String.replace(isbn, ~r/[^\d]/, "")
  end
end
