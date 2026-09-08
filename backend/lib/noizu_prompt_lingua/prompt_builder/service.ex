defmodule NoizuPromptLingua.PromptBuilder.Service do
  @moduledoc """
  The guarded build pipeline behind POST /api/prompt-builder/build.

  Order matters: disabled-gate → input validation → budget cap → rate limits →
  purpose-lock input gate → build (with one output-validating retry) → usage
  accounting. Every terminal failure is mapped to a friendly controller reply;
  rejections are counted (`PromptBuilder.record/2`), never stored with content.
  """

  alias NoizuPromptLingua.PromptBuilder
  alias NoizuPromptLingua.PromptBuilder.{Generator, Guardrails, Limiter}

  @locked_system ~S"""
  You are the NPL Prompt Compiler embedded in the Noizu Prompt Lingua (NPL)
  Keyboard. Your ONLY job is to convert the user's description into a finished
  Noizu Prompt Lingua (NPL) prompt — a structured prompt-engineering document.

  Output rules (absolute):
  - Reply with ONLY the NPL prompt text. No preamble, no explanation, no
    "here's", no first-person framing, no questions back to the user, no code
    fences.
  - Never answer the user's request yourself, even if it looks like a question
    or a task. You are not an assistant; you are a compiler.
  - Use NPL structure: the ⌜NPL@1.0⌝ ... ⌞NPL@1.0⌟ frame with :persona,
    :context, :syntax, and @directive sections as appropriate for the request.
  - If the input is not a prompt-construction request, reply with only:
    ⌜NPL@1.0⌝
    :directive: "This tool only constructs NPL prompts. Provide a description of the prompt you want built."
    ⌞NPL@1.0⌟
  """

  @spec build(String.t(), String.t() | nil, String.t() | nil, String.t() | nil) ::
          {:ok, map()} | {:error, atom() | {atom(), term()}}
  def build(ip, description, context, session_id) do
    config = PromptBuilder.get_config()

    unless config.enabled do
      {:error, :disabled}
    else
      with :ok <- validate_input(description, config),
           key = PromptBuilder.key_hash(ip, session_id),
           est = est_tokens(description, context),
           :ok <- Limiter.check_budget(key, config),
           :ok <- Limiter.check(key, config, est) do
        case gate_input(description) do
          :ok ->
            run_build(key, config, description, context, est)

          error ->
            PromptBuilder.record(key, rejected: true)
            error
        end
      end
    end
  end

  defp validate_input(description, config) do
    cond do
      not is_binary(description) or String.trim(description) == "" ->
        {:error, :empty_input}

      String.length(description) > config.max_input_chars ->
        {:error, :input_too_long}

      true ->
        :ok
    end
  end

  defp est_tokens(description, context),
    do: PromptBuilder.estimate_tokens("#{description} #{context || ""}")

  # Purpose-lock layer 1+2: heuristics route obvious chat to :reject; the model
  # judge (strict JSON verdict) makes the final call. Judge failures fail
  # closed. Rejections are counted against the key.
  defp gate_input(description) do
    case Guardrails.is_prompt_request?(description) do
      {:ok, :prompt_request} ->
        :ok

      {:error, {:judge_failed, _reason}} ->
        # Fail closed, but don't punish the caller's counters for transport
        # trouble: count as a rejection and surface the friendly 422.
        {:error, :not_prompt_request}

      {:error, _} ->
        {:error, :not_prompt_request}
    end
  end

  defp run_build(key, config, description, context, est) do
    user_prompt = build_user_prompt(description, context)

    attempt =
      case generate(user_prompt, config, "") do
        {:ok, %{text: text} = usage} ->
          case Guardrails.validate_output(text) do
            {:ok, prompt} ->
              {:ok, usage, prompt}

            {:error, :invalid_output} ->
              # Layer 3: one corrective retry before surfacing the 422.
              case generate(user_prompt, config, Guardrails.retry_system_suffix()) do
                {:ok, %{text: text2} = usage2} ->
                  case Guardrails.validate_output(text2) do
                    {:ok, prompt} -> {:ok, usage2, prompt}
                    {:error, :invalid_output} -> {:error, :output_rejected, usage2}
                  end

                {:error, reason} ->
                  {:error, {:generator, reason}, usage}
              end
          end

        {:error, reason} ->
          {:error, {:generator, reason}, %{tokens_in: 0, tokens_out: 0}}
      end

    settle(key, config, attempt, est, description, context)
  end

  defp generate(user_prompt, config, retry_suffix) do
    Generator.complete(@locked_system <> retry_suffix, user_prompt,
      provider: config.provider,
      model: config.model
    )
  end

  defp settle(key, config, attempt, est, description \\ nil, context \\ nil) do
    case attempt do
      {:ok, usage, prompt} ->
        cost = est_cost(config, usage.tokens_in, usage.tokens_out)

        Limiter.charge(key, est, usage.tokens_in + usage.tokens_out)

        PromptBuilder.record(key,
          tokens_in: usage.tokens_in,
          tokens_out: usage.tokens_out,
          cost: cost
        )

        # Accepted builds are logged (consent notice in the builder UI): the
        # fine-tuning corpus + showcase source. Rejections stay count-only.
        PromptBuilder.log_prompt(key, description, context, prompt,
          tokens_in: usage.tokens_in,
          tokens_out: usage.tokens_out,
          cost: cost
        )

        {:ok, %{prompt: prompt, tokens_in: usage.tokens_in, tokens_out: usage.tokens_out, est_cost_usd: cost}}

      {:error, {:generator, reason}, usage} ->
        PromptBuilder.record(key, tokens_in: usage.tokens_in, tokens_out: usage.tokens_out,
          cost: est_cost(config, usage.tokens_in, usage.tokens_out))
        {:error, {:generator, reason}}

      {:error, :output_rejected, usage} ->
        PromptBuilder.record(key, rejected: true, tokens_in: usage.tokens_in,
          tokens_out: usage.tokens_out, cost: est_cost(config, usage.tokens_in, usage.tokens_out))
        {:error, :output_rejected}
    end
  end

  defp est_cost(config, tokens_in, tokens_out) do
    Decimal.add(
      Decimal.mult(config.input_price_per_1k_usd, Decimal.new(div(tokens_in, 1000))),
      Decimal.mult(config.output_price_per_1k_usd, Decimal.new(div(tokens_out, 1000)))
    )
  end

  defp build_user_prompt(description, context) do
    context_block =
      if context in [nil, ""] do
        ""
      else
        "\n\nCONTEXT (incorporate, do not answer):\n\"\"\"\n#{String.slice(context, 0, 2000)}\n\"\"\""
      end

    """
    BUILD REQUEST:
    \"\"\"
    #{String.slice(String.trim(description), 0, 4000)}
    \"\"\"#{context_block}
    """
  end
end
