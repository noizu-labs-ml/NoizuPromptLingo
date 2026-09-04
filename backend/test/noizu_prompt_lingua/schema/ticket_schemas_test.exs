defmodule NoizuPromptLingua.Schema.TicketSchemasTest do
  use NoizuPromptLingua.DataCase, async: true

  @moduledoc """
  Ticket definition schemas: TicketFieldDefinition (field-type inclusion,
  three-scope model with the project-requires-org rule) and
  TicketTypeDefinition (same scoping rule), plus the Ticket schema's
  priority/required guards on both changeset actions.
  """

  alias NoizuPromptLingua.Schema.Ticket
  alias NoizuPromptLingua.Schema.TicketFieldDefinition
  alias NoizuPromptLingua.Schema.TicketTypeDefinition

  @org Ecto.UUID.generate()
  @project Ecto.UUID.generate()

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
  end

  # ── TicketFieldDefinition ────────────────────────────────────────

  test "field definition: global valid, field types enforced, accessors" do
    cs =
      TicketFieldDefinition.changeset(%TicketFieldDefinition{}, %{
        slug: "severity",
        label: "Severity",
        field_type: "select",
        options: %{"choices" => ["low", "high"]}
      })

    assert cs.valid?
    assert "multi_select" in TicketFieldDefinition.field_types()
    assert "persona" in TicketFieldDefinition.field_types()

    cs2 =
      TicketFieldDefinition.changeset(%TicketFieldDefinition{}, %{
        slug: "x",
        label: "X",
        field_type: "hologram"
      })

    refute cs2.valid?
    assert errors_on(cs2).field_type
  end

  test "field definition: required fields" do
    cs = TicketFieldDefinition.changeset(%TicketFieldDefinition{}, %{})
    refute cs.valid?
    errs = errors_on(cs)
    assert errs.slug
    assert errs.label
    assert errs.field_type
  end

  test "field definition: project scope requires organization" do
    base = %{slug: "s", label: "L", field_type: "text"}

    assert TicketFieldDefinition.changeset(
             %TicketFieldDefinition{},
             Map.merge(base, %{organization_id: @org, project_id: @project})
           ).valid?

    assert TicketFieldDefinition.changeset(
             %TicketFieldDefinition{},
             Map.merge(base, %{organization_id: @org})
           ).valid?

    cs =
      TicketFieldDefinition.changeset(
        %TicketFieldDefinition{},
        Map.merge(base, %{project_id: @project})
      )

    refute cs.valid?
    assert errors_on(cs).organization_id
  end

  # ── TicketTypeDefinition ─────────────────────────────────────────

  test "type definition: valid + tombstone flag + scope rule" do
    base = %{slug: "bug", name: "Bug"}

    cs = TicketTypeDefinition.changeset(%TicketTypeDefinition{}, base)
    assert cs.valid?
    assert get_field(cs, :disabled) == false

    cs2 =
      TicketTypeDefinition.changeset(%TicketTypeDefinition{}, Map.merge(base, %{disabled: true}))

    assert cs2.valid?

    assert TicketTypeDefinition.changeset(
             %TicketTypeDefinition{},
             Map.merge(base, %{organization_id: @org, project_id: @project})
           ).valid?

    cs3 =
      TicketTypeDefinition.changeset(
        %TicketTypeDefinition{},
        Map.merge(base, %{project_id: @project})
      )

    refute cs3.valid?
    assert errors_on(cs3).organization_id
  end

  test "type definition: required fields" do
    cs = TicketTypeDefinition.changeset(%TicketTypeDefinition{}, %{})
    refute cs.valid?
    errs = errors_on(cs)
    assert errs.slug
    assert errs.name
  end

  # ── Ticket schema ────────────────────────────────────────────────

  test "ticket changeset: required + priority inclusion" do
    cs =
      Ticket.changeset(%Ticket{}, %{
        organization_id: @org,
        title: "Fix the flibber",
        ticket_type: "task",
        status: "open",
        priority: "high"
      })

    assert cs.valid?

    cs2 =
      Ticket.changeset(%Ticket{}, %{
        organization_id: @org,
        title: "t",
        ticket_type: "task",
        priority: "blocker"
      })

    refute cs2.valid?
    assert errors_on(cs2).priority

    # nil priority allowed
    cs3 =
      Ticket.changeset(%Ticket{}, %{
        organization_id: @org,
        title: "t",
        ticket_type: "task",
        priority: nil
      })

    assert cs3.valid?

    cs4 = Ticket.changeset(%Ticket{}, %{})
    refute cs4.valid?
    errs = errors_on(cs4)
    assert errs.organization_id
    assert errs.title
    assert errs.ticket_type
  end

  test "ticket update_changeset: mutable subset only" do
    ticket = %Ticket{
      id: Ecto.UUID.generate(),
      organization_id: @org,
      title: "t",
      ticket_type: "task"
    }

    cs = Ticket.update_changeset(ticket, %{title: "t2", status: "closed", priority: "low"})
    assert cs.valid?
    assert cs.changes.title == "t2"

    # ticket_type is NOT castable on update
    cs2 = Ticket.update_changeset(ticket, %{ticket_type: "bug", title: "t3"})
    assert cs2.valid?
    refute Map.has_key?(cs2.changes, :ticket_type)

    cs3 = Ticket.update_changeset(ticket, %{priority: "nope"})
    refute cs3.valid?
  end
end
