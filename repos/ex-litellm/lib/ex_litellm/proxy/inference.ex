defmodule ExLiteLLM.Proxy.Inference do
  @moduledoc """
  Inference endpoint handlers — the OpenAI-compatible surface run-claude drives.

  Phase 2: non-streaming `/v1/chat/completions`, `/v1/completions` (aliased to
  chat when the body carries `messages`), and `/v1/embeddings`, plus `/v1/models`.
  Streaming (`stream: true`) is added with `ExLiteLLM.Core.Streaming`; until
  then a streaming request is served as a single non-streamed body.

  Each handler expects the request body already decoded into a map (the router's
  JSON body parser handles that) and the caller already authenticated.
  """

  import Plug.Conn

  alias ExLiteLLM.Core.{Completion, Embeddings, Streaming}
  alias ExLiteLLM.Deployments
  alias ExLiteLLM.Error

  @doc "POST /v1/chat/completions — streams when the body sets `stream: true`."
  def chat_completions(conn) do
    params = body(conn)

    if params["stream"] == true do
      stream_chat(conn, params)
    else
      case Completion.run(params) do
        {:ok, model_response} -> json(conn, 200, model_response)
        {:error, %Error{} = e} -> json(conn, e.status, Error.to_body(e))
      end
    end
  end

  defp stream_chat(conn, params) do
    case Completion.prepare(params) do
      {:ok, adapter, req} ->
        # Ask the upstream to stream; the adapter's transform_request carries
        # the provider-specific `stream` flag into the outgoing body.
        upstream_body = adapter.transform_request(req)
        Streaming.stream(conn, adapter, req, upstream_body)

      {:error, %Error{} = e} ->
        json(conn, e.status, Error.to_body(e))
    end
  end

  @doc "POST /v1/embeddings"
  def embeddings(conn) do
    params = body(conn)

    case Embeddings.run(params) do
      {:ok, response} -> json(conn, 200, response)
      {:error, %Error{} = e} -> json(conn, e.status, Error.to_body(e))
    end
  end

  @doc "GET /v1/models — list configured model groups in OpenAI shape."
  def models(conn) do
    data =
      Deployments.model_names()
      |> Enum.map(fn name ->
        %{id: name, object: "model", created: 0, owned_by: "ex-litellm"}
      end)

    json(conn, 200, %{object: "list", data: data})
  end

  # --- helpers ---

  # The router stashes the decoded JSON body in assigns to avoid re-reading.
  defp body(conn), do: conn.assigns[:json_body] || %{}

  defp json(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(body))
  end
end
