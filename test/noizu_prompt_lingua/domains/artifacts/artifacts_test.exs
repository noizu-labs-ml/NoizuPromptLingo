defmodule NoizuPromptLingua.Domains.ArtifactsTest do
  use NoizuPromptLingua.DataCase, async: true

  alias NoizuPromptLingua.Domains.Artifacts

  defp create_artifact(attrs \\ %{}) do
    defaults = %{kind: "document", title: "Test Doc", content: "# Hello"}
    Artifacts.create(Map.merge(defaults, attrs))
  end

  describe "create/1" do
    test "creates artifact with initial revision" do
      assert {:ok, artifact} = create_artifact()
      assert artifact.kind == "document"
      assert artifact.title == "Test Doc"
      assert length(artifact.revisions) == 1
      assert hd(artifact.revisions).content == "# Hello"
      assert hd(artifact.revisions).revision_number == 1
    end

    test "creates with mime_type" do
      assert {:ok, artifact} = create_artifact(%{mime_type: "text/markdown"})
      assert artifact.mime_type == "text/markdown"
    end

    test "validates kind" do
      assert {:error, _} = Artifacts.create(%{kind: "invalid", title: "X", content: "Y"})
    end

    test "requires kind and title" do
      assert {:error, _} = Artifacts.create(%{content: "Y"})
    end

    test "accepts all valid kinds" do
      for kind <- ~w(code document image wiki config binary) do
        assert {:ok, _} = create_artifact(%{kind: kind, title: "#{kind} artifact"})
      end
    end
  end

  describe "get/2" do
    test "returns artifact with latest revision" do
      {:ok, artifact} = create_artifact()
      {a, rev} = Artifacts.get(artifact.id)
      assert a.id == artifact.id
      assert rev.revision_number == 1
    end

    test "returns specific revision" do
      {:ok, artifact} = create_artifact()
      {:ok, rev2} = Artifacts.add_revision(artifact.id, "v2 content", "update")
      {_, rev} = Artifacts.get(artifact.id, rev2.id)
      assert rev.revision_number == 2
    end

    test "returns nil for missing artifact" do
      assert is_nil(Artifacts.get(Ecto.UUID.generate()))
    end
  end

  describe "list/1" do
    test "returns artifacts" do
      {:ok, _} = create_artifact()
      assert length(Artifacts.list()) >= 1
    end

    test "filters by kind" do
      {:ok, _} = create_artifact(%{kind: "code", title: "Code"})
      {:ok, _} = create_artifact(%{kind: "image", title: "Image"})

      code_only = Artifacts.list(kind: "code")
      assert Enum.all?(code_only, &(&1.kind == "code"))
    end

    test "searches by title" do
      {:ok, _} = create_artifact(%{title: "UniqueSearchTerm123"})
      results = Artifacts.list(search: "UniqueSearchTerm")
      assert length(results) >= 1
      assert hd(results).title =~ "UniqueSearchTerm"
    end

    test "respects limit and offset" do
      for i <- 1..5, do: create_artifact(%{title: "Art #{i}"})
      page = Artifacts.list(limit: 2, offset: 0)
      assert length(page) == 2
    end
  end

  describe "add_revision/3" do
    test "appends a new revision" do
      {:ok, artifact} = create_artifact()
      assert {:ok, rev} = Artifacts.add_revision(artifact.id, "v2", "fix typo")
      assert rev.revision_number == 2
      assert rev.content == "v2"
      assert rev.note == "fix typo"
    end

    test "auto-increments revision number" do
      {:ok, artifact} = create_artifact()
      {:ok, _} = Artifacts.add_revision(artifact.id, "v2")
      {:ok, rev3} = Artifacts.add_revision(artifact.id, "v3")
      assert rev3.revision_number == 3
    end

    test "get returns latest after adding revision" do
      {:ok, artifact} = create_artifact()
      {:ok, _} = Artifacts.add_revision(artifact.id, "updated content")
      {_, rev} = Artifacts.get(artifact.id)
      assert rev.content == "updated content"
      assert rev.revision_number == 2
    end
  end

  describe "list_revisions/2" do
    test "returns revisions newest first" do
      {:ok, artifact} = create_artifact()
      Artifacts.add_revision(artifact.id, "v2")
      Artifacts.add_revision(artifact.id, "v3")

      revisions = Artifacts.list_revisions(artifact.id)
      assert length(revisions) == 3
      assert hd(revisions).revision_number == 3
      assert List.last(revisions).revision_number == 1
    end

    test "respects limit" do
      {:ok, artifact} = create_artifact()
      for _ <- 1..5, do: Artifacts.add_revision(artifact.id, "content")
      revisions = Artifacts.list_revisions(artifact.id, limit: 2)
      assert length(revisions) == 2
    end

    test "empty for missing artifact" do
      assert Artifacts.list_revisions(Ecto.UUID.generate()) == []
    end
  end

  describe "count_by_kind/0" do
    test "returns counts" do
      {:ok, _} = create_artifact(%{kind: "code"})
      {:ok, _} = create_artifact(%{kind: "code"})
      {:ok, _} = create_artifact(%{kind: "wiki"})

      counts = Artifacts.count_by_kind()
      assert counts["code"] >= 2
      assert counts["wiki"] >= 1
    end
  end
end
