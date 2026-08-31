defmodule NoizuPromptLingua.Repo.Migrations.OrgSlugUniqueness do
  use Ecto.Migration

  @moduledoc """
  Org-slug normalization + named unique index (Liquibase 081-org-slug-uniqueness
  twin). Ecto mirrors are the prod-apply path (Helm gates Liquibase off), so
  this must be independently safe: already-clean rows are skipped and the index
  is IF NOT EXISTS. Collision rule (suffix -2, -3, …) matches the unit-tested
  NoizuPromptLingua.Organizations.SlugBackfill reference implementation.
  """

  @normalize ~S"""
  DO $$
  DECLARE
    r record;
    base text;
    candidate text;
    n int;
  BEGIN
    FOR r IN SELECT id, slug, name FROM organizations LOOP
      base := lower(regexp_replace(
        coalesce(nullif(btrim(coalesce(r.slug, '')), ''), r.name, r.id::text),
        '[^a-z0-9]+', '-', 'g'));
      base := btrim(base, '-');
      IF base IS NULL OR base = '' THEN
        base := 'org-' || left(r.id::text, 8);
      END IF;
      base := left(base, 64);
      candidate := base;
      n := 1;
      WHILE EXISTS (
        SELECT 1 FROM organizations o
        WHERE o.slug = candidate AND o.id <> r.id
      ) LOOP
        n := n + 1;
        candidate := base || '-' || n::text;
      END LOOP;
      IF candidate <> r.slug THEN
        UPDATE organizations
          SET slug = candidate, updated_at = now()
          WHERE id = r.id;
      END IF;
    END LOOP;
  END $$;
  """

  def up do
    execute(@normalize)
    execute("CREATE UNIQUE INDEX IF NOT EXISTS idx_organizations_slug ON organizations (slug)")
  end

  def down do
    # The named index only; normalized slugs are kept (data fix, not a schema
    # fix — restoring whitespace would be restoring damage).
    execute("DROP INDEX IF EXISTS idx_organizations_slug")
  end
end
