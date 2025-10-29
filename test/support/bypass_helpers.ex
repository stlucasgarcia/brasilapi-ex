defmodule Brasilapi.BypassHelpers do
  @moduledoc """
  Helper functions for setting up Bypass in tests.

  This module provides common setup functionality for API tests using Bypass.
  """

  @doc """
  Sets up a Bypass instance and configures the application base_url for testing.

  This function should be called from a test module's `setup` block. It will:
  - Store the original base_url configuration
  - Create a new Bypass instance
  - Override the base_url to point to the Bypass server
  - Register a cleanup function to restore the original base_url

  ## Example

      setup do
        BypassHelpers.setup_bypass_for_base_url()
      end

  ## Returns

  `{:ok, bypass: bypass, base_url: base_url}`
  """
  def setup_bypass_for_base_url do
    # Store original base_url to restore later
    original_base_url = Application.get_env(:brasilapi, :base_url)

    bypass = Bypass.open()
    base_url = "http://localhost:#{bypass.port}/api"

    # Override the base URL for testing
    Application.put_env(:brasilapi, :base_url, base_url)

    ExUnit.Callbacks.on_exit(fn ->
      if original_base_url do
        Application.put_env(:brasilapi, :base_url, original_base_url)
      else
        Application.delete_env(:brasilapi, :base_url)
      end
    end)

    {:ok, bypass: bypass, base_url: base_url}
  end
end
