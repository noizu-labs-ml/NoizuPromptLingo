defmodule NoizuPromptLingua.Domains.TicketsHumanKeyTest do
  @moduledoc """
  Ticket human keys via the TRP shared-key plane (W4 cutover): TRP mints the
  immutable `PREFIX-NNN` key/number server-side; NPL preserves both verbatim in
  the ticket shape and resolves `get_by_key` within the org. Key GENERATION
  (prefix derivation, gap-free numbering, backfill) is now TRP-owned and covered
  by TRP's own suite — not retested here.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.Tickets
  alias NoizuPromptLingua.TRP.TestStub

  setup do
    NoizuPromptLingua.TRP.Cache.clear()
    TestStub.reset()
    org_id = TestStub.seed_org(Ecto.UUID.generate(), "acme-corp")
    {:ok, org_id: org_id}
  end

  defp create!(attrs) do
    {:ok, t} = Tickets.create(Map.merge(%{ticket_type: "task"}, attrs))
    t
  end

  test "created tickets carry TRP-minted keys + numbers, with ticket_type alias", c do
    t = create!(%{organization_id: c.org_id, title: "A"})

    assert is_binary(t.key) and t.key != ""
    assert is_integer(t.number) or is_binary(t.number)
    assert t.ticket_type == "task"
    assert t.item_type == "task"
  end

  test "get_by_key resolves within the org; unknown key -> nil", c do
    a = create!(%{organization_id: c.org_id, title: "A"})
    assert Tickets.get_by_key(c.org_id, a.key).id == a.id
    assert Tickets.get_by_key(c.org_id, "NOPE-999") == nil
  end

  test "custom_fields and project scoping round-trip", c do
    project_id = Ecto.UUID.generate()

    t =
      create!(%{
        organization_id: c.org_id,
        project_id: project_id,
        title: "A",
        custom_fields: %{"severity" => "high"}
      })

    got = Tickets.get(t.id)
    assert got.project_id == project_id
    assert got.custom_fields == %{"severity" => "high"}
  end
end
