defmodule NoizuPromptLingua.MarketingSignupTestSchema do
  @moduledoc """
  Idempotently ensures the Liquibase 077 marketing tables (marketing_signups,
  marketing_settings) exist on the test DB so the marketing-signup suites are
  self-contained on top of whatever Liquibase state the test DB has.
  Mirrors `MCPCustomScopeTestSchema` / `TicketTestSchema`.
  """
  alias NoizuPromptLingua.Repo

  def ensure! do
    Ecto.Adapters.SQL.query!(
      Repo,
      """
      CREATE TABLE IF NOT EXISTS marketing_signups (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        email varchar(255) NOT NULL,
        source varchar(64) NOT NULL DEFAULT 'landing',
        promo_awarded boolean NOT NULL DEFAULT false,
        waitlisted boolean NOT NULL DEFAULT false,
        metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
        inserted_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT uq_marketing_signups_email UNIQUE (email)
      )
      """,
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      "CREATE INDEX IF NOT EXISTS idx_marketing_signups_source ON marketing_signups (source)",
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      "CREATE INDEX IF NOT EXISTS idx_marketing_signups_waitlisted ON marketing_signups (waitlisted)",
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      """
      CREATE TABLE IF NOT EXISTS marketing_settings (
        id integer PRIMARY KEY DEFAULT 1 CONSTRAINT marketing_settings_singleton CHECK (id = 1),
        beta_signup_cap integer,
        promo_cap integer,
        signups_open boolean NOT NULL DEFAULT true,
        promo_active boolean NOT NULL DEFAULT true,
        updated_at timestamptz NOT NULL DEFAULT now()
      )
      """,
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      "INSERT INTO marketing_settings (id) VALUES (1) ON CONFLICT (id) DO NOTHING",
      []
    )
  end
end
