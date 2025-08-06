defmodule Brasilapi.RegistroBrTest do
  use ExUnit.Case, async: false

  alias Brasilapi.RegistroBr
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

  describe "get_domain_info/1 delegation" do
    test "delegates to API.get_domain_info/1", %{bypass: bypass} do
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
          "blog.br"
        ]
      }

      Bypass.expect(bypass, "GET", "/api/registrobr/v1/brasilapi.com.br", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, domain} = RegistroBr.get_domain_info("brasilapi.com.br")

      assert %Domain{
               status_code: 2,
               status: "REGISTERED",
               fqdn: "brasilapi.com.br",
               hosts: ["bob.ns.cloudflare.com", "lily.ns.cloudflare.com"]
             } = domain
    end
  end
end
