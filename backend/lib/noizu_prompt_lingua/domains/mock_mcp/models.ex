defmodule NoizuPromptLingua.Domains.MockMCP.Models do
  @moduledoc """
  Registry of selectable LLM models for Mock MCP generation/inference.

  Single source of truth for the model picker exposed to the frontend and the
  per-definition `llm_provider`/`llm_model` fields. `resolve/1,3` maps a selection
  to a `GenAI.Model` struct understood by the `genai` library.
  """

  # Curated list surfaced in the UI. `id` is what the frontend stores; it maps
  # 1:1 onto a (provider, model) pair.
  @models [
    %{id: "openai:gpt-4o", label: "OpenAI · GPT-4o", provider: "openai", model: "gpt-4o"},
    %{id: "openai:gpt-4o-mini", label: "OpenAI · GPT-4o mini", provider: "openai", model: "gpt-4o-mini"},
    %{id: "openai:gpt-4.1", label: "OpenAI · GPT-4.1", provider: "openai", model: "gpt-4.1"},
    %{id: "anthropic:claude-sonnet-4-6", label: "Anthropic · Claude Sonnet 4.6", provider: "anthropic", model: "claude-sonnet-4-6"},
    %{id: "anthropic:claude-opus-4-6", label: "Anthropic · Claude Opus 4.6", provider: "anthropic", model: "claude-opus-4-6"},
    %{id: "anthropic:claude-haiku-4-5", label: "Anthropic · Claude Haiku 4.5", provider: "anthropic", model: "claude-haiku-4-5"},
    %{id: "deepseek:deepseek-chat", label: "DeepSeek · Chat", provider: "deepseek", model: "deepseek-chat"},
    %{id: "deepseek:deepseek-reasoner", label: "DeepSeek · Reasoner", provider: "deepseek", model: "deepseek-reasoner"},
    %{id: "zai:glm-5", label: "Z.ai · GLM-5", provider: "zai", model: "glm-5"},
    %{id: "zai:glm-4.6", label: "Z.ai · GLM-4.6", provider: "zai", model: "glm-4.6"},
    %{id: "cerebras:gpt-oss-120b", label: "Cerebras · GPT-OSS 120B", provider: "cerebras", model: "gpt-oss-120b"},
    %{id: "cerebras:zai-glm-4.7", label: "Cerebras · GLM-4.7", provider: "cerebras", model: "zai-glm-4.7"},
    %{id: "gemini:gemini-2.5-pro", label: "Gemini · 2.5 Pro", provider: "gemini", model: "gemini-2.5-pro"},
    %{id: "gemini:gemini-2.5-flash", label: "Gemini · 2.5 Flash", provider: "gemini", model: "gemini-2.5-flash"},
    %{id: "xai:grok-4", label: "Grok · 4", provider: "xai", model: "grok-4"},
    %{id: "xai:grok-4-fast-reasoning", label: "Grok · 4 Fast (reasoning)", provider: "xai", model: "grok-4-fast-reasoning"},
    %{id: "litellm:default", label: "LiteLLM · proxy default", provider: "litellm", model: "default"}
  ]

  @doc "All selectable models (for the frontend picker / MCP ListModels)."
  def all, do: @models

  @doc "The default model id, configurable via `:noizu_prompt_lingua, :mock_mcp`."
  def default_id do
    cfg = Application.get_env(:noizu_prompt_lingua, :mock_mcp, [])
    provider = cfg[:default_provider] || "openai"
    model = cfg[:default_model] || "gpt-4o-mini"
    "#{provider}:#{model}"
  end

  @doc """
  Resolve a selection to a `GenAI.Model` struct.

  Accepts either a registry id (`"openai:gpt-4o"`) or an explicit
  `provider`/`model` pair (per-definition fields). Falls back to the configured
  default when the selection is blank/unknown.
  """
  def resolve(nil), do: resolve(default_id())
  def resolve(""), do: resolve(default_id())

  def resolve(id) when is_binary(id) do
    case String.split(id, ":", parts: 2) do
      [provider, model] -> resolve(provider, model)
      [model] -> resolve("openai", model)
    end
  end

  def resolve(provider, model, _endpoint \\ nil)

  def resolve("anthropic", model, _endpoint) when is_binary(model) and model != "" do
    GenAI.Provider.Anthropic.Models.model(model)
  end

  def resolve("openai", model, _endpoint) when is_binary(model) and model != "" do
    GenAI.Provider.OpenAI.Models.model(model)
  end

  def resolve("deepseek", model, _endpoint) when is_binary(model) and model != "",
    do: GenAI.Provider.DeepSeek.Models.model(model)

  def resolve("zai", model, _endpoint) when is_binary(model) and model != "",
    do: GenAI.Provider.ZAI.Models.model(model)

  def resolve("cerebras", model, _endpoint) when is_binary(model) and model != "",
    do: GenAI.Provider.Cerebras.Models.model(model)

  def resolve("gemini", model, _endpoint) when is_binary(model) and model != "",
    do: GenAI.Provider.Gemini.Models.model(model)

  def resolve("xai", model, _endpoint) when is_binary(model) and model != "",
    do: GenAI.Provider.XAI.Models.model(model)

  def resolve("grok", model, endpoint), do: resolve("xai", model, endpoint)

  def resolve("groq", model, _endpoint) when is_binary(model) and model != "",
    do: GenAI.Provider.Groq.Models.model(model)

  def resolve("litellm", model, _endpoint) when is_binary(model) and model != "",
    do: GenAI.Provider.LiteLLM.Models.model(model)

  # Local / OpenAI-compatible custom endpoints are addressed through the OpenAI
  # provider (chat/completions shape). Unknown providers fall back here too.
  def resolve(_provider, model, _endpoint) when is_binary(model) and model != "" do
    GenAI.Provider.OpenAI.Models.model(model)
  end

  def resolve(_provider, _model, _endpoint), do: resolve(default_id())

  @doc """
  The `genai` provider module for a provider string. Used to attach a
  per-definition API key to the inference thread via `GenAI.with_api_key/3`.
  """
  def provider_module("anthropic"), do: GenAI.Provider.Anthropic
  def provider_module("deepseek"), do: GenAI.Provider.DeepSeek
  def provider_module("zai"), do: GenAI.Provider.ZAI
  def provider_module("cerebras"), do: GenAI.Provider.Cerebras
  def provider_module("gemini"), do: GenAI.Provider.Gemini
  def provider_module("xai"), do: GenAI.Provider.XAI
  def provider_module("grok"), do: GenAI.Provider.XAI
  def provider_module("groq"), do: GenAI.Provider.Groq
  def provider_module("litellm"), do: GenAI.Provider.LiteLLM
  def provider_module(_), do: GenAI.Provider.OpenAI
end
