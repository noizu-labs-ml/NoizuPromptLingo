defmodule NoizuPromptLingua.Domains.Chat.SlugTest do
  @moduledoc """
  bc10f471 — verification for the chat-room slug contract (epic ffc795c5, ADR-013).

  Restores slug coverage that was dropped from chat_test.exs during the rebuild, asserting
  the LOCKED behavior (NOT the superseded org-wide/"room" behavior):

    * slugify/1 = transliterate -> NFKD -> strip \\p{Mn} -> downcase -> [a-z0-9]+ -> '-'
      -> trim -> cap(80) -> "room-"<>shortid fallback   (dmitri seq99 / ADR-013 §Canonical slugify/1)
    * H1: final slug INCLUDING the collision suffix is always <= 80 bytes
    * F1: the room-<shortid> fallback is lowercase [a-z0-9]+
    * per-(org,project) uniqueness via the two partial indexes; lookup predicate == index predicate (A3)
    * collision suffix assigned via 23505 retry (no select-then-insert); concurrent creates never 500 (A2 TOCTOU)

  Pure-function tests (golden/property/fallback) need no DB. The `@tag :db` block needs the
  052 slug column + the two partial indexes (provisioned by ChatTestSchema).
  """
  use NoizuPromptLingua.DataCase, async: false
  use ExUnitProperties

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.Domains.Chat.Slug

  @slug_max 80
  # a normal slug OR the room-<shortid> fallback, all lowercase
  @slug_re ~r/^([a-z0-9](-?[a-z0-9])*|room-[a-z0-9]+)$/

  @golden [
    {"Café", "cafe"},
    {"naïve", "naive"},
    {"Ünïcödé Tëst", "unicode-test"},
    {"Hello World", "hello-world"},
    {"  Hello   World  ", "hello-world"},
    {"Hello---World", "hello-world"},
    {"C++ Rocks!", "c-rocks"},
    {"①", "1"},
    {"ⅣⅤ", "ivv"},
    {"Straße", "strasse"},
    {"Łódź", "lodz"},
    {"Øresund", "oresund"},
    {"Encyclopædia", "encyclopaedia"},
    {"Ærø", "aero"},
    {"Þorn", "thorn"}
  ]

  @fallback_names ["🎉🎉", "日本語", "Привет", "!!!", "   "]

  describe "Chat.slugify/1 — golden vectors (frozen oracle)" do
    for {input, expected} <- @golden do
      test "#{inspect(input)} -> #{inspect(expected)}" do
        assert Slug.slugify(unquote(input)) == unquote(expected)
      end
    end
  end

  describe "Chat.slugify/1 — degenerate-name fallback (F1: lowercase shortid)" do
    for name <- @fallback_names do
      test "#{inspect(name)} -> room-<lowercase-shortid>" do
        assert Slug.slugify(unquote(name)) =~ ~r/^room-[a-z0-9]+$/
      end
    end
  end

  describe "Chat.slugify/1 — property invariants" do
    property "matches the slug grammar, non-empty, no edge/double dashes, <= 80 bytes" do
      check all name <- string(:printable, max_length: 60), max_runs: 500 do
        slug = Slug.slugify(name)
        assert slug != ""
        assert Regex.match?(@slug_re, slug), "bad slug #{inspect(slug)} from #{inspect(name)}"
        refute String.starts_with?(slug, "-")
        refute String.ends_with?(slug, "-")
        refute String.contains?(slug, "--")
        assert byte_size(slug) <= @slug_max
      end
    end

    property "idempotent: slugify(slugify(x)) == slugify(x)" do
      check all name <- string(:printable, max_length: 60), max_runs: 500 do
        slug = Slug.slugify(name)
        assert Slug.slugify(slug) == slug
      end
    end

    property "multibyte unicode never blows the byte cap" do
      check all name <- string(:utf8, max_length: 120), max_runs: 500 do
        assert byte_size(Slug.slugify(name)) <= @slug_max
      end
    end

    property "a base slug from any long input is capped to <= 80 (H1 base)" do
      check all n <- integer(80..400), max_runs: 50 do
        assert byte_size(Slug.slugify(String.duplicate("a", n))) <= @slug_max
      end
    end
  end

  describe "Chat.Slug.with_suffix/2 — H1 collision suffix governance" do
    test "n<=1 is the bare base; n>=2 appends -n" do
      assert Slug.with_suffix("general", 1) == "general"
      assert Slug.with_suffix("general", 2) == "general-2"
      assert Slug.with_suffix("general", 3) == "general-3"
    end

    test "final slug incl. suffix stays <= 80 bytes for any N, no dangling dash" do
      base = Slug.slugify(String.duplicate("a", 200))
      assert byte_size(base) <= @slug_max

      for n <- [2, 99, 1000, 10_000, 99_999] do
        composed = Slug.with_suffix(base, n)
        assert byte_size(composed) <= @slug_max, "N=#{n} produced #{byte_size(composed)} bytes"
        assert String.ends_with?(composed, "-#{n}")
        refute String.contains?(composed, "--")
      end
    end
  end

  # ── integration: per-(org,project) bucket + collision race (needs 052 indexes live) ──
  describe "create_room — bucket uniqueness, collision suffix, TOCTOU" do
    @describetag :db

    setup do
      org_id = insert_org()
      {:ok, org_id: org_id, project_id: insert_project(org_id)}
    end

    test "duplicate names in the SAME (org, project) bucket get suffixed", ctx do
      attrs = %{organization_id: ctx.org_id, project_id: ctx.project_id, name: "Standup"}
      {:ok, a} = Chat.create_room(attrs)
      {:ok, b} = Chat.create_room(attrs)
      {:ok, c} = Chat.create_room(attrs)
      assert a.slug == "standup"
      assert b.slug == "standup-2"
      assert c.slug == "standup-3"
    end

    test "the same slug COEXISTS across project=NULL and project=X buckets (A3)", ctx do
      {:ok, with_proj} =
        Chat.create_room(%{organization_id: ctx.org_id, project_id: ctx.project_id, name: "General"})

      {:ok, no_proj} =
        Chat.create_room(%{organization_id: ctx.org_id, project_id: nil, name: "General"})

      assert with_proj.slug == "general"
      assert no_proj.slug == "general"
    end

    test "by-slug lookup is bucket-scoped (predicate == partial-index predicate, A3)", ctx do
      {:ok, room} =
        Chat.create_room(%{organization_id: ctx.org_id, project_id: ctx.project_id, name: "Retro"})

      assert Chat.get_room_by_slug(ctx.org_id, ctx.project_id, "retro").id == room.id
      # wrong bucket / wrong org must NOT resolve it
      assert Chat.get_room_by_slug(ctx.org_id, nil, "retro") == nil
      assert Chat.get_room_by_slug(insert_org(), ctx.project_id, "retro") == nil
    end

    test "same slug allowed across different orgs", ctx do
      {:ok, a} = Chat.create_room(%{organization_id: ctx.org_id, name: "Town Hall"})
      {:ok, b} = Chat.create_room(%{organization_id: insert_org(), name: "Town Hall"})
      assert a.slug == "town-hall"
      assert b.slug == "town-hall"
    end

    test "concurrent create of same-name rooms never 500s; all slugs unique + <= 80 (A2/H1)", ctx do
      attrs = %{organization_id: ctx.org_id, project_id: ctx.project_id, name: "Race"}

      results =
        1..12
        |> Task.async_stream(fn _ -> Chat.create_room(attrs) end,
          max_concurrency: 12,
          ordered: false
        )
        |> Enum.map(fn {:ok, r} -> r end)

      assert Enum.all?(results, &match?({:ok, _}, &1)),
             "a concurrent create raised instead of retrying on 23505: #{inspect(results)}"

      slugs = Enum.map(results, fn {:ok, r} -> r.slug end)
      assert length(Enum.uniq(slugs)) == 12, "collision suffixing produced a duplicate"
      assert Enum.all?(slugs, &(byte_size(&1) <= @slug_max))
    end
  end

  # ── fixtures ──
  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["slugtest-#{System.unique_integer([:positive])}", "Slug Test Org"]
      )

    Ecto.UUID.load!(raw)
  end

  # chat_rooms.project_id is a real FK -> projects(id); the project-bucket cases need a
  # backing row (create_room only retries :slug 23505, never an FK violation — marcus seq193).
  defp insert_project(org_id) do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO projects (id, organization_id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, $3, now(), now()) RETURNING id",
        [Ecto.UUID.dump!(org_id), "slugproj-#{System.unique_integer([:positive])}", "Slug Test Project"]
      )

    Ecto.UUID.load!(raw)
  end
end
