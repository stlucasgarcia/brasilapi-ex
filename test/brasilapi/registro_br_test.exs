defmodule Brasilapi.RegistroBrTest do
  use ExUnit.Case, async: false

  alias Brasilapi.RegistroBr
  alias Brasilapi.RegistroBr.Domain
  alias Brasilapi.BypassHelpers

  setup do
    BypassHelpers.setup_bypass_for_base_url()
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
