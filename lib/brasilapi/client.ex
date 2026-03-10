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
  @type mapper(result, mapped) :: (result -> mapped)

  @status_messages %{
    400 => "Bad request",
    401 => "Unauthorized",
    403 => "Forbidden",
    404 => "Not found",
    422 => "Unprocessable entity",
    429 => "Rate limit exceeded"
  }

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
    request(:get, path, opts)
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
    request(:post, path, [json: body] ++ opts)
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
    request(:put, path, [json: body] ++ opts)
  end

  @doc """
  Makes a DELETE request to the specified path.

  ## Parameters

    * `path` - The API path (without base URL)
    * `opts` - Additional options (optional)

  """
  @spec delete(String.t(), keyword()) :: response()
  def delete(path, opts \\ []) do
    request(:delete, path, opts)
  end

  @doc false
  @spec get_list(String.t(), mapper(map(), mapped), keyword()) ::
          {:ok, [mapped]} | error_response()
        when mapped: term()
  def get_list(path, mapper, opts \\ []) when is_function(mapper, 1) do
    with {:ok, items} when is_list(items) <- get(path, opts) do
      {:ok, Enum.map(items, mapper)}
    end
  end

  @doc false
  @spec get_one(String.t(), mapper(map(), mapped), keyword()) :: {:ok, mapped} | error_response()
        when mapped: term()
  def get_one(path, mapper, opts \\ []) when is_function(mapper, 1) do
    with {:ok, %{} = item} <- get(path, opts) do
      {:ok, mapper.(item)}
    end
  end

  # Private functions

  @spec request(atom(), String.t(), keyword()) :: response()
  defp request(method, path, opts) do
    req_opts =
      [method: method, url: build_url(path)]
      |> Keyword.merge(build_req_options(opts))

    case Req.request(req_opts) do
      {:ok, %Req.Response{status: status, body: body}} ->
        handle_response(status, body)

      {:error, exception} ->
        handle_exception(exception)
    end
  end

  @spec build_url(String.t()) :: String.t()
  defp build_url(path) do
    base_url = Config.base_url()
    Path.join(base_url, path)
  end

  @spec build_req_options(keyword()) :: keyword()
  defp build_req_options(opts) do
    default_opts = [
      receive_timeout: Config.timeout()
    ]

    config_opts = Config.req_options()

    default_opts
    |> Keyword.merge(Config.retry_options())
    |> Keyword.merge(config_opts)
    |> Keyword.merge(opts)
  end

  @spec handle_response(pos_integer(), term()) :: response()
  defp handle_response(status, body) when status in 200..299 do
    {:ok, body}
  end

  defp handle_response(status, body) when status in 500..599 do
    error_response(status, body, "Server error")
  end

  defp handle_response(status, body) do
    error_response(status, body, Map.get(@status_messages, status, "Unexpected response"))
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

  defp error_response(status, body, message) do
    {:error, %{status: status, body: body, message: message}}
  end
end
