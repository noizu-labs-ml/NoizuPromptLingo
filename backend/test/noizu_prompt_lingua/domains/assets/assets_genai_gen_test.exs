defmodule NoizuPromptLingua.Domains.AssetsGenAIGenTest do
  @moduledoc """
  Asset generation via the genai media framework (GenAI.generate_media — ede43647).
  Covers the GenAIGenerator request-build/modality mapping (pure) and the full
  Assets.generate genai path (sync bytes -> artifact; async Job + error -> media-tool
  fallback), with the genai call + media-tool both stubbed via config (no network/binary).
  """
  use NoizuPromptLingua.DataCase

  alias NoizuPromptLingua.Domains.{Assets, Artifacts}
  alias NoizuPromptLingua.Domains.Assets.GenAIGenerator
  alias NoizuPromptLingua.Schema.AssetOutput

  @moduletag :db

  @png <<137, 80, 78, 71, 13, 10, 26, 10>>

  # Stub genai generator: returns bytes / a job / an error per the entry's title.
  defmodule StubGenAI do
    @behaviour NoizuPromptLingua.Domains.Assets.GenAIGenerator
    @impl true
    def generate(%{title: "job"}, _opts), do: {:ok, {:job, %{id: "task-1", __struct__: :job}}}
    def generate(%{title: "boom"}, _opts), do: {:error, :no_provider_for_modality}
    def generate(_entry, _opts), do: {:ok, <<137, 80, 78, 71, 13, 10, 26, 10>>, "image/png"}
  end

  # Media-tool fallback stub (writes a fake PNG).
  defmodule StubTool do
    @behaviour NoizuPromptLingua.Domains.Assets.MediaToolRunner
    @impl true
    def run(_p, tmp_dir, _o) do
      out = Path.join(tmp_dir, "fallback.png")
      File.write!(out, "FALLBACK")
      {:ok, %{output_path: out, mime: "image/png"}}
    end
  end

  setup do
    org_id = insert_org()

    on_exit(fn ->
      Application.delete_env(:noizu_prompt_lingua, :genai_media_generator)
      Application.delete_env(:noizu_prompt_lingua, :media_tool_runner)
    end)

    {:ok, org_id: org_id}
  end

  describe "GenAIGenerator (pure)" do
    test "media_type? only for binary-media types" do
      assert GenAIGenerator.media_type?("image")
      assert GenAIGenerator.media_type?("voice")
      assert GenAIGenerator.media_type?("music")
      assert GenAIGenerator.media_type?("video")
      refute GenAIGenerator.media_type?("svg")
      refute GenAIGenerator.media_type?("document")
    end

    test "modality maps types (and errors on non-media)" do
      assert {:ok, :image} = GenAIGenerator.modality("image")
      assert {:ok, :speech} = GenAIGenerator.modality("voice")
      assert {:ok, :music} = GenAIGenerator.modality("music")
      assert {:error, {:unsupported_asset_type, "svg"}} = GenAIGenerator.modality("svg")
    end

    test "build_request pulls prompt + atomized settings from the .media.prompt YAML" do
      entry = %{
        title: "Hero",
        prompt_yaml: "prompt:\n  text: a red fox\n  provider_options:\n    size: \"1024x1024\"\n",
        asset_type: "image"
      }

      req = GenAIGenerator.build_request(entry, :image, [])
      assert req.output == :image
      assert req.prompt == "a red fox"
      assert req.settings[:size] == "1024x1024"
      assert req.provider == nil
    end

    test "build_request falls back to the title when the YAML has no prompt text" do
      req =
        GenAIGenerator.build_request(
          %{title: "Fallback", prompt_yaml: "type: image\n"},
          :image,
          []
        )

      assert req.prompt == "Fallback"
    end
  end

  describe "Assets.generate genai path" do
    setup do
      Application.put_env(:noizu_prompt_lingua, :genai_media_generator, StubGenAI)
      Application.put_env(:noizu_prompt_lingua, :media_tool_runner, StubTool)
      :ok
    end

    test "sync bytes -> base64 image artifact + AssetOutput", %{org_id: org_id} do
      {:ok, entry} = create_image(org_id, "Hero")

      assert {:ok, %AssetOutput{} = output} = Assets.generate(entry.id, generator: :genai)
      {artifact, revision} = Artifacts.get(output.artifact_id)
      assert artifact.mime_type == "image/png"
      assert {:ok, @png} == Base.decode64(revision.content)
    end

    test "async Job falls back to the media-tool", %{org_id: org_id} do
      {:ok, entry} = create_image(org_id, "job")

      assert {:ok, %AssetOutput{} = output} = Assets.generate(entry.id, generator: :genai)
      {_artifact, revision} = Artifacts.get(output.artifact_id)
      assert revision.content == Base.encode64("FALLBACK")
    end

    test "genai error falls back to the media-tool", %{org_id: org_id} do
      {:ok, entry} = create_image(org_id, "boom")

      assert {:ok, %AssetOutput{}} = Assets.generate(entry.id, generator: :genai)
    end

    test "generator: :media_tool skips genai entirely", %{org_id: org_id} do
      {:ok, entry} = create_image(org_id, "Hero")

      assert {:ok, %AssetOutput{} = output} = Assets.generate(entry.id, generator: :media_tool)
      {_artifact, revision} = Artifacts.get(output.artifact_id)
      assert revision.content == Base.encode64("FALLBACK")
    end
  end

  defp create_image(org_id, title) do
    Assets.create(%{
      organization_id: org_id,
      slug: "genai-#{System.unique_integer([:positive])}",
      title: title,
      asset_type: "image",
      prompt_yaml: "prompt:\n  text: a hero image\n"
    })
  end

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["genaigen-#{System.unique_integer([:positive])}", "GenAI Gen Org"]
      )

    Ecto.UUID.load!(raw)
  end
end
