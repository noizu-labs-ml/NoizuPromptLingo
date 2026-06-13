defmodule NoizuPromptLingua.Schema.TicketSchemaTest do
  use NoizuPromptLingua.DataCase, async: true

  alias NoizuPromptLingua.Schema.{
    Ticket, TicketFieldDefinition, TicketTypeDefinition,
    TicketTypeField, TicketQueue, TicketLink
  }

  describe "Ticket changeset" do
    test "valid with required fields" do
      cs = Ticket.changeset(%Ticket{}, %{title: "Bug", ticket_type: "bug"})
      assert cs.valid?
    end

    test "invalid without title" do
      cs = Ticket.changeset(%Ticket{}, %{ticket_type: "bug"})
      refute cs.valid?
    end

    test "invalid without ticket_type" do
      cs = Ticket.changeset(%Ticket{}, %{title: "Bug"})
      refute cs.valid?
    end

    test "validates priority values" do
      cs = Ticket.changeset(%Ticket{}, %{title: "X", ticket_type: "task", priority: "extreme"})
      refute cs.valid?
    end

    test "accepts valid priority" do
      for p <- ~w(low medium high critical) do
        cs = Ticket.changeset(%Ticket{}, %{title: "X", ticket_type: "task", priority: p})
        assert cs.valid?, "Priority #{p} should be valid"
      end
    end

    test "defaults status to open" do
      cs = Ticket.changeset(%Ticket{}, %{title: "X", ticket_type: "task"})
      assert Ecto.Changeset.get_field(cs, :status) == "open"
    end

    test "defaults custom_fields to empty map" do
      cs = Ticket.changeset(%Ticket{}, %{title: "X", ticket_type: "task"})
      assert Ecto.Changeset.get_field(cs, :custom_fields) == %{}
    end
  end

  describe "TicketFieldDefinition changeset" do
    test "valid with required fields" do
      cs = TicketFieldDefinition.changeset(%TicketFieldDefinition{}, %{
        slug: "test", label: "Test", field_type: "text"
      })
      assert cs.valid?
    end

    test "invalid field_type" do
      cs = TicketFieldDefinition.changeset(%TicketFieldDefinition{}, %{
        slug: "test", label: "Test", field_type: "invalid"
      })
      refute cs.valid?
    end

    test "accepts all valid field types" do
      for ft <- TicketFieldDefinition.field_types() do
        cs = TicketFieldDefinition.changeset(%TicketFieldDefinition{}, %{
          slug: ft, label: ft, field_type: ft
        })
        assert cs.valid?, "Field type #{ft} should be valid"
      end
    end
  end

  describe "TicketTypeDefinition changeset" do
    test "valid with required fields" do
      cs = TicketTypeDefinition.changeset(%TicketTypeDefinition{}, %{slug: "epic", name: "Epic"})
      assert cs.valid?
    end

    test "invalid without slug" do
      cs = TicketTypeDefinition.changeset(%TicketTypeDefinition{}, %{name: "Epic"})
      refute cs.valid?
    end
  end

  describe "TicketQueue changeset" do
    test "valid with name and slug" do
      cs = TicketQueue.changeset(%TicketQueue{}, %{name: "Backlog", slug: "backlog"})
      assert cs.valid?
    end

    test "invalid without slug" do
      cs = TicketQueue.changeset(%TicketQueue{}, %{name: "Backlog"})
      refute cs.valid?
    end
  end

  describe "TicketLink changeset" do
    test "valid with required fields" do
      cs = TicketLink.changeset(%TicketLink{}, %{
        source_ticket_id: Ecto.UUID.generate(),
        target_ticket_id: Ecto.UUID.generate(),
        link_type: "blocks"
      })
      assert cs.valid?
    end

    test "invalid link_type" do
      cs = TicketLink.changeset(%TicketLink{}, %{
        source_ticket_id: Ecto.UUID.generate(),
        target_ticket_id: Ecto.UUID.generate(),
        link_type: "invalid"
      })
      refute cs.valid?
    end

    test "accepts all valid link types" do
      for lt <- TicketLink.link_types() do
        cs = TicketLink.changeset(%TicketLink{}, %{
          source_ticket_id: Ecto.UUID.generate(),
          target_ticket_id: Ecto.UUID.generate(),
          link_type: lt
        })
        assert cs.valid?, "Link type #{lt} should be valid"
      end
    end
  end

  describe "TicketTypeField changeset" do
    test "valid with required refs" do
      cs = TicketTypeField.changeset(%TicketTypeField{}, %{
        ticket_type_definition_id: Ecto.UUID.generate(),
        ticket_field_definition_id: Ecto.UUID.generate()
      })
      assert cs.valid?
    end

    test "defaults required to false" do
      cs = TicketTypeField.changeset(%TicketTypeField{}, %{
        ticket_type_definition_id: Ecto.UUID.generate(),
        ticket_field_definition_id: Ecto.UUID.generate()
      })
      assert Ecto.Changeset.get_field(cs, :required) == false
    end
  end
end
