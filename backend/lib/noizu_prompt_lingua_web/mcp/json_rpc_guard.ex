defmodule NoizuPromptLinguaWeb.MCP.JsonRpcGuard do
  @moduledoc """
  NPL-side JSON-RPC 2.0 framing gate (stage probe B4).

  The lib transport (`Noizu.MCP.Transport.StreamableHTTP.Plug`, pinned dep —
  not editable here) never inspects the `jsonrpc` member: a body with
  `"jsonrpc": "1.0"` — or no version at all — classifies as a request and is
  delivered to a session that silently drops it, so the connection hangs with
  no reply and no close until the client times out. Spec-wise those bodies are
  malformed and deserve `-32600 Invalid Request`.

  This guard is the earliest NPL-owned seam: it runs in front of EVERY
  transport mount (the root `/mcp` forward via `TransportPlug`, and the
  custom/set gateway controllers' serve path):

    * POST body decodes to a JSON OBJECT carrying `"method"` (a request or
      notification) with `jsonrpc` missing or != "2.0" ⇒ immediate
      HTTP 400 + JSON-RPC envelope `{"code": -32600}` (id echoed when
      present, else null). No session is touched, nothing hangs.
    * POST bodies the gate does not own — unparseable JSON, non-object
      bodies (batch arrays / scalars) — are answered with the transport's own
      framing replies ("Invalid JSON body" / "Not a JSON-RPC message") so the
      guard is a total handler for POSTs and never leaves a consumed body
      dangling. Client-response objects (`result`/`error`, no `method`) are
      out of scope: the transport already answers them without waiting.
    * Everything else (well-framed "2.0" requests, GET/DELETE, non-POST)
      passes through; a validated body is re-materialized into
      `conn.body_params` so the transport's `decoded_body/1` consumes it
      without a second read.
  """

  import Plug.Conn

  @invalid_request %{"code" => -32600, "message" => "Invalid Request"}

  @doc "`{:ok, conn}` to pass through (validated body reattached) or `{:halt, conn}` already answered."
  @spec check(Plug.Conn.t()) :: {:ok, Plug.Conn.t()} | {:halt, Plug.Conn.t()}
  def check(%Plug.Conn{method: "POST"} = conn) do
    case decode(conn) do
      {:map, conn, body} ->
        if framed?(body) do
          {:ok, %{conn | body_params: body}}
        else
          {:halt, invalid_request(conn, body)}
        end

      {:other, conn} ->
        {:halt, send_resp(conn, 400, "Not a JSON-RPC message")}

      {:bad_body, conn} ->
        {:halt, send_resp(conn, 400, "Invalid JSON body")}
    end
  end

  def check(conn), do: {:ok, conn}

  # A JSON-RPC 2.0 request/notification REQUIRES `"jsonrpc": "2.0"` (both the
  # JSON-RPC spec and MCP 2025-11-25 §Structure). Response-shaped objects
  # (client → server results) never hang the transport, so they pass.
  defp framed?(%{"method" => _} = body) do
    case Map.fetch(body, "jsonrpc") do
      {:ok, "2.0"} -> true
      _ -> false
    end
  end

  defp framed?(_other), do: true

  defp invalid_request(conn, body) do
    envelope = %{"jsonrpc" => "2.0", "id" => Map.get(body, "id"), "error" => @invalid_request}

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(400, Jason.encode!(envelope))
  end

  # Mirror of the transport's decoded_body/1 — body_params when the endpoint
  # parsers already ran, a raw read otherwise — but total: every outcome is
  # resolved here so the body is never consumed twice.
  defp decode(conn) do
    params = conn.body_params

    cond do
      match?(%Plug.Conn.Unfetched{}, params) ->
        case read_body(conn) do
          {:ok, raw, conn} ->
            case Jason.decode(raw) do
              {:ok, %{} = body} -> {:map, conn, body}
              {:ok, _} -> {:other, conn}
              {:error, _} -> {:bad_body, conn}
            end

          _ ->
            {:bad_body, conn}
        end

      is_map(params) ->
        {:map, conn, params}

      true ->
        {:other, conn}
    end
  end
end
