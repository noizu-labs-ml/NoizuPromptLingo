defmodule NoizuPromptLingua.Domains.Browser.CapturesEnumTest do
  @moduledoc """
  Regression (fix/error-family B8b, stage log c6322): `GET .../browser/captures`
  raised Postgrex 22P02 → 500 because media.owner_type is the PG enum
  `resource_type_enum`, which lacked the browser capture values. Migration
  20260902000000 (+ Liquibase 084 twin) adds 'browser_screenshot' and
  'browser_video'; captures listing and registration now work.
  """

  use NoizuPromptLingua.DataCase

  alias NoizuPromptLingua.Domains.Browser
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Media.Asset

  test "list_captures/1 answers [] for an org with no captures (was a 500)" do
    org_id = Ecto.UUID.generate()
    assert Browser.list_captures(org_id) == []
  end

  test "a browser_screenshot asset registers and is listed" do
    org_id = Ecto.UUID.generate()

    {:ok, asset} =
      Repo.insert(
        %Asset{}
        |> Asset.changeset(%{
          media_type: :image,
          file_type: :png,
          file: "browser/#{org_id}/#{Ecto.UUID.generate()}.png",
          short_id: "cap#{System.unique_integer([:positive])}ab",
          visibility: "org",
          owner_type: "browser_screenshot",
          owner_id: org_id,
          settings: %{}
        })
      )

    captures = Browser.list_captures(org_id)
    assert length(captures) == 1
    assert hd(captures).id == asset.id
  end

  test "browser_video assets are listed; other orgs' captures are not" do
    org_id = Ecto.UUID.generate()

    {:ok, _} =
      Repo.insert(
        %Asset{}
        |> Asset.changeset(%{
          media_type: :video,
          file_type: :webm,
          file: "browser/#{org_id}/#{Ecto.UUID.generate()}.webm",
          short_id: "vid#{System.unique_integer([:positive])}ab",
          visibility: "org",
          owner_type: "browser_video",
          owner_id: org_id,
          settings: %{}
        })
      )

    assert length(Browser.list_captures(org_id)) == 1
    assert Browser.list_captures(Ecto.UUID.generate()) == []
  end
end
