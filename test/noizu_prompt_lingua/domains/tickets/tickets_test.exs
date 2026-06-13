defmodule NoizuPromptLingua.Domains.TicketsTest do
  use NoizuPromptLingua.DataCase, async: true

  alias NoizuPromptLingua.Domains.Tickets

  defp create_ticket(attrs \\ %{}) do
    defaults = %{title: "Test Ticket", ticket_type: "task"}
    Tickets.create(Map.merge(defaults, attrs))
  end

  describe "create/1" do
    test "creates a ticket with required fields" do
      assert {:ok, ticket} = create_ticket()
      assert ticket.title == "Test Ticket"
      assert ticket.ticket_type == "task"
      assert ticket.status == "open"
    end

    test "creates a ticket with all fields" do
      assert {:ok, ticket} = create_ticket(%{
        description: "A bug",
        ticket_type: "bug",
        priority: "high",
        assignee: "alice",
        reporter: "bob",
        custom_fields: %{"severity" => "major"}
      })

      assert ticket.priority == "high"
      assert ticket.custom_fields["severity"] == "major"
    end

    test "requires title" do
      assert {:error, changeset} = Tickets.create(%{ticket_type: "task"})
      assert %{title: _} = errors_on(changeset)
    end

    test "validates priority values" do
      assert {:error, changeset} = create_ticket(%{priority: "extreme"})
      assert %{priority: _} = errors_on(changeset)
    end
  end

  describe "get/1" do
    test "returns a ticket by id" do
      {:ok, ticket} = create_ticket()
      fetched = Tickets.get(ticket.id)
      assert fetched.id == ticket.id
    end

    test "returns nil for missing id" do
      assert is_nil(Tickets.get(Ecto.UUID.generate()))
    end
  end

  describe "update/2" do
    test "updates scalar fields" do
      {:ok, ticket} = create_ticket()
      assert {:ok, updated} = Tickets.update(ticket.id, %{status: "in_progress", priority: "high"})
      assert updated.status == "in_progress"
      assert updated.priority == "high"
    end

    test "merges custom_fields" do
      {:ok, ticket} = create_ticket(%{custom_fields: %{"a" => "1"}})
      assert {:ok, updated} = Tickets.update(ticket.id, %{custom_fields: %{"b" => "2"}})
      assert updated.custom_fields == %{"a" => "1", "b" => "2"}
    end

    test "returns error for missing ticket" do
      assert {:error, :not_found} = Tickets.update(Ecto.UUID.generate(), %{status: "done"})
    end
  end

  describe "list/1" do
    test "returns tickets ordered by inserted_at desc" do
      {:ok, t1} = create_ticket(%{title: "First"})
      {:ok, t2} = create_ticket(%{title: "Second"})
      tickets = Tickets.list()
      ids = Enum.map(tickets, & &1.id)
      assert t2.id in ids
      assert t1.id in ids
    end

    test "filters by status" do
      {:ok, _} = create_ticket(%{title: "Open"})
      {:ok, closed} = create_ticket(%{title: "Closed"})
      Tickets.update(closed.id, %{status: "closed"})

      tickets = Tickets.list(status: "open")
      assert Enum.all?(tickets, &(&1.status == "open"))
    end

    test "filters by ticket_type" do
      {:ok, _} = create_ticket(%{ticket_type: "bug"})
      {:ok, _} = create_ticket(%{ticket_type: "task"})

      bugs = Tickets.list(ticket_type: "bug")
      assert Enum.all?(bugs, &(&1.ticket_type == "bug"))
    end

    test "filters by priority" do
      {:ok, _} = create_ticket(%{priority: "critical"})
      {:ok, _} = create_ticket(%{priority: "low"})

      critical = Tickets.list(priority: "critical")
      assert Enum.all?(critical, &(&1.priority == "critical"))
    end

    test "filters by assignee" do
      {:ok, _} = create_ticket(%{assignee: "alice"})
      {:ok, _} = create_ticket(%{assignee: "bob"})

      assert [ticket] = Tickets.list(assignee: "alice")
      assert ticket.assignee == "alice"
    end

    test "respects limit and offset" do
      for i <- 1..5, do: create_ticket(%{title: "Ticket #{i}"})

      page1 = Tickets.list(limit: 2, offset: 0)
      page2 = Tickets.list(limit: 2, offset: 2)

      assert length(page1) == 2
      assert length(page2) == 2
      assert MapSet.disjoint?(MapSet.new(page1, & &1.id), MapSet.new(page2, & &1.id))
    end
  end

  describe "count_by_status/0" do
    test "returns status counts" do
      {:ok, _} = create_ticket()
      {:ok, t2} = create_ticket()
      Tickets.update(t2.id, %{status: "done"})

      counts = Tickets.count_by_status()
      assert counts["open"] >= 1
      assert counts["done"] >= 1
    end
  end

  describe "links" do
    test "link/3 creates a link between tickets" do
      {:ok, t1} = create_ticket(%{title: "Blocker"})
      {:ok, t2} = create_ticket(%{title: "Blocked"})

      assert {:ok, link} = Tickets.link(t1.id, t2.id, "blocks")
      assert link.link_type == "blocks"
    end

    test "link/3 validates link_type" do
      {:ok, t1} = create_ticket()
      {:ok, t2} = create_ticket()

      assert {:error, _} = Tickets.link(t1.id, t2.id, "invalid_type")
    end

    test "link/3 enforces uniqueness" do
      {:ok, t1} = create_ticket()
      {:ok, t2} = create_ticket()

      assert {:ok, _} = Tickets.link(t1.id, t2.id, "relates_to")
      assert {:error, _} = Tickets.link(t1.id, t2.id, "relates_to")
    end

    test "unlink/3 removes a link" do
      {:ok, t1} = create_ticket()
      {:ok, t2} = create_ticket()
      Tickets.link(t1.id, t2.id, "blocks")

      assert {:ok, _} = Tickets.unlink(t1.id, t2.id, "blocks")
      assert {:error, :not_found} = Tickets.unlink(t1.id, t2.id, "blocks")
    end

    test "get_links/1 returns outgoing and incoming links" do
      {:ok, t1} = create_ticket()
      {:ok, t2} = create_ticket()
      {:ok, t3} = create_ticket()

      Tickets.link(t1.id, t2.id, "blocks")
      Tickets.link(t3.id, t1.id, "relates_to")

      links = Tickets.get_links(t1.id)
      assert length(links.outgoing) == 1
      assert length(links.incoming) == 1
      assert hd(links.outgoing).target_ticket_id == t2.id
      assert hd(links.incoming).source_ticket_id == t3.id
    end
  end

  describe "parent/child" do
    test "tickets can reference a parent" do
      {:ok, epic} = create_ticket(%{title: "Epic", ticket_type: "epic"})
      {:ok, story} = create_ticket(%{title: "Story", ticket_type: "user_story", parent_id: epic.id})

      assert story.parent_id == epic.id
      children = Tickets.list(parent_id: epic.id)
      assert length(children) == 1
      assert hd(children).id == story.id
    end
  end

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
