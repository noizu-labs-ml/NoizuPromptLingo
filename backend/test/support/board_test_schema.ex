defmodule NoizuPromptLingua.BoardTestSchema do
  @moduledoc """
  Idempotently brings `ticket_queues` up to the Liquibase 038-boards schema on the
  test DB — the org/project/methodology/config columns and the three partial unique
  slug indexes — so the boards/queues suite is self-contained on top of whatever
  Liquibase state the test DB has. Mirrors `ChatTestSchema` / `MemoryTestSchema`.

  Why this is needed: `ticket_queues` is created at 035 and EXTENDED at 038. A test DB
  that only ran through 035 (as the shared instance did — `ticket_queues` had zero test
  coverage, so the gap was invisible) is missing `config`/`organization_id`/`project_id`/
  `methodology`, and `Queues.create` 500s on the missing `config` column. These
  IF-NOT-EXISTS statements close that gap without depending on a full Liquibase run.
  038 is committed + in master, so prod already has these columns — this only reconciles
  the test DB.
  """
  alias NoizuPromptLingua.Repo

  @statements [
    # 038 drops the original global-unique-on-slug index in favor of the three partial
    # indexes below; drop it here too so the test DB matches prod (slugs may repeat
    # across scopes).
    "DROP INDEX IF EXISTS idx_ticket_queues_slug",
    "ALTER TABLE ticket_queues ADD COLUMN IF NOT EXISTS organization_id uuid REFERENCES organizations(id) ON DELETE CASCADE",
    "ALTER TABLE ticket_queues ADD COLUMN IF NOT EXISTS project_id uuid REFERENCES projects(id) ON DELETE CASCADE",
    "ALTER TABLE ticket_queues ADD COLUMN IF NOT EXISTS methodology varchar(255) NOT NULL DEFAULT 'kanban'",
    "ALTER TABLE ticket_queues ADD COLUMN IF NOT EXISTS config jsonb NOT NULL DEFAULT '{}'",
    """
    CREATE UNIQUE INDEX IF NOT EXISTS idx_ticket_queues_global_slug
    ON ticket_queues (slug) WHERE organization_id IS NULL AND project_id IS NULL
    """,
    """
    CREATE UNIQUE INDEX IF NOT EXISTS idx_ticket_queues_org_slug
    ON ticket_queues (organization_id, slug) WHERE organization_id IS NOT NULL AND project_id IS NULL
    """,
    """
    CREATE UNIQUE INDEX IF NOT EXISTS idx_ticket_queues_project_slug
    ON ticket_queues (organization_id, project_id, slug) WHERE project_id IS NOT NULL
    """,
    # 038 also creates board_stages + board_iterations and adds tickets.stage_id/iteration_id;
    # the test DB lagged ALL of 038, and Queues.create seeds default stages on insert.
    """
    CREATE TABLE IF NOT EXISTS board_stages (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      queue_id uuid NOT NULL REFERENCES ticket_queues(id) ON DELETE CASCADE,
      slug varchar(255) NOT NULL,
      name varchar(255) NOT NULL,
      kind varchar(255) NOT NULL DEFAULT 'stage',
      position integer NOT NULL DEFAULT 0,
      wip_limit integer,
      config jsonb NOT NULL DEFAULT '{}',
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )
    """,
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_board_stages_queue_slug ON board_stages (queue_id, slug)",
    "CREATE INDEX IF NOT EXISTS idx_board_stages_queue_position ON board_stages (queue_id, position)",
    """
    CREATE TABLE IF NOT EXISTS board_iterations (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      queue_id uuid NOT NULL REFERENCES ticket_queues(id) ON DELETE CASCADE,
      name varchar(255) NOT NULL,
      sequence integer NOT NULL DEFAULT 0,
      status varchar(255) NOT NULL DEFAULT 'planned' CHECK (status IN ('planned', 'active', 'completed')),
      goal text,
      starts_on date,
      ends_on date,
      config jsonb NOT NULL DEFAULT '{}',
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )
    """,
    "CREATE INDEX IF NOT EXISTS idx_board_iterations_queue_seq ON board_iterations (queue_id, sequence)",
    "CREATE INDEX IF NOT EXISTS idx_board_iterations_status ON board_iterations (queue_id, status)",
    "ALTER TABLE tickets ADD COLUMN IF NOT EXISTS stage_id uuid REFERENCES board_stages(id) ON DELETE SET NULL",
    "ALTER TABLE tickets ADD COLUMN IF NOT EXISTS iteration_id uuid REFERENCES board_iterations(id) ON DELETE SET NULL",
    "CREATE INDEX IF NOT EXISTS idx_tickets_stage_id ON tickets (stage_id)",
    "CREATE INDEX IF NOT EXISTS idx_tickets_iteration_id ON tickets (iteration_id)"
  ]

  def ensure! do
    Enum.each(@statements, fn sql -> Ecto.Adapters.SQL.query!(Repo, sql, []) end)
    :ok
  end
end
