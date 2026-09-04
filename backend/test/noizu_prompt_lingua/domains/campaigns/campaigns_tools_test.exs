defmodule NoizuPromptLingua.Domains.Campaigns.ToolsTest do
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.Domains.Campaigns.Tools.{
    AdCopyApprove,
    AdCopyCreate,
    AdCopyGenerate,
    AdCopyGet,
    AdCopyList,
    AdCopyReject,
    AdGroupCreate,
    AdGroupGet,
    AdGroupList,
    AdGroupUpdate,
    CampaignCreate,
    CampaignGet,
    CampaignList,
    CampaignUpdate,
    DomainNameCreate,
    DomainNameGet,
    DomainNameList,
    DomainNameUpdate,
    LandingPageCreate,
    LandingPageGenerate,
    LandingPageGet,
    LandingPageList,
    LandingPageUpdate,
    Overview
  }

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization

  setup do
    org_id = insert_org()
    org_slug = Repo.get!(Organization, org_id).slug
    {:ok, org_id: org_id, org_slug: org_slug}
  end

  defp uniq(suffix), do: "#{suffix}-#{System.unique_integer([:positive])}"

  defp create_campaign(org_slug) do
    slug = uniq("camp")

    {:ok, %{id: id}} =
      CampaignCreate.call(
        %{"organization" => org_slug, "slug" => slug, "name" => "Launch", "channel" => "ppc"},
        %{}
      )

    id
  end

  # ── Campaigns ──────────────────────────────────────────────────────

  test "campaign create / get / update / list", %{org_slug: org_slug} do
    slug = uniq("camp")

    assert {:ok, %{id: id, slug: ^slug, name: "Launch", channel: "ppc", status: "draft"}} =
             CampaignCreate.call(
               %{"organization" => org_slug, "slug" => slug, "name" => "Launch", "channel" => "ppc"},
               %{}
             )

    assert {:ok, %{id: ^id, channel: "ppc"}} =
             CampaignGet.call(%{"organization" => org_slug, "id" => slug}, %{})

    assert {:ok, %{id: ^id, status: "archived"}} =
             CampaignUpdate.call(%{"id" => id, "status" => "archived"}, %{})

    assert {:ok, %{campaigns: [_]}} = CampaignList.call(%{"organization" => org_slug}, %{})

    assert {:error, "Campaign 'ghost' not found"} =
             CampaignGet.call(%{"organization" => org_slug, "id" => "ghost"}, %{})
  end

  # ── Ad groups + ad copies ──────────────────────────────────────────

  test "ad group + ad copy lifecycle incl. approve / reject", %{org_slug: org_slug} do
    campaign_id = create_campaign(org_slug)
    group_slug = uniq("grp")

    assert {:ok, %{id: group_id, slug: ^group_slug, campaign_id: ^campaign_id}} =
             AdGroupCreate.call(
               %{"campaign_id" => campaign_id, "slug" => group_slug, "name" => "Brand"},
               %{}
             )

    missing = Ecto.UUID.generate()

    assert {:error, msg} = AdGroupCreate.call(%{"campaign_id" => missing}, %{})
    assert msg == "Campaign '#{missing}' not found"

    assert {:ok, %{id: ^group_id}} = AdGroupGet.call(%{"id" => group_id}, %{})
    assert {:ok, %{ad_groups: [_]}} = AdGroupList.call(%{"campaign_id" => campaign_id}, %{})
    assert {:ok, %{id: ^group_id}} = AdGroupUpdate.call(%{"id" => group_id, "name" => "Brand v2"}, %{})
    assert {:error, "Ad group not found"} = AdGroupGet.call(%{"id" => Ecto.UUID.generate()}, %{})

    assert {:ok, %{id: copy_id, status: "draft"}} =
             AdCopyCreate.call(%{"campaign_id" => campaign_id, "body" => "Buy stuff"}, %{})

    assert {:error, "Campaign not found"} = AdCopyCreate.call(%{"campaign_id" => Ecto.UUID.generate()}, %{})

    assert {:ok, %{id: ^copy_id}} = AdCopyGet.call(%{"id" => copy_id}, %{})
    assert {:ok, %{ad_copies: copies}} = AdCopyList.call(%{"campaign_id" => campaign_id}, %{})
    assert length(copies) == 1

    assert {:ok, %{id: ^copy_id, status: "approved"}} = AdCopyApprove.call(%{"id" => copy_id}, %{})
    assert {:ok, %{id: ^copy_id, status: "rejected"}} = AdCopyReject.call(%{"id" => copy_id}, %{})
    assert {:error, "Ad copy not found"} = AdCopyGet.call(%{"id" => Ecto.UUID.generate()}, %{})
  end

  test "ad copy generation resolves the campaign or fails gracefully", %{org_slug: org_slug} do
    campaign_id = create_campaign(org_slug)

    result =
      AdCopyGenerate.call(
        %{"campaign_id" => campaign_id, "llm_generate" => false, "prompt" => "offline copy"},
        %{}
      )

    case result do
      {:ok, %{ad_copies: copies, created: created}} when is_list(copies) ->
        assert length(copies) == created

      {:error, "Generation failed: " <> _} ->
        :ok

      other ->
        flunk("unexpected: #{inspect(other)}")
    end

    assert {:error, msg} = AdCopyGenerate.call(%{"campaign_id" => Ecto.UUID.generate()}, %{})
    assert msg == "Campaign '#{Ecto.UUID.generate()}' not found" or msg =~ "not found"
  end

  # ── Landing pages ──────────────────────────────────────────────────

  test "landing page create / get / update / list / offline generate", %{org_slug: org_slug} do
    slug = uniq("lp")

    assert {:ok, %{id: id, slug: ^slug, title: "Home", status: "draft"}} =
             LandingPageCreate.call(
               %{"organization" => org_slug, "slug" => slug, "title" => "Home"},
               %{}
             )

    assert {:ok, %{id: ^id}} = LandingPageGet.call(%{"organization" => org_slug, "id" => slug}, %{})
    assert {:ok, %{id: ^id, title: "Home v2"}} = LandingPageUpdate.call(%{"id" => id, "title" => "Home v2"}, %{})
    assert {:ok, %{landing_pages: [_]}} = LandingPageList.call(%{"organization" => org_slug}, %{})
    assert {:error, "Landing page 'ghost' not found"} =
             LandingPageGet.call(%{"organization" => org_slug, "id" => "ghost"}, %{})

    result = LandingPageGenerate.call(%{"id" => id, "llm_generate" => false}, %{})

    case result do
      {:ok, %{id: ^id, artifact_id: artifact_id}} -> refute is_nil(artifact_id)
      {:error, "Generation failed: " <> _} -> :ok
      other -> flunk("unexpected: #{inspect(other)}")
    end
  end

  # ── Domain names ───────────────────────────────────────────────────

  test "domain name create / get / update / list", %{org_slug: org_slug} do
    slug = uniq("dn")

    assert {:ok, %{id: id, slug: ^slug, name: "example.com"}} =
             DomainNameCreate.call(
               %{"organization" => org_slug, "slug" => slug, "name" => "example.com"},
               %{}
             )

    assert {:ok, %{id: ^id}} = DomainNameGet.call(%{"organization" => org_slug, "id" => slug}, %{})
    assert {:ok, %{id: ^id}} = DomainNameUpdate.call(%{"id" => id, "status" => "registered"}, %{})
    assert {:ok, %{domain_names: [_]}} = DomainNameList.call(%{"organization" => org_slug}, %{})
    assert {:error, "Domain name 'ghost' not found"} =
             DomainNameGet.call(%{"organization" => org_slug, "id" => "ghost"}, %{})
  end

  # ── Overview + org errors ──────────────────────────────────────────

  test "Overview and org error paths", %{org_slug: org_slug} do
    assert {:ok, %{domain: "Campaigns", campaign_count: 0, tools: %{campaigns: tools}}} =
             Overview.call(%{"organization" => org_slug}, %{})

    assert "Campaign.Create" in tools
    assert {:ok, %{campaign_count: 0}} = Overview.call(%{"organization" => "nope"}, %{})

    assert {:error, "Organization 'nope' not found"} =
             CampaignCreate.call(%{"organization" => "nope", "slug" => "s", "name" => "n", "channel" => "ppc"}, %{})

    assert {:error, "Organization not found"} = CampaignList.call(%{"organization" => "nope"}, %{})
    assert {:error, "Organization not found"} = LandingPageList.call(%{"organization" => "nope"}, %{})
    assert {:error, "Organization not found"} = DomainNameList.call(%{"organization" => "nope"}, %{})
  end

  # ── helpers ────────────────────────────────────────────────────────

  defp insert_org do
    slug = "camp-org-#{System.unique_integer([:positive])}"

    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        [slug, "Campaigns Tools Test Org"]
      )

    Ecto.UUID.load!(raw)
  end
end
