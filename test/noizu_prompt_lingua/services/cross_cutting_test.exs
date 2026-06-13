defmodule NoizuPromptLingua.Services.CrossCuttingTest do
  use NoizuPromptLingua.DataCase, async: true

  alias NoizuPromptLingua.Services.{Comment, Attach, Watch}
  alias NoizuPromptLingua.Domains.Tickets

  defp create_ticket do
    {:ok, ticket} = Tickets.create(%{title: "Test", ticket_type: "task"})
    ticket
  end

  describe "Comment service" do
    test "add/3 creates a comment" do
      ticket = create_ticket()

      assert {:ok, comment} = Comment.add("ticket", ticket.id, %{
        content: "This is a comment",
        author: "alice"
      })

      assert comment.content == "This is a comment"
      assert comment.author == "alice"
      assert comment.entity_type == "ticket"
    end

    test "list/3 returns comments for an entity" do
      ticket = create_ticket()
      Comment.add("ticket", ticket.id, %{content: "First"})
      Comment.add("ticket", ticket.id, %{content: "Second"})

      comments = Comment.list("ticket", ticket.id)
      assert length(comments) == 2
      assert hd(comments).content == "First"
    end

    test "comments are scoped to entity" do
      t1 = create_ticket()
      t2 = create_ticket()
      Comment.add("ticket", t1.id, %{content: "For T1"})
      Comment.add("ticket", t2.id, %{content: "For T2"})

      assert length(Comment.list("ticket", t1.id)) == 1
      assert length(Comment.list("ticket", t2.id)) == 1
    end

    test "threaded replies via reply_to_id" do
      ticket = create_ticket()
      {:ok, parent} = Comment.add("ticket", ticket.id, %{content: "Parent"})
      {:ok, reply} = Comment.add("ticket", ticket.id, %{
        content: "Reply", reply_to_id: parent.id
      })

      assert reply.reply_to_id == parent.id
    end
  end

  describe "Attach service" do
    test "add/3 creates an attachment" do
      ticket = create_ticket()

      assert {:ok, att} = Attach.add("ticket", ticket.id, %{
        artifact_type: "url",
        url: "https://example.com",
        description: "Reference doc",
        created_by: "alice"
      })

      assert att.artifact_type == "url"
      assert att.url == "https://example.com"
    end

    test "list/2 returns attachments for an entity" do
      ticket = create_ticket()
      Attach.add("ticket", ticket.id, %{artifact_type: "url", url: "https://a.com"})
      Attach.add("ticket", ticket.id, %{artifact_type: "git_branch", git_branch: "fix/bug-123"})

      atts = Attach.list("ticket", ticket.id)
      assert length(atts) == 2
    end

    test "remove/1 deletes an attachment" do
      ticket = create_ticket()
      {:ok, att} = Attach.add("ticket", ticket.id, %{artifact_type: "url", url: "https://x.com"})

      assert {:ok, _} = Attach.remove(att.id)
      assert Attach.list("ticket", ticket.id) == []
    end

    test "remove/1 returns error for missing attachment" do
      assert {:error, :not_found} = Attach.remove(Ecto.UUID.generate())
    end

    test "validates artifact_type" do
      ticket = create_ticket()
      assert {:error, _} = Attach.add("ticket", ticket.id, %{artifact_type: "invalid"})
    end
  end

  describe "Watch service" do
    test "watch/3 subscribes a persona" do
      ticket = create_ticket()

      assert {:ok, _} = Watch.watch("ticket", ticket.id, "alice")
      assert Watch.watching?("ticket", ticket.id, "alice")
    end

    test "watch/3 is idempotent" do
      ticket = create_ticket()
      Watch.watch("ticket", ticket.id, "alice")
      Watch.watch("ticket", ticket.id, "alice")

      assert Watch.watchers("ticket", ticket.id) == ["alice"]
    end

    test "unwatch/3 removes subscription" do
      ticket = create_ticket()
      Watch.watch("ticket", ticket.id, "alice")

      assert {:ok, _} = Watch.unwatch("ticket", ticket.id, "alice")
      refute Watch.watching?("ticket", ticket.id, "alice")
    end

    test "unwatch/3 returns error when not watching" do
      ticket = create_ticket()
      assert {:error, :not_found} = Watch.unwatch("ticket", ticket.id, "alice")
    end

    test "watchers/2 returns all personas watching" do
      ticket = create_ticket()
      Watch.watch("ticket", ticket.id, "alice")
      Watch.watch("ticket", ticket.id, "bob")

      watchers = Watch.watchers("ticket", ticket.id)
      assert "alice" in watchers
      assert "bob" in watchers
    end

    test "watching?/3 returns false for non-watchers" do
      ticket = create_ticket()
      refute Watch.watching?("ticket", ticket.id, "nobody")
    end
  end
end
