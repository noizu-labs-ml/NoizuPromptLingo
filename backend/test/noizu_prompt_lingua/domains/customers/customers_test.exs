defmodule NoizuPromptLingua.Domains.CustomersTest do
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.Domains.{Customers, Links, Tickets}

  setup do
    {:ok, org_id: insert_org()}
  end

  test "create + resolve a customer persona by slug", %{org_id: org_id} do
    {:ok, p} =
      Customers.create_persona(%{
        organization_id: org_id,
        slug: "icp-buyer",
        name: "Technical Buyer",
        archetype: "Engineer",
        goals: ["ship faster"],
        pains: ["toil"]
      })

    assert p.id
    assert Customers.resolve_persona(org_id, "icp-buyer").id == p.id
    assert Customers.resolve_persona(org_id, p.id).slug == "icp-buyer"
  end

  test "persona requires organization + slug + name", %{org_id: _org_id} do
    assert {:error, cs} = Customers.create_persona(%{name: "x"})
    assert cs.errors[:organization_id]
    assert cs.errors[:slug]
  end

  test "segment + persona scoping and listing", %{org_id: org_id} do
    {:ok, seg} = Customers.create_segment(%{organization_id: org_id, slug: "smb", name: "SMB"})

    {:ok, _} =
      Customers.create_persona(%{
        organization_id: org_id,
        slug: "p1",
        name: "P1",
        segment_id: seg.id
      })

    {:ok, _} = Customers.create_persona(%{organization_id: org_id, slug: "p2", name: "P2"})

    assert length(Customers.list_personas(organization_id: org_id)) == 2
    assert [%{slug: "p1"}] = Customers.list_personas(organization_id: org_id, segment_id: seg.id)
    assert Customers.count_personas(org_id) == 2
  end

  describe "ticket linking (requirement #1)" do
    test "link a persona to a ticket and reverse-lookup", %{org_id: org_id} do
      {:ok, persona} =
        Customers.create_persona(%{organization_id: org_id, slug: "icp", name: "ICP"})

      {:ok, ticket} =
        Tickets.create(%{organization_id: org_id, title: "Build feature X", ticket_type: "task"})

      assert {:ok, link} = Customers.link_ticket(persona.id, ticket.id, link_type: "targets")
      assert link.entity_type == "customer_persona"
      assert link.link_type == "targets"

      # reverse lookup: which tickets target this persona
      assert [%{ticket_id: tid}] = Customers.linked_tickets(persona.id)
      assert tid == ticket.id

      # forward lookup from the ticket side
      assert [%{entity_id: eid, entity_type: "customer_persona"}] =
               Links.get_entity_links(ticket.id)

      assert eid == persona.id
    end

    test "linking to a missing ticket is a clean error", %{org_id: org_id} do
      {:ok, persona} =
        Customers.create_persona(%{organization_id: org_id, slug: "icp2", name: "ICP2"})

      assert {:error, :ticket_not_found} = Customers.link_ticket(persona.id, Ecto.UUID.generate())
    end

    test "duplicate link is rejected by the unique index", %{org_id: org_id} do
      {:ok, persona} =
        Customers.create_persona(%{organization_id: org_id, slug: "icp3", name: "ICP3"})

      {:ok, ticket} = Tickets.create(%{organization_id: org_id, title: "T", ticket_type: "task"})
      assert {:ok, _} = Customers.link_ticket(persona.id, ticket.id)
      assert {:error, _} = Customers.link_ticket(persona.id, ticket.id)
      assert {:ok, _} = Customers.unlink_ticket(persona.id, ticket.id)
      assert [] = Customers.linked_tickets(persona.id)
    end
  end

  describe "draft_persona (offline path)" do
    test "llm_generate: false stores an artifact and sets summary/artifact_id", %{org_id: org_id} do
      {:ok, persona} =
        Customers.create_persona(%{
          organization_id: org_id,
          slug: "draftme",
          name: "Draft Me",
          goals: ["win"],
          pains: ["lose"]
        })

      assert {:ok, updated} = Customers.draft_persona(persona.id, llm_generate: false)
      assert updated.artifact_id
      assert is_binary(updated.summary)
    end
  end

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["custtest-#{System.unique_integer([:positive])}", "Customers Test Org"]
      )

    Ecto.UUID.load!(raw)
  end
end
