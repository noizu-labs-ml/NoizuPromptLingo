defmodule NoizuPromptLingua.Domains.AssetsMcpToolsTest do
  @moduledoc "Repro for c3c88d01 — Asset.Get + Asset.Publish MCP tools throwing."
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.Domains.Assets
  alias NoizuPromptLingua.Domains.Assets.Tools.{AssetGet, AssetPublish}

  setup do
    org_id = insert_org()

    {:ok, entry} =
      Assets.create(%{
        organization_id: org_id,
        slug: "asset-#{System.unique_integer([:positive])}",
        title: "Test Asset",
        asset_type: "document",
        prompt_yaml: "name: example"
      })

    {:ok, org_id: org_id, entry: entry}
  end

  test "Get on entry with ZERO outputs", %{entry: entry} do
    assert {:ok, %{outputs: []}} = AssetGet.call(%{asset: entry.id}, %{})
  end

  test "Get on entry with an active + accepted output", %{entry: entry} do
    {:ok, out} = Assets.generate(entry.id, llm_generate: false)
    {:ok, _} = Assets.accept_output(out.id)
    {:ok, _} = Assets.set_active(entry.id, out.id)
    assert {:ok, %{}} = AssetGet.call(%{asset: entry.id}, %{})
  end

  test "Get by SLUG (tool advertises slug or uuid) — no longer a CastError", %{entry: entry} do
    assert {:ok, %{slug: slug}} = AssetGet.call(%{asset: entry.slug}, %{})
    assert slug == entry.slug
  end

  test "Get unknown asset -> {:error, not found}, not a crash", %{} do
    assert {:error, msg} = AssetGet.call(%{asset: "no-such-asset-slug"}, %{})
    assert msg =~ "not found"
  end

  test "Publish with an active + accepted output", %{entry: entry} do
    {:ok, out} = Assets.generate(entry.id, llm_generate: false)
    {:ok, _} = Assets.accept_output(out.id)
    {:ok, _} = Assets.set_active(entry.id, out.id)
    assert {:ok, %{status: "published"}} = AssetPublish.call(%{asset: entry.id}, %{})
  end

  test "Publish by SLUG resolves (no CastError)", %{entry: entry} do
    assert {:ok, %{status: "published"}} = AssetPublish.call(%{asset: entry.slug}, %{})
  end

  test "Publish unknown asset -> {:error, not found}, not a crash", %{} do
    assert {:error, "Asset not found"} = AssetPublish.call(%{asset: "no-such-asset-slug"}, %{})
  end

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["assettest-#{System.unique_integer([:positive])}", "Asset Test Org"]
      )

    Ecto.UUID.load!(raw)
  end
end
