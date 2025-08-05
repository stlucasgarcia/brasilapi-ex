defmodule Brasilapi.Client do
  @moduledoc """
  HTTP client for BrasilAPI endpoints.
  
  Provides a consistent interface for making HTTP requests to BrasilAPI
  with proper error handling, retries, and response parsing.
  """

  alias Brasilapi.Config

  @type success_response :: {:ok, term()}
  @type error_response :: {:error, map()}
  @type response :: success_response() | error_response()

  @doc """
  Makes a GET request to the specified path.
  
  ## Parameters
  
    * `path` - The API path (without base URL)
    * `opts` - Additional options (optional)
  
  ## Examples
  
      iex> Brasilapi.Client.get("/banks/v1")
      {:ok, [%{"ispb" => "00000000", "name" => "BCO DO BRASIL S.A.", ...}]}
      
      iex> Brasilapi.Client.get("/banks/v1/999999")
      {:error, %{status: 404, message: "Not found"}}
  
  """
  @spec get(String.t(), keyword()) :: response()
  def get(path, opts \\ []) do
    url = build_url(path)
    req_opts = build_req_options(opts)

    case Req.get(url, req_opts) do
      {:ok, %Req.Response{status: status, body: body}} ->
        handle_response(status, body)

      {:error, exception} ->
        handle_exception(exception)
    end
  end

  @doc """
  Makes a POST request to the specified path.
  
  ## Parameters
  
    * `path` - The API path (without base URL)
    * `body` - The request body
    * `opts` - Additional options (optional)
  
  """
  @spec post(String.t(), term(), keyword()) :: response()
  def post(path, body, opts \\ []) do
    url = build_url(path)
    req_opts = build_req_options([json: body] ++ opts)

    case Req.post(url, req_opts) do
      {:ok, %Req.Response{status: status, body: response_body}} ->
        handle_response(status, response_body)

      {:error, exception} ->
        handle_exception(exception)
    end
  end

  @doc """
  Makes a PUT request to the specified path.
  
  ## Parameters
  
    * `path` - The API path (without base URL)
    * `body` - The request body
    * `opts` - Additional options (optional)
  
  """
  @spec put(String.t(), term(), keyword()) :: response()
  def put(path, body, opts \\ []) do
    url = build_url(path)
    req_opts = build_req_options([json: body] ++ opts)

    case Req.put(url, req_opts) do
      {:ok, %Req.Response{status: status, body: response_body}} ->
        handle_response(status, response_body)

      {:error, exception} ->
        handle_exception(exception)
    end
  end

  @doc """
  Makes a DELETE request to the specified path.
  
  ## Parameters
  
    * `path` - The API path (without base URL)
    * `opts` - Additional options (optional)
  
  """
  @spec delete(String.t(), keyword()) :: response()
  def delete(path, opts \\ []) do
    url = build_url(path)
    req_opts = build_req_options(opts)

    case Req.delete(url, req_opts) do
      {:ok, %Req.Response{status: status, body: body}} ->
        handle_response(status, body)

      {:error, exception} ->
        handle_exception(exception)
    end
  end

  # Private functions

  @spec build_url(String.t()) :: String.t()
  defp build_url(path) do
    base_url = Config.base_url()
    Path.join(base_url, path)
  end

  @spec build_req_options(keyword()) :: keyword()
  defp build_req_options(opts) do
    retry_attempts = Config.retry_attempts()
    
    default_opts = [
      receive_timeout: Config.timeout()
    ]
    
    # Only add retry options if retries are enabled
    default_opts = if retry_attempts > 0 do
      default_opts ++ [retry: :transient, max_retries: retry_attempts]
    else
      default_opts ++ [retry: false, max_retries: 0]
    end

    config_opts = Config.req_options()
    
    default_opts
    |> Keyword.merge(config_opts)
    |> Keyword.merge(opts)
  end

  @spec handle_response(pos_integer(), term()) :: response()
  defp handle_response(status, body) when status in 200..299 do
    {:ok, body}
  end

  defp handle_response(404, body) do
    {:error, %{status: 404, body: body, message: "Not found"}}
  end

  defp handle_response(400, body) do
    {:error, %{status: 400, body: body, message: "Bad request"}}
  end

  defp handle_response(401, body) do
    {:error, %{status: 401, body: body, message: "Unauthorized"}}
  end

  defp handle_response(403, body) do
    {:error, %{status: 403, body: body, message: "Forbidden"}}
  end

  defp handle_response(422, body) do
    {:error, %{status: 422, body: body, message: "Unprocessable entity"}}
  end

  defp handle_response(429, body) do
    {:error, %{status: 429, body: body, message: "Rate limit exceeded"}}
  end

  defp handle_response(status, body) when status in 500..599 do
    {:error, %{status: status, body: body, message: "Server error"}}
  end

  defp handle_response(status, body) do
    {:error, %{status: status, body: body, message: "Unexpected response"}}
  end

  @spec handle_exception(Exception.t()) :: error_response()
  defp handle_exception(%Req.TransportError{reason: reason}) do
    {:error, %{reason: reason, message: "Network error"}}
  end

  defp handle_exception(%{__exception__: true, reason: :timeout}) do
    {:error, %{reason: :timeout, message: "Request timeout"}}
  end

  defp handle_exception(exception) when is_exception(exception) do
    reason = if Map.has_key?(exception, :reason), do: exception.reason, else: :unknown
    {:error, %{reason: reason, message: "Request failed"}}
  end

  defp handle_exception(exception) do
    {:error, %{reason: exception, message: "Request failed"}}
  end
end