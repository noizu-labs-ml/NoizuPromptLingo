defmodule NoizuPromptLingua.MemoryTestSchema do
  @moduledoc """
  Applies the memory-engine schema (Liquibase changelogs 045–050) directly to the test DB so the
  memory suite is self-contained on top of whatever Liquibase state the test DB has. Idempotent:
  drops + recreates the memory tables/enums each run. A minimal `personas` table is created only
  if absent (the FK target for `agent_call_signs`).
  """
  alias NoizuPromptLingua.Repo

  @statements [
    # clean slate
    "DROP TABLE IF EXISTS memory_recall_log, memory_quarantine, memory_agent_state, memory_compartments, association_edges, agent_call_signs, memories CASCADE",
    "DROP TYPE IF EXISTS memory_edge_type, memory_classification, memory_state, memory_content_type, memory_scope_type CASCADE",
    "CREATE EXTENSION IF NOT EXISTS pg_trgm",

    # minimal personas (only if the real one isn't present)
    """
    CREATE TABLE IF NOT EXISTS personas (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      organization_id uuid,
      project_id uuid,
      slug varchar(255),
      name varchar(255),
      role varchar(255),
      bio text,
      avatar varchar(255),
      tags text[] NOT NULL DEFAULT '{}',
      metadata jsonb NOT NULL DEFAULT '{}',
      status varchar(32) DEFAULT 'active',
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )
    """,

    # enums
    "CREATE TYPE memory_scope_type AS ENUM ('persona','weego','team_member')",
    "CREATE TYPE memory_content_type AS ENUM ('episodic','semantic','procedural')",
    "CREATE TYPE memory_state AS ENUM ('active','consolidating','archived','quarantined','pruned')",
    "CREATE TYPE memory_classification AS ENUM ('open','restricted','sealed')",
    "CREATE TYPE memory_edge_type AS ENUM ('semantic','emotional','temporal','causal','co_occurrence','synthetic','contextual','tangent')",

    # memories
    """
    CREATE TABLE memories (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      organization_id uuid NOT NULL,
      project_id uuid,
      scope_type memory_scope_type NOT NULL,
      scope_id uuid NOT NULL,
      source_agent text NOT NULL DEFAULT 'external',
      content text NOT NULL,
      context text,
      reflection text,
      tangent text,
      summary text,
      content_type memory_content_type NOT NULL DEFAULT 'episodic',
      valence real NOT NULL,
      arousal real NOT NULL,
      dominance real NOT NULL,
      cortisol real NOT NULL,
      dopamine real NOT NULL,
      oxytocin real NOT NULL,
      serotonin real NOT NULL,
      frustration_index real NOT NULL DEFAULT 0.0,
      confidence text NOT NULL DEFAULT 'low',
      occurred_at timestamptz NOT NULL DEFAULT now(),
      time_of_day text,
      day_of_week smallint,
      season text,
      domain text,
      topic text,
      session_id uuid,
      turn integer,
      modality text,
      collaborators text[] NOT NULL DEFAULT '{}',
      environment jsonb NOT NULL DEFAULT '{}',
      state memory_state NOT NULL DEFAULT 'consolidating',
      decay_weight real NOT NULL DEFAULT 1.0,
      pinned boolean NOT NULL DEFAULT false,
      last_recalled_at timestamptz,
      last_reinforced_at timestamptz NOT NULL DEFAULT now(),
      recall_count integer NOT NULL DEFAULT 0,
      reinforcement_count integer NOT NULL DEFAULT 0,
      denforcement_count integer NOT NULL DEFAULT 0,
      consolidation_ids uuid[] NOT NULL DEFAULT '{}',
      pruned_at timestamptz,
      compartment text NOT NULL DEFAULT 'default',
      classification memory_classification NOT NULL DEFAULT 'open',
      salience real GENERATED ALWAYS AS (decay_weight * (0.6 + 0.4 * GREATEST(abs(valence), arousal))) STORED,
      embedding_model text,
      embedding_version integer NOT NULL DEFAULT 1,
      vectors_synced boolean NOT NULL DEFAULT false,
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )
    """,
    "CREATE INDEX idx_memories_scope_active ON memories (organization_id, scope_type, scope_id, compartment) WHERE state IN ('active','consolidating')",
    "CREATE INDEX idx_memories_content_trgm ON memories USING gin (content gin_trgm_ops)",
    "CREATE INDEX idx_memories_collaborators ON memories USING gin (collaborators)",

    # association_edges
    """
    CREATE TABLE association_edges (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      source_memory_id uuid NOT NULL REFERENCES memories(id) ON DELETE CASCADE,
      target_memory_id uuid NOT NULL REFERENCES memories(id) ON DELETE CASCADE,
      weight real NOT NULL DEFAULT 0.5 CHECK (weight >= 0.0 AND weight <= 1.0),
      edge_type memory_edge_type NOT NULL,
      created_by text NOT NULL DEFAULT 'weaver',
      reinforcement_count integer NOT NULL DEFAULT 0,
      denforcement_count integer NOT NULL DEFAULT 0,
      reason text,
      emotional_similarity real,
      temporal_proximity real,
      last_reinforced_at timestamptz NOT NULL DEFAULT now(),
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now(),
      CONSTRAINT uq_edge UNIQUE (source_memory_id, target_memory_id, edge_type),
      CONSTRAINT no_self_edge CHECK (source_memory_id <> target_memory_id)
    )
    """,
    "CREATE INDEX idx_edges_source_w ON association_edges (source_memory_id, weight DESC) WHERE weight >= 0.2",
    "CREATE INDEX idx_edges_target_w ON association_edges (target_memory_id, weight DESC) WHERE weight >= 0.2",

    # aux
    """
    CREATE TABLE memory_compartments (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      organization_id uuid NOT NULL,
      scope_type memory_scope_type NOT NULL,
      scope_id uuid NOT NULL,
      slug text NOT NULL,
      classification memory_classification NOT NULL DEFAULT 'open',
      settings jsonb NOT NULL DEFAULT '{}',
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now(),
      CONSTRAINT uq_compartment UNIQUE (organization_id, scope_type, scope_id, slug)
    )
    """,
    """
    CREATE TABLE memory_agent_state (
      organization_id uuid NOT NULL,
      scope_type memory_scope_type NOT NULL,
      scope_id uuid NOT NULL,
      status text NOT NULL DEFAULT 'active',
      current_emotional real[],
      baseline_emotional real[],
      current_bucket text,
      last_bucket_refresh timestamptz,
      metrics jsonb NOT NULL DEFAULT '{}',
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now(),
      CONSTRAINT pk_memory_agent_state PRIMARY KEY (organization_id, scope_type, scope_id)
    )
    """,
    """
    CREATE TABLE memory_quarantine (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      memory_id uuid REFERENCES memories(id) ON DELETE SET NULL,
      organization_id uuid NOT NULL,
      scope_type memory_scope_type NOT NULL,
      scope_id uuid NOT NULL,
      reason text NOT NULL,
      payload jsonb NOT NULL DEFAULT '{}',
      resolved boolean NOT NULL DEFAULT false,
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )
    """,
    """
    CREATE TABLE memory_recall_log (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      requester_id text NOT NULL,
      organization_id uuid NOT NULL,
      scope_type memory_scope_type NOT NULL,
      scope_id uuid NOT NULL,
      mode text NOT NULL,
      query text,
      total_candidates integer,
      returned_count integer,
      hot_index_hit boolean NOT NULL DEFAULT false,
      duration_ms integer,
      result_memory_ids uuid[] NOT NULL DEFAULT '{}',
      path_breakdown jsonb NOT NULL DEFAULT '{}',
      occurred_at timestamptz NOT NULL DEFAULT now()
    )
    """,

    # agent_call_signs
    """
    CREATE TABLE agent_call_signs (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      organization_id uuid NOT NULL,
      kind text NOT NULL CHECK (kind IN ('weego','team_member')),
      call_sign varchar(255) NOT NULL,
      display_name varchar(255),
      persona_id uuid REFERENCES personas(id) ON DELETE SET NULL,
      status varchar(32) NOT NULL DEFAULT 'active',
      metadata jsonb NOT NULL DEFAULT '{}',
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )
    """,
    "CREATE UNIQUE INDEX idx_agent_call_signs_org_callsign ON agent_call_signs (organization_id, call_sign)"
  ]

  def ensure! do
    Enum.each(@statements, fn sql -> Ecto.Adapters.SQL.query!(Repo, sql, []) end)
    :ok
  end
end
