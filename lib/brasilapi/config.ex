defmodule Brasilapi.Config do
  @moduledoc """
  Configuration module for BrasilAPI client.
  """

  @default_base_url "https://brasilapi.com.br/api"
  @default_timeout 30_000
  @default_retry_attempts 3
  @env (if Code.ensure_loaded?(Mix), do: Mix.env(), else: :prod)

  @doc """
  Returns the base URL for BrasilAPI.

  Can be overridden via application environment or system environment.
  """
  @spec base_url() :: String.t()
  def base_url do
    Application.get_env(:brasilapi, :base_url) ||
      System.get_env("BRASILAPI_BASE_URL") ||
      @default_base_url
  end

  @doc """
  Returns the request timeout in milliseconds.
  """
  @spec timeout() :: pos_integer()
  def timeout do
    Application.get_env(:brasilapi, :timeout, @default_timeout)
  end

  @doc """
  Returns the number of retry attempts for failed requests.
  """
  @spec retry_attempts() :: non_neg_integer()
  def retry_attempts do
    Application.get_env(:brasilapi, :retry_attempts, @default_retry_attempts)
  end

  @doc """
  Returns additional Req options for HTTP requests.

  Automatically disables retries in test environment for faster tests.
  """
  @spec req_options() :: keyword()
  def req_options do
    if @env == :test do
      Application.get_env(:brasilapi, :req_options, []) ++ [retry: false, max_retries: 0]
    else
      Application.get_env(:brasilapi, :req_options, [])
    end
  end
end
