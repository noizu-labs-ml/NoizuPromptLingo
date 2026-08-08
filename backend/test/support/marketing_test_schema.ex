defmodule NoizuPromptLingua.MarketingTestSchema do
  @moduledoc """
  Idempotently creates the Liquibase 059-customers / 060-market / 061-campaigns
  tables (+ the polymorphic ticket_entity_links) on the test DB so the marketing
  suites are self-contained on top of whatever Liquibase state the test DB has.
  Mirrors `AssetTestSchema` / `TicketTestSchema`. These changelogs are committed +
  in master, so prod already has these tables — this only reconciles the test DB.
  """
  alias NoizuPromptLingua.Repo

  @statements [
    # ── 059 customers ──────────────────────────────────────────
    """
    CREATE TABLE IF NOT EXISTS customer_segments (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
      project_id uuid REFERENCES projects(id) ON DELETE SET NULL,
      slug varchar(255) NOT NULL,
      name varchar(255) NOT NULL,
      description text,
      criteria jsonb DEFAULT '{}'::jsonb,
      tags text[] DEFAULT '{}',
      status varchar(255) NOT NULL DEFAULT 'active',
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )
    """,
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_customer_segments_org_slug ON customer_segments (organization_id, slug)",
    "CREATE INDEX IF NOT EXISTS idx_customer_segments_project_id ON customer_segments (project_id)",
    "CREATE INDEX IF NOT EXISTS idx_customer_segments_tags ON customer_segments USING gin (tags)",
    """
    CREATE TABLE IF NOT EXISTS customer_personas (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
      project_id uuid REFERENCES projects(id) ON DELETE SET NULL,
      segment_id uuid REFERENCES customer_segments(id) ON DELETE SET NULL,
      slug varchar(255) NOT NULL,
      name varchar(255) NOT NULL,
      archetype varchar(255),
      demographics jsonb DEFAULT '{}'::jsonb,
      goals text[] DEFAULT '{}',
      pains text[] DEFAULT '{}',
      channels text[] DEFAULT '{}',
      motivations text,
      objections text,
      summary text,
      artifact_id uuid REFERENCES artifacts(id) ON DELETE SET NULL,
      tags text[] DEFAULT '{}',
      status varchar(255) NOT NULL DEFAULT 'active',
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )
    """,
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_customer_personas_org_slug ON customer_personas (organization_id, slug)",
    "CREATE INDEX IF NOT EXISTS idx_customer_personas_project_id ON customer_personas (project_id)",
    "CREATE INDEX IF NOT EXISTS idx_customer_personas_segment_id ON customer_personas (segment_id)",
    """
    CREATE TABLE IF NOT EXISTS ticket_entity_links (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      ticket_id uuid NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
      entity_type varchar(64) NOT NULL,
      entity_id uuid NOT NULL,
      link_type varchar(64) NOT NULL DEFAULT 'relates_to',
      metadata jsonb DEFAULT '{}'::jsonb,
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )
    """,
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_ticket_entity_links_uniq ON ticket_entity_links (ticket_id, entity_type, entity_id, link_type)",
    "CREATE INDEX IF NOT EXISTS idx_ticket_entity_links_entity ON ticket_entity_links (entity_type, entity_id)",

    # ── 060 market ─────────────────────────────────────────────
    """
    CREATE TABLE IF NOT EXISTS competitors (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
      project_id uuid REFERENCES projects(id) ON DELETE SET NULL,
      slug varchar(255) NOT NULL,
      name varchar(255) NOT NULL,
      website varchar(1024),
      description text,
      tier varchar(64),
      strengths text[] DEFAULT '{}',
      weaknesses text[] DEFAULT '{}',
      metadata jsonb DEFAULT '{}'::jsonb,
      tags text[] DEFAULT '{}',
      status varchar(255) NOT NULL DEFAULT 'active',
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )
    """,
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_competitors_org_slug ON competitors (organization_id, slug)",
    "CREATE INDEX IF NOT EXISTS idx_competitors_project_id ON competitors (project_id)",
    "CREATE INDEX IF NOT EXISTS idx_competitors_tags ON competitors USING gin (tags)",
    """
    CREATE TABLE IF NOT EXISTS keywords (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
      project_id uuid REFERENCES projects(id) ON DELETE SET NULL,
      competitor_id uuid REFERENCES competitors(id) ON DELETE SET NULL,
      slug varchar(255) NOT NULL,
      term varchar(512) NOT NULL,
      intent varchar(64),
      volume integer,
      difficulty integer,
      cpc numeric(10,2),
      competition numeric(5,2),
      source varchar(255),
      metadata jsonb DEFAULT '{}'::jsonb,
      tags text[] DEFAULT '{}',
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )
    """,
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_keywords_org_slug ON keywords (organization_id, slug)",
    "CREATE INDEX IF NOT EXISTS idx_keywords_project_id ON keywords (project_id)",
    "CREATE INDEX IF NOT EXISTS idx_keywords_intent ON keywords (intent)",
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_keywords_proj_term ON keywords (organization_id, project_id, term) WHERE project_id IS NOT NULL",
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_keywords_org_term ON keywords (organization_id, term) WHERE project_id IS NULL",
    "CREATE INDEX IF NOT EXISTS idx_keywords_tags ON keywords USING gin (tags)",
    """
    CREATE TABLE IF NOT EXISTS market_reports (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
      project_id uuid REFERENCES projects(id) ON DELETE SET NULL,
      competitor_id uuid REFERENCES competitors(id) ON DELETE SET NULL,
      segment_id uuid,
      slug varchar(255) NOT NULL,
      title varchar(512) NOT NULL,
      report_type varchar(64) NOT NULL DEFAULT 'market_analysis',
      summary text,
      artifact_id uuid REFERENCES artifacts(id) ON DELETE SET NULL,
      parameters jsonb DEFAULT '{}'::jsonb,
      tags text[] DEFAULT '{}',
      status varchar(255) NOT NULL DEFAULT 'draft',
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )
    """,
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_market_reports_org_slug ON market_reports (organization_id, slug)",
    "CREATE INDEX IF NOT EXISTS idx_market_reports_project_id ON market_reports (project_id)",
    "CREATE INDEX IF NOT EXISTS idx_market_reports_type ON market_reports (report_type)",
    "CREATE INDEX IF NOT EXISTS idx_market_reports_tags ON market_reports USING gin (tags)",

    # ── 061 campaigns ──────────────────────────────────────────
    """
    CREATE TABLE IF NOT EXISTS campaigns (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
      project_id uuid REFERENCES projects(id) ON DELETE SET NULL,
      segment_id uuid,
      slug varchar(255) NOT NULL,
      name varchar(512) NOT NULL,
      channel varchar(64) NOT NULL,
      objective varchar(255),
      status varchar(255) NOT NULL DEFAULT 'draft',
      budget_cents bigint,
      currency varchar(8) DEFAULT 'USD',
      start_date date,
      end_date date,
      targeting jsonb DEFAULT '{}'::jsonb,
      metadata jsonb DEFAULT '{}'::jsonb,
      tags text[] DEFAULT '{}',
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )
    """,
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_campaigns_org_slug ON campaigns (organization_id, slug)",
    "CREATE INDEX IF NOT EXISTS idx_campaigns_project_id ON campaigns (project_id)",
    "CREATE INDEX IF NOT EXISTS idx_campaigns_channel ON campaigns (channel)",
    "CREATE INDEX IF NOT EXISTS idx_campaigns_status ON campaigns (status)",
    "CREATE INDEX IF NOT EXISTS idx_campaigns_tags ON campaigns USING gin (tags)",
    """
    CREATE TABLE IF NOT EXISTS ad_groups (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
      project_id uuid REFERENCES projects(id) ON DELETE SET NULL,
      campaign_id uuid NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
      slug varchar(255) NOT NULL,
      name varchar(512) NOT NULL,
      theme varchar(512),
      keywords text[] DEFAULT '{}',
      bid_cents bigint,
      status varchar(255) NOT NULL DEFAULT 'active',
      metadata jsonb DEFAULT '{}'::jsonb,
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )
    """,
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_ad_groups_campaign_slug ON ad_groups (campaign_id, slug)",
    "CREATE INDEX IF NOT EXISTS idx_ad_groups_campaign_id ON ad_groups (campaign_id)",
    """
    CREATE TABLE IF NOT EXISTS ad_copies (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
      project_id uuid REFERENCES projects(id) ON DELETE SET NULL,
      campaign_id uuid NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
      ad_group_id uuid REFERENCES ad_groups(id) ON DELETE CASCADE,
      variant_number integer NOT NULL DEFAULT 1,
      headline varchar(512),
      body text,
      cta varchar(255),
      format varchar(64),
      artifact_id uuid REFERENCES artifacts(id) ON DELETE SET NULL,
      llm_generated boolean NOT NULL DEFAULT false,
      status varchar(255) NOT NULL DEFAULT 'draft',
      metadata jsonb DEFAULT '{}'::jsonb,
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )
    """,
    "CREATE INDEX IF NOT EXISTS idx_ad_copies_campaign_id ON ad_copies (campaign_id)",
    "CREATE INDEX IF NOT EXISTS idx_ad_copies_ad_group_id ON ad_copies (ad_group_id)",
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_ad_copies_group_variant ON ad_copies (ad_group_id, variant_number) WHERE ad_group_id IS NOT NULL",
    """
    CREATE TABLE IF NOT EXISTS domain_names (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
      project_id uuid REFERENCES projects(id) ON DELETE SET NULL,
      campaign_id uuid REFERENCES campaigns(id) ON DELETE SET NULL,
      slug varchar(255) NOT NULL,
      name varchar(255) NOT NULL,
      status varchar(255) NOT NULL DEFAULT 'candidate',
      registrar varchar(255),
      registered_at date,
      expires_at date,
      metadata jsonb DEFAULT '{}'::jsonb,
      tags text[] DEFAULT '{}',
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )
    """,
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_domain_names_org_slug ON domain_names (organization_id, slug)",
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_domain_names_org_name ON domain_names (organization_id, name)",
    "CREATE INDEX IF NOT EXISTS idx_domain_names_project_id ON domain_names (project_id)",
    "CREATE INDEX IF NOT EXISTS idx_domain_names_tags ON domain_names USING gin (tags)",
    """
    CREATE TABLE IF NOT EXISTS landing_pages (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
      project_id uuid REFERENCES projects(id) ON DELETE SET NULL,
      campaign_id uuid REFERENCES campaigns(id) ON DELETE SET NULL,
      domain_name_id uuid REFERENCES domain_names(id) ON DELETE SET NULL,
      slug varchar(255) NOT NULL,
      title varchar(512) NOT NULL,
      path varchar(1024),
      headline text,
      artifact_id uuid REFERENCES artifacts(id) ON DELETE SET NULL,
      status varchar(255) NOT NULL DEFAULT 'draft',
      metadata jsonb DEFAULT '{}'::jsonb,
      tags text[] DEFAULT '{}',
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )
    """,
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_landing_pages_org_slug ON landing_pages (organization_id, slug)",
    "CREATE INDEX IF NOT EXISTS idx_landing_pages_project_id ON landing_pages (project_id)",
    "CREATE INDEX IF NOT EXISTS idx_landing_pages_campaign_id ON landing_pages (campaign_id)",
    "CREATE INDEX IF NOT EXISTS idx_landing_pages_tags ON landing_pages USING gin (tags)"
  ]

  def ensure! do
    Enum.each(@statements, fn sql -> Ecto.Adapters.SQL.query!(Repo, sql, []) end)
    :ok
  end
end
