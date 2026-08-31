defmodule NoizuPromptLingua.Domains.Tickets.TicketFromEntityTest do
  @moduledoc """
  Stream F (tests): the `Ticket.FromEntity` MCP tool.

  Converting a source entity into a ticket must (1) create the ticket with a
  description that points back at the source and (2) create a `references` entity
  link via `Domains.Links`.

  The org ref is passed as a UUID so `Resolve.organization_id/1` resolves without
  the Redis-backed slug cache.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.Tickets.Tools.TicketFromEntity
  alias NoizuPromptLingua.Domains.Links

  setup do
    NoizuPromptLingua.TRP.Cache.clear()
    NoizuPromptLingua.TRP.TestStub.reset()
    {:ok, org_id: NoizuPromptLingua.TRP.TestStub.seed_org(Ecto.UUID.generate(), "tfeorg")}
  end

  test "FromEntity creates a ticket and a `references` link to the source", %{org_id: org_id} do
    subject_id = Ecto.UUID.generate()

    {:ok, result} =
      TicketFromEntity.call(
        %{
          organization: org_id,
          subject_type: "chat_message",
          subject_id: subject_id,
          summary: "needs follow-up"
        },
        %{}
      )

    assert is_binary(result.id)
    assert result.source == %{entity_type: "chat_message", entity_id: subject_id}

    # the tool reports the link it created …
    assert result.link.link_type == "references"
    assert result.link.entity_type == "chat_message"
    assert result.link.entity_id == subject_id

    # … and it is persisted via Domains.Links
    links = Links.get_entity_links(result.id)

    assert [%{link_type: "references", entity_type: "chat_message", entity_id: ^subject_id}] =
             links
  end

  test "FromEntity defaults the ticket_type to task", %{org_id: org_id} do
    {:ok, result} =
      TicketFromEntity.call(
        %{organization: org_id, subject_type: "wiki_page", subject_id: Ecto.UUID.generate()},
        %{}
      )

    assert result.ticket_type == "task"
  end

  # Slug resolution misses go through the Redis-backed slug cache.
  @tag :redis
  test "FromEntity errors when the organization cannot be resolved" do
    assert {:error, msg} =
             TicketFromEntity.call(
               %{organization: "no-such-org-slug", subject_type: "chat_message", subject_id: "x"},
               %{}
             )

    assert msg =~ "not found"
  end
end
