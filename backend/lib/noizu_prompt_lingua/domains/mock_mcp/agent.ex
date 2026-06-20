defmodule NoizuPromptLingua.Domains.MockMCP.Agent do
  @moduledoc """
  LLM integration for MockMCP, backed by the `genai` library (with a direct
  HTTP path for custom endpoints).

  Responsibilities:
    * generate the server *surface* (tools, resources, prompts) from a prose
      prompt — each tool/resource/prompt also gets a **private `handler`**: an
      internal spec, never exposed to clients, telling the server exactly how to
      respond and format that item's result;
    * fabricate responses for tool calls, resource reads, and prompt gets,
      injecting the relevant private handler.

  Model/provider/endpoint/key selection flows through the active LLM connection
  (see `MockMCP.active_llm_opts/1`).
  """

  alias NoizuPromptLingua.Domains.MockMCP.{Models, InternalOps}

  # Max internal data-ops the agent may run while fulfilling a single request.
  @max_internal_steps 5

  @surface_gen_system_prompt """
  You are an MCP server architect. Given a description of what an MCP server should do,
  generate a JSON object with three arrays: "tools", "resources", and "prompts".

  Each TOOL: {
    "name": snake_case string,
    "description": string (client-facing),
    "inputSchema": JSON Schema object with "type":"object","properties","required",
    "handler": string
  }
  Each RESOURCE: {
    "uri": string (e.g. "mock://orders/recent"),
    "name": string,
    "description": string,
    "mimeType": string (e.g. "application/json" or "text/plain"),
    "handler": string
  }
  Each PROMPT: {
    "name": snake_case string,
    "description": string,
    "arguments": [{"name": string, "description": string, "required": boolean}],
    "handler": string
  }

  The "handler" field is PRIVATE server-side instructions that are NEVER shown to
  clients. Write it as explicit guidance to yourself on exactly how to respond to
  this item and how to format the result (shape, fields, tone, invariants).

  Return ONLY the JSON object, no markdown fences or explanation.
  """

  @tool_call_system """
  You are an MCP server. Your behavior is defined by the following prompt:

  ---
  %PROMPT%
  ---

  You are handling the tool "%TOOL%". Follow these PRIVATE handler instructions
  exactly — they define how you must respond and format the result:

  ---
  %HANDLER%
  ---

  Respond with the tool's result as a JSON object. Return ONLY the JSON result,
  no explanation. For text content use {"type":"text","text":"..."};
  for structured data use {"type":"json","data":{...}}.
  """

  @resource_read_system """
  You are an MCP server. Your behavior is defined by the following prompt:

  ---
  %PROMPT%
  ---

  You are producing the contents of the resource "%URI%". Follow these PRIVATE
  handler instructions exactly:

  ---
  %HANDLER%
  ---

  Return ONLY the resource contents (raw text or JSON matching the resource's
  mimeType), no explanation, no markdown fences.
  """

  @prompt_get_system """
  You are an MCP server. Your behavior is defined by the following prompt:

  ---
  %PROMPT%
  ---

  You are producing the messages for the prompt "%NAME%". Follow these PRIVATE
  handler instructions exactly:

  ---
  %HANDLER%
  ---

  Return ONLY a JSON object {"messages":[{"role":"user|assistant|system","content":"..."}]},
  no explanation, no markdown fences.
  """

  # ── Surface generation ───────────────────────────────────────

  @doc """
  Generate the full server surface from the prose prompt. Returns
  `{:ok, %{"tools" => [...], "resources" => [...], "prompts" => [...]}}`,
  `{:error, :invalid_surface_json, raw}`, or `{:error, reason}`.
  """
  def generate_surface(prompt, opts \\ []) do
    messages = [
      GenAI.Message.system(@surface_gen_system_prompt),
      GenAI.Message.user(prompt)
    ]

    case run(messages, opts) do
      {:ok, response} ->
        case decode_json(response) do
          {:ok, %{} = obj} ->
            {:ok,
             %{
               "tools" => list_field(obj, "tools"),
               "resources" => list_field(obj, "resources"),
               "prompts" => list_field(obj, "prompts")
             }}
          # tolerate a bare tools array
          {:ok, tools} when is_list(tools) ->
            {:ok, %{"tools" => tools, "resources" => [], "prompts" => []}}
          _ ->
            {:error, :invalid_surface_json, response}
        end
      error -> error
    end
  end

  defp list_field(obj, key) do
    case obj[key] do
      l when is_list(l) -> l
      _ -> []
    end
  end

  # ── Tool calls ───────────────────────────────────────────────

  @doc """
  Handle a (generated) tool call. `def_` is the definition (supplies the mock
  prompt + private datastore); `handler` is the tool's private response spec.
  Runs a bounded internal tool-use loop so the agent can read/write its private
  datastore. Returns `{:ok, content, latency_ms, trace}` or
  `{:error, reason, latency_ms, trace}`.
  """
  def handle_tool_call(def_, tool_name, arguments, handler, opts \\ []) do
    system =
      @tool_call_system
      |> fill("%PROMPT%", def_.prompt)
      |> fill("%TOOL%", tool_name)
      |> fill("%HANDLER%", handler)
      |> append_ops(def_)

    user_msg = "Tool: #{tool_name}\nArguments: #{Jason.encode!(arguments || %{})}"

    agent_loop(def_, system, user_msg, opts, &parse_tool_response/1)
  end

  defp parse_tool_response(response) do
    case decode_json(response) do
      {:ok, %{"type" => "text", "text" => text}} -> [%{"type" => "text", "text" => text}]
      {:ok, %{"type" => "json", "data" => data}} -> [%{"type" => "text", "text" => Jason.encode!(data)}]
      {:ok, data} when is_map(data) -> [%{"type" => "text", "text" => Jason.encode!(data)}]
      _ -> [%{"type" => "text", "text" => response}]
    end
  end

  # ── Resource reads ───────────────────────────────────────────

  @doc """
  Produce a resource's contents. `resource` is the stored descriptor (uri,
  mimeType, handler). Returns `{:ok, contents, latency_ms}` where contents is the
  MCP `contents` array, or `{:error, reason, latency_ms}`.
  """
  def handle_resource_read(def_, resource, opts \\ []) do
    uri = resource["uri"]
    mime = resource["mimeType"] || "text/plain"

    system =
      @resource_read_system
      |> fill("%PROMPT%", def_.prompt)
      |> fill("%URI%", uri)
      |> fill("%HANDLER%", resource["handler"])
      |> append_ops(def_)

    agent_loop(def_, system, "Produce the contents of #{uri}.", opts, fn response ->
      [%{"uri" => uri, "mimeType" => mime, "text" => response}]
    end)
  end

  # ── Prompt gets ──────────────────────────────────────────────

  @doc """
  Produce a prompt's messages. Returns `{:ok, messages, latency_ms}` (MCP prompt
  messages) or `{:error, reason, latency_ms}`.
  """
  def handle_prompt_get(def_, prompt_def, arguments, opts \\ []) do
    name = prompt_def["name"]

    system =
      @prompt_get_system
      |> fill("%PROMPT%", def_.prompt)
      |> fill("%NAME%", name)
      |> fill("%HANDLER%", prompt_def["handler"])
      |> append_ops(def_)

    user_msg = "Arguments: #{Jason.encode!(arguments || %{})}"

    agent_loop(def_, system, user_msg, opts, &normalize_prompt_messages/1)
  end

  defp normalize_prompt_messages(response) do
    case decode_json(response) do
      {:ok, %{"messages" => msgs}} when is_list(msgs) ->
        Enum.map(msgs, &to_mcp_message/1)
      {:ok, msgs} when is_list(msgs) ->
        Enum.map(msgs, &to_mcp_message/1)
      _ ->
        [%{"role" => "user", "content" => %{"type" => "text", "text" => response}}]
    end
  end

  defp to_mcp_message(%{"role" => role, "content" => content}) when is_binary(content),
    do: %{"role" => role, "content" => %{"type" => "text", "text" => content}}
  defp to_mcp_message(%{"role" => role, "content" => %{} = content}),
    do: %{"role" => role, "content" => content}
  defp to_mcp_message(other),
    do: %{"role" => "user", "content" => %{"type" => "text", "text" => to_string_safe(other)}}

  defp to_string_safe(v) when is_binary(v), do: v
  defp to_string_safe(v), do: Jason.encode!(v)

  # ── Bounded internal tool-use loop ───────────────────────────

  # Run the agent over up to @max_internal_steps internal data ops, then
  # finalize the response with `parse`. Returns {:ok, parsed, latency, trace} |
  # {:error, reason, latency, trace}. `trace` is the list of executed ops.
  defp agent_loop(def_, system, user_msg, opts, parse) do
    messages = [GenAI.Message.system(system), GenAI.Message.user(user_msg)]
    start = System.monotonic_time(:millisecond)
    {result, trace} = loop(def_, messages, opts, @max_internal_steps, [])
    latency = System.monotonic_time(:millisecond) - start

    case result do
      {:ok, response} -> {:ok, parse.(response), latency, Enum.reverse(trace)}
      {:error, reason} -> {:error, reason, latency, Enum.reverse(trace)}
    end
  end

  defp loop(def_, messages, opts, steps, trace) do
    case run(messages, opts) do
      {:error, reason} ->
        {{:error, reason}, trace}

      {:ok, text} ->
        case parse_op(text) do
          :final ->
            {{:ok, text}, trace}

          {:op, _op, _args} when steps <= 0 ->
            # Out of internal-op budget — force a final answer.
            forced =
              messages ++
                [
                  GenAI.Message.assistant(text),
                  GenAI.Message.user("Stop. Do not use any more ops. Return ONLY the final result now.")
                ]

            case run(forced, opts) do
              {:ok, final} -> {{:ok, final}, trace}
              {:error, reason} -> {{:error, reason}, trace}
            end

          {:op, op, args} ->
            {res, entry} = exec_op(def_, op, args)

            next =
              messages ++
                [
                  GenAI.Message.assistant(text),
                  GenAI.Message.user("OP RESULT (#{op}): #{Jason.encode!(res)}")
                ]

            loop(def_, next, opts, steps - 1, [entry | trace])
        end
    end
  end

  # An internal-op message is a JSON object with a recognised "op" and no result
  # "type" field; anything else is treated as the final result.
  defp parse_op(text) do
    case decode_json(text) do
      {:ok, %{"op" => op} = m} when is_binary(op) ->
        if InternalOps.op?(op) and not Map.has_key?(m, "type"),
          do: {:op, op, m["args"] || %{}},
          else: :final

      _ ->
        :final
    end
  end

  defp exec_op(def_, op, args) do
    case InternalOps.exec(def_, op, args) do
      {:ok, res} -> {res, %{"op" => op, "args" => args, "result" => res}}
      {:error, msg} -> {%{"error" => msg}, %{"op" => op, "args" => args, "error" => msg}}
    end
  end

  defp append_ops(system, def_) do
    system <>
      """


      You have a PRIVATE datastore the caller cannot see; use it to keep your
      responses stateful and consistent across calls. To run an operation, reply
      with ONLY a JSON object {"op": "<name>", "args": { ... }}. I will reply with
      "OP RESULT (<name>): <json>". You may run several in sequence. When finished,
      reply with ONLY the final result described above (no "op" field).

      #{InternalOps.available(def_)}
      """
  end

  defp fill(template, token, value), do: String.replace(template, token, value || "")

  # ── Inference plumbing (genai or direct HTTP for custom endpoints) ──

  defp run(messages, opts) do
    endpoint = blank_to_nil(opts[:endpoint])
    if endpoint, do: run_http(messages, opts, endpoint), else: run_genai(messages, opts)
  end

  defp run_genai(messages, opts) do
    model = Models.resolve(opts[:provider], opts[:model], opts[:endpoint])

    GenAI.chat()
    |> GenAI.with_model(model)
    |> maybe_with_api_key(opts)
    |> GenAI.with_messages(messages)
    |> GenAI.run()
    |> case do
      {:ok, completion} ->
        case extract_content(completion) do
          nil -> {:error, {:unexpected_response, completion}}
          content -> {:ok, String.trim(content)}
        end
      {:error, reason} -> {:error, reason}
      other -> {:error, {:unexpected_response, other}}
    end
  end

  defp maybe_with_api_key(thread, opts) do
    case blank_to_nil(opts[:api_key]) do
      nil -> thread
      key -> GenAI.with_api_key(thread, Models.provider_module(opts[:provider]), key)
    end
  end

  defp run_http(messages, opts, endpoint) do
    provider = opts[:provider] || "openai"
    model = blank_to_nil(opts[:model]) || "gpt-4o-mini"
    key = blank_to_nil(opts[:api_key]) || ""

    {url, headers, body} = build_http_request(provider, endpoint, model, key, messages)

    :inets.start()
    :ssl.start()

    case :httpc.request(
           :post,
           {String.to_charlist(url),
            [{~c"Content-Type", ~c"application/json"} | headers], ~c"application/json", body},
           [{:timeout, 60_000}],
           []
         ) do
      {:ok, {{_, 200, _}, _, resp_body}} -> parse_http_response(provider, to_string(resp_body))
      {:ok, {{_, status, _}, _, resp_body}} -> {:error, {:http_error, status, to_string(resp_body)}}
      {:error, reason} -> {:error, {:request_failed, reason}}
    end
  end

  defp build_http_request("anthropic" <> _, endpoint, model, key, messages) do
    {system, turns} = split_system(messages)

    body =
      Jason.encode!(%{
        model: model,
        max_tokens: 4096,
        system: system,
        messages: Enum.map(turns, &%{role: to_string(&1.role), content: content_string(&1.content)})
      })

    headers = [
      {~c"x-api-key", String.to_charlist(key)},
      {~c"anthropic-version", ~c"2023-06-01"}
    ]

    {endpoint, headers, body}
  end

  defp build_http_request(_provider, endpoint, model, key, messages) do
    body =
      Jason.encode!(%{
        model: model,
        temperature: 0.7,
        messages: Enum.map(messages, &%{role: to_string(&1.role), content: content_string(&1.content)})
      })

    headers = [{~c"Authorization", String.to_charlist("Bearer #{key}")}]
    {endpoint, headers, body}
  end

  defp parse_http_response("anthropic" <> _, raw) do
    case Jason.decode(raw) do
      {:ok, %{"content" => [%{"text" => text} | _]}} -> {:ok, String.trim(text)}
      {:ok, other} -> {:error, {:unexpected_response, other}}
      {:error, reason} -> {:error, {:invalid_json, reason}}
    end
  end

  defp parse_http_response(_provider, raw) do
    case Jason.decode(raw) do
      {:ok, %{"choices" => [%{"message" => %{"content" => content}} | _]}} -> {:ok, String.trim(content)}
      {:ok, other} -> {:error, {:unexpected_response, other}}
      {:error, reason} -> {:error, {:invalid_json, reason}}
    end
  end

  defp split_system(messages) do
    {systems, turns} = Enum.split_with(messages, &(&1.role == :system))
    system = systems |> Enum.map(&content_string(&1.content)) |> Enum.join("\n\n")
    {system, turns}
  end

  defp content_string(content) when is_binary(content), do: content
  defp content_string(content) when is_list(content) do
    content |> Enum.map(&block_text/1) |> Enum.reject(&is_nil/1) |> Enum.join("")
  end
  defp content_string(content), do: to_string(content)

  defp extract_content(%{choices: [choice | _]}) do
    choice |> Map.get(:message) |> message_text()
  end
  defp extract_content(_), do: nil

  defp message_text(%{content: content}) when is_binary(content), do: content
  defp message_text(%{content: content}) when is_list(content) do
    content |> Enum.map(&block_text/1) |> Enum.reject(&is_nil/1) |> Enum.join("")
  end
  defp message_text(_), do: nil

  defp block_text(text) when is_binary(text), do: text
  defp block_text(%{text: text}) when is_binary(text), do: text
  defp block_text(_), do: nil

  defp decode_json(response) when is_binary(response) do
    response |> strip_fences() |> Jason.decode()
  end

  defp strip_fences(str) do
    str = String.trim(str)
    case Regex.run(~r/^```(?:json)?\s*\n(.*)\n```$/s, str) do
      [_, inner] -> String.trim(inner)
      _ -> str
    end
  end

  defp blank_to_nil(nil), do: nil
  defp blank_to_nil(""), do: nil
  defp blank_to_nil(v), do: v
end
