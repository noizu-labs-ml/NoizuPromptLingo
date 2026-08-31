defmodule ExLiteLLM.Gateway.Forwarder do
  @moduledoc """
  Upstream request forwarding for the gateway's passthrough targets (Anthropic
  or an arbitrary URL) — the reverse-proxy half of the old front proxy, now a
  shared helper.

  Handles hop-by-hop header stripping, the master-key-swap vs passthrough auth
  decision, and both buffered and SSE-streaming forwarding via `Req`.
  """

  import Plug.Conn
  require Logger

  alias ExLiteLLM.Runtime

  # Headers not forwarded upstream. `accept-encoding` is deliberately dropped:
  # bodies are relayed verbatim while `content-encoding` is stripped from the
  # response headers, so a compressed upstream reply (zstd/br/gzip) would reach
  # the client as undecodable binary (seen as garbled "API Error: 400 <binary>"
  # in Claude Code). Not advertising compression makes upstreams answer plain.
  @hop_by_hop ~w(host connection keep-alive transfer-encoding te trailer upgrade content-length accept-encoding)
  @strip_resp ~w(content-encoding content-length transfer-encoding)

  @doc """
  Forward the current request to `base_url` and relay the response. `auth_mode`
  is `:master_key` (strip client auth, inject the LiteLLM master key) or
  `:passthrough` (keep original headers). Streams when the client asked for SSE.
  """
  @spec forward(Plug.Conn.t(), String.t(), :master_key | :passthrough, binary()) :: Plug.Conn.t()
  def forward(conn, base_url, auth_mode, raw_body) do
    url = base_url <> conn.request_path <> qs(conn)
    headers = forward_headers(conn, auth_mode)
    ExLiteLLM.Proxy.MetricsPlug.tag(target: base_url)

    if streaming?(conn) do
      stream(conn, url, headers, raw_body)
    else
      buffered(conn, url, headers, raw_body)
    end
  end

  @doc """
  Forward to an explicit `url` with fully prepared `headers` (map) and `body` —
  used when the gateway rewrites the request (e.g. Anthropic-compatible
  deployments where model + credentials are swapped in). Streams on SSE Accept.
  """
  @spec forward_to(Plug.Conn.t(), String.t(), map(), binary()) :: Plug.Conn.t()
  def forward_to(conn, url, headers, body) do
    header_list = Map.to_list(headers)

    if streaming?(conn) do
      stream(conn, url, header_list, body)
    else
      buffered(conn, url, header_list, body)
    end
  end

  defp buffered(conn, url, headers, body) do
    case Req.request(
           [
             method: method_atom(conn.method),
             url: url,
             headers: headers,
             body: body,
             decode_body: false,
             receive_timeout: 600_000
           ] ++ ExLiteLLM.HTTP.buffered_opts()
         ) do
      {:ok, %Req.Response{status: status, headers: resp_headers, body: resp_body}} ->
        conn
        |> put_resp_headers(resp_headers)
        |> send_resp(status, resp_body)

      {:error, exc} ->
        proxy_error(conn, exc)
    end
  end

  # How many times a stream may be re-attempted when the pooled connection was
  # closed under us BEFORE the response was committed to the client.
  @stream_connect_retries 2

  defp stream(conn, url, headers, body) do
    ExLiteLLM.Proxy.MetricsPlug.defer()

    conn
    |> stream_attempt(url, headers, body, 1)
    |> ExLiteLLM.Proxy.MetricsPlug.finalize()
  end

  # The chunked response is committed LAZILY — only once the upstream actually
  # answers — so a connect-stage failure can be retried (or surfaced as a real
  # 502) instead of dying inside an already-committed 200 stream. The upstream's
  # status + headers are relayed, matching the Python front proxy.
  defp stream_attempt(conn, url, headers, body, attempt) when is_binary(url) do
    conn_ref_put(%{conn: conn, chunked: false})

    result =
      Req.request(
        [
          method: method_atom(conn.method),
          url: url,
          headers: headers,
          body: body,
          decode_body: false,
          receive_timeout: 600_000,
          into: fn {:data, data}, {req, resp} ->
            st = ensure_chunked(conn_ref_get(), resp)
            ExLiteLLM.Proxy.MetricsPlug.add_resp_bytes(byte_size(data))

            case chunk(st.conn, data) do
              {:ok, c} -> conn_ref_put(%{st | conn: c})
              {:error, _} -> conn_ref_put(st)
            end

            {:cont, {req, resp}}
          end
        ] ++ ExLiteLLM.HTTP.stream_opts()
      )

    st = conn_ref_get()

    case result do
      {:ok, %Req.Response{} = resp} ->
        if st.chunked do
          st.conn
        else
          # Upstream answered but produced no body chunks (e.g. an error status
          # with an empty body) — relay status/headers as a plain response.
          st.conn
          |> put_resp_headers(resp.headers)
          |> send_resp(resp.status, "")
        end

      {:error, %Req.TransportError{reason: :closed}}
      when attempt <= @stream_connect_retries ->
        if st.chunked do
          # Mid-stream death — a retry would duplicate delivered events.
          Logger.error("[gateway] stream died mid-flight (socket closed)")
          st.conn
        else
          Logger.warning("[gateway] stale connection at stream connect — retrying (#{attempt})")
          stream_attempt(conn, url, headers, body, attempt + 1)
        end

      {:error, exc} ->
        if st.chunked do
          Logger.error("[gateway] stream forward error: #{inspect(exc)}")
          st.conn
        else
          # Nothing committed yet — the client gets an honest 502.
          proxy_error(conn, exc)
        end
    end
  end

  defp ensure_chunked(%{chunked: true} = st, _resp), do: st

  defp ensure_chunked(%{conn: conn}, resp) do
    conn =
      conn
      |> put_resp_headers(resp.headers)
      |> send_chunked(resp.status)

    %{conn: conn, chunked: true}
  end

  # --- headers ---

  defp forward_headers(conn, :master_key) do
    master = Runtime.get().master_key || ""

    conn.req_headers
    |> Enum.reject(fn {k, _v} -> String.downcase(k) in @hop_by_hop end)
    |> Enum.reject(fn {k, _v} -> String.downcase(k) == "authorization" end)
    |> Kernel.++([{"authorization", "Bearer " <> master}])
  end

  defp forward_headers(conn, :passthrough) do
    Enum.reject(conn.req_headers, fn {k, _v} -> String.downcase(k) in @hop_by_hop end)
  end

  defp put_resp_headers(conn, resp_headers) do
    Enum.reduce(resp_headers, conn, fn {k, v}, acc ->
      if String.downcase(k) in @strip_resp do
        acc
      else
        put_resp_header(acc, String.downcase(k), to_string(v))
      end
    end)
  end

  # --- helpers ---

  defp streaming?(conn) do
    case get_req_header(conn, "accept") do
      [accept | _] -> String.contains?(accept, "text/event-stream")
      _ -> false
    end
  end

  defp qs(%{query_string: ""}), do: ""
  defp qs(%{query_string: q}), do: "?" <> q

  defp method_atom(method), do: method |> String.downcase() |> String.to_atom()

  defp proxy_error(conn, exc) do
    Logger.error("[gateway] upstream forward error: #{inspect(exc)}")
    ExLiteLLM.Proxy.MetricsPlug.tag(error: error_reason(exc))

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(
      502,
      Jason.encode!(%{
        type: "error",
        error: %{type: "api_error", message: "upstream request failed: #{error_reason(exc)}"}
      })
    )
  end

  defp error_reason(%Req.TransportError{reason: reason}), do: "transport #{inspect(reason)}"
  defp error_reason(%{__struct__: _} = exc), do: Exception.message(exc)
  defp error_reason(other), do: inspect(other)

  defp conn_ref_get, do: Process.get(:exll_fwd_conn)
  defp conn_ref_put(conn), do: (Process.put(:exll_fwd_conn, conn) && conn)
end
