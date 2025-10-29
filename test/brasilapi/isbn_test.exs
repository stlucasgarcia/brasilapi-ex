defmodule Brasilapi.IsbnTest do
  use ExUnit.Case, async: false

  alias Brasilapi.Isbn
  alias Brasilapi.Isbn.Book

  setup do
    # Store original base_url to restore later
    original_base_url = Application.get_env(:brasilapi, :base_url)

    bypass = Bypass.open()
    base_url = "http://localhost:#{bypass.port}/api"

    # Override the base URL for testing
    Application.put_env(:brasilapi, :base_url, base_url)

    on_exit(fn ->
      if original_base_url do
        Application.put_env(:brasilapi, :base_url, original_base_url)
      else
        Application.delete_env(:brasilapi, :base_url)
      end
    end)

    {:ok, bypass: bypass, base_url: base_url}
  end

  describe "get_book/1 delegation" do
    test "delegates to API.get_book/2 with default opts", %{bypass: bypass} do
      expected_response = %{
        "isbn" => "9781234567890",
        "title" => "Sample Book Title",
        "subtitle" => "A Sample Subtitle",
        "authors" => ["Author Name"],
        "publisher" => "Sample Publisher",
        "synopsis" => "This is a sample book synopsis.",
        "year" => 2020,
        "format" => "PHYSICAL",
        "page_count" => 250,
        "provider" => "cbl"
      }

      Bypass.expect(bypass, "GET", "/api/isbn/v1/9781234567890", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, book} = Isbn.get_book("9781234567890")

      assert %Book{
               isbn: "9781234567890",
               title: "Sample Book Title",
               subtitle: "A Sample Subtitle",
               authors: ["Author Name"],
               publisher: "Sample Publisher"
             } = book
    end
  end

  describe "get_book/2 delegation" do
    test "delegates to API.get_book/2 with providers option", %{bypass: bypass} do
      expected_response = %{
        "isbn" => "9781234567890",
        "title" => "Sample Book Title",
        "authors" => ["Author Name"],
        "publisher" => "Sample Publisher",
        "provider" => "cbl"
      }

      Bypass.expect(bypass, "GET", "/api/isbn/v1/9781234567890", fn conn ->
        assert conn.query_string == "providers=cbl"

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, book} = Isbn.get_book("9781234567890", providers: ["cbl"])

      assert %Book{
               isbn: "9781234567890",
               title: "Sample Book Title",
               provider: "cbl"
             } = book
    end
  end
end
