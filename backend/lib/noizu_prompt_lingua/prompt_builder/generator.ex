defmodule NoizuPromptLingua.PromptBuilder.Generator do
  @moduledoc """
  Transport seam for the Prompt Builder's LLM calls (same pattern as
  MCPOverview.Generator): `complete/3` returns text plus token counts, and the
  active implementation is selected via `:noizu_prompt_lingua, :prompt_builder,
  :generator`. The LLM impl drives Groq (gpt-oss-120b) through the shared GenAI
  client; the Stub impl exists for tests and keyless dev.
  """

  @callback complete(system :: String.t(), user :: String.t(), opts :: keyword()) ::
              {:ok, %{text: String.t(), tokens_in: pos_integer(), tokens_out: pos_integer()}}
              | {:error, term()}

  @spec impl() :: module()
  def impl do
    cfg = Application.get_env(:noizu_prompt_lingua, :prompt_builder, [])
    cfg[:generator] || LLM
  end

  def complete(system, user, opts \\ []), do: impl().complete(system, user, opts)

  defmodule LLM do
    @moduledoc """
    Groq (OpenAI-compatible gpt-oss-120b) via the shared GenAI client. Provider/
    model come from the DB config row so admins can retarget without a deploy;
    the key is whatever `config :genai, :groq, api_key:` carries (GROQ_API_KEY
    via runtime.exs / Infisical).
    """
    @behaviour NoizuPromptLingua.PromptBuilder.Generator

    alias NoizuPromptLingua.PromptBuilder

    @impl true
    def complete(system, user, _opts) do
      config = PromptBuilder.get_config()
      model = resolve_model(config.provider, config.model)

      messages = [
        GenAI.Message.system(system),
        GenAI.Message.user(user)
      ]

      case GenAI.chat()
           |> GenAI.with_model(model)
           |> GenAI.with_messages(messages)
           |> GenAI.run() do
        {:ok, completion} ->
          case extract_text(completion) do
            nil ->
              {:error, :empty_completion}

            text ->
              {tokens_in, tokens_out} = extract_usage(completion)
              {:ok, %{text: String.trim(text), tokens_in: tokens_in, tokens_out: tokens_out}}
          end

        {:error, reason} ->
          {:error, reason}

        other ->
          {:error, {:unexpected_response, other}}
      end
    end

    defp resolve_model("groq", model), do: GenAI.Provider.Groq.Models.model(model)
    defp resolve_model("openai", model), do: GenAI.Provider.OpenAI.Models.model(model)
    defp resolve_model("anthropic", model), do: GenAI.Provider.Anthropic.Models.model(model)

    defp resolve_model(_provider, model), do: GenAI.Provider.OpenAI.Models.model(model)

    # Same completion-shape handling as MCPOverview.Generator.LLM.
    defp extract_text(%{choices: [choice | _]}) do
      case choice[:message] || Map.get(choice, :message) do
        %{content: content} when is_binary(content) -> content
        %{content: content} when is_list(content) -> Enum.join(content, " ")
        _ -> nil
      end
    end

    defp extract_text(_), do: nil

    defp extract_usage(completion) when is_map(completion) do
      usage = completion[:usage] || Map.get(completion, :usage) || %{}

      tokens_in = usage[:prompt_tokens] || Map.get(usage, :prompt_tokens)
      tokens_out = usage[:completion_tokens] || Map.get(usage, :completion_tokens)

      {tokens_in || 0, tokens_out || 0}
    end

    defp extract_usage(_), do: {0, 0}
  end

  defmodule Stub do
    @moduledoc """
    Deterministic implementation for tests and keyless dev: echoes an NPL-shaped
    prompt so the guardrail/limiter/budget paths run end-to-end without a
    provider. Tests script replies via the process dict:
    `Process.put(:pb_stub_replies, [{:text, "..."}, {:error, reason}, ...])` —
    one entry per call, FIFO; falls back to the echo when the queue is empty.
    """
    @behaviour NoizuPromptLingua.PromptBuilder.Generator

    @impl true
    def complete(_system, user, _opts) do
      case pop_reply() do
        {:error, reason} ->
          {:error, reason}

        {:text, text} ->
          {:ok, %{text: text, tokens_in: 100, tokens_out: 50}}

        _ ->
          desc = String.slice(user, 0, 120)

          {:ok,
           %{
             text: "⌜NPL@1.0⌝\n:persona: \"built from: #{desc}\"\n:syntax\n⌞NPL@1.0⌟",
             tokens_in: 100,
             tokens_out: 50
           }}
      end
    end

    defp pop_reply do
      case Process.get(:pb_stub_replies) do
        [reply | rest] when elem(reply, 0) in [:text, :error] ->
          Process.put(:pb_stub_replies, rest)
          reply

        _ ->
          nil
      end
    end
  end
end
