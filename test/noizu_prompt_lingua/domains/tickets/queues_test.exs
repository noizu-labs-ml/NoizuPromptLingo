defmodule NoizuPromptLingua.Domains.Tickets.QueuesTest do
  use NoizuPromptLingua.DataCase, async: true

  alias NoizuPromptLingua.Domains.Tickets.Queues
  alias NoizuPromptLingua.Domains.Tickets

  defp create_queue(attrs \\ %{}) do
    defaults = %{name: "Test Queue", slug: "test-queue-#{System.unique_integer([:positive])}"}
    Queues.create(Map.merge(defaults, attrs))
  end

  describe "create/1" do
    test "creates a queue" do
      assert {:ok, queue} = create_queue(%{name: "Backlog", slug: "backlog"})
      assert queue.name == "Backlog"
      assert queue.slug == "backlog"
    end

    test "enforces unique slug" do
      {:ok, _} = create_queue(%{slug: "unique-q"})
      assert {:error, _} = create_queue(%{slug: "unique-q"})
    end

    test "requires name and slug" do
      assert {:error, _} = Queues.create(%{})
    end
  end

  describe "get/1" do
    test "returns queue by slug" do
      {:ok, queue} = create_queue(%{slug: "find-q"})
      assert %{slug: "find-q"} = Queues.get("find-q")
      assert queue.id == Queues.get("find-q").id
    end

    test "returns nil for missing slug" do
      assert is_nil(Queues.get("nonexistent"))
    end
  end

  describe "list/0" do
    test "returns all queues sorted by name" do
      {:ok, _} = create_queue(%{name: "Zebra", slug: "zebra-q"})
      {:ok, _} = create_queue(%{name: "Alpha", slug: "alpha-q"})

      queues = Queues.list()
      names = Enum.map(queues, & &1.name)
      assert Enum.find_index(names, &(&1 == "Alpha")) < Enum.find_index(names, &(&1 == "Zebra"))
    end
  end

  describe "status_counts/1" do
    test "returns counts by status for a queue" do
      {:ok, queue} = create_queue()

      {:ok, _} = Tickets.create(%{title: "T1", ticket_type: "task", queue_id: queue.id})
      {:ok, t2} = Tickets.create(%{title: "T2", ticket_type: "task", queue_id: queue.id})
      Tickets.update(t2.id, %{status: "done"})

      counts = Queues.status_counts(queue.id)
      assert counts["open"] == 1
      assert counts["done"] == 1
    end

    test "returns empty map for empty queue" do
      {:ok, queue} = create_queue()
      assert Queues.status_counts(queue.id) == %{}
    end
  end
end
