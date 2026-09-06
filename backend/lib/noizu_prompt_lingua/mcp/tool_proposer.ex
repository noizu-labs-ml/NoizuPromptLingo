defmodule NoizuPromptLingua.MCP.ToolProposer do
  @moduledoc """
  PRD-020 FR-3: LLM-backed tool-set proposer for the endpoint creation wizard.

  Given a plain-language endpoint description (plus optional clarifying-question
  answers), asks the LLM for either up to 4 clarifying questions (max 2 rounds)
  or a proposed tool set, then **grounds** the proposal: names are canonicalized
  (`MCP.ToolNames.canonical/1`) and intersected with the universe catalog
  (`Tools.Catalog.build/2`) AND with `MCPCustomScopes.catalog/0` group
  membership, so every surviving tool is real and carries a server-resolved
  `group` id. The LLM never supplies the group; a bogus `group` key in its
  payload is discarded (D4/NFR-7).

  LLM seam: `:llm {mod, fun}` opt -> app env `:noizu_prompt_lingua,
  :tool_proposer_llm` -> the genai default (the `MockMCP.Agent` runner
  precedent, custom-endpoint HTTP variant included). Runner contract:
  `apply(mod, fun, [messages, opts]) :: {:ok, String.t()} | {:error, term()}`
  where the ok text is a JSON object.

  Every unusable outcome (runner error/timeout, non-JSON or schema-invalid
  payload, a third questions round, empty grounded set) collapses to
  `{:error, :llm_unavailable}` — never a partial success (FR-3.4).
  """

  alias NoizuPromptLingua.Domains.Memory.Embeddings
  alias NoizuPromptLingua.Domains.MCPOverview.Indexer
  alias NoizuPromptLingua.Domains.MCPOverview.Store
  alias NoizuPromptLingua.Domains.MockMCP.Agent
  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLingua.MCP.ToolNames
  alias NoizuPromptLingua.Tools.Catalog

  @type question :: %{
          required(:prompt) => String.t(),
          required(:kind) => :single | :multi | :text,
          optional(:options) => [String.t()]
        }

  @type answer :: %{required(:question_id) => String.t(), required(:answer) => String.t()}

  @type proposed_tool :: %{required(:name) => String.t(), required(:rationale) => String.t()}

  @typedoc "Server-minted question id (`r1-1`..`r2-4`); regex `r[12]-[a-z0-9-]{1,32}`."
  @type question_id :: String.t()

  @default_max_questions 4
  @default_timeout 8_000
  @max_proposed_tools 25
  @ranker_limit 24
  @ranker_scope "endpoint-wizard"
  @id_regex ~r/^r[12]-[a-z0-9-]{1,32}$/

  @system_prompt """
  You configure MCP tool endpoints for a user. You MUST respond with a single \
  JSON object and nothing else — no markdown fences, no commentary.

  Two response shapes are allowed.

  1. Clarifying questions (only when the goal is still ambiguous):
  {"questions": [{"prompt": "...", "kind": "single", "options": ["...", "..."]},
                 {"prompt": "...", "kind": "multi", "options": ["...", "..."]},
                 {"prompt": "...", "kind": "text"}]}
  "options" is REQUIRED for kind "single" and "multi" and MUST BE OMITTED for \
  kind "text". Ask at most the number of questions the user prompt allows.

  2. Tool proposal (when you have enough information):
  {"summary": "1-2 sentence summary of the proposed toolkit.",
   "tools": [{"name": "<shortlist tool name>", "rationale": "1-2 sentences."}]}
  Use ONLY names that appear verbatim in the shortlist — never invent or \
  variant-spell tool names. Do NOT include a "group" field; the server \
  resolves groups itself.
  """

  # ── Public API ──────────────────────────────────────────────────────────────

  @doc """
  Propose clarifying questions or a grounded tool set for an endpoint.

  Round accounting (FR-3.1, stateless):

    * `answers == []` (after silently dropping malformed ids) -> round-1
      questions (`r1-*` ids minted server-side);
    * all remaining ids start `r1-` -> one more questions round (`r2-*`) or a
      proposal, whichever the LLM decides;
    * any id starts `r2-` -> the LLM is told to propose; a questions response
      is retried once with a strict proposal instruction, then
      `{:error, :llm_unavailable}`.
  """
  @spec propose(String.t() | nil, String.t(), [answer()] | term(), keyword()) ::
          {:ok, {:questions, [question()]}}
          | {:ok, {:proposal, %{tools: [map()], summary: String.t()}}}
          | {:error, :llm_unavailable}
  def propose(name, description, answers, opts \\ [])

  def propose(name, description, answers, opts) when is_binary(description) do
    valid_answers = normalize_answers(answers)
    shortlist = shortlist_for(description, valid_answers, opts)

    case mode_for(valid_answers) do
      {:ask, prefix} ->
        messages = build_messages(:ask, name, description, valid_answers, shortlist, prefix)
        ask_once(messages, prefix, opts)

      :force_proposal ->
        force_proposal(name, description, valid_answers, shortlist, opts)
    end
  end

  def propose(_name, _description, _answers, _opts), do: {:error, :llm_unavailable}

  # ── Ask path ────────────────────────────────────────────────────────────────

  defp ask_once(messages, prefix, opts) do
    case call_runner(messages, opts) do
      {:ok, payload} ->
        case classify(payload) do
          {:questions, raw} ->
            case build_questions(raw, prefix, opts) do
              [] -> {:error, :llm_unavailable}
              questions -> {:ok, {:questions, questions}}
            end

          {:proposal, %{summary: summary, tools: raw}} ->
            finish_proposal(summary, raw)

          :invalid ->
            {:error, :llm_unavailable}
        end

      _other ->
        {:error, :llm_unavailable}
    end
  end

  # Round cap (FR-3.1): after r2-* answers the LLM must propose; one strict
  # retry, never a third questions round.
  defp force_proposal(name, description, answers, shortlist, opts) do
    messages = build_messages(:force_proposal, name, description, answers, shortlist, "r2")

    with {:ok, payload} <- call_runner(messages, opts),
         {:proposal, %{summary: summary, tools: raw}} <- classify(payload) do
      finish_proposal(summary, raw)
    else
      {:questions, _} ->
        strict =
          build_messages(:strict_proposal, name, description, answers, shortlist, "r2")

        with {:ok, payload2} <- call_runner(strict, opts),
             {:proposal, %{summary: summary2, tools: raw2}} <- classify(payload2) do
          finish_proposal(summary2, raw2)
        else
          _ -> {:error, :llm_unavailable}
        end

    _ ->
      {:error, :llm_unavailable}
    end
  end

  defp finish_proposal(summary, raw_tools) do
    case ground(raw_tools) do
      [] -> {:error, :llm_unavailable}
      tools -> {:ok, {:proposal, %{tools: tools, summary: summary}}}
    end
  end

  # ── Round accounting / answers ─────────────────────────────────────────────

  defp mode_for([]), do: {:ask, "r1"}

  defp mode_for(answers) do
    if Enum.any?(answers, &String.starts_with?(&1.question_id, "r2-")) do
      :force_proposal
    else
      {:ask, "r2"}
    end
  end

  # Malformed question ids are dropped silently (FR-2); entries failing the
  # `r[12]-[a-z0-9-]{1,32}` shape never reach the LLM prompt.
  defp normalize_answers(answers) when is_list(answers) do
    answers
    |> Enum.filter(&is_map/1)
    |> Enum.map(&answer_entry/1)
    |> Enum.reject(&is_nil/1)
  end

  defp normalize_answers(_), do: []

  defp answer_entry(a) do
    question_id = entry_key(a, "question_id")
    answer = entry_key(a, "answer")

    if is_binary(question_id) and Regex.match?(@id_regex, question_id) and
         is_binary(answer) and String.trim(answer) != "" do
      %{question_id: question_id, answer: String.trim(answer)}
    end
  end

  defp entry_key(map, key) when is_map(map),
    do: Map.get(map, key) || Map.get(map, String.to_atom(key))

  # ── Questions normalization ────────────────────────────────────────────────

  # Server mints ids `r<round>-<n>` (1..max_questions); `options` is present
  # iff kind != :text; schema-invalid entries are dropped.
  defp build_questions(raw, prefix, opts) do
    max = Keyword.get(opts, :max_questions, @default_max_questions)

    raw
    |> Enum.map(&normalize_question/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.take(max)
    |> Enum.with_index(1)
    |> Enum.map(fn {q, i} -> Map.put(q, :id, "#{prefix}-#{i}") end)
  end

  defp normalize_question(%{"prompt" => prompt, "kind" => kind} = q)
       when is_binary(prompt) and prompt != "" and is_binary(kind) do
    case kind do
      "text" -> %{prompt: prompt, kind: :text}
      "single" -> question_with_options(prompt, :single, Map.get(q, "options"))
      "multi" -> question_with_options(prompt, :multi, Map.get(q, "options"))
      _ -> nil
    end
  end

  defp normalize_question(_), do: nil

  defp question_with_options(prompt, kind, options) when is_list(options) and options != [] do
    if Enum.all?(options, &is_binary/1) do
      %{prompt: prompt, kind: kind, options: options}
    end
  end

  defp question_with_options(_, _, _), do: nil

  # ── Grounding (D4 — hard rule) ─────────────────────────────────────────────

  # Canonicalize names, intersect with the universe catalog AND customizable
  # group membership, resolve the group server-side (LLM "group" discarded),
  # dedupe, cap at 25. Invented names, Discovery-category tools, and tools
  # outside every customizable group are dropped.
  defp ground(raw_tools) when is_list(raw_tools) do
    membership = group_membership()
    universe = universe_names()

    raw_tools
    |> Enum.map(&normalize_proposal_entry/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq_by(& &1.name)
    |> Enum.filter(&MapSet.member?(universe, &1.name) and Map.has_key?(membership, &1.name))
    |> Enum.map(&Map.put(&1, :group, Map.fetch!(membership, &1.name)))
    |> Enum.take(@max_proposed_tools)
  end

  defp ground(_), do: []

  defp normalize_proposal_entry(%{"name" => name, "rationale" => rationale})
       when is_binary(name) and is_binary(rationale) and rationale != "" do
    %{name: ToolNames.canonical(name), rationale: String.trim(rationale)}
  end

  defp normalize_proposal_entry(_), do: nil

  defp group_membership do
    MCPCustomScopes.catalog()
    |> Enum.flat_map(fn group -> Enum.map(group.tools, &{&1.name, group.id}) end)
    |> Map.new()
  end

  defp universe_names do
    Catalog.build()
    |> Enum.map(& &1.name)
    |> MapSet.new()
  end

  # ── Candidate pre-ranking (FR-3.2) ─────────────────────────────────────────

  defp shortlist_for(description, answers, opts) do
    ranker = Keyword.get(opts, :ranker) || (&default_ranker/2)
    text = Enum.join([description | Enum.map(answers, & &1.answer)], " ")

    case safe_rank(ranker, text, @ranker_limit) do
      names when is_list(names) -> Enum.filter(names, &is_binary/1)
      _ -> full_customizable_list()
    end
  end

  defp safe_rank(ranker, text, limit) do
    ranker.(text, limit)
  rescue
    _ -> nil
  end

  # Default: embed description + flattened answers, refresh the per-tool
  # vectors under the "endpoint-wizard" scope, and rank via the ToolSearch
  # :intent vector plumbing. Embeddings unconfigured / any failure -> the full
  # customizable-catalog name list (prompt never carries the raw catalog dump
  # with descriptions, only names + group ids).
  def default_ranker(text, limit) when is_binary(text) and is_integer(limit) do
    specs = ranker_specs()

    fallback = Enum.map(specs, & &1.name)

    if specs == [] or not Embeddings.configured?() do
      fallback
    else
      with {:ok, [vec]} <- Embeddings.embed([text]),
           true <- is_list(vec) and vec != [],
           refreshed = Indexer.refresh(@ranker_scope, specs),
           true <- is_map(refreshed) do
        case Store.nearest_tool_vectors(@ranker_scope, vec, limit: limit) do
          rows when is_list(rows) and rows != [] -> Enum.map(rows, & &1.tool_name)
          _ -> fallback
        end
      else
        _ -> fallback
      end
    end
  end

  defp ranker_specs do
    MCPCustomScopes.catalog()
    |> Enum.flat_map(fn group ->
      Enum.map(group.tools, fn tool ->
        %{name: tool.name, category: group.id, description: tool.description}
      end)
    end)
  end

  defp full_customizable_list do
    MCPCustomScopes.catalog()
    |> Enum.flat_map(fn group -> Enum.map(group.tools, fn tool -> tool.name end) end)
  end

  # ── Prompt assembly (NFR-6: user text + shortlist names only) ──────────────

  defp build_messages(mode, name, description, answers, shortlist, prefix) do
    user =
      [
        name_section(name),
        "Endpoint description: #{description}",
        answers_section(answers),
        "Candidate tools (shortlist — propose only from these, names verbatim):\n" <>
          render_shortlist(shortlist),
        directive(mode, prefix)
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join("\n\n")

    [GenAI.Message.system(@system_prompt), GenAI.Message.user(user)]
  end

  defp name_section(nil), do: nil
  defp name_section(""), do: nil
  defp name_section(name) when is_binary(name), do: "Endpoint name: #{name}"

  defp answers_section([]), do: nil

  defp answers_section(answers) do
    lines = Enum.map(answers, fn a -> "- #{a.question_id}: #{a.answer}" end)
    "User answers so far:\n" <> Enum.join(lines, "\n")
  end

  defp render_shortlist(shortlist) do
    membership = group_membership()
    {grouped, stray} = Enum.split_with(shortlist, &Map.has_key?(membership, &1))

    group_lines =
      grouped
      |> Enum.group_by(&Map.fetch!(membership, &1))
      |> Enum.sort()
      |> Enum.map(fn {group_id, names} -> "- #{group_id}: #{Enum.join(names, ", ")}" end)

    stray_lines =
      case stray do
        [] -> []
        names -> ["- other: #{Enum.join(names, ", ")}"]
      end

    case group_lines ++ stray_lines do
      [] -> "(no candidates available)"
      lines -> Enum.join(lines, "\n")
    end
  end

  defp directive(:ask, "r1"),
    do:
      "If the description and answers are enough to choose a sensible tool set, " <>
        "return the proposal JSON. Otherwise return the clarifying-questions JSON."

  defp directive(:ask, _),
    do:
      "This is the final clarifying round (round 2 of 2). You may return ONE more " <>
        "questions entry set, or — preferably — the proposal JSON if you have enough information."

  defp directive(:force_proposal, _),
    do: "The user has answered the questions. Return the proposal JSON now — do not ask more questions."

  defp directive(:strict_proposal, _),
    do:
      "STRICT: you returned questions when a proposal was required. Return ONLY the " <>
        "proposal JSON object ({\"summary\": ..., \"tools\": [...]}) — questions are no longer allowed."

  # ── Runner plumbing ─────────────────────────────────────────────────────────

  # `:llm` opt -> `:tool_proposer_llm` app-env seam -> genai default
  # (MockMCP.Agent runner: genai pipeline + custom-endpoint HTTP variant).
  defp resolve_runner(opts) do
    case Keyword.get(opts, :llm) || Application.get_env(:noizu_prompt_lingua, :tool_proposer_llm) do
      {mod, fun} when is_atom(mod) and is_atom(fun) -> {mod, fun}
      _ -> {Agent, :run}
    end
  end

  # The runner runs in a task so the `:timeout` (default 8s, NFR-2) maps a
  # hung LLM onto the llm_unavailable path instead of blocking the request.
  defp call_runner(messages, opts) do
    {mod, fun} = resolve_runner(opts)
    runner_opts = Keyword.take(opts, [:provider, :model, :endpoint, :api_key])
    timeout = Keyword.get(opts, :timeout, @default_timeout)

    task = Task.async(fn -> apply(mod, fun, [messages, runner_opts]) end)

    try do
      Task.await(task, timeout)
    catch
      :exit, _ -> {:error, :timeout}
    end
  end

  # ── Payload parsing ─────────────────────────────────────────────────────────

  # Accepted LLM payloads (stub contract / FR-2):
  #   {"questions": [{"prompt", "kind", "options"?}]}
  #   {"summary", "tools": [{"name", "rationale"}]}
  # Anything else — including a payload whose only extra is a "group" key on a
  # tool — is normalized here; unknown keys (bogus group included) are simply
  # never read, so they cannot leak into the response.
  defp classify({:ok, text}) when is_binary(text) do
    case text |> strip_fences() |> Jason.decode() do
      {:ok, %{"questions" => questions}} when is_list(questions) ->
        {:questions, questions}

      {:ok, %{"summary" => summary, "tools" => tools}}
      when is_binary(summary) and is_list(tools) ->
        {:proposal, %{summary: summary, tools: tools}}

      _ ->
        :invalid
    end
  end

  defp classify(_), do: :invalid

  defp strip_fences(text) do
    text = String.trim(text)

    case Regex.run(~r/^```(?:json)?\s*\n(.*)\n```$/s, text) do
      [_, inner] -> String.trim(inner)
      _ -> text
    end
  end
end
