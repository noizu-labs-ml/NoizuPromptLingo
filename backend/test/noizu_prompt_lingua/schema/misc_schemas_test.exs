defmodule NoizuPromptLingua.Schema.MiscSchemasTest do
  use NoizuPromptLingua.DataCase, async: true

  @moduledoc """
  Changeset matrices for the long tail of small domain schemas: authz policy
  document guard, MCPCustomScope kinds/visibility/window config, MCP prompt
  arguments, and the marketing/customers/wiki/notification/asset families.
  Changeset-level only (no persistence): unique/FK constraints stay declared
  but unexercised here.
  """

  alias NoizuPromptLingua.Schema.AssetEntry
  alias NoizuPromptLingua.Schema.Authz.Policy
  alias NoizuPromptLingua.Schema.BoardIteration
  alias NoizuPromptLingua.Schema.Campaign
  alias NoizuPromptLingua.Schema.ChatEvent
  alias NoizuPromptLingua.Schema.Competitor
  alias NoizuPromptLingua.Schema.MarketReport
  alias NoizuPromptLingua.Schema.MCP.McpPrompt
  alias NoizuPromptLingua.Schema.MCPCustomScope
  alias NoizuPromptLingua.Schema.Notification
  alias NoizuPromptLingua.Schema.Persona
  alias NoizuPromptLingua.Schema.PersonaJournalEntry
  alias NoizuPromptLingua.Schema.TicketEntityLink
  alias NoizuPromptLingua.Schema.TicketLink
  alias NoizuPromptLingua.Schema.Wiki.Page
  alias NoizuPromptLingua.Schema.Wiki.Reaction
  alias NoizuPromptLingua.Schema.Wiki.Space

  @org Ecto.UUID.generate()

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
  end

  defp valid?(schema, attrs), do: schema.changeset(struct(schema), attrs).valid?

  # ── Authz.Policy ─────────────────────────────────────────────────

  test "policy document must carry a statements array" do
    assert valid?(Policy, %{
             name: "p",
             policy_document: %{"statements" => [%{"effect" => "allow"}]}
           })

    refute valid?(Policy, %{name: "p", policy_document: %{"statements" => "all"}})
    refute valid?(Policy, %{name: "p", policy_document: %{"effect" => "allow"}})

    # no document CHANGE ⇒ no document validation
    cs = Policy.changeset(%Policy{name: "n", policy_document: %{}}, %{description: "d"})
    assert cs.valid?
  end

  # ── MCPCustomScope ───────────────────────────────────────────────

  test "custom scope: kinds + visibilities accessors" do
    assert MCPCustomScope.kinds() == ~w(custom all_in_one core_variant)
    assert MCPCustomScope.visibilities() == ~w(org account shared)
  end

  test "custom scope: visibility/1 resolution branches" do
    scope = fn config -> %MCPCustomScope{config: config} end

    assert MCPCustomScope.visibility(scope.(%{"visibility" => "shared"})) == "shared"
    assert MCPCustomScope.visibility(scope.(%{visibility: "account"})) == "account"
    # invalid, absent, and junk configs resolve to "org"
    assert MCPCustomScope.visibility(scope.(%{"visibility" => "galactic"})) == "org"
    assert MCPCustomScope.visibility(scope.(%{})) == "org"
    assert MCPCustomScope.visibility(nil) == "org"
  end

  test "custom scope: changeset slug normalization, requireds, kind inclusion" do
    cs =
      MCPCustomScope.changeset(%MCPCustomScope{}, %{
        "slug" => "  MyScope  ",
        "name" => "Scope",
        "kind" => "custom"
      })

    assert cs.valid?
    assert get_field(cs, :slug) == "myscope"

    # normalize (trim/downcase) does not rescue slug-format violations —
    # embedded spaces still fail ^[a-z0-9][a-z0-9-]{0,62}$ (pinned)
    cs_space =
      MCPCustomScope.changeset(%MCPCustomScope{}, %{"slug" => "my scope", "name" => "Scope"})

    refute cs_space.valid?
    assert errors_on(cs_space).slug

    cs2 = MCPCustomScope.changeset(%MCPCustomScope{}, %{"name" => "Scope"})
    refute cs2.valid?
    # kind has a default ("custom"), so only slug is required in practice
    assert errors_on(cs2).slug

    cs3 =
      MCPCustomScope.changeset(%MCPCustomScope{}, %{
        "slug" => "UPPER",
        "name" => "S",
        "kind" => "warp"
      })

    refute cs3.valid?
    assert errors_on(cs3).kind

    assert MCPCustomScope.changeset(%MCPCustomScope{}, %{
             "slug" => "ok-slug-1",
             "name" => "S",
             "kind" => "core_variant"
           }).valid?
  end

  test "custom scope: config jsonb validation incl window entries" do
    refute valid?(MCPCustomScope, %{"slug" => "s", "name" => "n", "config" => "junk"})

    # invalid visibility in config
    cs =
      MCPCustomScope.changeset(%MCPCustomScope{}, %{
        "slug" => "s",
        "name" => "n",
        "config" => %{"visibility" => "world"}
      })

    refute cs.valid?
    assert errors_on(cs).visibility

    # atom-keyed visibility is accepted
    assert valid?(MCPCustomScope, %{
             "slug" => "s",
             "name" => "n",
             "config" => %{visibility: "shared"}
           })

    # valid window entry passes
    good_entry = %{"hide_until" => "2030-01-01T00:00:00Z"}

    assert valid?(MCPCustomScope, %{
             "slug" => "s",
             "name" => "n",
             "config" => %{"groups" => %{"g" => %{"tools" => %{"T" => good_entry}}}}
           })

    # broken window entry surfaces with its path
    bad_entry = %{"hide_until" => "2030-01-01T00:00:00Z", "enable_for_hours" => 4}

    cs2 =
      MCPCustomScope.changeset(%MCPCustomScope{}, %{
        "slug" => "s",
        "name" => "n",
        "config" => %{"groups" => %{"g" => %{"tools" => %{"T" => bad_entry}}}}
      })

    refute cs2.valid?
    assert IO.iodata_to_binary(errors_on(cs2).config) =~ "groups.g.tools.T"

    # non-map groups value is ignored by the window walk (no crash)
    assert valid?(MCPCustomScope, %{
             "slug" => "s",
             "name" => "n",
             "config" => %{"groups" => "oops"}
           })
  end

  # ── MCP prompt ───────────────────────────────────────────────────

  test "mcp prompt: slug format + arguments list guard" do
    # normalize (trim/downcase) then format-check: spaces fail the format
    refute valid?(McpPrompt, %{
             "slug" => " Deploy Ctx ",
             "name" => "Deploy",
             "arguments" => [%{"name" => "env"}]
           })

    assert valid?(McpPrompt, %{
             "slug" => " Deploy_Ctx ",
             "name" => "Deploy",
             "arguments" => [%{"name" => "env"}]
           })

    assert valid?(McpPrompt, %{"slug" => "deploy", "name" => "D", "arguments" => [%{name: "env"}]})

    cs = McpPrompt.changeset(struct(McpPrompt), %{"slug" => "Bad Slug!", "name" => "X"})
    refute cs.valid?
    assert errors_on(cs).slug

    cs2 =
      McpPrompt.changeset(struct(McpPrompt), %{
        "slug" => "s",
        "name" => "X",
        "arguments" => "nope"
      })

    refute cs2.valid?
    assert errors_on(cs2).arguments

    cs3 =
      McpPrompt.changeset(struct(McpPrompt), %{
        "slug" => "s",
        "name" => "X",
        "arguments" => [%{"title" => "no name"}]
      })

    refute cs3.valid?
    assert errors_on(cs3).arguments
  end

  # ── marketing / customers family ─────────────────────────────────

  test "campaign, competitor, market_report, persona inclusion matrices" do
    assert valid?(Campaign, %{organization_id: @org, slug: "c", name: "C", channel: "email"})

    refute valid?(Campaign, %{
             organization_id: @org,
             slug: "c",
             name: "C",
             channel: "smoke-signals"
           })

    assert valid?(Competitor, %{
             organization_id: @org,
             slug: "rival",
             name: "Rival",
             tier: "direct"
           })

    refute valid?(Competitor, %{
             organization_id: @org,
             slug: "rival",
             name: "Rival",
             tier: "nemesis"
           })

    assert valid?(MarketReport, %{
             organization_id: @org,
             slug: "rep",
             title: "Rep",
             report_type: "swot"
           })

    refute valid?(MarketReport, %{
             organization_id: @org,
             slug: "rep",
             title: "Rep",
             report_type: "vibes"
           })

    assert valid?(Persona, %{organization_id: @org, slug: "p", name: "P", status: "active"})
    refute valid?(Persona, %{organization_id: @org, slug: "p", name: "P", status: "haunted"})
  end

  test "asset_entry types/status/quality" do
    base = %{
      organization_id: @org,
      slug: "hero",
      title: "Hero",
      asset_type: "image",
      prompt_yaml: "media: x"
    }

    assert valid?(AssetEntry, base)
    assert valid?(AssetEntry, Map.merge(base, %{quality: "high"}))
    assert valid?(AssetEntry, Map.merge(base, %{quality: nil}))
    refute valid?(AssetEntry, Map.merge(base, %{quality: "pristine"}))
    refute valid?(AssetEntry, Map.merge(base, %{asset_type: "smell"}))
    refute valid?(AssetEntry, Map.merge(base, %{status: "vibing"}))

    assert "style_guide" in AssetEntry.asset_types()
  end

  # ── wiki / chat / notifications / journal / links ────────────────

  test "wiki space + page slug format" do
    assert valid?(Space, %{organization_id: @org, slug: "eng", name: "Eng"})
    refute valid?(Space, %{organization_id: @org, slug: "Bad_Slug", name: "X"})

    assert valid?(Page, %{space_id: Ecto.UUID.generate(), slug: "overview", title: "Overview"})
    refute valid?(Page, %{space_id: Ecto.UUID.generate(), slug: "OVERVIEW", title: "X"})
  end

  test "wiki reaction inclusions" do
    base = %{
      target_type: "page",
      target_id: Ecto.UUID.generate(),
      emoji: "tada",
      actor: Ecto.UUID.generate()
    }

    assert valid?(Reaction, base)
    refute valid?(Reaction, Map.merge(base, %{target_type: "wiki"}))
    assert "comment" in Reaction.target_types()
  end

  test "persona journal entry categories" do
    base = %{persona_id: Ecto.UUID.generate(), body: "did the thing"}

    assert valid?(PersonaJournalEntry, base)
    assert valid?(PersonaJournalEntry, Map.merge(base, %{category: "reflection"}))
    refute valid?(PersonaJournalEntry, Map.merge(base, %{category: "diary"}))
    assert "decision" in PersonaJournalEntry.categories()
  end

  test "ticket links (entity + ticket-to-ticket)" do
    t1 = Ecto.UUID.generate()

    assert valid?(TicketEntityLink, %{
             ticket_id: t1,
             entity_type: "customer_persona",
             entity_id: Ecto.UUID.generate(),
             link_type: "relates_to"
           })

    # NOTE (pinned): entity_type is NOT validated against the @entity_types
    # list — junk types pass the changeset (only link_type is inclusion-checked)
    assert valid?(TicketEntityLink, %{
             ticket_id: t1,
             entity_type: "ufo",
             entity_id: Ecto.UUID.generate(),
             link_type: "relates_to"
           })

    refute valid?(TicketEntityLink, %{
             ticket_id: t1,
             entity_type: "customer_persona",
             entity_id: Ecto.UUID.generate(),
             link_type: "haunts"
           })

    assert "blocks" in TicketEntityLink.link_types()

    assert valid?(TicketLink, %{
             source_ticket_id: t1,
             target_ticket_id: Ecto.UUID.generate(),
             link_type: "blocks"
           })

    refute valid?(TicketLink, %{
             source_ticket_id: t1,
             target_ticket_id: Ecto.UUID.generate(),
             link_type: "obsesses_over"
           })

    assert "duplicates" in TicketLink.link_types()
  end

  test "chat event + board iteration + notification basics" do
    assert valid?(ChatEvent, %{
             room_id: Ecto.UUID.generate(),
             event_type: "decision",
             content: "ship it",
             sender: Ecto.UUID.generate()
           })

    refute valid?(ChatEvent, %{
             room_id: Ecto.UUID.generate(),
             event_type: "party",
             content: "x",
             sender: Ecto.UUID.generate()
           })

    assert valid?(BoardIteration, %{
             queue_id: Ecto.UUID.generate(),
             name: "Sprint 1",
             status: "planned"
           })

    refute valid?(BoardIteration, %{
             queue_id: Ecto.UUID.generate(),
             name: "Sprint 1",
             status: "sprinting"
           })

    assert valid?(Notification, %{
             organization_id: @org,
             recipient: Ecto.UUID.generate(),
             kind: "mention"
           })

    refute valid?(Notification, %{
             organization_id: @org,
             recipient: Ecto.UUID.generate(),
             kind: "telepathy"
           })
  end
end
