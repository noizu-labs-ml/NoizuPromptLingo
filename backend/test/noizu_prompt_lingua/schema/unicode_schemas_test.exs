defmodule NoizuPromptLingua.Schema.UnicodeSchemasTest do
  use NoizuPromptLingua.DataCase, async: true

  @moduledoc """
  Unicode codex schemas: Element (codepoint parsing, slug normalization,
  scope/visibility matrices) and SpecialUsage (scope matrix), plus
  ElementRelation's relation-type guard.
  """

  alias NoizuPromptLingua.Schema.Unicode.Element
  alias NoizuPromptLingua.Schema.Unicode.ElementRelation
  alias NoizuPromptLingua.Schema.Unicode.SpecialUsage

  @org Ecto.UUID.generate()
  @project Ecto.UUID.generate()

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
  end

  # ── parse_codepoint_int ──────────────────────────────────────────

  test "parse_codepoint_int handles all notations" do
    assert Element.parse_codepoint_int("U+0041") == 0x41
    # PINNED: only the uppercase "U+" prefix is recognized — lowercase u+ is
    # not parsed (falls into the bare-hex branch and fails there)
    assert Element.parse_codepoint_int("u+0041") == nil
    assert Element.parse_codepoint_int("\\u0041") == 0x41
    assert Element.parse_codepoint_int("\\x41") == 0x41
    assert Element.parse_codepoint_int("0041") == 0x41
    assert Element.parse_codepoint_int("U+0041 U+0042") == 0x41
    assert Element.parse_codepoint_int("10FFFF") == 0x10FFFF
    assert Element.parse_codepoint_int(nil) == nil
    assert Element.parse_codepoint_int("") == nil
    assert Element.parse_codepoint_int("zzzz") == nil
    assert Element.parse_codepoint_int("110000") == nil
    assert Element.parse_codepoint_int(-1) == nil
    assert Element.parse_codepoint_int(42) == nil
  end

  # ── Element changesets ───────────────────────────────────────────

  test "valid global element with derived codepoint_int" do
    cs =
      Element.changeset(%Element{}, %{
        slug: "  Bulb ",
        name: "Bulb",
        title: "Light Bulb",
        codepoint: "U+1F4A1"
      })

    assert cs.valid?
    assert get_field(cs, :slug) == "bulb"
    assert get_field(cs, :codepoint_int) == 0x1F4A1
    assert get_field(cs, :scope) == "global"
    assert get_field(cs, :visibility) == "glyph"

    # explicit codepoint_int wins (no re-derivation)
    cs2 =
      Element.changeset(%Element{}, %{
        slug: "s2",
        name: "n",
        title: "t",
        codepoint: "U+0041",
        codepoint_int: 99
      })

    assert cs2.valid?
    assert get_field(cs2, :codepoint_int) == 99
  end

  test "element required fields and inclusion guards" do
    cs = Element.changeset(%Element{}, %{})
    refute cs.valid?
    errs = errors_on(cs)
    assert errs.slug
    assert errs.name
    assert errs.title

    cs2 =
      Element.changeset(%Element{}, %{slug: "s", name: "n", title: "t", scope: "galactic"})

    refute cs2.valid?
    assert errors_on(cs2).scope

    cs3 =
      Element.changeset(%Element{}, %{slug: "s", name: "n", title: "t", visibility: "hidden"})

    refute cs3.valid?
    assert errors_on(cs3).visibility
  end

  test "element scope matrix" do
    base = %{slug: "s", name: "n", title: "t"}

    assert Element.changeset(%Element{}, base).valid?

    assert Element.changeset(
             %Element{},
             Map.merge(base, %{scope: "organization", organization_id: @org})
           ).valid?

    assert Element.changeset(
             %Element{},
             Map.merge(base, %{scope: "project", organization_id: @org, project_id: @project})
           ).valid?

    cs = Element.changeset(%Element{}, Map.merge(base, %{organization_id: @org}))
    assert errors_on(cs).scope

    cs =
      Element.changeset(
        %Element{},
        Map.merge(base, %{scope: "organization", project_id: @project})
      )

    # org missing is reported first; project_id surfaces only when org present
    assert errors_on(cs).organization_id

    cs = Element.changeset(%Element{}, Map.merge(base, %{scope: "organization"}))
    assert errors_on(cs).organization_id

    cs = Element.changeset(%Element{}, Map.merge(base, %{scope: "project"}))
    errs = errors_on(cs)
    assert errs.organization_id
    assert errs.project_id

    cs = Element.changeset(%Element{}, Map.merge(base, %{scope: "project", project_id: @project}))
    assert errors_on(cs).organization_id

    cs =
      Element.changeset(%Element{}, Map.merge(base, %{scope: "project", organization_id: @org}))

    assert errors_on(cs).project_id
  end

  test "element scope/visibility accessors" do
    assert "global" in Element.scopes()
    assert "invisible" in Element.visibilities()
  end

  # ── SpecialUsage ─────────────────────────────────────────────────

  test "special usage valid global + scope matrix" do
    base = %{slug: " Variation Selector ", name: "VS", title: "Variation Selector"}

    cs = SpecialUsage.changeset(%SpecialUsage{}, base)
    assert cs.valid?
    assert get_field(cs, :slug) == "variation selector"

    assert SpecialUsage.changeset(
             %SpecialUsage{},
             Map.merge(base, %{scope: "organization", organization_id: @org})
           ).valid?

    assert SpecialUsage.changeset(
             %SpecialUsage{},
             Map.merge(base, %{scope: "project", organization_id: @org, project_id: @project})
           ).valid?

    cs = SpecialUsage.changeset(%SpecialUsage{}, Map.merge(base, %{organization_id: @org}))
    assert errors_on(cs).scope

    assert "organization" in SpecialUsage.scopes()
  end

  test "special usage required fields" do
    cs = SpecialUsage.changeset(%SpecialUsage{}, %{})
    refute cs.valid?
    errs = errors_on(cs)
    assert errs.slug
    assert errs.name
    assert errs.title
  end

  # ── ElementRelation ──────────────────────────────────────────────

  test "element relation types enforced" do
    base = %{source_element_id: Ecto.UUID.generate(), target_element_id: Ecto.UUID.generate()}

    cs =
      ElementRelation.changeset(
        %ElementRelation{},
        Map.merge(base, %{relation_type: "confusable-with"})
      )

    assert cs.valid?

    cs2 =
      ElementRelation.changeset(
        %ElementRelation{},
        Map.merge(base, %{relation_type: "enemies-with"})
      )

    refute cs2.valid?

    assert "composes-with" in ElementRelation.relation_types()

    cs3 = ElementRelation.changeset(%ElementRelation{}, %{})
    refute cs3.valid?
    assert errors_on(cs3).relation_type
  end
end
