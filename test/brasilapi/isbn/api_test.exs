defmodule Brasilapi.Isbn.APITest do
  use ExUnit.Case, async: false

  alias Brasilapi.Isbn.API
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

  describe "get_book/2" do
    test "returns book on success with ISBN-13 string", %{bypass: bypass} do
      expected_response = %{
        "isbn" => "9788545702870",
        "title" => "Akira",
        "subtitle" => nil,
        "authors" => [
          "KATSUHIRO OTOMO",
          "DRIK SADA",
          "CASSIUS MEDAUAR",
          "MARCELO DEL GRECO",
          "DENIS TAKATA"
        ],
        "publisher" => "Japorama Editora e Comunicação",
        "synopsis" =>
          "Um dos marcos da ficção científica oriental que revolucionou a chegada dos mangás e da cultura pop japonesa no Ocidente retorna em uma nova edição especial.",
        "dimensions" => %{
          "width" => 17.5,
          "height" => 25.7,
          "unit" => "CENTIMETER"
        },
        "year" => 2017,
        "format" => "PHYSICAL",
        "page_count" => 364,
        "subjects" => [
          "Cartoons; caricaturas e quadrinhos",
          "mangá",
          "motocicleta",
          "gangue",
          "Delinquência"
        ],
        "location" => "SÃO PAULO, SP",
        "retail_price" => nil,
        "cover_url" => nil,
        "provider" => "cbl"
      }

      Bypass.expect(bypass, "GET", "/api/isbn/v1/9788545702870", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, book} = API.get_book("9788545702870")

      assert %Book{
               isbn: "9788545702870",
               title: "Akira",
               subtitle: nil,
               authors: [
                 "KATSUHIRO OTOMO",
                 "DRIK SADA",
                 "CASSIUS MEDAUAR",
                 "MARCELO DEL GRECO",
                 "DENIS TAKATA"
               ],
               publisher: "Japorama Editora e Comunicação",
               synopsis:
                 "Um dos marcos da ficção científica oriental que revolucionou a chegada dos mangás e da cultura pop japonesa no Ocidente retorna em uma nova edição especial.",
               year: 2017,
               format: "PHYSICAL",
               page_count: 364,
               subjects: [
                 "Cartoons; caricaturas e quadrinhos",
                 "mangá",
                 "motocicleta",
                 "gangue",
                 "Delinquência"
               ],
               location: "SÃO PAULO, SP",
               retail_price: nil,
               cover_url: nil,
               provider: "cbl"
             } = book

      assert book.dimensions != nil
      assert book.dimensions.width == 17.5
      assert book.dimensions.height == 25.7
      assert book.dimensions.unit == "CENTIMETER"
    end

    test "handles formatted ISBN-13 string", %{bypass: bypass} do
      expected_response = %{
        "isbn" => "9788545702870",
        "title" => "Akira",
        "provider" => "cbl"
      }

      Bypass.expect(bypass, "GET", "/api/isbn/v1/9788545702870", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, book} = API.get_book("978-85-457-0287-0")

      assert %Book{
               isbn: "9788545702870",
               title: "Akira",
               provider: "cbl"
             } = book
    end

    test "handles ISBN-10 string", %{bypass: bypass} do
      expected_response = %{
        "isbn" => "8545702876",
        "title" => "Test Book",
        "provider" => "cbl"
      }

      Bypass.expect(bypass, "GET", "/api/isbn/v1/8545702876", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, book} = API.get_book("8545702876")

      assert %Book{
               isbn: "8545702876",
               title: "Test Book",
               provider: "cbl"
             } = book
    end

    test "handles formatted ISBN-10 string", %{bypass: bypass} do
      expected_response = %{
        "isbn" => "8545702876",
        "title" => "Test Book",
        "provider" => "cbl"
      }

      Bypass.expect(bypass, "GET", "/api/isbn/v1/8545702876", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, book} = API.get_book("85-457-0287-6")

      assert %Book{
               isbn: "8545702876",
               title: "Test Book",
               provider: "cbl"
             } = book
    end

    test "returns book with single provider specified", %{bypass: bypass} do
      expected_response = %{
        "isbn" => "9788545702870",
        "title" => "Akira",
        "provider" => "cbl"
      }

      Bypass.expect(bypass, "GET", "/api/isbn/v1/9788545702870", fn conn ->
        assert conn.query_string == "providers=cbl"

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, book} = API.get_book("9788545702870", providers: ["cbl"])

      assert %Book{
               isbn: "9788545702870",
               title: "Akira",
               provider: "cbl"
             } = book
    end

    test "returns book with multiple providers specified", %{bypass: bypass} do
      expected_response = %{
        "isbn" => "9788545702870",
        "title" => "Akira",
        "provider" => "google-books"
      }

      Bypass.expect(bypass, "GET", "/api/isbn/v1/9788545702870", fn conn ->
        assert conn.query_string == "providers=cbl%2Cgoogle-books"

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, book} = API.get_book("9788545702870", providers: ["cbl", "google-books"])

      assert %Book{
               isbn: "9788545702870",
               title: "Akira",
               provider: "google-books"
             } = book
    end

    test "returns error on API failure - ISBN not found", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/isbn/v1/1234567890123", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(404, Jason.encode!(%{error: "ISBN não encontrado"}))
      end)

      assert {:error, %{status: 404}} = API.get_book("1234567890123")
    end

    test "returns error on server error", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/isbn/v1/9788545702870", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(
          500,
          Jason.encode!(%{error: "Todos os serviços de ISBN retornaram erro"})
        )
      end)

      assert {:error, %{status: 500}} = API.get_book("9788545702870")
    end

    test "returns error for invalid ISBN format - too short" do
      assert {:error, %{message: "Invalid ISBN format. Must be 10 or 13 digits."}} =
               API.get_book("123")
    end

    test "returns error for invalid ISBN format - too long" do
      assert {:error, %{message: "Invalid ISBN format. Must be 10 or 13 digits."}} =
               API.get_book("12345678901234")
    end

    test "returns error for invalid ISBN format - contains letters" do
      assert {:error, %{message: "Invalid ISBN format. Must be 10 or 13 digits."}} =
               API.get_book("978854570287A")
    end

    test "returns error for invalid ISBN type" do
      assert {:error, %{message: "ISBN must be a string"}} =
               API.get_book(9_788_545_702_870)
    end

    test "returns error for invalid provider" do
      assert {:error, %{message: message}} = API.get_book("9788545702870", providers: ["invalid"])
      assert String.contains?(message, "Invalid providers: invalid")

      assert String.contains?(
               message,
               "Valid providers are: cbl, mercado-editorial, open-library, google-books"
             )
    end

    test "returns error for multiple invalid providers" do
      assert {:error, %{message: message}} =
               API.get_book("9788545702870", providers: ["invalid1", "invalid2"])

      assert String.contains?(message, "Invalid providers: invalid1, invalid2")
    end

    test "returns error for mixed valid and invalid providers" do
      assert {:error, %{message: message}} =
               API.get_book("9788545702870", providers: ["cbl", "invalid"])

      assert String.contains?(message, "Invalid providers: invalid")
    end

    test "returns error for non-list providers" do
      assert {:error, %{message: message}} = API.get_book("9788545702870", providers: "cbl")
      assert String.contains?(message, "Providers must be a list of strings")
    end

    test "handles connection failure", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %{message: _}} = API.get_book("9788545702870")
    end

    test "handles book with null dimensions", %{bypass: bypass} do
      expected_response = %{
        "isbn" => "9788545702870",
        "title" => "Book Without Dimensions",
        "dimensions" => nil,
        "provider" => "cbl"
      }

      Bypass.expect(bypass, "GET", "/api/isbn/v1/9788545702870", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, book} = API.get_book("9788545702870")

      assert %Book{
               isbn: "9788545702870",
               title: "Book Without Dimensions",
               dimensions: nil,
               provider: "cbl"
             } = book
    end

    test "handles all valid providers", %{bypass: bypass} do
      valid_providers = ["cbl", "mercado-editorial", "open-library", "google-books"]

      Enum.each(valid_providers, fn provider ->
        expected_response = %{
          "isbn" => "9788545702870",
          "title" => "Test Book",
          "provider" => provider
        }

        Bypass.expect(bypass, "GET", "/api/isbn/v1/9788545702870", fn conn ->
          assert conn.query_string == "providers=#{provider}"

          conn
          |> Plug.Conn.put_resp_header("content-type", "application/json")
          |> Plug.Conn.resp(200, Jason.encode!(expected_response))
        end)

        assert {:ok, book} = API.get_book("9788545702870", providers: [provider])
        assert book.provider == provider
      end)
    end
  end
end
