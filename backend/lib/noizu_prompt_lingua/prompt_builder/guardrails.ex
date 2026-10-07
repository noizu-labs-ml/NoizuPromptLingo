defmodule NoizuPromptLingua.PromptBuilder.Guardrails do
  @moduledoc """
  Purpose-lock for the Prompt Builder: the model may ONLY construct NPL
  prompts, never answer arbitrary questions or hold a conversation.

  Three layers:

  1. `classify_input/1` — cheap heuristics flag conversational/question-shaped
     input; anything flagged (or nothing) is confirmed by
  2. a model-judge pass over the SAME generator with a strict JSON verdict —
     `is_prompt_request?/1` composes both and fails closed on judge errors
     (error → treat as rejected; do not spend output tokens on a maybe);
  3. `validate_output/1` — rejects conversational answers / refusals that lack
     NPL structure, so the service can retry once before surfacing a 422.

  Rejections are counted upstream (`PromptBuilder.record/2`); no request or
  output content is persisted.
  """

  alias NoizuPromptLingua.PromptBuilder.Generator

  # Question-shaped / chat-shaped openers that suggest the user is trying to
  # chat, not build a prompt. Deliberately conservative: the model judge makes
  # the final call; these only route input to it with a prior against chat.
  @chat_patterns [
    ~r/^\s*(what|who|when|where|why|how|is|are|can|could|do|does|did|tell me|explain|describe|write me an? (essay|story|poem)|give me (advice|your opinion))/i,
    ~r/\?\s*$/
  ]

  # Signals that output is an NPL prompt rather than a conversational reply.
  @npl_signals [
    "⌜", "⌞", "npl@", ":persona", ":syntax", ":context", ":directive",
    "@directive", "npl declaration", "intuition pump", "reasoning pump"
  ]

  # Conversational framings / refusals that mean the model answered instead of
  # building.
  @refusal_patterns [
    ~r/^\s*(i('| a)m sorry|i can'?t|i cannot|i won'?t|unfortunately)/i,
    ~r/\b(as an ai (language model)?|i don'?t have the ability|i'm not able to)\b/i
  ]

  @chat_openers ~r/^\s*(sure|certainly|of course|absolutely|great question|happy to help|here'?s (a|an|the)\b)/i

  @judge_system """
  You are a strict input classifier for a prompt-construction tool. The tool's
  ONLY purpose is to author Noizu Prompt Lingua (NPL) prompts — structured
  prompt-engineering documents. It must NEVER answer questions, chat, write
  essays, or fulfill the request itself.

  Decide whether the user's input is a request to BUILD/CONSTRUCT/IMPROVE a
  prompt (for an agent, persona, assistant, workflow, or model).

  Reply with ONLY minified JSON, no prose, no code fences:
  {"prompt_request": true|false, "reason": "<= 12 words"}
  """

  # ── Input side ──────────────────────────────────────────────────────────

  @doc """
  Fast path: :ok when input looks like prompt construction, :reject when it is
  obviously conversational, :needs_judge otherwise.
  """
  @spec classify_input(String.t()) :: :ok | :reject | :needs_judge
  def classify_input(input) do
    trimmed = String.trim(input || "")

    cond do
      trimmed == "" -> :reject
      String.length(trimmed) < 8 -> :reject
      Enum.any?(@chat_patterns, &Regex.match?(&1, trimmed)) -> :needs_judge
      true -> :needs_judge
    end
  end

  @doc """
  Full input gate: heuristic pre-class + model judge (strict JSON schema).
  Fails closed — any judge transport/parse error rejects.
  """
  @spec is_prompt_request?(String.t()) :: {:ok, :prompt_request} | {:error, :not_prompt_request | term()}
  def is_prompt_request?(input) do
    if classify_input(input) == :reject do
      {:error, :not_prompt_request}
    else
      judge(input)
    end
  end

  defp judge(input) do
    case Generator.complete(@judge_system, judge_user_prompt(input), judge?: true) do
      {:ok, %{text: text}} ->
        case parse_verdict(text) do
          {:ok, _} = ok -> ok
          # A clean false verdict is a decision, not a judge failure.
          {:error, :not_prompt_request} = rejected -> rejected
          {:error, reason} -> {:error, {:judge_failed, reason}}
        end

      {:error, reason} ->
        {:error, {:judge_failed, reason}}
    end
  end

  defp judge_user_prompt(input) do
    """
    USER INPUT:
    \"\"\"
    #{String.slice(String.trim(input), 0, 2000)}
    \"\"\"

    Is this a prompt-construction request? JSON verdict only.
    """
  end

  defp parse_verdict(text) do
    case extract_json(text) do
      %{"prompt_request" => true} -> {:ok, :prompt_request}
      %{"prompt_request" => false} -> {:error, :not_prompt_request}
      _ -> {:error, :unparseable_verdict}
    end
  end

  defp extract_json(text) do
    case Regex.run(~r/\{.*\}/s, text) do
      [json] ->
        case Jason.decode(json) do
          {:ok, decoded} -> decoded
          _ -> nil
        end

      _ ->
        nil
    end
  end

  # ── Output side ─────────────────────────────────────────────────────────

  @doc """
  Output gate: strip code fences, then reject refusal-style or conversational
  replies that carry no NPL structure. Returns {:ok, prompt} | {:error, :invalid_output}.
  """
  @spec validate_output(String.t()) :: {:ok, String.t()} | {:error, :invalid_output}
  def validate_output(text) do
    cleaned =
      text
      |> String.trim()
      |> strip_fences()
      |> String.trim()

    cond do
      cleaned == "" ->
        {:error, :invalid_output}

      Enum.any?(@refusal_patterns, &Regex.match?(&1, cleaned)) ->
        {:error, :invalid_output}

      has_npl_structure?(cleaned) ->
        {:ok, cleaned}

      Regex.match?(@chat_openers, cleaned) ->
        # "Sure, here's a prompt for you:" — strip the framing, keep the body.
        case split_opener(cleaned) do
          {:ok, body} -> validate_output(body)
          :error -> {:error, :invalid_output}
        end

      true ->
        {:error, :invalid_output}
    end
  end

  defp has_npl_structure?(text) do
    lower = String.downcase(text)
    Enum.any?(@npl_signals, &String.contains?(lower, String.downcase(&1)))
  end

  defp strip_fences(text) do
    case Regex.run(~r/```[a-zA-Z0-9_-]*\n(.*)```/s, text) do
      [_, body] -> body
      _ -> text
    end
  end

  defp split_opener(text) do
    case Regex.run(~r/^[^:]{0,80}:\s*/i, text) do
      [prefix] ->
        body = String.slice(text, String.length(prefix)..-1//1)
        if String.trim(body) == "", do: :error, else: {:ok, body}

      _ ->
        :error
    end
  end

  @doc "Corrective nudge appended to the system prompt on the single retry."
  @spec retry_system_suffix() :: String.t()
  def retry_system_suffix do
    "\n\nIMPORTANT: Your previous reply was rejected because it did not look like a pure NPL prompt. " <>
      "Reply with ONLY the NPL prompt text — no preamble, no explanation, no first-person framing, no code fences."
  end
end
