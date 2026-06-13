defmodule NoizuPromptLingua.Domains.AgentsTest do
  use NoizuPromptLingua.DataCase, async: true

  alias NoizuPromptLingua.Domains.Agents

  describe "pipes" do
    test "pipe_out sends and pipe_in consumes" do
      {:ok, 2} = Agents.pipe_out(["bot-a", "bot-b"], "task: analyze", "controller")

      msgs_a = Agents.pipe_in("bot-a")
      assert length(msgs_a) == 1
      assert hd(msgs_a).content == "task: analyze"
      assert hd(msgs_a).sender == "controller"

      msgs_a_again = Agents.pipe_in("bot-a")
      assert msgs_a_again == []
    end

    test "pipe_in respects limit" do
      for i <- 1..5, do: Agents.pipe_out(["bot-x"], "msg #{i}", "sender")
      msgs = Agents.pipe_in("bot-x", limit: 2)
      assert length(msgs) == 2
    end

    test "pipe_out with priority" do
      {:ok, 1} = Agents.pipe_out(["bot-p"], "urgent", "ctrl", priority: "high")
      [msg] = Agents.pipe_in("bot-p")
      assert msg.priority == "high"
    end

    test "pipe_in returns empty for no messages" do
      assert Agents.pipe_in("nobody") == []
    end
  end

  describe "instructions" do
    test "create and get" do
      {:ok, instr} = Agents.create_instruction(%{title: "Style Guide", content: "Use short sentences.", tags: ["writing"]})
      assert instr.title == "Style Guide"
      assert instr.version == 1

      fetched = Agents.get_instruction(instr.id)
      assert fetched.content == "Use short sentences."
    end

    test "list with search" do
      {:ok, _} = Agents.create_instruction(%{title: "UniqueInstrTitle999", content: "X"})
      results = Agents.list_instructions(search: "UniqueInstrTitle")
      assert length(results) >= 1
    end

    test "list with tag filter" do
      {:ok, _} = Agents.create_instruction(%{title: "Tagged", content: "X", tags: ["special"]})
      results = Agents.list_instructions(tags: ["special"])
      assert Enum.any?(results, &("special" in &1.tags))
    end

    test "list with session filter" do
      sid = Ecto.UUID.generate()
      {:ok, _} = Agents.create_instruction(%{title: "Sessioned", content: "X", session_id: sid})
      results = Agents.list_instructions(session_id: sid)
      assert length(results) >= 1
    end

    test "get returns nil for missing" do
      assert is_nil(Agents.get_instruction(Ecto.UUID.generate()))
    end
  end

  describe "orchestration" do
    test "trigger and get status" do
      {:ok, orch} = Agents.trigger_pipeline(%{pipeline: "summarize", context: %{"input" => "text"}})
      assert orch.status == "pending"
      assert orch.pipeline == "summarize"

      fetched = Agents.get_orchestration(orch.id)
      assert fetched.id == orch.id
    end

    test "update orchestration status" do
      {:ok, orch} = Agents.trigger_pipeline(%{pipeline: "analyze"})
      {:ok, updated} = Agents.update_orchestration(orch.id, %{status: "running"})
      assert updated.status == "running"
    end

    test "complete orchestration with result" do
      {:ok, orch} = Agents.trigger_pipeline(%{pipeline: "extract"})
      {:ok, done} = Agents.update_orchestration(orch.id, %{status: "completed", result: %{"output" => "wisdom"}})
      assert done.status == "completed"
      assert done.result["output"] == "wisdom"
    end

    test "get returns nil for missing" do
      assert is_nil(Agents.get_orchestration(Ecto.UUID.generate()))
    end
  end
end
