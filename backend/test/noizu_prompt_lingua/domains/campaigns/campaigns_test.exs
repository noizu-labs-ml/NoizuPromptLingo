defmodule NoizuPromptLingua.Domains.CampaignsTest do
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.Domains.Campaigns

  setup do
    org_id = insert_org()
    {:ok, campaign} = Campaigns.create_campaign(%{organization_id: org_id, slug: "launch", name: "Launch", channel: "ppc", objective: "signups"})
    {:ok, org_id: org_id, campaign: campaign}
  end

  test "campaign CRUD + channel/status filters", %{org_id: org_id, campaign: campaign} do
    assert Campaigns.resolve_campaign(org_id, "launch").id == campaign.id
    {:ok, _} = Campaigns.update_campaign(campaign.id, %{status: "active"})
    assert [%{slug: "launch"}] = Campaigns.list_campaigns(organization_id: org_id, channel: "ppc")
    assert [] = Campaigns.list_campaigns(organization_id: org_id, status: "paused")
    assert Campaigns.count_campaigns(org_id) == 1
  end

  test "campaign requires a valid channel", %{org_id: org_id} do
    assert {:error, cs} = Campaigns.create_campaign(%{organization_id: org_id, slug: "x", name: "X", channel: "telepathy"})
    assert cs.errors[:channel]
  end

  test "ad group slug unique per campaign; ad copy variant auto-numbering", %{campaign: campaign} do
    {:ok, group} = Campaigns.create_ad_group(%{organization_id: campaign.organization_id, campaign_id: campaign.id, slug: "g1", name: "Group 1"})
    assert {:error, _} = Campaigns.create_ad_group(%{organization_id: campaign.organization_id, campaign_id: campaign.id, slug: "g1", name: "Dup"})

    {:ok, a1} = Campaigns.create_ad_copy(%{organization_id: campaign.organization_id, campaign_id: campaign.id, ad_group_id: group.id, headline: "H1"})
    {:ok, a2} = Campaigns.create_ad_copy(%{organization_id: campaign.organization_id, campaign_id: campaign.id, ad_group_id: group.id, headline: "H2"})
    assert a1.variant_number == 1
    assert a2.variant_number == 2

    {:ok, approved} = Campaigns.approve_ad_copy(a1.id)
    assert approved.status == "approved"
  end

  describe "ad copy generation (offline path)" do
    test "generate_ad_copy with llm_generate: false stores artifact + inserts N variants", %{campaign: campaign} do
      assert {:ok, rows} = Campaigns.generate_ad_copy(campaign.id, count: 3, llm_generate: false)
      assert length(rows) == 3
      assert Enum.all?(rows, & &1.artifact_id)
      assert Enum.map(rows, & &1.variant_number) == [1, 2, 3]
    end
  end

  test "landing page generate (offline) sets artifact_id", %{org_id: org_id} do
    {:ok, page} = Campaigns.create_landing_page(%{organization_id: org_id, slug: "lp", title: "Landing", headline: "Hi"})
    assert {:ok, updated} = Campaigns.generate_landing_page(page.id, llm_generate: false)
    assert updated.artifact_id
  end

  test "domain name FQDN unique per org", %{org_id: org_id} do
    {:ok, _} = Campaigns.create_domain_name(%{organization_id: org_id, slug: "d1", name: "example.com"})
    assert {:error, _} = Campaigns.create_domain_name(%{organization_id: org_id, slug: "d2", name: "example.com"})
  end

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["camptest-#{System.unique_integer([:positive])}", "Campaigns Test Org"]
      )

    Ecto.UUID.load!(raw)
  end
end
