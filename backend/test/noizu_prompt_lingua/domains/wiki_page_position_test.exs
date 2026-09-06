defmodule NoizuPromptLingua.Domains.Wiki.PagePositionTest do
  @moduledoc """
  Regression (fix/error-family B8a, stage log c6295): `POST .../wiki/spaces/:sid/pages`
  without a `position` raised Postgrex not_null_violation on wiki_pages.position → 500.
  create_page now appends by default: max(position) + 1 within the space (0 for the
  first page); an explicit position is respected.
  """

  use NoizuPromptLingua.DataCase

  alias NoizuPromptLingua.Domains.Wiki

  setup do
    org_id = Ecto.UUID.generate()

    {:ok, space} = Wiki.create_space(%{organization_id: org_id, name: "Probe Space"})

    %{org_id: org_id, space_id: space.id}
  end

  test "create without position appends (0, then 1) instead of raising not-null violation", %{
    space_id: space_id
  } do
    {:ok, first} =
      Wiki.create_page(%{space_id: space_id, title: "Probe Page", content: "hello"})

    assert first.position == 0

    {:ok, second} = Wiki.create_page(%{space_id: space_id, title: "Second Page"})
    assert second.position == 1
  end

  test "an explicit position is respected", %{space_id: space_id} do
    {:ok, page} =
      Wiki.create_page(%{space_id: space_id, title: "Pinned", position: 5})

    assert page.position == 5
  end

  test "pages order by position in the listing", %{space_id: space_id} do
    {:ok, _} = Wiki.create_page(%{space_id: space_id, title: "Alpha"})
    {:ok, _} = Wiki.create_page(%{space_id: space_id, title: "Beta"})

    titles = Enum.map(Wiki.list_pages(space_id), & &1.title)
    assert titles == ["Alpha", "Beta"]
  end
end
