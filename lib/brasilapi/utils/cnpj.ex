defmodule Brasilapi.Utils.Cnpj do
  @moduledoc """
  Utilities for CNPJ (Cadastro Nacional da Pessoa Jurídica) handling.

  This module provides functions to validate, sanitize, and format CNPJ numbers
  for use across the BrasilAPI client library.

  CNPJ is the Brazilian national registry of legal entities, consisting of 14 digits.

  ## Validation Approach

  This module provides **lightweight validation**:
  - Only validates 14-digit length and numeric characters
  - Does NOT perform checksum validation
  - Accepts integers, formatted strings (`11.000.000/0001-97`), and plain strings
  - Automatically converts all inputs to clean 14-digit strings

  For complete CNPJ validation with checksum verification, use a dedicated library
  such as `brcpfcnpj` before calling BrasilAPI functions.
  """

  @doc """
  Sanitizes and validates a CNPJ number.

  Accepts CNPJ as string (formatted or unformatted) or integer.
  Returns a sanitized 14-digit string if valid, or an error if invalid.

  ## Parameters

    * `cnpj` - CNPJ as string or integer

  ## Examples

      iex> Brasilapi.Utils.Cnpj.sanitize_and_validate("11.000.000/0001-97")
      {:ok, "11000000000197"}

      iex> Brasilapi.Utils.Cnpj.sanitize_and_validate("11000000000197")
      {:ok, "11000000000197"}

      iex> Brasilapi.Utils.Cnpj.sanitize_and_validate(11000000000197)
      {:ok, "11000000000197"}

      iex> Brasilapi.Utils.Cnpj.sanitize_and_validate(197)
      {:ok, "00000000000197"}

      iex> Brasilapi.Utils.Cnpj.sanitize_and_validate("123")
      {:error, %{message: "Invalid CNPJ format. Must be 14 digits."}}

      iex> Brasilapi.Utils.Cnpj.sanitize_and_validate("1234567890123A")
      {:error, %{message: "Invalid CNPJ format. Must be 14 digits."}}

  """
  @spec sanitize_and_validate(String.t() | integer()) :: {:ok, String.t()} | {:error, map()}
  def sanitize_and_validate(cnpj) when is_integer(cnpj) do
    cnpj
    |> Integer.to_string()
    |> String.pad_leading(14, "0")
    |> sanitize_and_validate()
  end

  def sanitize_and_validate(cnpj) when is_binary(cnpj) do
    # First sanitize by removing formatting characters
    sanitized = String.replace(cnpj, ~r/[^\d]/, "")

    # Check if length is exactly 14 digits
    case String.length(sanitized) do
      14 -> {:ok, sanitized}
      _ -> {:error, %{message: "Invalid CNPJ format. Must be 14 digits."}}
    end
  end

  def sanitize_and_validate(_cnpj) do
    {:error, %{message: "CNPJ must be a string or integer"}}
  end

  @doc """
  Formats a CNPJ string with standard Brazilian formatting.

  Takes a 14-digit CNPJ string and applies the standard format: XX.XXX.XXX/XXXX-XX

  ## Parameters

    * `cnpj` - 14-digit CNPJ string

  ## Examples

      iex> Brasilapi.Utils.Cnpj.format("11000000000197")
      "11.000.000/0001-97"

      iex> Brasilapi.Utils.Cnpj.format("00000000000191")
      "00.000.000/0001-91"

  """
  @spec format(String.t()) :: String.t()
  def format(cnpj) when is_binary(cnpj) and byte_size(cnpj) == 14 do
    <<a::binary-size(2), b::binary-size(3), c::binary-size(3), d::binary-size(4),
      e::binary-size(2)>> = cnpj

    "#{a}.#{b}.#{c}/#{d}-#{e}"
  end

  @doc """
  Validates if a CNPJ string contains only digits and has correct length.

  This is a simpler validation that only checks format without sanitization.

  ## Parameters

    * `cnpj` - CNPJ string to validate

  ## Examples

      iex> Brasilapi.Utils.Cnpj.valid_format?("11000000000197")
      true

      iex> Brasilapi.Utils.Cnpj.valid_format?("123")
      false

      iex> Brasilapi.Utils.Cnpj.valid_format?("1234567890123A")
      false

  """
  @spec valid_format?(String.t()) :: boolean()
  def valid_format?(cnpj) when is_binary(cnpj) do
    String.match?(cnpj, ~r/^\d{14}$/)
  end

  def valid_format?(_), do: false

  @doc """
  Removes all formatting from a CNPJ string, keeping only digits.

  ## Parameters

    * `cnpj` - Formatted or unformatted CNPJ string

  ## Examples

      iex> Brasilapi.Utils.Cnpj.remove_formatting("11.000.000/0001-97")
      "11000000000197"

      iex> Brasilapi.Utils.Cnpj.remove_formatting("11000000000197")
      "11000000000197"

  """
  @spec remove_formatting(String.t()) :: String.t()
  def remove_formatting(cnpj) when is_binary(cnpj) do
    String.replace(cnpj, ~r/[^\d]/, "")
  end
end
