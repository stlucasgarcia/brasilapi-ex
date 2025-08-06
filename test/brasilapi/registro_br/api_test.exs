defmodule Brasilapi.RegistroBr.APITest do
  use ExUnit.Case, async: false

  alias Brasilapi.RegistroBr.API
  alias Brasilapi.RegistroBr.Domain

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

  describe "get_domain_info/1" do
    test "returns domain information when domain is found", %{bypass: bypass} do
      expected_response = %{
        "status_code" => 2,
        "status" => "REGISTERED",
        "fqdn" => "brasilapi.com.br",
        "hosts" => [
          "bob.ns.cloudflare.com",
          "lily.ns.cloudflare.com"
        ],
        "publication-status" => "published",
        "expires-at" => "2022-09-23T00:00:00-03:00",
        "suggestions" => [
          "agr.br",
          "app.br",
          "art.br",
          "blog.br",
          "dev.br",
          "eco.br"
        ]
      }

      Bypass.expect(bypass, "GET", "/api/registrobr/v1/brasilapi.com.br", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, domain} = API.get_domain_info("brasilapi.com.br")

      assert %Domain{
               status_code: 2,
               status: "REGISTERED",
               fqdn: "brasilapi.com.br",
               hosts: ["bob.ns.cloudflare.com", "lily.ns.cloudflare.com"],
               publication_status: "published",
               expires_at: "2022-09-23T00:00:00-03:00",
               suggestions: ["agr.br", "app.br", "art.br", "blog.br", "dev.br", "eco.br"]
             } = domain
    end

    test "returns error when domain is not found or invalid", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/registrobr/v1/invalid-domain.com.br", fn conn ->
        Plug.Conn.resp(conn, 400, "Bad Request")
      end)

      assert {:error, %{status: 400, message: "Bad request"}} =
               API.get_domain_info("invalid-domain.com.br")
    end

    test "returns error when request fails", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/registrobr/v1/test.com.br", fn conn ->
        Plug.Conn.resp(conn, 500, "Internal Server Error")
      end)

      assert {:error, %{status: 500, message: "Server error"}} =
               API.get_domain_info("test.com.br")
    end

    test "returns error for invalid domain parameter" do
      assert {:error, %{message: "Domain must be a string"}} = API.get_domain_info(123)
      assert {:error, %{message: "Domain must be a string"}} = API.get_domain_info(nil)
    end

    test "returns error when connection fails", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %{reason: :econnrefused, message: "Network error"}} =
               API.get_domain_info("test.com.br")
    end
  end
end
