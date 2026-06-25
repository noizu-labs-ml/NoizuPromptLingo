defmodule NoizuPromptLingua.Domains.AssetsGenerateTest do
  @moduledoc """
  Asset generation graceful-failure — ticket 2989d130. A missing provider key or a
  failed/raising generation returns {:error, :generation_unavailable} (never a
  MatchError -> 500), and the transaction rolls back cleanly. Explicit content or
  llm_generate:false still succeed without touching the LLM.
  """
  use NoizuPromptLingua.DataCase

  alias NoizuPromptLingua.Domains.Assets
  alias NoizuPromptLingua.Schema.AssetOutput

  @moduletag :db

  setup do
    org_id = insert_org()

    {:ok, entry} =
      Assets.create(%{
        organization_id: org_id,
        slug: "asset-#{System.unique_integer([:positive])}",
        title: "Test Asset",
        asset_type: "document",
        prompt_yaml: "name: example\nbody: hi"
      })

    {:ok, org_id: org_id, entry_id: entry.id}
  end

  test "llm_generate:false materializes a placeholder output (no LLM, no crash)", ctx do
    assert {:ok, %AssetOutput{} = output} = Assets.generate(ctx.entry_id, llm_generate: false)
    assert output.artifact_id
    assert output.variant_number == 1
  end

  test "explicit content succeeds without touching the LLM", ctx do
    assert {:ok, %AssetOutput{}} = Assets.generate(ctx.entry_id, content: "rendered content")
  end

  test "no provider key -> {:error, :generation_unavailable}, never a crash", ctx do
    prev = System.get_env("OPENAI_API_KEY")
    System.put_env("OPENAI_API_KEY", "")
    on_exit(fn ->
      if prev, do: System.put_env("OPENAI_API_KEY", prev), else: System.delete_env("OPENAI_API_KEY")
    end)

    assert {:error, :generation_unavailable} = Assets.generate(ctx.entry_id, provider: "openai")
    # transaction rolled back: no output row persisted
    assert Assets.list_outputs(ctx.entry_id) == []
  end

  test "unknown entry -> {:error, :not_found}" do
    assert {:error, :not_found} = Assets.generate(Ecto.UUID.generate())
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
