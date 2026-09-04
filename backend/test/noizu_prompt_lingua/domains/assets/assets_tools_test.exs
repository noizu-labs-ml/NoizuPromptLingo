defmodule NoizuPromptLingua.Domains.Assets.ToolsTest do
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.Domains.Assets.Tools.{
    AssetArchive,
    AssetCreate,
    AssetGenerate,
    AssetHistory,
    AssetList,
    AssetOutputs,
    AssetPublish,
    AssetUpdate
  }

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization

  setup do
    org_id = insert_org()
    org_slug = Repo.get!(Organization, org_id).slug
    {:ok, org_id: org_id, org_slug: org_slug}
  end

  defp uniq(suffix), do: "#{suffix}-#{System.unique_integer([:positive])}"

  defp create_asset(org_slug, extra \\ %{}) do
    {:ok, %{id: id}} =
      AssetCreate.call(
        Map.merge(
          %{
            "organization" => org_slug,
            "slug" => uniq("asset"),
            "title" => "Hero Banner",
            "asset_type" => "image",
            "prompt_yaml" => "prompt: hero art\n"
          },
          extra
        ),
        %{}
      )

    id
  end

  test "asset create / list / update / archive lifecycle", %{org_slug: org_slug} do
    slug = uniq("asset")

    assert {:ok,
            %{id: id, slug: ^slug, title: "Hero Banner", asset_type: "image", status: "draft"}} =
             AssetCreate.call(
               %{
                 "organization" => org_slug,
                 "slug" => slug,
                 "title" => "Hero Banner",
                 "asset_type" => "image",
                 "prompt_yaml" => "prompt: hero art\n"
               },
               %{}
             )

    assert {:ok, %{assets: entries}} = AssetList.call(%{"organization" => org_slug}, %{})
    assert length(entries) == 1

    assert {:ok, %{id: ^id, title: "Hero v2"}} =
             AssetUpdate.call(%{"asset" => id, "title" => "Hero v2"}, %{})

    assert {:ok, %{id: ^id, status: "archived"}} = AssetArchive.call(%{"asset" => id}, %{})

    assert {:error, "Asset not found"} =
             AssetArchive.call(%{"asset" => Ecto.UUID.generate()}, %{})
  end

  test "outputs + history for an entry are empty by default", %{org_slug: org_slug} do
    id = create_asset(org_slug)

    assert {:ok, %{outputs: []}} = AssetOutputs.call(%{"entry_id" => id}, %{})
    assert {:ok, %{events: history}} = AssetHistory.call(%{"entry_id" => id}, %{})
    assert Enum.any?(history, &(&1.action == "created"))
  end

  test "generate without a provider fails gracefully; publish validates state", %{
    org_slug: org_slug
  } do
    id = create_asset(org_slug)

    result = AssetGenerate.call(%{"entry_id" => id, "llm_generate" => false}, %{})

    case result do
      {:ok, %{output_id: _}} -> :ok
      {:error, "Failed: " <> _} -> :ok
      other -> flunk("unexpected: #{inspect(other)}")
    end

    assert {:ok, %{id: ^id, status: "published"}} = AssetPublish.call(%{"asset" => id}, %{})

    assert {:error, "Asset not found"} =
             AssetPublish.call(%{"asset" => Ecto.UUID.generate()}, %{})
  end

  defp insert_org do
    slug = uniq("assets-org")

    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        [slug, "Assets Tools Org"]
      )

    Ecto.UUID.load!(raw)
  end
end
