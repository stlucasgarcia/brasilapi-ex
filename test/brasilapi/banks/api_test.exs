defmodule Brasilapi.Banks.APITest do
  use ExUnit.Case, async: false

  alias Brasilapi.Banks.{API, Bank}
  alias Brasilapi.BypassHelpers

  setup do
    BypassHelpers.setup_bypass_for_base_url()
  end

  describe "get_banks/0" do
    test "returns list of banks on successful response", %{bypass: bypass} do
      expected_response = [
        %{
          "ispb" => "00000000",
          "name" => "BCO DO BRASIL S.A.",
          "code" => 1,
          "fullName" => "Banco do Brasil S.A."
        },
        %{
          "ispb" => "00000208",
          "name" => "BCO ORIGINAL S.A.",
          "code" => 212,
          "fullName" => "Banco Original S.A."
        }
      ]

      Bypass.expect(bypass, "GET", "/api/banks/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, banks} = API.get_banks()
      assert length(banks) == 2

      assert [
               %Bank{
                 ispb: "00000000",
                 name: "BCO DO BRASIL S.A.",
                 code: 1,
                 full_name: "Banco do Brasil S.A."
               },
               %Bank{
                 ispb: "00000208",
                 name: "BCO ORIGINAL S.A.",
                 code: 212,
                 full_name: "Banco Original S.A."
               }
             ] = banks
    end

    test "returns error on non-200 response", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/banks/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(500, Jason.encode!(%{"error" => "Internal server error"}))
      end)

      assert {:error, %{status: 500, message: "Server error"}} = API.get_banks()
    end

    test "returns error on network failure", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %{reason: :econnrefused, message: "Network error"}} = API.get_banks()
    end

    test "filters out banks with nil code or empty ispb", %{bypass: bypass} do
      expected_response = [
        %{
          "ispb" => "00000000",
          "name" => "BCO DO BRASIL S.A.",
          "code" => 1,
          "fullName" => "Banco do Brasil S.A."
        },
        %{
          "ispb" => "",
          "name" => "INVALID BANK 1",
          "code" => 2,
          "fullName" => "Invalid Bank 1"
        },
        %{
          "ispb" => "12345678",
          "name" => "VALID BANK",
          "code" => 3,
          "fullName" => "Valid Bank S.A."
        },
        %{
          "ispb" => "99999999",
          "name" => "INVALID BANK 2",
          "code" => nil,
          "fullName" => "Invalid Bank 2"
        }
      ]

      Bypass.expect(bypass, "GET", "/api/banks/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, banks} = API.get_banks()
      assert length(banks) == 2

      # Should only contain banks with valid ispb (not empty) and code (not nil)
      assert [
               %Bank{
                 ispb: "00000000",
                 name: "BCO DO BRASIL S.A.",
                 code: 1,
                 full_name: "Banco do Brasil S.A."
               },
               %Bank{
                 ispb: "12345678",
                 name: "VALID BANK",
                 code: 3,
                 full_name: "Valid Bank S.A."
               }
             ] = banks
    end
  end

  describe "get_bank_by_code/1" do
    test "returns bank on successful response", %{bypass: bypass} do
      expected_response = %{
        "ispb" => "00000000",
        "name" => "BCO DO BRASIL S.A.",
        "code" => 1,
        "fullName" => "Banco do Brasil S.A."
      }

      Bypass.expect(bypass, "GET", "/api/banks/v1/1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, bank} = API.get_bank_by_code(1)

      assert %Bank{
               ispb: "00000000",
               name: "BCO DO BRASIL S.A.",
               code: 1,
               full_name: "Banco do Brasil S.A."
             } = bank
    end

    test "returns error on 404 response", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/banks/v1/999999", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(404, Jason.encode!(%{"error" => "Bank not found"}))
      end)

      assert {:error, %{status: 404, message: "Not found"}} = API.get_bank_by_code(999_999)
    end

    test "returns error on non-200 response", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/banks/v1/1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(500, Jason.encode!(%{"error" => "Internal server error"}))
      end)

      assert {:error, %{status: 500, message: "Server error"}} = API.get_bank_by_code(1)
    end

    test "returns error on network failure", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %{reason: :econnrefused, message: "Network error"}} = API.get_bank_by_code(1)
    end

    test "accepts string code", %{bypass: bypass} do
      expected_response = %{
        "ispb" => "00000000",
        "name" => "BCO DO BRASIL S.A.",
        "code" => 1,
        "fullName" => "Banco do Brasil S.A."
      }

      Bypass.expect(bypass, "GET", "/api/banks/v1/1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, bank} = API.get_bank_by_code("1")

      assert %Bank{
               ispb: "00000000",
               name: "BCO DO BRASIL S.A.",
               code: 1,
               full_name: "Banco do Brasil S.A."
             } = bank
    end

    test "returns error for invalid code type" do
      assert {:error, %{message: "Code must be an integer or string"}} = API.get_bank_by_code(nil)
      assert {:error, %{message: "Code must be an integer or string"}} = API.get_bank_by_code(%{})
    end
  end
end
