defmodule NoizuPromptLingua.Domains.Instructions.ToolsTest do
  @moduledoc """
  MCP tool surface for the Instructions domain (Instruction.Get/List/Update/Versions).

  Tools are exercised through call/2 exactly as the transport delivers them —
  string-keyed arg maps, empty ctx.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.Instructions

  alias NoizuPromptLingua.Domains.Instructions.Tools.{
    InstructionGet,
    InstructionList,
    InstructionUpdate,
    InstructionVersions
  }

  alias NoizuPromptLingua.Schema.Organizations.Organization

  setup do
    suffix = Ecto.UUID.generate() |> binary_part(0, 8)

    org =
      Repo.insert!(%Organization{name: "Tool Org #{suffix}", slug: "tool-org-#{suffix}"})

    {:ok, instruction} =
      Instructions.create(
        %{organization_id: org.id, slug: "tool-instr-#{suffix}", title: "Tool Instruction"},
        body: "v1 body"
      )

    %{org: org, instruction: instruction, slug: "tool-instr-#{suffix}"}
  end

  # ── Instruction.Get ───────────────────────────────────────────────────────

  describe "Instruction.Get" do
    test "returns the instruction with its active version body", %{instruction: i} do
      assert {:ok, result} = InstructionGet.call(%{"instruction" => i.id}, %{})

      assert %{title: "Tool Instruction", body: "v1 body", active_version: 1, version: 1} =
               result

      assert result.id == i.id
      assert result.slug == i.slug
    end

    test "resolves a slug through an organization", %{org: org, instruction: i, slug: slug} do
      assert {:ok, result} =
               InstructionGet.call(%{"instruction" => slug, "organization" => org.slug}, %{})

      assert result.id == i.id
    end

    test "explicit version selects that body", %{instruction: i} do
      {:ok, _} = Instructions.update(i.id, %{}, body: "v2 body")

      assert {:ok, result} = InstructionGet.call(%{"instruction" => i.id, "version" => 1}, %{})
      assert result.version == 1
      assert result.body == "v1 body"
    end

    test "unknown handle returns an error", %{instruction: i} do
      ghost = Ecto.UUID.generate()

      assert {:error, msg} = InstructionGet.call(%{"instruction" => ghost}, %{})
      assert msg == "Instruction '#{ghost}' not found"

      # An unknown organization resolves to nil org_id → falls back to a bare
      # id lookup, so a direct UUID still resolves.
      assert {:ok, _} =
               InstructionGet.call(
                 %{"instruction" => i.id, "organization" => "ghost-org"},
                 %{}
               )
    end
  end

  # ── Instruction.List ──────────────────────────────────────────────────────

  describe "Instruction.List" do
    test "lists the organization's instructions", %{org: org, instruction: i} do
      assert {:ok, %{count: 1, instructions: [row]}} =
               InstructionList.call(%{"organization" => org.id}, %{})

      assert row.id == i.id
      assert row.param_count == 0
    end

    test "status, tag, and query filters pass through", %{org: org, instruction: i} do
      {:ok, _} =
        Instructions.create(
          %{
            organization_id: org.id,
            slug: i.slug <> "-archived",
            title: "Archived",
            status: "archived",
            tags: ["legacy"]
          },
          body: "b"
        )

      assert {:ok, %{count: 1}} =
               InstructionList.call(%{"organization" => org.id, "status" => "archived"}, %{})

      assert {:ok, %{count: 1}} =
               InstructionList.call(%{"organization" => org.id, "tag" => "legacy"}, %{})

      assert {:ok, %{count: 1}} =
               InstructionList.call(%{"organization" => org.id, "query" => "Archived"}, %{})

      assert {:ok, %{count: 2}} = InstructionList.call(%{"organization" => org.id}, %{})
    end

    test "declared parameters surface as param_count", %{org: org, instruction: i} do
      {:ok, _} =
        Instructions.update(i.id, %{
          parameters: [%{"name" => "topic", "default" => "x"}]
        })

      assert {:ok, %{instructions: [%{param_count: 1}]}} =
               InstructionList.call(%{"organization" => org.id}, %{})
    end

    test "unknown organization and unknown project produce tool errors", %{org: org} do
      assert {:error, "Organization not found"} =
               InstructionList.call(%{"organization" => "ghost-org"}, %{})

      assert {:error, "Invalid project"} =
               InstructionList.call(
                 %{"organization" => org.id, "project" => "ghost-project"},
                 %{}
               )
    end
  end

  # ── Instruction.Update ────────────────────────────────────────────────────

  describe "Instruction.Update" do
    test "metadata-only update keeps the active version", %{instruction: i} do
      assert {:ok, result} =
               InstructionUpdate.call(
                 %{"instruction" => i.id, "title" => "Renamed", "status" => "archived"},
                 %{}
               )

      assert result.id == i.id
      assert result.active_version == 1
      assert Instructions.get(i.id).title == "Renamed"
    end

    test "a body creates the next version", %{instruction: i} do
      assert {:ok, %{active_version: 2}} =
               InstructionUpdate.call(
                 %{"instruction" => i.id, "body" => "v2 body", "change_note" => "rev"},
                 %{}
               )

      assert Instructions.get_version(i.id).body == "v2 body"
    end

    test "resolves slug via organization", %{org: org, instruction: i, slug: slug} do
      assert {:ok, result} =
               InstructionUpdate.call(
                 %{"instruction" => slug, "organization" => org.slug, "description" => "d"},
                 %{}
               )

      assert result.id == i.id
    end

    test "unknown handle and invalid attrs return errors", %{instruction: i} do
      ghost = Ecto.UUID.generate()

      assert {:error, msg} = InstructionUpdate.call(%{"instruction" => ghost}, %{})
      assert msg == "Instruction '#{ghost}' not found"

      assert {:error, <<"Failed: " <> _>>} =
               InstructionUpdate.call(%{"instruction" => i.id, "status" => "bogus"}, %{})
    end
  end

  # ── Instruction.Versions ──────────────────────────────────────────────────

  describe "Instruction.Versions" do
    test "lists version history with active flags", %{instruction: i} do
      {:ok, _} = Instructions.update(i.id, %{}, body: "v2 body")

      assert {:ok, result} = InstructionVersions.call(%{"instruction" => i.id}, %{})
      assert result.active_version == 2
      assert result.count == 2

      assert [%{version: 2, active: true, change_note: "Updated"}, %{version: 1, active: false}] =
               result.versions
    end

    test "unknown handle returns an error" do
      ghost = Ecto.UUID.generate()

      assert {:error, msg} = InstructionVersions.call(%{"instruction" => ghost}, %{})
      assert msg == "Instruction '#{ghost}' not found"
    end
  end
end
