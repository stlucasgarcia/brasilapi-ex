defmodule Brasilapi.Isbn do
  @moduledoc """
  ISBN (International Standard Book Number) module for BrasilAPI.

  This module provides the main interface for ISBN book information,
  allowing users to get detailed book data including title, authors,
  publisher, synopsis, and other metadata.
  """

  alias Brasilapi.Isbn.API

  @doc """
  Gets book information by ISBN.

  Delegates to `Brasilapi.Isbn.API.get_book/2`.
  """
  defdelegate get_book(isbn, opts \\ []), to: API
end
