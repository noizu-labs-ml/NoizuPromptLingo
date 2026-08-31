defmodule ExLiteLLM.Gateway.Router do
  @moduledoc """
  Dispatch logic for the unified gateway's non-native routes — the front-proxy
  routing folded in.

  * `messages/1` — `/v1/messages`. A `claude-*` model is reverse-proxied to
    Anthropic (auth preserved); a non-`claude-*` model is served by the native
    inference path (translated OpenAI ↔ provider), because ex-litellm speaks
    those providers itself now.
  * `passthrough/1` — any other path. Resolved against the runtime rule table;
    typically an Anthropic passthrough.
  * `get_rules/1` / `put_rules/1` / `put_mode/1` — live rule administration.
  """

  import Plug.Conn

  alias ExLiteLLM.Anthropic.Translate
  alias ExLiteLLM.Core.{Completion, Provider}
  alias ExLiteLLM.Deployments
  alias ExLiteLLM.Error
  alias ExLiteLLM.FrontProxy.{Rules, RouterLogic}
  alias ExLiteLLM.Gateway.Forwarder

  @anthropic "https://api.anthropic.com"

  @doc """
  Handle POST /v1/messages (the Anthropic Messages API surface Claude Code speaks).

  Routing by the requested model:

    * `claude-*` → passthrough to api.anthropic.com preserving the caller's own
      auth (OAuth / API key).
    * a registered deployment whose upstream is **Anthropic-family** (e.g. zai's
      `anthropic/glm-5.2` at api.z.ai) → keep the body Anthropic-shaped, swap in
      the deployment's model + credentials, forward, return the Anthropic
      response untouched.
    * a deployment on an **OpenAI-family** provider → translate the request to
      OpenAI chat, run native inference, translate the response back to
      Anthropic shape (content blocks, stop_reason, `usage.input/output_tokens`).
  """
  def messages(conn) do
    body = conn.assigns[:json_body] || %{}
    model = RouterLogic.extract_model(body)

    cond do
      String.starts_with?(model, "claude-") ->
        Forwarder.forward(conn, @anthropic, :passthrough, raw_body())

      deployment = Deployments.lookup(model) ->
        messages_via_deployment(conn, body, deployment)

      true ->
        # Unknown non-claude aliases used to passthrough to Anthropic and hang
        # (groq/opus[1m], retired Groq ids). Fail closed so Claude Code sees
        # the miss instead of an empty turn. (claude-* is handled above.)
        json(conn, 404, anthropic_error(Error.new(404, "model not found: #{model}", type: "not_found_error")))
    end
  end

  # A deployment backs this model — dispatch by the upstream provider family.
  defp messages_via_deployment(conn, body, deployment) do
    lp = deployment["litellm_params"] || %{}
    upstream = lp["model"] || ""

    case Provider.resolve(upstream, lp) do
      {:ok, :anthropic, bare_model, adapter} ->
        anthropic_family_forward(conn, body, bare_model, adapter, lp)

      {:ok, _provider, _bare, _adapter} ->
        openai_family_translate(conn, body)

      {:error, _} ->
        openai_family_translate(conn, body)
    end
  end

  # Anthropic-compatible upstream: same wire shape — swap model + credentials,
  # relay verbatim (buffered or streaming; Forwarder streams on SSE Accept).
  defp anthropic_family_forward(conn, body, bare_model, adapter, lp) do
    req = %ExLiteLLM.Providers.Adapter.Request{
      model: bare_model,
      provider: :anthropic,
      litellm_params: lp,
      call_type: :chat
    }

    case adapter.validate_environment(req, %{}) do
      {:ok, headers} ->
        url = adapter.get_complete_url(req)
        out_body = body |> Map.put("model", bare_model) |> Jason.encode!()
        Forwarder.forward_to(conn, url, headers, out_body)

      {:error, %Error{} = e} ->
        json(conn, e.status, Error.to_body(e))
    end
  end

  # OpenAI-family upstream: translate Anthropic → OpenAI, execute natively,
  # translate the response back to Anthropic shape.
  defp openai_family_translate(conn, body) do
    openai_body = Translate.request_to_openai(body)

    if body["stream"] == true do
      stream_translated(conn, openai_body, body["model"])
    else
      case Completion.run(openai_body) do
        {:ok, model_response} ->
          json(conn, 200, Translate.response_from_model_response(model_response, body["model"]))

        {:error, %Error{} = e} ->
          json(conn, e.status, anthropic_error(e))
      end
    end
  end

  # Stream an OpenAI-family completion back out as Anthropic SSE events.
  defp stream_translated(conn, openai_body, requested_model) do
    case Completion.prepare(openai_body) do
      {:ok, adapter, req} ->
        upstream_body = adapter.transform_request(req)

        ExLiteLLM.Core.Streaming.stream_anthropic(
          conn,
          adapter,
          req,
          upstream_body,
          requested_model
        )

      {:error, %Error{} = e} ->
        json(conn, e.status, anthropic_error(e))
    end
  end

  # Anthropic error envelope ({"type":"error","error":{...}}), not OpenAI's.
  defp anthropic_error(%Error{} = e) do
    %{"type" => "error", "error" => %{"type" => e.type, "message" => e.message}}
  end

  @doc "Handle any non-native path via the runtime rule table."
  def passthrough(conn) do
    body = conn.assigns[:json_body] || %{}
    {target_base, auth_mode} = RouterLogic.route(conn.request_path, body)
    Forwarder.forward(conn, target_base, auth_mode, raw_body())
  end

  # --- admin ---

  def get_rules(conn) do
    json(conn, 200, %{mode: Rules.mode(), rules: encode_rules(Rules.list())})
  end

  def put_rules(conn) do
    case decode_rules(conn.assigns[:json_body]) do
      {:ok, rules} ->
        Rules.put(rules)
        json(conn, 200, %{status: "ok", count: length(rules)})

      {:error, reason} ->
        json(conn, 400, %{error: %{message: "invalid rules: #{inspect(reason)}"}})
    end
  end

  def put_mode(conn) do
    with %{"mode" => mode_str} <- conn.assigns[:json_body],
         mode when mode in [:standard, :passthrough] <- to_mode(mode_str),
         :ok <- Rules.set_mode(mode) do
      json(conn, 200, %{status: "ok", mode: mode})
    else
      _ -> json(conn, 400, %{error: %{message: "mode must be 'standard' or 'passthrough'"}})
    end
  end

  # --- helpers ---

  defp raw_body, do: Process.get(:exll_raw_body, "")

  defp json(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(body))
  end

  defp to_mode("standard"), do: :standard
  defp to_mode("passthrough"), do: :passthrough
  defp to_mode(_), do: :invalid

  defp encode_rules(rules) do
    Enum.map(rules, fn %Rules.Rule{match: match, target: target, auth: auth} ->
      %{match: encode_match(match), target: encode_target(target), auth: to_string(auth)}
    end)
  end

  defp encode_match({:path_in, paths}), do: %{type: "path_in", paths: paths}
  defp encode_match({:messages_model, prefix}), do: %{type: "messages_model", prefix: prefix}
  defp encode_match({:messages_not_model, prefix}), do: %{type: "messages_not_model", prefix: prefix}
  defp encode_match(:any), do: %{type: "any"}

  defp encode_target(:litellm), do: %{type: "litellm"}
  defp encode_target(:anthropic), do: %{type: "anthropic"}
  defp encode_target({:url, url}), do: %{type: "url", url: url}

  defp decode_rules(%{"rules" => raw}) when is_list(raw) do
    {:ok, Enum.map(raw, &decode_rule/1)}
  rescue
    e -> {:error, e}
  end

  defp decode_rules(_), do: {:error, :missing_rules_key}

  defp decode_rule(%{"match" => m, "target" => t, "auth" => a}) do
    %Rules.Rule{match: decode_match(m), target: decode_target(t), auth: String.to_existing_atom(a)}
  end

  defp decode_match(%{"type" => "path_in", "paths" => paths}), do: {:path_in, paths}
  defp decode_match(%{"type" => "messages_model", "prefix" => p}), do: {:messages_model, p}
  defp decode_match(%{"type" => "messages_not_model", "prefix" => p}), do: {:messages_not_model, p}
  defp decode_match(%{"type" => "any"}), do: :any

  defp decode_target(%{"type" => "litellm"}), do: :litellm
  defp decode_target(%{"type" => "anthropic"}), do: :anthropic
  defp decode_target(%{"type" => "url", "url" => url}), do: {:url, url}
end
