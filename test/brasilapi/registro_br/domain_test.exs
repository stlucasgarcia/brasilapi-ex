defmodule Brasilapi.RegistroBr.DomainTest do
  use ExUnit.Case

  alias Brasilapi.RegistroBr.Domain

  describe "from_map/1" do
    test "creates Domain struct from valid map" do
      map = %{
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

      result = Domain.from_map(map)

      assert %Domain{
               status_code: 2,
               status: "REGISTERED",
               fqdn: "brasilapi.com.br",
               hosts: ["bob.ns.cloudflare.com", "lily.ns.cloudflare.com"],
               publication_status: "published",
               expires_at: "2022-09-23T00:00:00-03:00",
               suggestions: ["agr.br", "app.br", "art.br", "blog.br"]
             } = result
    end

    test "creates Domain struct with different values" do
      map = %{
        "status_code" => 1,
        "status" => "AVAILABLE",
        "fqdn" => "available-domain.com.br",
        "hosts" => [],
        "publication-status" => "not-published",
        "expires-at" => nil,
        "suggestions" => [
          "net.br",
          "org.br",
          "edu.br"
        ]
      }

      result = Domain.from_map(map)

      assert %Domain{
               status_code: 1,
               status: "AVAILABLE",
               fqdn: "available-domain.com.br",
               hosts: [],
               publication_status: "not-published",
               expires_at: nil,
               suggestions: ["net.br", "org.br", "edu.br"],
               exempt: nil,
               fqdnace: nil
             } = result
    end

    test "creates Domain struct with exempt and fqdnace fields" do
      map = %{
        "exempt" => false,
        "fqdn" => "available-domain.com.br",
        "fqdnace" => "",
        "status" => "AVAILABLE",
        "status_code" => 0
      }

      result = Domain.from_map(map)

      assert %Domain{
               status_code: 0,
               status: "AVAILABLE",
               fqdn: "available-domain.com.br",
               hosts: nil,
               publication_status: nil,
               expires_at: nil,
               suggestions: nil,
               exempt: false,
               fqdnace: ""
             } = result
    end
  end

  describe "Jason.Encoder" do
    test "encodes Domain struct to JSON" do
      domain = %Domain{
        status_code: 2,
        status: "REGISTERED",
        fqdn: "brasilapi.com.br",
        hosts: ["bob.ns.cloudflare.com", "lily.ns.cloudflare.com"],
        publication_status: "published",
        expires_at: "2022-09-23T00:00:00-03:00",
        suggestions: ["agr.br", "app.br"]
      }

      json_string = Jason.encode!(domain)
      decoded = Jason.decode!(json_string)

      assert %{
               "status_code" => 2,
               "status" => "REGISTERED",
               "fqdn" => "brasilapi.com.br",
               "hosts" => ["bob.ns.cloudflare.com", "lily.ns.cloudflare.com"],
               "publication_status" => "published",
               "expires_at" => "2022-09-23T00:00:00-03:00",
               "suggestions" => ["agr.br", "app.br"]
             } = decoded
    end
  end
end
