defmodule Brasilapi.Isbn.Book do
  @moduledoc """
  Represents a book with complete information from ISBN lookup.

  Contains detailed book metadata including title, authors, publisher,
  synopsis, dimensions, and other bibliographic information.
  """

  alias Brasilapi.Isbn.Dimensions

  @type t :: %__MODULE__{
          isbn: String.t() | nil,
          title: String.t() | nil,
          subtitle: String.t() | nil,
          authors: [String.t()] | nil,
          publisher: String.t() | nil,
          synopsis: String.t() | nil,
          dimensions: Dimensions.t() | nil,
          year: integer() | nil,
          format: String.t() | nil,
          page_count: integer() | nil,
          subjects: [String.t()] | nil,
          location: String.t() | nil,
          retail_price: number() | nil,
          cover_url: String.t() | nil,
          provider: String.t() | nil
        }

  @derive Jason.Encoder
  defstruct [
    :isbn,
    :title,
    :subtitle,
    :authors,
    :publisher,
    :synopsis,
    :dimensions,
    :year,
    :format,
    :page_count,
    :subjects,
    :location,
    :retail_price,
    :cover_url,
    :provider
  ]

  @doc """
  Creates a Book struct from API response data.
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      isbn: Map.get(map, "isbn"),
      title: Map.get(map, "title"),
      subtitle: Map.get(map, "subtitle"),
      authors: Map.get(map, "authors"),
      publisher: Map.get(map, "publisher"),
      synopsis: Map.get(map, "synopsis"),
      dimensions: Dimensions.from_map(Map.get(map, "dimensions")),
      year: Map.get(map, "year"),
      format: Map.get(map, "format"),
      page_count: Map.get(map, "page_count"),
      subjects: Map.get(map, "subjects"),
      location: Map.get(map, "location"),
      retail_price: Map.get(map, "retail_price"),
      cover_url: Map.get(map, "cover_url"),
      provider: Map.get(map, "provider")
    }
  end
end
