defmodule NoizuPromptLingua.Domains.InstructionsTest do
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.Instructions
  alias NoizuPromptLingua.Schema.InstructionVersion
  alias NoizuPromptLingua.Schema.Organizations.Organization

  defp org! do
    suffix = Ecto.UUID.generate() |> binary_part(0, 8)

    Repo.insert!(%Organization{
      name: "Instr Org #{suffix}",
      slug: "instr-org-#{suffix}"
    })
  end

  defp instruction!(org, attrs \\ %{}, opts \\ []) do
    slug = Ecto.UUID.generate() |> binary_part(0, 8)

    attrs =
      Map.merge(
        %{organization_id: org.id, slug: "instr-#{slug}", title: "Instruction #{slug}"},
        attrs
      )

    opts = Keyword.put_new(opts, :body, "default body")
    {:ok, instruction} = Instructions.create(attrs, opts)
    instruction
  end

  # ── create/2 ──────────────────────────────────────────────────────────────

  describe "create/2" do
    test "creates the instruction plus its v1 body version" do
      org = org!()

      {:ok, instruction} =
        Instructions.create(
          %{organization_id: org.id, slug: "hello-world", title: "Hello World"},
          body: "say hi to {{name}}"
        )

      assert instruction.active_version == 1
      assert instruction.slug == "hello-world"

      assert %InstructionVersion{version: 1, body: "say hi to {{name}}"} =
               Instructions.get_version(instruction.id)

      assert [%InstructionVersion{version: 1}] = Instructions.list_versions(instruction.id)
    end

    test "body can be supplied via attrs (atom or string keyed)" do
      org = org!()

      {:ok, a} =
        Instructions.create(%{
          organization_id: org.id,
          slug: "body-atom",
          title: "T",
          body: "atom body"
        })

      {:ok, b} =
        Instructions.create(
          %{"organization_id" => org.id, "slug" => "body-string", "title" => "T", "body" => "string body"},
          []
        )

      assert Instructions.get_version(a.id).body == "atom body"
      assert Instructions.get_version(b.id).body == "string body"
    end

    test "invalid attrs return {:error, changeset} without persisting" do
      org = org!()

      assert {:error, %Ecto.Changeset{}} =
               Instructions.create(%{organization_id: org.id, slug: "no-title"}, body: "b")

      assert Instructions.resolve(org.id, "no-title") == nil
    end

    test "duplicate org+slug is rejected; the same slug in another org is fine" do
      org_a = org!()
      org_b = org!()
      instruction!(org_a, %{slug: "dup-slug"})

      assert {:error, %Ecto.Changeset{}} =
               Instructions.create(
                 %{organization_id: org_a.id, slug: "dup-slug", title: "Dup"},
                 body: "b"
               )

      assert {:ok, _} =
               Instructions.create(
                 %{organization_id: org_b.id, slug: "dup-slug", title: "Dup"},
                 body: "b"
               )
    end

    test "creating without a body returns a changeset error instead of crashing" do
      # Regression: body defaulted to "" which fails validate_required on the
      # version changeset; the unmatched {:ok, _v} raise used to blow up the
      # transaction with a MatchError. The fix rolls back like the instruction
      # insert branch does.
      org = org!()

      assert {:error, %Ecto.Changeset{}} =
               Instructions.create(%{organization_id: org.id, slug: "no-body", title: "NB"})

      assert Instructions.resolve(org.id, "no-body") == nil
    end
  end

  # ── get/1 & resolve/2 ─────────────────────────────────────────────────────

  describe "get/1 and resolve/2" do
    test "get returns the row or nil" do
      org = org!()
      instruction = instruction!(org)

      assert Instructions.get(instruction.id).id == instruction.id
      assert Instructions.get(Ecto.UUID.generate()) == nil
    end

    test "resolve accepts an id, a slug, or a non-uuid handle" do
      org = org!()
      instruction = instruction!(org, %{slug: "find-me"})

      assert Instructions.resolve(org.id, instruction.id).id == instruction.id
      assert Instructions.resolve(org.id, "find-me").id == instruction.id
      assert Instructions.resolve(org.id, Ecto.UUID.generate()) == nil
    end

    test "resolve is org-scoped for slug lookups" do
      org_a = org!()
      org_b = org!()
      instruction!(org_a, %{slug: "scoped-slug"})

      assert Instructions.resolve(org_b.id, "scoped-slug") == nil
      assert Instructions.resolve(org_a.id, "scoped-slug")
    end
  end

  # ── versions ──────────────────────────────────────────────────────────────

  describe "get_version/2 and list_versions/1" do
    test "nil version resolves through active_version; explicit version is honored" do
      org = org!()
      instruction = instruction!(org, %{}, body: "v1 body")
      {:ok, _} = Instructions.update(instruction.id, %{}, body: "v2 body")

      assert Instructions.get_version(instruction.id).body == "v2 body"
      assert Instructions.get_version(instruction.id, 1).body == "v1 body"
      assert Instructions.get_version(instruction.id, 99) == nil
    end

    test "missing instruction has no versions" do
      assert Instructions.get_version(Ecto.UUID.generate()) == nil
      assert Instructions.list_versions(Ecto.UUID.generate()) == []
    end

    test "list_versions returns versions newest-first" do
      org = org!()
      instruction = instruction!(org, %{}, body: "v1 body")
      {:ok, _} = Instructions.update(instruction.id, %{}, body: "v2 body")

      assert [%InstructionVersion{version: 2}, %InstructionVersion{version: 1}] =
               Instructions.list_versions(instruction.id)
    end
  end

  # ── update/3 ──────────────────────────────────────────────────────────────

  describe "update/3" do
    test "metadata-only update does not create a version" do
      org = org!()
      instruction = instruction!(org)

      assert {:ok, updated} = Instructions.update(instruction.id, %{title: "Renamed"})

      assert updated.title == "Renamed"
      assert updated.active_version == 1
      assert [%InstructionVersion{version: 1}] = Instructions.list_versions(instruction.id)
    end

    test "supplying a body creates the next active version" do
      org = org!()
      instruction = instruction!(org, %{}, body: "v1 body")

      assert {:ok, updated} =
               Instructions.update(instruction.id, %{}, body: "v2 body", change_note: "tweaked")

      assert updated.active_version == 2

      assert {:ok, rendered} = Instructions.render(updated)
      assert rendered.body == "v2 body"
      assert rendered.version == 2

      assert [%{change_note: "tweaked"}, %{change_note: "Initial version"}] =
               Instructions.list_versions(instruction.id)
    end

    test "change_note can arrive via attrs with string keys; empty body creates no version" do
      org = org!()
      instruction = instruction!(org)

      {:ok, updated} =
        Instructions.update(instruction.id, %{"change_note" => "from attrs", "body" => ""})

      assert updated.active_version == 1
      assert [%InstructionVersion{version: 1}] = Instructions.list_versions(instruction.id)
    end

    test "defaults the change note to \"Updated\"" do
      org = org!()
      instruction = instruction!(org)
      {:ok, _} = Instructions.update(instruction.id, %{}, body: "v2 body")

      assert [%{change_note: "Updated"}, _] = Instructions.list_versions(instruction.id)
    end

    test "unknown id returns {:error, :not_found}" do
      assert Instructions.update(Ecto.UUID.generate(), %{title: "x"}) == {:error, :not_found}
    end

    test "unknown string keys are dropped, known string keys are applied" do
      org = org!()
      instruction = instruction!(org)

      {:ok, updated} =
        Instructions.update(instruction.id, %{"title" => "Via Strings", "banana" => "ignored"})

      assert updated.title == "Via Strings"
    end

    test "invalid metadata rolls back without creating a version" do
      org = org!()
      instruction = instruction!(org)

      assert {:error, %Ecto.Changeset{}} =
               Instructions.update(instruction.id, %{status: "bogus-status"})

      assert [%InstructionVersion{version: 1}] = Instructions.list_versions(instruction.id)
      assert Instructions.get(instruction.id).active_version == 1
    end
  end

  # ── set_active_version/2 ──────────────────────────────────────────────────

  describe "set_active_version/2" do
    test "points active_version at an existing version" do
      org = org!()
      instruction = instruction!(org, %{}, body: "v1 body")
      {:ok, _} = Instructions.update(instruction.id, %{}, body: "v2 body")

      assert {:ok, rolled_back} = Instructions.set_active_version(instruction.id, 1)
      assert rolled_back.active_version == 1
      assert {:ok, %{body: "v1 body", version: 1}} = Instructions.render(rolled_back)
    end

    test "missing instruction or version returns {:error, :not_found}" do
      org = org!()
      instruction = instruction!(org)

      assert Instructions.set_active_version(Ecto.UUID.generate(), 1) == {:error, :not_found}
      assert Instructions.set_active_version(instruction.id, 42) == {:error, :not_found}
    end
  end

  # ── delete/1 ──────────────────────────────────────────────────────────────

  describe "delete/1" do
    test "removes the instruction and its versions" do
      org = org!()
      instruction = instruction!(org, %{}, body: "v1 body")
      {:ok, _} = Instructions.update(instruction.id, %{}, body: "v2 body")

      assert {:ok, _} = Instructions.delete(instruction.id)

      assert Instructions.get(instruction.id) == nil
      assert Instructions.list_versions(instruction.id) == []
    end

    test "missing id returns {:error, :not_found}" do
      assert Instructions.delete(Ecto.UUID.generate()) == {:error, :not_found}
    end
  end

  # ── list/1 & count/1 ──────────────────────────────────────────────────────

  describe "list/1 and count/1" do
    test "filters by org, project, status, tag, and query; supports limit/offset" do
      org = org!()
      other = org!()
      project_id = Ecto.UUID.generate()

      kept = instruction!(org, %{slug: "alpha", title: "Alpha Prompt", tags: ["core"]})
      instruction!(org, %{slug: "beta", title: "Beta Prompt", status: "archived"})
      instruction!(org, %{slug: "gamma", title: "Searchable Gamma", tags: ["extra"]})
      instruction!(org, %{slug: "delta", title: "Delta", project_id: project_id})
      instruction!(other, %{slug: "alpha"})

      orgs = Instructions.list(organization_id: org.id)
      assert length(orgs) == 4
      assert kept.id in Enum.map(orgs, & &1.id)

      assert [%{slug: "beta"}] = Instructions.list(organization_id: org.id, status: "archived")
      assert [%{slug: "delta"}] = Instructions.list(project_id: project_id)
      assert [%{slug: "alpha"}] = Instructions.list(organization_id: org.id, tag: "core")

      assert [%{slug: "gamma"}] = Instructions.list(organization_id: org.id, query: "gamma")
      assert [%{slug: "gamma"}] = Instructions.list(organization_id: org.id, query: "GAMMA")
      assert [%{slug: "gamma"}] = Instructions.list(organization_id: org.id, query: "Searchable")

      assert length(Instructions.list(organization_id: org.id, limit: 2)) == 2

      paged = Instructions.list(organization_id: org.id, limit: 2, offset: 2)
      assert length(paged) == 2

      # Empty query string is ignored (not treated as a match-nothing filter).
      assert length(Instructions.list(organization_id: org.id, query: "")) == 4
      assert Instructions.count(org.id) == 4
      assert Instructions.count(other.id) == 1
    end
  end

  # ── render/3 ──────────────────────────────────────────────────────────────

  describe "render/3" do
    test "substitutes params into {{placeholders}}, whitespace-insensitively" do
      org = org!()

      instruction =
        instruction!(org, %{}, body: "Use {{topic}} for {{ topic }} please.")

      assert {:ok, rendered} = Instructions.render(instruction, %{"topic" => "jellybeans"})
      assert rendered.body == "Use jellybeans for jellybeans please."
      assert rendered.params == %{"topic" => "jellybeans"}
      assert rendered.slug == instruction.slug
      assert rendered.title == instruction.title
      assert rendered.version == 1
    end

    test "atom-keyed params are stringified" do
      org = org!()
      instruction = instruction!(org, %{}, body: "hello {{name}}")

      assert {:ok, rendered} = Instructions.render(instruction, %{name: "world"})
      assert rendered.body == "hello world"
    end

    test "declared defaults fill gaps; explicit params override defaults" do
      org = org!()

      instruction =
        instruction!(
          org,
          %{
            parameters: [
              %{"name" => "topic", "default" => "default-topic"},
              %{"name" => "tone", "default" => "dry"}
            ]
          },
          body: "{{topic}}/{{tone}}"
        )

      assert {:ok, rendered} = Instructions.render(instruction, %{"topic" => "override"})

      assert rendered.body == "override/dry"
      assert rendered.params == %{"topic" => "override", "tone" => "dry"}
    end

    test "missing required params yield {:error, {:missing_params, names}}" do
      org = org!()

      instruction =
        instruction!(org, %{
          parameters: [
            %{"name" => "topic", "required" => true},
            %{"name" => "opt", "default" => "x"}
          ]
        })

      assert {:error, {:missing_params, ["topic"]}} = Instructions.render(instruction)
      assert {:ok, _} = Instructions.render(instruction, %{"topic" => "here"})
    end

    test "required params satisfied by defaults are not reported missing" do
      org = org!()

      instruction =
        instruction!(
          org,
          %{parameters: [%{"name" => "topic", "required" => true, "default" => "fallback"}]},
          body: "{{topic}}"
        )

      assert {:ok, %{body: "fallback"}} = Instructions.render(instruction)
    end

    test "declared params without a name are ignored" do
      org = org!()
      instruction = instruction!(org, %{parameters: [%{"description" => "unnamed"}]})

      assert {:ok, _} = Instructions.render(instruction)
    end

    test "unknown placeholders are left intact" do
      org = org!()
      instruction = instruction!(org, %{}, body: "{{known}} {{unknown}}")

      assert {:ok, rendered} = Instructions.render(instruction, %{"known" => "v"})
      assert rendered.body == "v {{unknown}}"
    end

    test "explicit version opt renders that version" do
      org = org!()
      instruction = instruction!(org, %{}, body: "v1 body")
      {:ok, _} = Instructions.update(instruction.id, %{}, body: "v2 body")

      assert {:ok, %{body: "v1 body", version: 1}} =
               Instructions.render(instruction, %{}, version: 1)
    end

    test "non-map params are treated as empty params" do
      org = org!()
      instruction = instruction!(org, %{}, body: "static")

      assert {:ok, rendered} = Instructions.render(instruction, "not-a-map")
      assert rendered.params == %{}
      assert rendered.body == "static"
    end

    test "nil instruction returns {:error, :not_found}" do
      assert Instructions.render(nil) == {:error, :not_found}
    end

    test "unknown version returns {:error, :version_not_found}" do
      org = org!()
      instruction = instruction!(org)

      assert Instructions.render(instruction, %{}, version: 99) == {:error, :version_not_found}
    end
  end
end
