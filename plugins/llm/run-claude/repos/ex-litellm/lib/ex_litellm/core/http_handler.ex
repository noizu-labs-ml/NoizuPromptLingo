defmodule ExLiteLLM.Core.HTTPHandler do
  @moduledoc """
  Generic outbound HTTP executor — litellm's `BaseLLMHTTPHandler`.

  Given a resolved adapter + request context, runs the pipeline:

      validate_environment → get_complete_url → transform_request
        → Req POST → transform_response

  Uses `Req` for the outbound call. Non-streaming only in this phase; the
  streaming path (SSE) is added with `ExLiteLLM.Core.Streaming`.
  """

  require Logger

  alias ExLiteLLM.Core.ModelResponse
  alias ExLiteLLM.Error
  alias ExLiteLLM.Providers.Adapter.Request

  @default_timeout 600_000

  @doc """
  Execute a non-streaming chat call. Returns `{:ok, %ModelResponse{}}` or
  `{:error, %Error{}}`.
  """
  @spec completion(module(), Request.t()) :: {:ok, ModelResponse.t()} | {:error, Error.t()}
  def completion(adapter, %Request{} = req) do
    with {:ok, resp_body} <- raw(adapter, req) do
      {:ok, adapter.transform_response(resp_body, req)}
    end
  end

  @doc """
  Execute a non-streaming call and return the decoded upstream body verbatim
  (no chat normalization). Used by embeddings and other endpoints whose provider
  response is already in the target shape.
  """
  @spec raw(module(), Request.t()) :: {:ok, map()} | {:error, Error.t()}
  def raw(adapter, %Request{} = req) do
    ExLiteLLM.Proxy.MetricsPlug.tag(target: "native:#{req.provider}")

    with {:ok, headers} <- adapter.validate_environment(req, %{}),
         url <- adapter.get_complete_url(req),
         body <- adapter.transform_request(req),
         {:ok, status, resp_body} <- post(url, headers, body, req),
         :ok <- ok_status(status, resp_body, adapter, req) do
      {:ok, resp_body}
    else
      {:error, %Error{} = e} = err ->
        ExLiteLLM.Proxy.MetricsPlug.tag(error: e.message)
        err
    end
  end

  # --- HTTP ---

  defp post(url, headers, body, %Request{litellm_params: lp}) do
    timeout = lp["timeout"] |> to_ms(@default_timeout)

    case Req.post(
           url,
           [
             headers: Map.to_list(headers),
             json: body,
             receive_timeout: timeout,
             decode_body: true
           ] ++ ExLiteLLM.HTTP.buffered_opts()
         ) do
      {:ok, %Req.Response{status: status, body: resp_body}} ->
        {:ok, status, normalize_body(resp_body)}

      {:error, %{__struct__: _} = exc} ->
        {:error, Error.new(502, "upstream request failed: #{Exception.message(exc)}", type: "api_error")}

      {:error, other} ->
        {:error, Error.new(502, "upstream request failed: #{inspect(other)}", type: "api_error")}
    end
  end

  defp ok_status(status, _body, _adapter, _req) when status in 200..299, do: :ok

  defp ok_status(status, body, adapter, _req) do
    {:error, adapter.get_error_class(status, body, %{})}
  end

  # Req decodes JSON automatically when content-type is json; guard for strings.
  defp normalize_body(body) when is_map(body), do: body

  defp normalize_body(body) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, decoded} -> decoded
      {:error, _} -> %{"error" => %{"message" => body}}
    end
  end

  defp normalize_body(body), do: %{"error" => %{"message" => inspect(body)}}

  defp to_ms(nil, default), do: default
  defp to_ms(n, _default) when is_integer(n), do: n * 1000
  defp to_ms(n, _default) when is_float(n), do: round(n * 1000)
  defp to_ms(_, default), do: default
end
