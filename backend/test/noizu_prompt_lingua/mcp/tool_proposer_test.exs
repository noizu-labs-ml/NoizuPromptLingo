defmodule NoizuPromptLingua.MCP.ToolProposerTest do
  @moduledoc """
  PRD-020 FR-3: `NoizuPromptLingua.MCP.ToolProposer.propose/4`.

  The LLM is injected through the `:llm {mod, fun}` opt (and the
  `:tool_proposer_llm` app-env seam) via
  `NoizuPromptLingua.TestSupport.ToolProposerLLMStub`; candidate pre-ranking is
  injected through `:ranker`. No network, no OpenAI keys.

  Scripted runner JSON contract (see the stub's moduledoc):

    questions -> {"questions": [{"prompt", "kind", "options"?}]}
    proposal  -> {"summary", "tools": [{"name", "rationale"}]}

  `group` is never LLM-supplied: FR-3 resolves it server-side from
  `MCPCustomScopes.catalog/0`, so the stub payloads omit it or supply a bogus
  value that must be discarded.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.MCP.ToolProposer
  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLingua.TestSupport.ToolProposerLLMStub, as: Stub

  @description "Answers support questions and files tickets"

  # ── helpers ────────────────────────────────────────────────────────────────

  defp ranker(names), do: fn _text, _limit -> names end

  defp tickets_tool do
    group = Enum.find(MCPCustomScopes.catalog(), &(&1.id == "tickets"))

    assert group, "tickets group missing from MCPCustomScopes.catalog/0 in the test env"
    assert Enum.any?(group.tools), "tickets group has no tools in the test env"

    hd(group.tools).name
  end

  defp catalog_names,
    do: MCPCustomScopes.catalog() |> Enum.flat_map(& &1.tools) |> Enum.map(& &1.name)

  defp group_of(tool_name) do
    Enum.find_value(MCPCustomScopes.catalog(), fn group ->
      if Enum.any?(group.tools, &(&1.name == tool_name)), do: group.id
    end)
  end

  defp questions_entry do
    {:ok,
     Jason.encode!(%{
       "questions" => [
         %{
           "prompt" => "Who will call this endpoint?",
           "kind" => "single",
           "options" => ["Human agents", "An automated agent"]
         },
         %{"prompt" => "Any compliance constraints?", "kind" => "text"}
       ]
     })}
  end

  defp proposal_entry(tool_names, summary \\ "A focused support toolkit.") do
    {:ok,
     Jason.encode!(%{
       "summary" => summary,
       "tools" =>
         Enum.map(tool_names, fn
           {name, extra} -> Map.merge(%{"name" => name, "rationale" => "Because."}, extra)
           name -> %{"name" => name, "rationale" => "Because."}
         end)
     })}
  end

  defp propose_with(answers, opts) do
    opts =
      opts
      |> Keyword.put_new(:llm, {Stub, :run})
      |> Keyword.put_new(:ranker, ranker([tickets_tool()]))

    ToolProposer.propose("Support bot", @description, answers, opts)
  end

  # ── round accounting (FR-3.1) ──────────────────────────────────────────────

  describe "questions round" do
    test "empty answers -> questions round, server-minted r1-* ids, options per kind" do
      start_supervised!({Stub, script: [questions_entry()]})

      assert {:ok, {:questions, questions}} = propose_with([], [])

      assert length(questions) in 1..4

      for {q, i} <- Enum.with_index(questions, 1) do
        assert q.id == "r1-#{i}"
        assert is_binary(q.prompt) and q.prompt != ""
        assert q.kind in [:single, :multi, :text]
        # options present iff kind != :text (FR-2/FR-3)
        assert Map.has_key?(q, :options) == (q.kind != :text)
      end
    end

    test "r1-* answers -> one more questions round with r2-* ids" do
      start_supervised!({Stub, script: [questions_entry()]})

      answers = [%{question_id: "r1-1", answer: "Read-only is fine"}]
      assert {:ok, {:questions, questions}} = propose_with(answers, [])

      assert Enum.all?(questions, fn %{id: id} ->
               is_binary(id) and String.starts_with?(id, "r2-")
             end)
    end

    test "name may be nil (optional)" do
      start_supervised!({Stub, script: [questions_entry()]})

      assert {:ok, {:questions, _}} =
               ToolProposer.propose(nil, @description, [],
                 llm: {Stub, :run},
                 ranker: ranker([tickets_tool()])
               )
    end

    test "answers whose ids are ALL malformed fall back to the round-1 questions path" do
      start_supervised!({Stub, script: [questions_entry()]})

      answers = [%{question_id: "q9", answer: "noise"}]
      assert {:ok, {:questions, questions}} = propose_with(answers, [])
      assert Enum.all?(questions, fn %{id: id} -> String.starts_with?(id, "r1-") end)
    end
  end

  describe "proposal round" do
    test "r1-* answers -> proposal with tools + summary" do
      real = tickets_tool()
      start_supervised!({Stub, script: [proposal_entry([real])]})

      answers = [%{question_id: "r1-1", answer: "Read-only is fine"}]

      assert {:ok, {:proposal, %{tools: tools, summary: summary}}} = propose_with(answers, [])
      assert is_binary(summary) and summary != ""
      assert [%{name: ^real}] = tools
    end

    test "grounding (D4): invented, Discovery and out-of-group names dropped; group server-resolved" do
      real = tickets_tool()
      dotted = String.replace(real, "_", ".")

      # ToolSearch is a root-server Discovery-category tool: in no customizable
      # group, so it must never survive grounding.
      payload_tools = [
        real,
        {dotted, %{}},
        {"Totally_Invented_Widget", %{}},
        {"ToolSearch", %{}},
        {real, %{"group" => "bogus-group"}}
      ]

      start_supervised!({Stub, script: [proposal_entry(payload_tools)]})

      answers = [%{question_id: "r1-1", answer: "Support agents"}]
      assert {:ok, {:proposal, %{tools: tools}}} = propose_with(answers, [])

      names = Enum.map(tools, & &1.name)
      assert real in names
      refute "Totally_Invented_Widget" in names
      refute "ToolSearch" in names
      # dotted alias is canonicalized, never emitted raw
      refute dotted in names

      for t <- tools do
        assert MapSet.member?(MapSet.new(catalog_names()), t.name)
        assert is_binary(t.group) and t.group != ""
        # group is the catalog group containing the tool — never the LLM's value
        assert group_of(t.name) == t.group
      end

      refute Enum.any?(tools, &(&1.group == "bogus-group"))
    end

    test "round cap: r2-* answers force a proposal (one strict retry, never a 3rd round)" do
      real = tickets_tool()
      start_supervised!({Stub, script: [questions_entry(), proposal_entry([real])]})

      answers = [%{question_id: "r2-1", answer: "Just propose"}]

      assert {:ok, {:proposal, %{tools: tools}}} = propose_with(answers, [])
      assert tools != []
      # exactly one retry — the first (questions) response must be discarded
      assert Stub.calls() == 2
    end

    test "round cap: a second questions response after r2-* answers -> llm_unavailable" do
      start_supervised!({Stub, script: [questions_entry(), questions_entry()]})

      answers = [%{question_id: "r2-1", answer: "Just propose"}]
      assert {:error, :llm_unavailable} = propose_with(answers, [])
      assert Stub.calls() == 2
    end

    test "malformed answer ids are dropped silently; valid r1-* answers still processed" do
      real = tickets_tool()
      start_supervised!({Stub, script: [proposal_entry([real])]})

      answers = [
        %{question_id: "not-a-valid-id", answer: "noise"},
        %{question_id: "r1-1", answer: "Read-only is fine"}
      ]

      assert {:ok, {:proposal, %{tools: tools}}} = propose_with(answers, [])
      assert tools != []
    end
  end

  # ── unusable outcomes (FR-3.4) ─────────────────────────────────────────────

  test "unusable outcomes -> {:error, :llm_unavailable} (never partial success)" do
    real = tickets_tool()

    cases = [
      {:error, :timeout},
      {:error, :boom},
      {:ok, "I could not produce JSON, sorry"},
      {:ok, Jason.encode!(%{"unexpected" => true})},
      proposal_entry(["Invented_Only"])
    ]

    for entry <- cases do
      start_supervised!({Stub, script: []})
      Stub.set_script([entry])

      assert {:error, :llm_unavailable} = propose_with([], []),
             "expected llm_unavailable for #{inspect(entry)}"
    end
  end

  # ── injection seams ────────────────────────────────────────────────────────

  test ":tool_proposer_llm app-env seam is honored when no :llm opt is given" do
    Application.put_env(:noizu_prompt_lingua, :tool_proposer_llm, {Stub, :run})

    on_exit(fn ->
      Application.delete_env(:noizu_prompt_lingua, :tool_proposer_llm)
    end)

    start_supervised!({Stub, script: [questions_entry()]})

    assert {:ok, {:questions, _}} =
             ToolProposer.propose(nil, @description, [], ranker: ranker([tickets_tool()]))
  end

  test "prompt hygiene (NFR-6): shortlist + user text enter the prompt, not the full catalog" do
    real = tickets_tool()
    excluded = Enum.find(catalog_names(), &(&1 != real))
    assert excluded, "expected a second catalog tool to assert exclusion"

    start_supervised!({Stub, script: [proposal_entry([real])]})
    assert {:ok, {:proposal, _}} = propose_with([], [])

    rendered = inspect(Stub.last_messages())
    assert rendered =~ @description
    assert rendered =~ "Support bot"
    assert rendered =~ real
    refute rendered =~ excluded
  end
end
