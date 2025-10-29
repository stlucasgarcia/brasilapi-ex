defmodule Brasilapi.CnpjTest do
  use ExUnit.Case, async: false

  alias Brasilapi.Cnpj
  alias Brasilapi.Cnpj.Company
  alias Brasilapi.BypassHelpers

  setup do
    BypassHelpers.setup_bypass_for_base_url()
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
