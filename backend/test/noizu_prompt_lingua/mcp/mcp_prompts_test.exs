defmodule NoizuPromptLingua.MCPromptsTest do
  use NoizuPromptLingua.DataCase, async: true

  alias NoizuPromptLingua.MCPrompts
  alias NoizuPromptLingua.Schema.MCP.McpPromptVersion

  @org Ecto.UUID.generate()
  @proj Ecto.UUID.generate()

  defp base_attrs(overrides \\ %{}) do
    Map.merge(
      %{
        "slug" => "release-notes",
        "name" => "Release Notes",
        "description" => "Draft release notes",
        "arguments" => [%{"name" => "version", "description" => "Version", "required" => true}]
      },
      overrides
    )
  end

  test "changeset requires slug + name and normalizes slug" do
    {:ok, prompt} = MCPrompts.create(base_attrs(%{"slug" => "  Release-Notes "}))

    assert prompt.slug == "release-notes"
  end

  test "changeset rejects bad slug and non-list arguments" do
    assert {:error, %Ecto.Changeset{}} = MCPrompts.create(base_attrs(%{"slug" => "Bad Slug!"}))
    assert {:error, %Ecto.Changeset{}} = MCPrompts.create(base_attrs(%{"arguments" => "nope"}))
  end

  test "slug is unique" do
    {:ok, _} = MCPrompts.create(base_attrs())
    assert {:error, %Ecto.Changeset{}} = MCPrompts.create(base_attrs())
  end

  test "publish_version creates immutable versions and bumps active_version" do
    {:ok, prompt} = MCPrompts.create(base_attrs())

    assert {:ok, 1} = MCPrompts.publish_version(prompt, "v {{version}} shipped", "first")
    assert {:ok, 2} = MCPrompts.publish_version(prompt, "v {{version}} shipped (fixed)", "fix")

    prompt = MCPrompts.get!(prompt.id)
    assert prompt.active_version == 2

    versions = MCPrompts.versions(prompt)
    assert length(versions) == 2
    assert Enum.map(versions, & &1.version) == [2, 1]
    assert %McpPromptVersion{} = MCPrompts.version(prompt, 1)

    # version rows are immutable: re-publishing never mutates old bodies
    assert MCPrompts.version(prompt, 1).template == "v {{version}} shipped"
  end

  test "render substitutes args and enforces required arguments" do
    {:ok, prompt} = MCPrompts.create(base_attrs())
    {:ok, _} = MCPrompts.publish_version(prompt, "Release {{version}}: {{summary}}", nil)

    assert {:ok, "Release 1.2: bugs squashed"} =
             MCPrompts.render(prompt, %{"version" => "1.2", "summary" => "bugs squashed"})

    assert {:error, {:missing_arguments, ["version"]}} = MCPrompts.render(prompt, %{})
    assert {:error, {:missing_arguments, ["version"]}} = MCPrompts.render(prompt, nil)
  end

  test "render resolves a specific (non-active) version" do
    {:ok, prompt} = MCPrompts.create(base_attrs())
    {:ok, _} = MCPrompts.publish_version(prompt, "one {{version}}", nil)
    {:ok, _} = MCPrompts.publish_version(prompt, "two {{version}}", nil)
    prompt = MCPrompts.get!(prompt.id)

    assert {:ok, "one 9"} = MCPrompts.render(prompt, %{"version" => "9"}, 1)
    assert {:ok, "two 9"} = MCPrompts.render(prompt, %{"version" => "9"})
    assert {:error, :version_not_found} = MCPrompts.render(prompt, %{"version" => "9"}, 99)
  end

  test "effective/3 visibility: globals visible everywhere; scoped rows only for their scope" do
    {:ok, global} = MCPrompts.create(base_attrs(%{"slug" => "global-p"}))

    {:ok, org_prompt} =
      MCPrompts.create(base_attrs(%{"slug" => "org-p", "organization_id" => @org}))

    {:ok, proj_prompt} =
      MCPrompts.create(
        base_attrs(%{"slug" => "proj-p", "organization_id" => @org, "project_id" => @proj})
      )

    other_org = Ecto.UUID.generate()
    other_proj = Ecto.UUID.generate()

    assert global.id == MCPrompts.effective(global.slug, nil, nil).id
    assert global.id == MCPrompts.effective(global.slug, @org, @proj).id
    assert org_prompt.id == MCPrompts.effective(org_prompt.slug, @org, @proj).id
    assert nil == MCPrompts.effective(org_prompt.slug, other_org, nil)
    assert proj_prompt.id == MCPrompts.effective(proj_prompt.slug, @org, @proj).id
    assert nil == MCPrompts.effective(proj_prompt.slug, @org, other_proj)
  end

  test "update_prompt + delete_prompt by slug" do
    {:ok, prompt} = MCPrompts.create(base_attrs())

    assert {:ok, updated} = MCPrompts.update_prompt(prompt.slug, %{"description" => "updated"})
    assert updated.description == "updated"

    assert {:ok, _} = MCPrompts.delete_prompt(prompt.slug)
    assert nil == MCPrompts.get_by_slug(prompt.slug)
    assert {:error, :not_found} = MCPrompts.delete_prompt("missing-slug")
  end
end
