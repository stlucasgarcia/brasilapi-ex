defmodule Brasilapi.Utils.Digits do
  @moduledoc false

  @spec only(String.t()) :: String.t()
  def only(value) when is_binary(value) do
    String.replace(value, ~r/\D/, "")
  end

  @spec normalize_exact(String.t() | integer(), pos_integer()) ::
          {:ok, String.t()} | {:error, atom()}
  def normalize_exact(value, length) when is_integer(value) do
    value
    |> Integer.to_string()
    |> String.pad_leading(length, "0")
    |> normalize_exact(length)
  end

  def normalize_exact(value, length) when is_binary(value) do
    digits = only(value)

    cond do
      digits == "" ->
        {:error, :empty}

      byte_size(digits) != length ->
        {:error, :invalid_length}

      true ->
        {:ok, digits}
    end
  end
end
