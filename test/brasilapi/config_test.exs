defmodule Brasilapi.ConfigTest do
  use ExUnit.Case, async: false

  alias Brasilapi.Config

  describe "base_url/0" do
    test "returns default base URL when not configured" do
      Application.delete_env(:brasilapi, :base_url)
      System.delete_env("BRASILAPI_BASE_URL")

      assert Config.base_url() == "https://brasilapi.com.br/api"
    end

    test "returns application env base URL when configured" do
      test_url = "https://test.example.com/api"
      Application.put_env(:brasilapi, :base_url, test_url)

      on_exit(fn ->
        Application.delete_env(:brasilapi, :base_url)
      end)

      assert Config.base_url() == test_url
    end

    test "returns system env base URL when configured" do
      test_url = "https://env.example.com/api"
      System.put_env("BRASILAPI_BASE_URL", test_url)

      on_exit(fn ->
        System.delete_env("BRASILAPI_BASE_URL")
      end)

      assert Config.base_url() == test_url
    end

    test "application env takes precedence over system env" do
      app_url = "https://app.example.com/api"
      env_url = "https://env.example.com/api"

      Application.put_env(:brasilapi, :base_url, app_url)
      System.put_env("BRASILAPI_BASE_URL", env_url)

      on_exit(fn ->
        Application.delete_env(:brasilapi, :base_url)
        System.delete_env("BRASILAPI_BASE_URL")
      end)

      assert Config.base_url() == app_url
    end
  end

  describe "timeout/0" do
    test "returns default timeout when not configured" do
      Application.delete_env(:brasilapi, :timeout)

      assert Config.timeout() == 30_000
    end

    test "returns configured timeout" do
      Application.put_env(:brasilapi, :timeout, 60_000)

      on_exit(fn ->
        Application.delete_env(:brasilapi, :timeout)
      end)

      assert Config.timeout() == 60_000
    end
  end

  describe "retry_attempts/0" do
    test "returns default retry attempts when not configured" do
      Application.delete_env(:brasilapi, :retry_attempts)

      # Should be 0 in test environment
      assert Config.retry_attempts() == 3
    end

    test "returns the custom retry value when configured" do
      Application.put_env(:brasilapi, :retry_attempts, 5)

      on_exit(fn ->
        Application.delete_env(:brasilapi, :retry_attempts)
      end)

      assert Config.retry_attempts() == 5
    end
  end

  describe "req_options/0" do
    # Remove testing environment override for these tests
    setup do
      original_env = Mix.env()
      Mix.env(:dev)

      on_exit(fn ->
        Mix.env(original_env)
      end)

      :ok
    end

    test "returns empty options when not configured" do
      Application.delete_env(:brasilapi, :req_options)

      assert Config.req_options() == []
    end

    test "returns configured options" do
      options = [headers: %{"custom" => "header"}]
      Application.put_env(:brasilapi, :req_options, options)

      on_exit(fn ->
        Application.delete_env(:brasilapi, :req_options)
      end)

      assert Config.req_options() == options
    end
  end
end
