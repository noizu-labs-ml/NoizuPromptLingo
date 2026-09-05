defmodule NoizuPromptLingua.Domains.MCPOverview.GeneratorTest do
  @moduledoc """
  MCPOverview.Generator — focus/ranking context assembly and the deterministic
  Stub adapter, including the ranked near/far split against seeded tool vectors.

  Not covered by design: the LLM adapter (Generator.LLM). It drives the shared
  GenAI client at app defaults with no per-adapter transport seam — stubbing it
  would mean rewiring the global GenAI provider mid-suite; its selection arms
  stay uncovered until a GenAI-level stub exists.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.MCPOverview.{Generator, Store}

  setup do
    original = Application.get_env(:noizu_prompt_lingua, :mcp_overview)

    Application.put_env(:noizu_prompt_lingua, :mcp_overview,
      generator: Generator.Stub,
      focus_count: 2
    )

    on_exit(fn ->
      if original,
        do: Application.put_env(:noizu_prompt_lingua, :mcp_overview, original),
        else: Application.delete_env(:noizu_prompt_lingua, :mcp_overview)
    end)

    %{scope: "gen-#{System.unique_integer([:positive])}"}
  end

  defp specs do
    [
      %{name: "Zeta", category: "Tickets", description: "zeta tool"},
      %{name: "Alpha", category: "Chat", description: "alpha tool"},
      %{name: "Mid", category: nil, description: nil}
    ]
  end

  # The pgvector column is fixed at 1536 dimensions.
  defp task_vec, do: List.duplicate(0.0, 1536) |> List.replace_at(0, 1.0)

  test "adapter/0 defaults to the LLM adapter when unconfigured" do
    Application.delete_env(:noizu_prompt_lingua, :mcp_overview)
    assert Generator.adapter() == Generator.LLM
  end

  test "focus_context without a task vector is unfocused: all near, sorted by name" do
    context = Generator.focus_context("s", "task", nil, specs())

    assert context.far == []
    assert Enum.map(context.near, & &1.name) == ["Alpha", "Mid", "Zeta"]
    assert Enum.all?(context.near, &is_nil(&1.distance))
    assert Enum.find(context.near, &(&1.name == "Mid")).group == "Uncategorized"
    assert Enum.find(context.near, &(&1.name == "Mid")).description == ""
  end

  test "focus_context ranks by vector proximity, filters to known specs, splits at focus_count",
       %{scope: scope} do
    {:ok, _} =
      Store.put_tool_vector(%{
        scope_slug: scope,
        tool_name: "Zeta",
        group_id: "gen",
        description_hash: "h",
        embedding: [0.0, 1.0 | List.duplicate(0.0, 1534)]
      })

    {:ok, _} =
      Store.put_tool_vector(%{
        scope_slug: scope,
        tool_name: "Alpha",
        group_id: "gen",
        description_hash: "h",
        embedding: List.duplicate(0.0, 1536) |> List.replace_at(0, 1.0)
      })

    {:ok, _} =
      Store.put_tool_vector(%{
        scope_slug: scope,
        tool_name: "Ghost",
        group_id: "gen",
        description_hash: "h",
        embedding: [0.99, 0.1 | List.duplicate(0.0, 1534)]
      })

    context = Generator.focus_context(scope, "task", task_vec(), specs())

    # Ghost ranks nearest but has no spec here — the near set is Alpha+Zeta.
    assert Enum.map(context.near, & &1.name) == ["Alpha", "Zeta"]
    assert Enum.map(context.far, & &1.name) == ["Mid"]

    alpha = Enum.find(context.near, &(&1.name == "Alpha"))
    assert alpha.distance != nil and alpha.distance < 0.01

    zeta = Enum.find(context.near, &(&1.name == "Zeta"))
    assert zeta.distance != nil and zeta.distance > 0.9
  end

  test "build/4 renders focused markdown through the Stub adapter", %{scope: scope} do
    {:ok, _} =
      Store.put_tool_vector(%{
        scope_slug: scope,
        tool_name: "Zeta",
        group_id: "gen",
        description_hash: "h",
        embedding: [0.0, 1.0 | List.duplicate(0.0, 1534)]
      })

    {:ok, _} =
      Store.put_tool_vector(%{
        scope_slug: scope,
        tool_name: "Alpha",
        group_id: "gen",
        description_hash: "h",
        embedding: List.duplicate(0.0, 1536) |> List.replace_at(0, 1.0)
      })

    assert {:ok, md} =
             Generator.build(scope, "ship tickets", task_vec(), specs(), focus: "triage")

    assert md =~ "# MCP Overview"
    assert md =~ "**Task:** ship tickets"
    assert md =~ "**Focus:** triage"
    assert md =~ "- **Alpha** (Chat): alpha tool"
    assert md =~ "## Other tools"
    assert md =~ "- `Mid`"
  end

  test "build/4 with no specs renders the none-marker without an other-tools section" do
    assert {:ok, md} = Generator.build("s", "task", nil, [])
    assert md =~ "_none_"
    refute md =~ "## Other tools"
    refute md =~ "**Focus:**"
  end

  test "an empty-string focus hint renders no focus line" do
    assert {:ok, md} =
             Generator.build("s", "task", nil, [%{name: "A", category: nil, description: "d"}],
               focus: ""
             )

    refute md =~ "**Focus:**"
    assert md =~ "- **A** (Uncategorized): d"
  end
end
