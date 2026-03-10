defmodule Brasilapi.Config do
  @moduledoc """
  Configuration module for BrasilAPI client.
  """

  @default_base_url "https://brasilapi.com.br/api"
  @default_timeout 30_000
  @default_retry_attempts 3

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
  """
  @spec req_options() :: keyword()
  def req_options do
    Application.get_env(:brasilapi, :req_options, [])
  end

  @doc """
  Returns retry options for Req based on the configured retry attempts.

  Retries are disabled automatically in test environment to keep tests fast
  and avoid repeated network failures against Bypass.
  """
  @spec retry_options() :: keyword()
  def retry_options do
    if test_env?() do
      [retry: false, max_retries: 0]
    else
      build_retry_options(retry_attempts())
    end
  end

  defp build_retry_options(retry_attempts) when retry_attempts > 0,
    do: [retry: :transient, max_retries: retry_attempts]

  defp build_retry_options(_retry_attempts), do: [retry: false, max_retries: 0]

  defp test_env? do
    Code.ensure_loaded?(Mix) and function_exported?(Mix, :env, 0) and Mix.env() == :test
  end
end
