defmodule CodefreshCli.Client do
  @moduledoc """
  Thin HTTP wrapper around `Req`. All calls use the base URL + bearer token
  from the supplied config map.

  On non-2xx responses, returns `{:error, :api, message}` tuples that the
  command modules can surface directly.
  """

  @type cfg :: %{optional(atom) => any}
  @type result :: {:ok, map() | binary()} | {:error, :api | :auth, String.t()}

  @default_timeout 30_000

  @doc "GET request; returns decoded JSON body on success."
  @spec get(cfg, String.t(), keyword()) :: result
  def get(cfg, path, opts \\ []) do
    request(cfg, :get, path, nil, opts)
  end

  @doc "POST request with JSON body; returns decoded JSON body on success."
  @spec post(cfg, String.t(), any(), keyword()) :: result
  def post(cfg, path, body, opts \\ []) do
    request(cfg, :post, path, body, opts)
  end

  @doc "POST request with raw string body (e.g. a YAML payload)."
  @spec post_raw(cfg, String.t(), String.t(), String.t(), keyword()) :: result
  def post_raw(cfg, path, body, content_type, opts \\ []) do
    headers = [{"content-type", content_type} | auth_headers(cfg)]

    Req.request(
      method: :post,
      url: url(cfg, path),
      headers: headers,
      body: body,
      receive_timeout: Keyword.get(opts, :timeout, @default_timeout)
    )
    |> handle_response()
  end

  @doc "GET request returning the raw response body (for export YAML)."
  @spec get_raw(cfg, String.t(), keyword()) :: {:ok, String.t()} | {:error, atom, String.t()}
  def get_raw(cfg, path, opts \\ []) do
    Req.request(
      method: :get,
      url: url(cfg, path),
      headers: auth_headers(cfg),
      receive_timeout: Keyword.get(opts, :timeout, @default_timeout),
      decode_body: false
    )
    |> handle_response(:raw)
  end

  defp request(cfg, method, path, body, opts) do
    req_opts = [
      method: method,
      url: url(cfg, path),
      headers: auth_headers(cfg),
      receive_timeout: Keyword.get(opts, :timeout, @default_timeout)
    ]

    req_opts = if body, do: Keyword.put(req_opts, :json, body), else: req_opts

    Req.request(req_opts)
    |> handle_response()
  end

  defp url(cfg, path) do
    base = Map.get(cfg, :api_url) |> String.trim_trailing("/")
    path = if String.starts_with?(path, "/"), do: path, else: "/" <> path
    base <> path
  end

  defp auth_headers(cfg) do
    token = Map.get(cfg, :token)

    base = [{"accept", "application/json"}, {"user-agent", user_agent()}]

    if token, do: [{"authorization", "Bearer " <> token} | base], else: base
  end

  defp user_agent do
    "codefresh-cli/#{Mix.Project.config()[:version] || "0.0.0"} (elixir)"
  end

  defp handle_response(resp, mode \\ :json)

  defp handle_response({:ok, %Req.Response{status: status, body: body}}, _mode)
       when status in 200..299 do
    {:ok, body}
  end

  defp handle_response({:ok, %Req.Response{status: 401, body: body}}, _mode) do
    {:error, :auth, error_message(body, "unauthorized — run `codefresh login`")}
  end

  defp handle_response({:ok, %Req.Response{status: 403, body: body}}, _mode) do
    {:error, :auth, error_message(body, "forbidden")}
  end

  defp handle_response({:ok, %Req.Response{status: status, body: body}}, _mode) do
    {:error, :api, "HTTP #{status}: " <> error_message(body, "unknown error")}
  end

  defp handle_response({:error, %{reason: reason}}, _mode) do
    {:error, :api, "network error: #{inspect(reason)}"}
  end

  defp handle_response({:error, reason}, _mode) do
    {:error, :api, "network error: #{inspect(reason)}"}
  end

  defp error_message(body, default) when is_map(body) do
    case body do
      %{"error" => %{"message" => msg}} -> msg
      %{"error" => msg} when is_binary(msg) -> msg
      %{"message" => msg} when is_binary(msg) -> msg
      %{"errors" => errors} -> inspect(errors)
      _ -> default
    end
  end

  defp error_message(body, _default) when is_binary(body), do: body
  defp error_message(_body, default), do: default
end
