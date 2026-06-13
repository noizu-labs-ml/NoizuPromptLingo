defmodule NoizuPromptLingua.Domains.AssetsTest do
  use NoizuPromptLingua.DataCase, async: true

  alias NoizuPromptLingua.Domains.{Assets, Projects}

  @sample_yaml """
  schema: "0.4"
  type: image
  quality: medium
  prompt:
    text: "A futuristic cityscape at sunset"
  output:
    formats:
      - format: png
    dimensions:
      width: 1024
      height: 1024
  """

  defp create_project(slug \\ nil) do
    slug = slug || "proj-#{System.unique_integer([:positive])}"
    {:ok, project} = Projects.create(%{name: "Test Project", slug: slug})
    project
  end

  defp create_entry(attrs \\ %{}) do
    project = attrs[:_project] || create_project()
    defaults = %{slug: "asset-#{System.unique_integer([:positive])}", title: "Test Asset",
                 asset_type: "image", prompt_yaml: @sample_yaml, project_id: project.id}
    Assets.create(Map.merge(defaults, Map.drop(attrs, [:_project])))
  end

  describe "entry CRUD" do
    test "create with prompt YAML" do
      assert {:ok, entry} = create_entry(%{slug: "hero-img", title: "Hero Image"})
      assert entry.slug == "hero-img"
      assert entry.asset_type == "image"
      assert entry.status == "draft"
      assert entry.prompt_yaml =~ "futuristic"
      assert entry.project_id
    end

    test "create requires project_id" do
      result = Assets.create(%{slug: "orphan", title: "Orphan", asset_type: "image", prompt_yaml: @sample_yaml})
      assert {:error, _} = result
    end

    test "create logs history" do
      {:ok, entry} = create_entry(actor: "alice")
      history = Assets.list_history(entry.id)
      assert length(history) >= 1
      assert hd(history).action == "created"
    end

    test "unique slug scoped to project" do
      project = create_project()
      {:ok, _} = create_entry(%{slug: "dupe-asset", _project: project})
      assert {:error, _} = create_entry(%{slug: "dupe-asset", _project: project})
    end

    test "same slug allowed in different projects" do
      p1 = create_project("proj-a")
      p2 = create_project("proj-b")
      assert {:ok, _} = create_entry(%{slug: "shared-slug", _project: p1})
      assert {:ok, _} = create_entry(%{slug: "shared-slug", _project: p2})
    end

    test "get by slug and id" do
      {:ok, entry} = create_entry(%{slug: "find-asset"})
      assert Assets.get("find-asset").id == entry.id
      assert Assets.get(entry.id).id == entry.id
    end

    test "get_by_project_slug" do
      project = create_project("my-project")
      {:ok, entry} = create_entry(%{slug: "my-asset", _project: project})
      found = Assets.get_by_project_slug("my-project", "my-asset")
      assert found.id == entry.id
    end

    test "get_by_project_slug returns nil for wrong project" do
      project = create_project("right-proj")
      create_project("wrong-proj")
      {:ok, _} = create_entry(%{slug: "scoped-asset", _project: project})
      assert Assets.get_by_project_slug("wrong-proj", "scoped-asset") == nil
    end

    test "update prompt and tags" do
      {:ok, entry} = create_entry()
      {:ok, updated} = Assets.update(entry.slug, %{title: "New Title", tags: ["hero"]})
      assert updated.title == "New Title"
      assert updated.tags == ["hero"]
    end

    test "list with filters" do
      project = create_project()
      {:ok, _} = create_entry(%{asset_type: "image", tags: ["brand"], _project: project})
      {:ok, _} = create_entry(%{asset_type: "video", _project: project})

      images = Assets.list(asset_type: "image")
      assert Enum.all?(images, &(&1.asset_type == "image"))

      tagged = Assets.list(tag: "brand")
      assert length(tagged) >= 1
    end

    test "publish and archive" do
      {:ok, entry} = create_entry()
      {:ok, pub} = Assets.publish(entry.slug)
      assert pub.status == "published"

      {:ok, arch} = Assets.archive(entry.slug)
      assert arch.status == "archived"
    end

    test "count_by_type and count_by_status" do
      {:ok, _} = create_entry(%{asset_type: "image"})
      assert Assets.count_by_type()["image"] >= 1
      assert Assets.count_by_status()["draft"] >= 1
    end
  end

  describe "outputs" do
    test "generate creates output with artifact" do
      {:ok, entry} = create_entry()
      {:ok, output} = Assets.generate(entry.id)
      assert output.variant_number == 1
      assert output.artifact_id
      assert output.entry_id == entry.id
    end

    test "generated artifact inherits project_id" do
      {:ok, entry} = create_entry()
      {:ok, output} = Assets.generate(entry.id)
      {artifact, _rev} = NoizuPromptLingua.Domains.Artifacts.get(output.artifact_id)
      assert artifact.project_id == entry.project_id
    end

    test "generate increments variant number" do
      {:ok, entry} = create_entry()
      {:ok, o1} = Assets.generate(entry.id)
      {:ok, o2} = Assets.generate(entry.id)
      assert o1.variant_number == 1
      assert o2.variant_number == 2
    end

    test "list_outputs returns variants" do
      {:ok, entry} = create_entry()
      Assets.generate(entry.id)
      Assets.generate(entry.id)
      outputs = Assets.list_outputs(entry.id)
      assert length(outputs) == 2
    end

    test "accept and reject" do
      {:ok, entry} = create_entry()
      {:ok, output} = Assets.generate(entry.id)

      {:ok, accepted} = Assets.accept_output(output.id)
      assert accepted.status == "accepted"

      {:ok, rejected} = Assets.reject_output(output.id)
      assert rejected.status == "rejected"
    end

    test "set_active" do
      {:ok, entry} = create_entry()
      {:ok, output} = Assets.generate(entry.id)
      {:ok, updated} = Assets.set_active(entry.id, output.id)
      assert updated.active_output_id == output.id
    end
  end

  describe "history" do
    test "tracks lifecycle events" do
      {:ok, entry} = create_entry()
      Assets.generate(entry.id, actor: "bot")
      Assets.publish(entry.slug, actor: "alice")

      history = Assets.list_history(entry.id)
      actions = Enum.map(history, & &1.action)
      assert "created" in actions
      assert "generated" in actions
      assert "published" in actions
    end
  end
end
