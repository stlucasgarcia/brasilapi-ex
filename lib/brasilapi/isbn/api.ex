defmodule Brasilapi.Isbn.API do
  @moduledoc """
  Client for BrasilAPI ISBN endpoints.

  Provides functions to fetch book information by ISBN from multiple providers
  including CBL, Mercado Editorial, Open Library, and Google Books.
  """

  alias Brasilapi.Client
  alias Brasilapi.Isbn.Book
  alias Brasilapi.Utils.Isbn

  @valid_providers ["cbl", "mercado-editorial", "open-library", "google-books"]

  @doc """
  Fetches book information by ISBN.

  Supports both ISBN-10 and ISBN-13 formats, with or without dashes.
  Returns detailed book information including title, authors, publisher,
  synopsis, dimensions, and other metadata.

  ## Parameters

    * `isbn` - The ISBN number (string, with or without dashes)
    * `opts` - Keyword list of options:
      * `:providers` - List of provider strings (default: all providers)

  ## Provider Options

  Available providers:
  - `"cbl"` - Câmara Brasileira do Livro
  - `"mercado-editorial"` - Mercado Editorial
  - `"open-library"` - Open Library
  - `"google-books"` - Google Books

  If no providers are specified, the API will try all providers and return
  the response from the fastest one.

  ## Examples

      iex> Brasilapi.Isbn.API.get_book("9788545702870")
      {:ok, %Brasilapi.Isbn.Book{isbn: "9788545702870", title: "Akira", ...}}

      iex> Brasilapi.Isbn.API.get_book("978-85-457-0287-0")
      {:ok, %Brasilapi.Isbn.Book{isbn: "9788545702870", title: "Akira", ...}}

      iex> Brasilapi.Isbn.API.get_book("9788545702870", providers: ["cbl"])
      {:ok, %Brasilapi.Isbn.Book{isbn: "9788545702870", title: "Akira", provider: "cbl", ...}}

      iex> Brasilapi.Isbn.API.get_book("1234567890123")
      {:error, %{status: 404, message: "ISBN não encontrado"}}

      iex> Brasilapi.Isbn.API.get_book("invalid")
      {:error, %{message: "Invalid ISBN format. Must be 10 or 13 digits."}}

  """
  @spec get_book(String.t(), keyword()) :: {:ok, Book.t()} | {:error, map()}
  def get_book(isbn, opts \\ []) do
    providers = Keyword.get(opts, :providers, [])

    with {:ok, isbn_string} <- Isbn.sanitize_and_validate(isbn),
         {:ok, providers_param} <- validate_providers(providers),
         {:ok, %{} = book_data} <- fetch_book_data(isbn_string, providers_param) do
      {:ok, Book.from_map(book_data)}
    end
  end

  # Private functions

  @spec fetch_book_data(String.t(), String.t()) :: {:ok, map()} | {:error, map()}
  defp fetch_book_data(isbn, providers_param) do
    path = "/isbn/v1/#{isbn}"

    query_params =
      case providers_param do
        "" -> []
        param -> [providers: param]
      end

    Client.get(path, params: params)
  end

  @spec validate_providers(list()) :: {:ok, String.t()} | {:error, map()}
  defp validate_providers([]), do: {:ok, ""}

  defp validate_providers(providers) when is_list(providers) do
    case Enum.all?(providers, &(&1 in @valid_providers)) do
      true ->
        {:ok, Enum.join(providers, ",")}

      false ->
        invalid = Enum.reject(providers, &(&1 in @valid_providers))
        valid = Enum.join(@valid_providers, ", ")

        {:error,
         %{
           message:
             "Invalid providers: #{Enum.join(invalid, ", ")}. Valid providers are: #{valid}"
         }}
    end
  end

  defp validate_providers(_providers) do
    valid = Enum.join(@valid_providers, ", ")
    {:error, %{message: "Providers must be a list of strings. Valid providers are: #{valid}"}}
  end
end
