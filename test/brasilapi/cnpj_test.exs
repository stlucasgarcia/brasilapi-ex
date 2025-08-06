defmodule Brasilapi.CnpjTest do
  use ExUnit.Case, async: false

  alias Brasilapi.Cnpj
  alias Brasilapi.Cnpj.Company

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

  describe "get_by_cnpj/1" do
    test "delegates to API.get_by_cnpj/1", %{bypass: bypass} do
      expected_response = %{
        "cnpj" => "12345678000195",
        "razao_social" => "ACME INC"
      }

      Bypass.expect(bypass, "GET", "/api/cnpj/v1/12345678000195", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, company} = Cnpj.get_by_cnpj("12345678000195")

      assert %Company{
               cnpj: "12345678000195",
               razao_social: "ACME INC"
             } = company
    end
  end
end
