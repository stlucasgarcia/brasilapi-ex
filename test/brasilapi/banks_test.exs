defmodule Brasilapi.BanksTest do
  use ExUnit.Case, async: false

  alias Brasilapi.Banks
  alias Brasilapi.Banks.Bank

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

  describe "get_all/0 delegation" do
    test "delegates to API.get_all/0", %{bypass: bypass} do
      expected_response = [
        %{
          "ispb" => "00000000",
          "name" => "BCO DO BRASIL S.A.",
          "code" => 1,
          "fullName" => "Banco do Brasil S.A."
        }
      ]

      Bypass.expect(bypass, "GET", "/api/banks/v1", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, [bank]} = Banks.get_all()
      assert %Bank{ispb: "00000000", name: "BCO DO BRASIL S.A."} = bank
    end
  end

  describe "get_by_code/1 delegation" do
    test "delegates to API.get_by_code/1", %{bypass: bypass} do
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

      assert {:ok, bank} = Banks.get_by_code(1)
      assert %Bank{ispb: "00000000", name: "BCO DO BRASIL S.A."} = bank
    end
  end
end