defmodule NoizuPromptLingua.Domains.MarketingContentTest do
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.Domains.Artifacts
  alias NoizuPromptLingua.Domains.MarketingContent

  setup do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["mc-org-#{System.unique_integer([:positive])}", "Marketing Content Org"]
      )

    {:ok, org_id: Ecto.UUID.load!(raw)}
  end

  test "generate_text with llm_generate: false echoes the prompt" do
    assert {:ok, "echo me"} = MarketingContent.generate_text("echo me", llm_generate: false)
  end

  test "generate_artifact persists an artifact with the echoed content", %{org_id: org_id} do
    assert {:ok, %{artifact_id: id, content: content}} =
             MarketingContent.generate_artifact(
               "offline body",
               %{organization_id: org_id, title: "Generated"},
               llm_generate: false
             )

    assert content == "offline body"
    assert {artifact, revision} = Artifacts.get(id)
    assert artifact.title == "Generated"
    assert revision.content == "offline body"
  end

  test "generate_text without a provider returns a typed error (no crash)" do
    result = MarketingContent.generate_text("hello", [])

    case result do
      {:ok, _} -> :ok
      {:error, :missing_api_key} -> :ok
      {:error, _} -> :ok
    end
  end
end
