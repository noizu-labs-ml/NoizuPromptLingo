defmodule NoizuPromptLingua.Schema.MCPToolSet.SlugifyTest do
  @moduledoc """
  Pins the probe item-12 finding (fix/error-family B7): a raw messy slug like
  "Bad Slug!" is slugified by the create changeset (derive_slug →
  SlugBackfill.slugify), never stored verbatim; an absent slug falls back to
  the slugified display_name.
  """

  use NoizuPromptLingua.DataCase

  alias NoizuPromptLingua.Schema.MCPToolSet

  test "'Bad Slug!' is slugified to 'bad-slug' on create" do
    changeset =
      MCPToolSet.changeset(%MCPToolSet{}, %{
        organization_id: Ecto.UUID.generate(),
        slug: "Bad Slug!",
        display_name: "Bad Slug!"
      })

    assert changeset.valid?
    assert Ecto.Changeset.get_field(changeset, :slug) == "bad-slug"
  end

  test "absent slug falls back to the slugified display_name" do
    changeset =
      MCPToolSet.changeset(%MCPToolSet{}, %{
        organization_id: Ecto.UUID.generate(),
        display_name: "My Cool Tools"
      })

    assert changeset.valid?
    assert Ecto.Changeset.get_field(changeset, :slug) == "my-cool-tools"
  end
end
