defmodule NoizuPromptLingua.Organizations.SlugBackfillTest do
  @moduledoc """
  Pure-function coverage for the org-slug backfill reference logic (Liquibase
  081 twin): slugify normalization, the -2/-3 collision rule, and the
  plan/changes split. No DB — the SQL changeset is verified separately by its
  idempotent-by-construction shape.
  """
  use ExUnit.Case, async: true

  alias NoizuPromptLingua.Organizations.SlugBackfill

  describe "slugify/1" do
    test "lowercases and collapses non-alphanumeric runs to single dashes" do
      assert SlugBackfill.slugify("Acme Corp!") == "acme-corp"
      assert SlugBackfill.slugify("  --Foo__Bar  ") == "foo-bar"
      assert SlugBackfill.slugify("Café Org") == "caf-org"
    end

    test "blank or non-alphanumeric input yields nil" do
      assert SlugBackfill.slugify(nil) == nil
      assert SlugBackfill.slugify("") == nil
      assert SlugBackfill.slugify("   ") == nil
      assert SlugBackfill.slugify("---___") == nil
    end

    test "caps at 64 characters and does not end on a dash" do
      long = String.duplicate("a", 60) <> "-" <> String.duplicate("b", 10)
      slug = SlugBackfill.slugify(long)
      assert byte_size(slug) == 64
      refute String.ends_with?(slug, "-")
    end
  end

  describe "plan/1" do
    test "first row wins a candidate; later collisions take -2 then -3" do
      rows = [
        %{id: "a", slug: "acme", name: "Acme"},
        %{id: "b", slug: "acme corp", name: "Acme Corp"},
        %{id: "c", slug: "ACME-CORP!", name: "Acme Three"}
      ]

      assert SlugBackfill.plan(rows) == %{
               "a" => "acme",
               "b" => "acme-corp",
               "c" => "acme-corp-2"
             }
    end

    test "already-clean slugs pass through unchanged" do
      rows = [%{id: "a", slug: "acme", name: "Acme"}, %{id: "b", slug: "other", name: "Other"}]
      assert SlugBackfill.plan(rows) == %{"a" => "acme", "b" => "other"}
    end

    test "falls back to the name, then to org-<id8>" do
      rows = [
        %{id: "11111111-2222-3333-4444-555555555555", slug: "  --  ", name: "Fallback Name"},
        %{id: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee", slug: nil, name: "!!!"}
      ]

      assert SlugBackfill.plan(rows) == %{
               "11111111-2222-3333-4444-555555555555" => "fallback-name",
               "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" => "org-aaaaaaaa"
             }
    end

    test "suffixed candidates are themselves collision-checked" do
      rows = [
        %{id: "a", slug: "acme", name: "Acme"},
        %{id: "b", slug: "acme", name: "Acme 2"},
        %{id: "c", slug: "acme-2", name: "Acme 3"}
      ]

      assert SlugBackfill.plan(rows) == %{"a" => "acme", "b" => "acme-2", "c" => "acme-2-2"}
    end
  end

  describe "changes/1" do
    test "reports only rows whose final slug differs, as {id, from, to}" do
      rows = [
        %{id: "a", slug: "acme", name: "Acme"},
        %{id: "b", slug: "Acme Corp", name: "Acme Corp"}
      ]

      assert [{_id, "Acme Corp", "acme-corp"}] = SlugBackfill.changes(rows)
    end

    test "empty when everything is already clean" do
      rows = [%{id: "a", slug: "acme", name: "Acme"}]
      assert SlugBackfill.changes(rows) == []
    end
  end
end
