defmodule ExLiteLLM.Core.Provider do
  @moduledoc """
  Model → provider resolution — ex-litellm's equivalent of litellm's
  `get_llm_provider` (`litellm/litellm_core_utils/get_llm_provider_logic.py`).

  Resolves a model string into `{:ok, provider_atom, bare_model, adapter_module}`:

    * **explicit prefix** — `"anthropic/claude-3-5-sonnet"` → `{:anthropic,
      "claude-3-5-sonnet"}` (split on the first `/` when the head is a known
      provider).
    * **api_base endpoint match** — a deployment whose `api_base` points at a
      known host (e.g. `api.groq.com`) pins the provider.
    * **bare-model pattern** — `"claude-*"` → anthropic, `"gpt-*"`/`"o1"`/`"o3"`
      → openai, `"gemini-*"` → gemini, etc.

  The registry maps a provider atom to its adapter module. Providers run-claude
  uses are all registered; the long tail is added as adapters land.
  """

  # provider atom → adapter module
  @registry %{
    openai: ExLiteLLM.Providers.OpenAI,
    anthropic: ExLiteLLM.Providers.Anthropic,
    groq: ExLiteLLM.Providers.Groq,
    cerebras: ExLiteLLM.Providers.Cerebras,
    deepseek: ExLiteLLM.Providers.DeepSeek,
    xai: ExLiteLLM.Providers.XAI,
    mistral: ExLiteLLM.Providers.Mistral,
    perplexity: ExLiteLLM.Providers.Perplexity,
    ollama: ExLiteLLM.Providers.Ollama,
    openai_compatible: ExLiteLLM.Providers.OpenAI
  }

  @providers Map.keys(@registry)

  @doc "The provider atom → adapter module registry."
  @spec registry() :: %{atom() => module()}
  def registry, do: @registry

  @doc "Known provider atoms."
  @spec providers() :: [atom()]
  def providers, do: @providers

  @doc """
  Resolve a model string (+ optional deployment `litellm_params`) into
  `{:ok, provider, bare_model, adapter}` or `{:error, reason}`.
  """
  @spec resolve(String.t(), map()) ::
          {:ok, atom(), String.t(), module()} | {:error, term()}
  def resolve(model, litellm_params \\ %{}) when is_binary(model) do
    with {:ok, provider, bare} <- classify(model, litellm_params),
         {:ok, adapter} <- adapter_for(provider) do
      {:ok, provider, bare, adapter}
    end
  end

  @doc "Look up the adapter module for a provider atom."
  @spec adapter_for(atom()) :: {:ok, module()} | {:error, term()}
  def adapter_for(provider) do
    case Map.fetch(@registry, provider) do
      {:ok, mod} -> {:ok, mod}
      :error -> {:error, {:unknown_provider, provider}}
    end
  end

  # --- classification ---

  defp classify(model, litellm_params) do
    cond do
      # 1. explicit `provider/model` prefix
      match = prefix_provider(model) ->
        {:ok, match, strip_prefix(model)}

      # 2. api_base endpoint match from the deployment
      provider = endpoint_provider(litellm_params) ->
        {:ok, provider, model}

      # 3. bare-model name pattern
      provider = pattern_provider(model) ->
        {:ok, provider, model}

      # 4. default: treat as OpenAI-compatible (custom api_base deployments)
      true ->
        {:ok, :openai_compatible, model}
    end
  end

  defp prefix_provider(model) do
    case String.split(model, "/", parts: 2) do
      [head, _rest] ->
        atom = safe_atom(head)
        if atom in @providers, do: atom, else: nil

      _ ->
        nil
    end
  end

  defp strip_prefix(model) do
    case String.split(model, "/", parts: 2) do
      [_head, rest] -> rest
      _ -> model
    end
  end

  defp endpoint_provider(%{"api_base" => base}) when is_binary(base) do
    cond do
      String.contains?(base, "api.groq.com") -> :groq
      String.contains?(base, "api.cerebras.ai") -> :cerebras
      String.contains?(base, "api.deepseek.com") -> :deepseek
      String.contains?(base, "api.x.ai") -> :xai
      String.contains?(base, "api.mistral.ai") -> :mistral
      String.contains?(base, "api.perplexity.ai") -> :perplexity
      String.contains?(base, "api.anthropic.com") -> :anthropic
      String.contains?(base, "api.openai.com") -> :openai
      true -> nil
    end
  end

  defp endpoint_provider(_), do: nil

  defp pattern_provider(model) do
    cond do
      String.starts_with?(model, "claude-") -> :anthropic
      String.starts_with?(model, "gpt-") -> :openai
      String.starts_with?(model, "o1") -> :openai
      String.starts_with?(model, "o3") -> :openai
      String.starts_with?(model, "chatgpt") -> :openai
      String.starts_with?(model, "text-embedding-") -> :openai
      String.starts_with?(model, "deepseek-") -> :deepseek
      String.starts_with?(model, "grok-") -> :xai
      String.starts_with?(model, "mistral-") -> :mistral
      true -> nil
    end
  end

  # Only convert to atom if it's already a known provider atom name — avoids
  # unbounded atom creation from arbitrary model prefixes.
  defp safe_atom(str) do
    try do
      String.to_existing_atom(str)
    rescue
      ArgumentError -> nil
    end
  end
end
