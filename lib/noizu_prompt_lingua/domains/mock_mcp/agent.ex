defmodule NoizuPromptLingua.Domains.MockMCP.Agent do
  @moduledoc """
  LLM integration for MockMCP. Generates tool definitions from prompts
  and handles tool calls by forwarding to an LLM with the mock's system prompt.
  """

  @tool_gen_system_prompt """
  You are an MCP server architect. Given a description of what an MCP server should do,
  generate a JSON array of MCP tool definitions. Each tool must have:
  - "name": string (snake_case)
  - "description": string
  - "inputSchema": JSON Schema object with "type": "object", "properties", and "required"

  Return ONLY the JSON array, no markdown fences or explanation.
  """

  @call_system_prompt_prefix """
  You are an MCP server. Your behavior is defined by the following prompt:

  ---
  %PROMPT%
  ---

  You have been called with the following tool invocation. Respond with the tool's
  result as a JSON object. Return ONLY the JSON result, no explanation.
  If the tool should return text content, use: {"type": "text", "text": "..."}
  If the tool should return structured data, use: {"type": "json", "data": {...}}
  """

  def generate_tools(prompt, opts \\ []) do
    provider = opts[:provider] || "openai"
    model = opts[:model]
    endpoint = opts[:endpoint]

    messages = [
      %{role: "system", content: @tool_gen_system_prompt},
      %{role: "user", content: prompt}
    ]

    case call_llm(messages, provider, model, endpoint) do
      {:ok, response} ->
        case Jason.decode(response) do
          {:ok, tools} when is_list(tools) -> {:ok, tools}
          {:ok, %{"tools" => tools}} when is_list(tools) -> {:ok, tools}
          _ -> {:error, :invalid_tool_json, response}
        end
      error -> error
    end
  end

  def handle_tool_call(prompt, tool_name, arguments, opts \\ []) do
    provider = opts[:provider] || "openai"
    model = opts[:model]
    endpoint = opts[:endpoint]

    system = String.replace(@call_system_prompt_prefix, "%PROMPT%", prompt)
    user_msg = "Tool: #{tool_name}\nArguments: #{Jason.encode!(arguments || %{})}"

    messages = [
      %{role: "system", content: system},
      %{role: "user", content: user_msg}
    ]

    start = System.monotonic_time(:millisecond)
    result = call_llm(messages, provider, model, endpoint)
    latency = System.monotonic_time(:millisecond) - start

    case result do
      {:ok, response} ->
        content = parse_tool_response(response)
        {:ok, content, latency}
      {:error, reason} ->
        {:error, reason, latency}
    end
  end

  defp parse_tool_response(response) do
    case Jason.decode(response) do
      {:ok, %{"type" => "text", "text" => text}} ->
        [%{"type" => "text", "text" => text}]
      {:ok, %{"type" => "json", "data" => data}} ->
        [%{"type" => "text", "text" => Jason.encode!(data)}]
      {:ok, data} when is_map(data) ->
        [%{"type" => "text", "text" => Jason.encode!(data)}]
      _ ->
        [%{"type" => "text", "text" => response}]
    end
  end

  defp call_llm(messages, provider, model, endpoint) do
    {url, headers, model} = resolve_provider(provider, model, endpoint)
    body = Jason.encode!(%{model: model, messages: messages, temperature: 0.7})

    case :httpc.request(:post,
      {String.to_charlist(url), [{~c"Content-Type", ~c"application/json"} | headers], ~c"application/json", body},
      [{:timeout, 30_000}], []) do
      {:ok, {{_, 200, _}, _, resp_body}} ->
        case Jason.decode(to_string(resp_body)) do
          {:ok, %{"choices" => [%{"message" => %{"content" => content}} | _]}} ->
            {:ok, String.trim(content)}
          {:ok, other} ->
            {:error, {:unexpected_response, other}}
        end
      {:ok, {{_, status, _}, _, resp_body}} ->
        {:error, {:http_error, status, to_string(resp_body)}}
      {:error, reason} ->
        {:error, {:request_failed, reason}}
    end
  end

  defp resolve_provider("openai", model, endpoint) do
    url = endpoint || "https://api.openai.com/v1/chat/completions"
    key = System.get_env("OPENAI_API_KEY", "")
    headers = [{~c"Authorization", String.to_charlist("Bearer #{key}")}]
    {url, headers, model || "gpt-4o-mini"}
  end

  defp resolve_provider("anthropic", model, endpoint) do
    url = endpoint || "https://api.anthropic.com/v1/messages"
    key = System.get_env("ANTHROPIC_API_KEY", "")
    headers = [
      {~c"x-api-key", String.to_charlist(key)},
      {~c"anthropic-version", ~c"2023-06-01"}
    ]
    {url, headers, model || "claude-sonnet-4-20250514"}
  end

  defp resolve_provider("local", model, endpoint) do
    url = endpoint || "http://localhost:1234/v1/chat/completions"
    {url, [], model || "default"}
  end

  defp resolve_provider(_, model, endpoint) do
    resolve_provider("openai", model, endpoint)
  end
end
