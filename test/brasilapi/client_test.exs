defmodule Brasilapi.ClientTest do
  use ExUnit.Case, async: false

  alias Brasilapi.Client

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

  describe "get/2" do
    test "returns success response for 200 status", %{bypass: bypass} do
      expected_body = %{"data" => "test"}

      Bypass.expect(bypass, "GET", "/api/test", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_body))
      end)

      assert {:ok, ^expected_body} = Client.get("/test")
    end

    test "returns error for 404 status", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/not-found", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(404, Jason.encode!(%{"error" => "Not found"}))
      end)

      assert {:error, %{status: 404, message: "Not found"}} = Client.get("/not-found")
    end

    test "returns error for 500 status", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/api/error", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(500, Jason.encode!(%{"error" => "Server error"}))
      end)

      assert {:error, %{status: 500, message: "Server error"}} = Client.get("/error")
    end

    test "returns error for network failure", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %{reason: :econnrefused, message: "Network error"}} = Client.get("/test")
    end
  end

  describe "post/3" do
    test "returns success response for 201 status", %{bypass: bypass} do
      request_body = %{"name" => "test"}
      expected_response = %{"id" => 1, "name" => "test"}

      Bypass.expect(bypass, "POST", "/api/create", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert Jason.decode!(body) == request_body

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(201, Jason.encode!(expected_response))
      end)

      assert {:ok, ^expected_response} = Client.post("/create", request_body)
    end

    test "returns error for 400 status", %{bypass: bypass} do
      Bypass.expect(bypass, "POST", "/api/bad-request", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(400, Jason.encode!(%{"error" => "Bad request"}))
      end)

      assert {:error, %{status: 400, message: "Bad request"}} =
               Client.post("/bad-request", %{})
    end
  end

  describe "put/3" do
    test "returns success response for 200 status", %{bypass: bypass} do
      request_body = %{"name" => "updated"}
      expected_response = %{"id" => 1, "name" => "updated"}

      Bypass.expect(bypass, "PUT", "/api/update/1", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert Jason.decode!(body) == request_body

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, ^expected_response} = Client.put("/update/1", request_body)
    end
  end

  describe "delete/2" do
    test "returns success response for 204 status", %{bypass: bypass} do
      Bypass.expect(bypass, "DELETE", "/api/delete/1", fn conn ->
        conn
        |> Plug.Conn.resp(204, "")
      end)

      assert {:ok, ""} = Client.delete("/delete/1")
    end

    test "returns error for 403 status", %{bypass: bypass} do
      Bypass.expect(bypass, "DELETE", "/api/forbidden", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(403, Jason.encode!(%{"error" => "Forbidden"}))
      end)

      assert {:error, %{status: 403, message: "Forbidden"}} = Client.delete("/forbidden")
    end
  end
end
