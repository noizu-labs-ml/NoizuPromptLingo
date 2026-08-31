defmodule ExLiteLLM.Core.Streaming do
  @moduledoc """
  Server-Sent-Events streaming — litellm's `CustomStreamWrapper` +
  `BaseModelResponseIterator`.

  Upstream is driven with `Finch.stream/5` so we can inspect the HTTP status
  **before** committing a 200 SSE preamble. Groq (and other strict providers)
  often 400/404 with a JSON body; treating that as an Anthropic empty turn is
  how `run-claude with groq-pro` showed "models do not reply".
  """

  import Plug.Conn
  require Logger

  alias ExLiteLLM.Anthropic.Stream, as: AnthropicStream
  alias ExLiteLLM.Anthropic.Translate
  alias ExLiteLLM.Error
  alias ExLiteLLM.Providers.Adapter.Request

  @doc """
  Stream a chat completion to the client as OpenAI SSE.
  """
  @spec stream(Plug.Conn.t(), module(), Request.t(), map()) :: Plug.Conn.t()
  def stream(conn, adapter, %Request{} = req, upstream_body) do
    ExLiteLLM.Proxy.MetricsPlug.defer()
    ExLiteLLM.Proxy.MetricsPlug.tag(target: "native:#{req.provider}")

    with {:ok, headers} <- adapter.validate_environment(req, %{}) do
      state = %{
        conn: conn,
        adapter: adapter,
        req: req,
        chunk_id: "chatcmpl-" <> rand(),
        created: System.system_time(:second),
        buffer: "",
        finished: false,
        emit: :openai,
        sse_started: false,
        status: nil,
        error_buf: ""
      }

      case upstream_stream(adapter.get_complete_url(req), headers, upstream_body, req, state) do
        {:ok, final} ->
          final |> finalize_openai() |> ExLiteLLM.Proxy.MetricsPlug.finalize()

        {:error, %Error{} = e, %{sse_started: true} = st} ->
          send_error_frame(st.conn, e)

        {:error, %Error{} = e, _} ->
          send_error(conn, e)
      end
    else
      {:error, %Error{} = e} -> send_error(conn, e)
    end
  end

  @doc """
  Stream a chat completion to the client as **Anthropic SSE**.

  Content blocks are opened lazily (`thinking` / `text` / `tool_use`) so
  Groq gpt-oss reasoning and tool calls are visible to Claude Code.
  """
  @spec stream_anthropic(Plug.Conn.t(), module(), Request.t(), map(), String.t()) :: Plug.Conn.t()
  def stream_anthropic(conn, adapter, %Request{} = req, upstream_body, requested_model) do
    ExLiteLLM.Proxy.MetricsPlug.defer()
    ExLiteLLM.Proxy.MetricsPlug.tag(target: "native:#{req.provider}")

    with {:ok, headers} <- adapter.validate_environment(req, %{}) do
      state = %{
        conn: conn,
        adapter: adapter,
        req: req,
        buffer: "",
        finished: false,
        emit: :anthropic,
        anth: AnthropicStream.new(requested_model),
        sse_started: false,
        status: nil,
        error_buf: ""
      }

      case upstream_stream(adapter.get_complete_url(req), headers, upstream_body, req, state) do
        {:ok, final} ->
          final = flush_anthropic_close(final)
          ExLiteLLM.Proxy.MetricsPlug.finalize(final.conn)

        {:error, %Error{} = e, %{sse_started: true} = st} ->
          _ = chunk_frame(st.conn, Translate.stream_error(e.type, e.message))
          ExLiteLLM.Proxy.MetricsPlug.finalize(st.conn)

        {:error, %Error{} = e, _} ->
          send_error(conn, e)
      end
    else
      {:error, %Error{} = e} -> send_error(conn, e)
    end
  end

  # --- upstream via Finch (status before client SSE) ---

  defp upstream_stream(url, headers, body, %Request{litellm_params: lp}, state) do
    timeout = stream_timeout(lp)
    header_list = Enum.map(headers, fn {k, v} -> {to_string(k), to_string(v)} end)
    payload = if is_binary(body), do: body, else: Jason.encode!(body)
    request = Finch.build(:post, url, header_list, payload)

    case Finch.stream(request, ExLiteLLM.HTTP.finch(), state, &finch_step/2, receive_timeout: timeout) do
      {:ok, %{status: status} = acc} when status in 200..299 ->
        {:ok, acc}

      {:ok, %{status: status} = acc} when is_integer(status) ->
        {:error, adapter_error(acc.adapter, status, acc.error_buf), acc}

      {:ok, acc} ->
        {:error, Error.new(502, "upstream stream failed: no status", type: "api_error"), acc}

      {:error, exc} ->
        {:error, stream_exc(exc), state}
    end
  end

  defp finch_step({:status, status}, acc), do: %{acc | status: status}
  defp finch_step({:headers, _}, acc), do: acc
  defp finch_step({:trailers, _}, acc), do: acc

  defp finch_step({:data, data}, acc) do
    if acc.status in 200..299 do
      acc
      |> maybe_start_sse()
      |> consume(data)
    else
      %{acc | error_buf: acc.error_buf <> data}
    end
  end

  defp maybe_start_sse(%{sse_started: true} = acc), do: acc

  defp maybe_start_sse(%{emit: :anthropic} = acc) do
    conn =
      acc.conn
      |> put_resp_content_type("text/event-stream")
      |> put_resp_header("cache-control", "no-cache")
      |> send_chunked(200)

    {anth, frames} = AnthropicStream.preamble(acc.anth)
    conn = write_frames(conn, frames)
    %{acc | conn: conn, anth: anth, sse_started: true}
  end

  defp maybe_start_sse(acc) do
    conn =
      acc.conn
      |> put_resp_content_type("text/event-stream")
      |> put_resp_header("cache-control", "no-cache")
      |> send_chunked(200)

    %{acc | conn: conn, sse_started: true}
  end

  # Feed a raw byte blob into the SSE line parser.
  defp consume(state, data) do
    {events, rest} = split_sse(state.buffer <> data)
    state = %{state | buffer: rest}

    Enum.reduce(events, state, fn event, acc ->
      case parse_event(event) do
        :skip -> acc
        :done -> %{acc | finished: true}
        {:data, payload} -> handle_payload(acc, payload)
      end
    end)
  end

  defp handle_payload(state, payload) do
    if state.finished do
      state
    else
      chunk = state.adapter.chunk_parser(payload)
      emit(state, chunk)
    end
  end

  defp emit(state, :done), do: %{state | finished: true}

  defp emit(%{emit: :anthropic} = state, chunk) when is_map(chunk) do
    {anth, frames} = AnthropicStream.push(state.anth, chunk)
    conn = write_frames(state.conn, frames)

    %{
      state
      | anth: anth,
        conn: conn,
        finished: chunk[:is_finished] || state.finished
    }
  end

  defp emit(state, chunk) when is_map(chunk) do
    frame = "data: " <> Jason.encode!(openai_chunk_frame(state, chunk)) <> "\n\n"
    ExLiteLLM.Proxy.MetricsPlug.add_resp_bytes(byte_size(frame))

    case chunk(state.conn, frame) do
      {:ok, conn} -> %{state | conn: conn, finished: chunk.is_finished || state.finished}
      {:error, _} -> %{state | finished: true}
    end
  end

  defp flush_anthropic_close(state) do
    {anth, frames} = AnthropicStream.close(state.anth)
    %{state | anth: anth, conn: write_frames(state.conn, frames)}
  end

  defp write_frames(conn, frames) do
    Enum.reduce(frames, conn, fn frame, acc ->
      ExLiteLLM.Proxy.MetricsPlug.add_resp_bytes(byte_size(frame))

      case chunk(acc, frame) do
        {:ok, c} -> c
        {:error, _} -> acc
      end
    end)
  end

  defp chunk_frame(conn, frame) do
    ExLiteLLM.Proxy.MetricsPlug.add_resp_bytes(byte_size(frame))
    chunk(conn, frame)
  end

  # --- OpenAI chunk shaping ---

  defp openai_chunk_frame(state, chunk) do
    delta =
      %{}
      |> put_if(:content, blank_to_nil(chunk[:text] || chunk["text"]))
      |> put_if(:tool_calls, chunk[:tool_use] || chunk["tool_use"])
      |> put_if(:reasoning, blank_to_nil(chunk[:reasoning] || chunk["reasoning"]))

    %{
      id: state.chunk_id,
      object: "chat.completion.chunk",
      created: state.created,
      model: state.req.model,
      choices: [
        %{
          index: chunk[:index] || 0,
          delta: delta,
          finish_reason: chunk[:finish_reason]
        }
      ]
    }
    |> maybe_usage(chunk[:usage])
  end

  defp maybe_usage(frame, nil), do: frame
  defp maybe_usage(frame, usage), do: Map.put(frame, :usage, usage)

  defp finalize_openai(%{error: %Error{} = e, conn: conn}), do: send_error_frame(conn, e)

  defp finalize_openai(state) do
    {:ok, conn} = chunk(state.conn, "data: [DONE]\n\n")
    conn
  end

  # --- SSE parsing ---

  defp split_sse(buffer) do
    parts = String.split(buffer, ~r/\r?\n\r?\n/)

    case Enum.reverse(parts) do
      [last | rest] -> {Enum.reverse(rest), last}
      [] -> {[], ""}
    end
  end

  defp parse_event(event) do
    data =
      event
      |> String.split(~r/\r?\n/)
      |> Enum.filter(&String.starts_with?(&1, "data:"))
      |> Enum.map(&String.trim_leading(String.replace_prefix(&1, "data:", "")))
      |> Enum.join("\n")

    cond do
      data == "" -> :skip
      String.trim(data) == "[DONE]" -> :done
      true -> decode_data(data)
    end
  end

  defp decode_data(data) do
    case Jason.decode(data) do
      {:ok, payload} -> {:data, payload}
      {:error, _} -> :skip
    end
  end

  defp adapter_error(adapter, status, buf) do
    body =
      case Jason.decode(buf) do
        {:ok, decoded} -> decoded
        _ -> buf
      end

    adapter.get_error_class(status, body, %{})
  end

  defp send_error(conn, %Error{} = e) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(e.status, Jason.encode!(anthropic_or_openai(conn, e)))
  end

  defp anthropic_or_openai(conn, %Error{} = e) do
    if String.contains?(conn.request_path || "", "/messages") do
      %{"type" => "error", "error" => %{"type" => e.type, "message" => e.message}}
    else
      Error.to_body(e)
    end
  end

  defp send_error_frame(conn, %Error{} = e) do
    {:ok, conn} = chunk(conn, "data: " <> Jason.encode!(Error.to_body(e)) <> "\n\n")
    {:ok, conn} = chunk(conn, "data: [DONE]\n\n")
    conn
  end

  defp put_if(map, _key, nil), do: map
  defp put_if(map, key, value), do: Map.put(map, key, value)

  defp blank_to_nil(""), do: nil
  defp blank_to_nil(v), do: v

  defp stream_timeout(%{"stream_timeout" => t}) when is_number(t), do: round(t * 1000)
  defp stream_timeout(%{"timeout" => t}) when is_number(t), do: round(t * 1000)
  defp stream_timeout(_), do: 600_000

  defp stream_exc(%{__struct__: _} = exc),
    do: Error.new(502, "upstream stream failed: #{Exception.message(exc)}", type: "api_error")

  defp stream_exc(other),
    do: Error.new(502, "upstream stream failed: #{inspect(other)}", type: "api_error")

  defp rand, do: 16 |> :crypto.strong_rand_bytes() |> Base.url_encode64(padding: false)
end
