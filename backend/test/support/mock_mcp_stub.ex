defmodule NoizuPromptLingua.MockMCPStub do
  @moduledoc """
  OpenAI-compatible chat-completions LLM stub served from a local ephemeral
  Bandit port (no external deps — Bandit ships with Phoenix).

  The domain code points an LLM connection's `endpoint` at
  `http://127.0.0.1:<port>/<segment>`; behavior is selected by the endpoint's
  last path segment. Each (port, segment) can carry an ordered response
  SEQUENCE (set via `seq/3`); each request pops the next entry, repeating the
  last one once the sequence is exhausted. Entries:

    {:content, term}      -> 200 OpenAI shape, content = Jason.encode!(term)
    {:text, binary}       -> 200 OpenAI shape, content = binary verbatim
    {:raw, binary}        -> 200 with the body verbatim (response-shape tests)
    {:status, code, body} -> that status + body (transport-failure tests)

  The last request's headers + body are recorded per segment (see
  `last_request/2`) for request-shaping assertions.
  """

  def start do
    # Bind an ephemeral port, then hand it to Bandit (tiny TOCTOU window OK).
    {:ok, sock} = :gen_tcp.listen(0, ip: {127, 0, 0, 1})
    {:ok, port} = :inet.port(sock)
    :gen_tcp.close(sock)

    table = :"mock_mcp_stub_#{port}"
    :ets.new(table, [:named_table, :public, :set])

    {:ok, pid} =
      Bandit.start_link(plug: {__MODULE__, table}, scheme: :http, ip: {127, 0, 0, 1}, port: port)

    %{port: port, pid: pid, table: table}
  end

  def stop(%{pid: pid, table: table}) do
    if Process.alive?(pid), do: Process.exit(pid, :shutdown)
    if :ets.whereis(table) != :undefined, do: :ets.delete(table)
    :ok
  end

  @doc "Set the response sequence for `seg` (defaults to repeating the last entry)."
  def seq(%{table: table}, seg, responses) when is_list(responses) and responses != [] do
    :ets.insert(table, {{:seq, seg}, responses})
    :ets.insert(table, {{:idx, seg}, 0})
    :ok
  end

  @doc "Headers + raw body of the last request made to `seg`."
  def last_request(%{table: table}, seg) do
    case :ets.lookup(table, {:req, seg}) do
      [{{:req, ^seg}, headers, body}] -> {headers, body}
      _ -> nil
    end
  end

  @doc "HTTP method of the last request made to `seg` (e.g. \"GET\")."
  def last_method(%{table: table}, seg) do
    case :ets.lookup(table, {:meth, seg}) do
      [{{:meth, ^seg}, method}] -> method
      _ -> nil
    end
  end

  # ── Plug ──────────────────────────────────────────────────────────────────

  def init(table), do: table

  def call(conn, table) do
    {:ok, body, conn} = Plug.Conn.read_body(conn)
    seg = List.last(conn.path_info) || ""
    :ets.insert(table, {{:req, seg}, conn.req_headers, body})
    :ets.insert(table, {{:meth, seg}, conn.method})

    case next(table, seg) do
      {:status, code, resp_body} ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(code, resp_body)

      {:raw, resp_body} ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, resp_body)

      flavor ->
        content =
          case flavor do
            {:text, text} -> text
            {:content, term} -> Jason.encode!(term)
            _ -> "unmatched"
          end

        resp_body = Jason.encode!(%{"choices" => [%{"message" => %{"content" => content}}]})

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, resp_body)
    end
  end

  defp next(table, seg) do
    case :ets.lookup(table, {:seq, seg}) do
      [{{:seq, ^seg}, responses}] ->
        idx = :ets.update_counter(table, {:idx, seg}, 1, {{:idx, seg}, 0})
        Enum.at(responses, idx - 1) || List.last(responses)

      _ ->
        nil
    end
  end
end
