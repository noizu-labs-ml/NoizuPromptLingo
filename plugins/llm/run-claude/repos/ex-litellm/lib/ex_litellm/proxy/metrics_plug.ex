defmodule ExLiteLLM.Proxy.MetricsPlug do
  @moduledoc """
  Per-request instrumentation for the gateway.

  Wraps the whole pipeline: stamps a monotonic start time when the request
  enters, then records `{method, path, model, target, status, duration,
  request/response bytes, streamed?, error}` to `ExLiteLLM.RequestLog` when the
  response goes out.

  * Duration covers the full gateway residence time (including upstream).
  * Request size comes from `content-length` (the body may be consumed as raw
    passthrough or parsed JSON — the header is the one uniform source).
  * Response size: `content-length` when buffered; for chunked/SSE responses
    the handler accumulates sent bytes in the process dict
    (`:exll_resp_bytes`) which the callback reads back.
  * `model` / `target` are picked up from process-dict breadcrumbs the
    handlers drop (`:exll_log_model`, `:exll_log_target`) — the plug itself
    stays handler-agnostic.

  Health/status endpoints are skipped to keep the log signal high.
  """

  @behaviour Plug

  import Plug.Conn

  @skip_paths ~w(/health /health/readiness /health/liveliness /health/liveness
                 /status /status.json /status/requests /favicon.ico /)

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    if conn.request_path in @skip_paths do
      conn
    else
      start = System.monotonic_time(:millisecond)
      Process.put(:exll_resp_bytes, 0)
      Process.put(:exll_req_start, start)

      register_before_send(conn, fn conn ->
        # Streaming handlers defer: before_send fires when chunked headers
        # commit (before the body streams), so they call finalize/1 themselves
        # once the stream completes — with real duration + byte counts.
        unless Process.get(:exll_defer_log), do: record(conn, start)
        conn
      end)
    end
  end

  @doc """
  Streaming handlers call this at entry so the before_send hook skips the
  too-early record; they must then call `finalize/1` when the stream ends.
  """
  @spec defer() :: :ok
  def defer do
    Process.put(:exll_defer_log, true)
    :ok
  end

  @doc "Record a deferred (streamed) request after its body finished."
  @spec finalize(Plug.Conn.t()) :: Plug.Conn.t()
  def finalize(conn) do
    if Process.get(:exll_defer_log) do
      Process.delete(:exll_defer_log)
      record(conn, Process.get(:exll_req_start))
    end

    conn
  end

  defp record(_conn, nil), do: :ok

  defp record(conn, start) do
    duration = System.monotonic_time(:millisecond) - start

    ExLiteLLM.RequestLog.record(%{
      method: conn.method,
      path: conn.request_path,
      model: Process.get(:exll_log_model),
      target: Process.get(:exll_log_target),
      status: conn.status,
      duration_ms: duration,
      req_bytes: req_bytes(conn),
      resp_bytes: resp_bytes(conn),
      stream: streamed?(conn),
      error: Process.get(:exll_log_error)
    })
  rescue
    # Never let logging break a response.
    _ -> :ok
  end

  defp req_bytes(conn) do
    case get_req_header(conn, "content-length") do
      [len | _] -> parse_int(len)
      _ -> byte_size(Process.get(:exll_raw_body) || "")
    end
  end

  defp resp_bytes(conn) do
    case Process.get(:exll_resp_bytes, 0) do
      n when is_integer(n) and n > 0 ->
        n

      _ ->
        case get_resp_header(conn, "content-length") do
          [len | _] -> parse_int(len)
          _ -> body_size(conn)
        end
    end
  end

  defp body_size(%{resp_body: body}) when is_binary(body), do: byte_size(body)
  defp body_size(_), do: 0

  defp streamed?(conn) do
    conn.state == :chunked or
      get_resp_header(conn, "content-type") |> List.first() |> sse?()
  end

  defp sse?(nil), do: false
  defp sse?(ct), do: String.contains?(ct, "text/event-stream")

  defp parse_int(s) do
    case Integer.parse(s) do
      {n, _} -> n
      :error -> 0
    end
  end

  @doc "Handlers call this to attribute the request to a model/target in the log."
  @spec tag(keyword()) :: :ok
  def tag(fields) do
    if model = fields[:model], do: Process.put(:exll_log_model, model)
    if target = fields[:target], do: Process.put(:exll_log_target, target)
    if error = fields[:error], do: Process.put(:exll_log_error, error)
    :ok
  end

  @doc "Streaming handlers call this per chunk so response bytes are counted."
  @spec add_resp_bytes(non_neg_integer()) :: :ok
  def add_resp_bytes(n) when is_integer(n) do
    Process.put(:exll_resp_bytes, Process.get(:exll_resp_bytes, 0) + n)
    :ok
  end
end
