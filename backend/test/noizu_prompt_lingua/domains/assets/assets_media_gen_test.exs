defmodule NoizuPromptLingua.Domains.AssetsMediaGenTest do
  @moduledoc """
  Interim real asset generation via the media-tool shell-out (e146ff64). The binary
  invocation is mocked via the swappable MediaToolRunner config, so this exercises the
  full Assets.generate path (temp prompt -> runner -> read bytes -> base64/raw -> artifact
  + AssetOutput, rollback-safe) WITHOUT the real binary.
  """
  use NoizuPromptLingua.DataCase

  alias NoizuPromptLingua.Domains.{Assets, Artifacts}
  alias NoizuPromptLingua.Schema.AssetOutput

  @moduletag :db

  @png <<137, 80, 78, 71, 13, 10, 26, 10>>

  # Stub runner: writes a fake PNG to the temp dir and reports it.
  defmodule StubOK do
    @behaviour NoizuPromptLingua.Domains.Assets.MediaToolRunner
    @impl true
    def run(_prompt_path, tmp_dir, _opts) do
      out = Path.join(tmp_dir, "out.png")
      File.write!(out, <<137, 80, 78, 71, 13, 10, 26, 10>>)
      {:ok, %{output_path: out, mime: "image/png"}}
    end
  end

  defmodule StubFail do
    @behaviour NoizuPromptLingua.Domains.Assets.MediaToolRunner
    @impl true
    def run(_p, _t, _o), do: {:error, {:exit, 1}}
  end

  setup do
    org_id = insert_org()

    {:ok, entry} =
      Assets.create(%{
        organization_id: org_id,
        slug: "asset-#{System.unique_integer([:positive])}",
        title: "Hero",
        asset_type: "image",
        prompt_yaml: "schema: \"0.4\"\noutput:\n  formats:\n    - format: png\n"
      })

    {:ok, org_id: org_id, entry_id: entry.id}
  end

  defp with_runner(mod) do
    Application.put_env(:noizu_prompt_lingua, :media_tool_runner, mod)
    on_exit(fn -> Application.delete_env(:noizu_prompt_lingua, :media_tool_runner) end)
  end

  test "real gen produces a base64 image artifact + AssetOutput", ctx do
    with_runner(StubOK)

    assert {:ok, %AssetOutput{} = output} = Assets.generate(ctx.entry_id)
    assert output.variant_number == 1

    {artifact, revision} = Artifacts.get(output.artifact_id)
    assert artifact.mime_type == "image/png"
    assert {:ok, @png} == Base.decode64(revision.content)
  end

  test "runner failure -> {:error, :generation_unavailable}, rollback leaves no output", ctx do
    with_runner(StubFail)

    assert {:error, :generation_unavailable} = Assets.generate(ctx.entry_id)
    assert Assets.list_outputs(ctx.entry_id) == []
  end

  test "llm_generate:false still materializes the placeholder (no binary)", ctx do
    assert {:ok, %AssetOutput{}} = Assets.generate(ctx.entry_id, llm_generate: false)
  end

  test "explicit content bypasses the binary", ctx do
    assert {:ok, %AssetOutput{} = output} = Assets.generate(ctx.entry_id, content: "inline")
    {_artifact, revision} = Artifacts.get(output.artifact_id)
    assert revision.content == "inline"
  end

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["mediagen-#{System.unique_integer([:positive])}", "Media Gen Org"]
      )

    Ecto.UUID.load!(raw)
  end
end
