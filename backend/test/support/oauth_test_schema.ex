defmodule NoizuPromptLingua.OAuthTestSchema do
  @moduledoc "Idempotent OAuth AS tables for the test DB (Liquibase 074)."

  alias NoizuPromptLingua.Repo

  def ensure! do
    Repo.query!("""
    CREATE TABLE IF NOT EXISTS oauth_clients (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      client_id varchar(255) NOT NULL,
      client_secret_hash varchar(255),
      client_name varchar(255) NOT NULL DEFAULT 'unnamed',
      redirect_uris jsonb NOT NULL DEFAULT '[]'::jsonb,
      grant_types jsonb NOT NULL DEFAULT '["authorization_code","refresh_token"]'::jsonb,
      token_endpoint_auth_method varchar(64) NOT NULL DEFAULT 'none',
      scope varchar(1024) NOT NULL DEFAULT 'openid mcp',
      is_first_party boolean NOT NULL DEFAULT false,
      status varchar(16) NOT NULL DEFAULT 'active',
      metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
      toolset_config jsonb NOT NULL DEFAULT '{}'::jsonb,
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )
    """)

    # Pre-existing test DBs (table created before W8) get the column added.
    Repo.query!(
      "ALTER TABLE oauth_clients ADD COLUMN IF NOT EXISTS toolset_config JSONB NOT NULL DEFAULT '{}'::jsonb"
    )

    Repo.query!(
      "CREATE UNIQUE INDEX IF NOT EXISTS idx_oauth_clients_client_id ON oauth_clients (client_id)"
    )

    Repo.query!("""
    CREATE TABLE IF NOT EXISTS mcp_pairing_grants (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      grant_id varchar(64) NOT NULL,
      user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      client_id varchar(255) NOT NULL,
      resource varchar(1024) NOT NULL,
      scope varchar(1024) NOT NULL DEFAULT 'mcp',
      authorization_details jsonb NOT NULL DEFAULT '[]'::jsonb,
      status varchar(16) NOT NULL DEFAULT 'active',
      expires_at timestamptz,
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )
    """)

    Repo.query!(
      "CREATE UNIQUE INDEX IF NOT EXISTS idx_mcp_pairing_grants_grant_id ON mcp_pairing_grants (grant_id)"
    )

    Repo.query!("""
    CREATE TABLE IF NOT EXISTS oauth_authorization_codes (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      code_hash varchar(255) NOT NULL,
      client_id varchar(255) NOT NULL,
      user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      redirect_uri varchar(2048) NOT NULL,
      resource varchar(1024),
      scope varchar(1024) NOT NULL DEFAULT 'mcp',
      code_challenge varchar(255) NOT NULL,
      code_challenge_method varchar(16) NOT NULL DEFAULT 'S256',
      grant_id varchar(64),
      expires_at timestamptz NOT NULL,
      consumed_at timestamptz,
      inserted_at timestamptz NOT NULL DEFAULT now()
    )
    """)

    Repo.query!(
      "CREATE UNIQUE INDEX IF NOT EXISTS idx_oauth_auth_codes_hash ON oauth_authorization_codes (code_hash)"
    )

    Repo.query!("""
    CREATE TABLE IF NOT EXISTS oauth_refresh_tokens (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      token_hash varchar(255) NOT NULL,
      client_id varchar(255) NOT NULL,
      user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      grant_id varchar(64),
      resource varchar(1024),
      scope varchar(1024) NOT NULL DEFAULT 'mcp',
      expires_at timestamptz NOT NULL,
      revoked_at timestamptz,
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )
    """)

    Repo.query!(
      "CREATE UNIQUE INDEX IF NOT EXISTS idx_oauth_refresh_tokens_hash ON oauth_refresh_tokens (token_hash)"
    )

    :ok
  end
end
