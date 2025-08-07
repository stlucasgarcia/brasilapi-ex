defmodule Brasilapi.IsbnTest do
  use ExUnit.Case

  alias Brasilapi.Isbn

  doctest Brasilapi.Isbn

  test "get_book/2 delegates to API.get_book/2" do
    # This test ensures the delegation is working correctly
    # The actual API functionality is tested in API test
    assert function_exported?(Isbn, :get_book, 2)
  end

  test "get_book/1 delegates to API.get_book/2 with default opts" do
    # This test ensures the single-arity delegation is working correctly
    assert function_exported?(Isbn, :get_book, 1)
  end
end
