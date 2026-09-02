defmodule NoizuPromptLingua.Repo.Migrations.BrowserCaptureResourceTypes do
  use Ecto.Migration

  # Liquibase 084-browser-capture-resource-types twin. The `media.owner_type`
  # column is typed `resource_type_enum`, but browser captures store
  # `browser_screenshot` / `browser_video` — both missing from the enum, so
  # `Browser.list_captures/2` (and media registration for captures) raised
  # Postgrex 22P02 → 500 (stage log c6322). Mirrors 029's github_repo ADD VALUE.
  #
  # ALTER TYPE ... ADD VALUE cannot run in a transaction on older Postgres, so
  # DDL transactions are disabled for this migration.
  @disable_ddl_transaction true
  @disable_migration_lock true

  def up do
    execute("ALTER TYPE resource_type_enum ADD VALUE IF NOT EXISTS 'browser_screenshot'")
    execute("ALTER TYPE resource_type_enum ADD VALUE IF NOT EXISTS 'browser_video'")
  end

  def down do
    # Postgres cannot remove an enum value; recreate the type without the two
    # browser values (same strategy as 029's rollback).
    execute("""
    ALTER TYPE resource_type_enum RENAME TO resource_type_enum_browser_old
    """)

    execute("""
    CREATE TYPE resource_type_enum AS ENUM ('organization', 'project', 'github_repo')
    """)

    execute("""
    ALTER TABLE media ALTER COLUMN owner_type TYPE resource_type_enum
      USING owner_type::text::resource_type_enum
    """)

    execute("""
    ALTER TABLE scoped_memberships ALTER COLUMN resource_type TYPE resource_type_enum
      USING resource_type::text::resource_type_enum
    """)

    execute("DROP TYPE resource_type_enum_browser_old")
  end
end
