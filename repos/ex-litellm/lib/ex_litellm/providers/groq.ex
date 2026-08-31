defmodule ExLiteLLM.Providers.Groq do
  @moduledoc """
  Groq — OpenAI-compatible. Groq is a "strict" provider: it rejects several
  OpenAI params (e.g. `logit_bias`, `logprobs`, `top_logprobs`, `n>1`), which is
  exactly what run-claude's `provider_compat` callback strips. We narrow the
  supported-param set so `drop_params` removes them before the call.

  GPT-OSS models (`openai/gpt-oss-*`) put chain-of-thought in `message.reasoning`
  and can exhaust `max_tokens` before any `content` is produced — which Claude
  Code renders as "the model did not reply". We hide reasoning from the wire
  (`include_reasoning: false`), alias `max_tokens` → `max_completion_tokens`,
  and coerce illegal `reasoning_effort` values so Groq does not 400.
  """
  use ExLiteLLM.Providers.OpenAICompatible,
    base_url: "https://api.groq.com/openai/v1",
    api_key_env: "GROQ_API_KEY"

  alias ExLiteLLM.Providers.Adapter.Request
  alias ExLiteLLM.Providers.OpenAICompatible.Shared

  @unsupported ~w(logit_bias logprobs top_logprobs)
  @gpt_oss_effort ~w(low medium high)
  @qwen_effort ~w(none default)
  @allowed_effort @gpt_oss_effort ++ @qwen_effort
  @min_gpt_oss_completion 2048

  @impl true
  def get_supported_openai_params(_model) do
    Shared.default_supported_params() -- @unsupported
  end

  @impl true
  def transform_request(%Request{} = req) do
    req
    |> Shared.transform_request()
    |> sanitize_reasoning_effort()
    |> sanitize_tool_schemas()
    |> maybe_hide_reasoning(req.model)
    |> alias_max_tokens(req.model)
  end

  defp sanitize_reasoning_effort(%{"reasoning_effort" => v} = body) when is_binary(v) do
    cond do
      v in @allowed_effort ->
        body

      v in ~w(max xhigh highest) ->
        Map.put(body, "reasoning_effort", "high")

      v in ~w(enabled adaptive auto) ->
        Map.put(body, "reasoning_effort", "medium")

      v in ~w(minimal min) ->
        Map.put(body, "reasoning_effort", "low")

      true ->
        Map.delete(body, "reasoning_effort")
    end
  end

  defp sanitize_reasoning_effort(%{"reasoning_effort" => _} = body), do: Map.delete(body, "reasoning_effort")
  defp sanitize_reasoning_effort(body), do: body

  defp maybe_hide_reasoning(body, model) do
    if gpt_oss?(model) do
      Map.put_new(body, "include_reasoning", false)
    else
      body
    end
  end

  defp alias_max_tokens(body, model) do
    n = body["max_completion_tokens"] || body["max_tokens"]

    cond do
      not gpt_oss?(model) ->
        body

      is_integer(n) ->
        body
        |> Map.put("max_completion_tokens", max(n, @min_gpt_oss_completion))
        |> Map.delete("max_tokens")

      true ->
        Map.put(body, "max_completion_tokens", @min_gpt_oss_completion)
    end
  end

  defp gpt_oss?(model) when is_binary(model), do: String.contains?(model, "gpt-oss")
  defp gpt_oss?(_), do: false

  # Groq compiles tool JSON Schema (draft 2020-12) and 400s on Claude Code
  # `pattern` values such as ^[A-Za-z0-9_=-]{1,4096}$ (invalid range under
  # format:regex). Drop pattern / patternProperties; keep names and types.
  defp sanitize_tool_schemas(%{"tools" => tools} = body) when is_list(tools) do
    Map.put(body, "tools", Enum.map(tools, &sanitize_tool/1))
  end

  defp sanitize_tool_schemas(body), do: body

  defp sanitize_tool(%{"function" => %{"parameters" => schema}} = tool) when is_map(schema) do
    put_in(tool, ["function", "parameters"], strip_schema_patterns(schema))
  end

  defp sanitize_tool(tool), do: tool

  defp strip_schema_patterns(schema) when is_map(schema) do
    schema
    |> Map.drop(["pattern", "patternProperties"])
    |> Map.new(fn {k, v} -> {k, strip_schema_patterns(v)} end)
  end

  defp strip_schema_patterns(list) when is_list(list), do: Enum.map(list, &strip_schema_patterns/1)
  defp strip_schema_patterns(other), do: other
end
