defmodule NoizuPromptLingua.Organizations.SlugBackfill do
  @moduledoc """
  Org-slug normalization + collision-safe backfill for the slug-URL work
  (`082-org-slug-uniqueness` Liquibase changeset / Ecto twin).

  `organizations.slug` is the primary segment of the canonical custom-MCP URL
  (`/org/<org_slug>/custom/<slug>/mcp`), so it must be clean and unique. The
  SQL changeset does the same normalization inline; these pure functions are
  the unit-tested reference implementation.

  Note pm_core — the authoritative org store post-cutover — already enforces
  `slug citext NOT NULL UNIQUE` (vendor 006-organizations.yaml). This module
  targets the legacy app-DB table, where the inline UNIQUE constraint exists
  but slugs may still be unnormalized (whitespace, mixed separators).
  """

  @max_length 64

  @doc """
  Slugify a slug/name: lowercase, every run of non-`[a-z0-9]` collapsed to a
  single `-`, edges trimmed, capped at #{@max_length}. Blank or fully
  non-alphanumeric input yields nil.
  """
  def slugify(nil), do: nil

  def slugify(value) when is_binary(value) do
    value
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
    |> String.slice(0, @max_length)
    |> String.trim_trailing("-")
    |> case do
      "" -> nil
      slug -> slug
    end
  end

  def slugify(_), do: nil

  @doc """
  Plan final slugs for `rows` (`%{id, slug, name}` maps). Deterministic:
  rows claim candidates in input order, first claim wins; a candidate already
  taken gets a `-2`, `-3`, … suffix. Each row's candidate is
  `slugify(slug) || slugify(name) || "org-" <> first-8-of-id`.

  Returns `%{id => final_slug}` covering every row.
  """
  def plan(rows) when is_list(rows) do
    {_taken, planned} =
      Enum.reduce(rows, {MapSet.new(), %{}}, fn row, {taken, planned} ->
        final = claim(candidate(row), taken, 1)
        {MapSet.put(taken, final), Map.put(planned, row.id, final)}
      end)

    planned
  end

  @doc """
  The subset of the plan that differs from the row's current slug:
  `[{id, from_slug, to_slug}]` — exactly the updates `run/0` applies.
  """
  def changes(rows) when is_list(rows) do
    planned = plan(rows)

    Enum.flat_map(rows, fn %{id: id, slug: from} ->
      to = Map.fetch!(planned, id)
      if from != to, do: [{id, from, to}], else: []
    end)
  end

  @doc """
  Apply the plan to the app-DB organizations table inside one transaction.
  Returns `{:ok, updated_count}`. Rows already normalized are left untouched,
  so re-running converges (idempotent).
  """
  def run do
    import Ecto.Query, only: [from: 2]

    alias NoizuPromptLingua.Repo
    alias NoizuPromptLingua.Schema.Organizations.Organization

    rows = Repo.all(from(o in Organization, select: %{id: o.id, slug: o.slug, name: o.name}))
    updates = changes(rows)

    {:ok, _} =
      Repo.transaction(fn ->
        Enum.each(updates, fn {id, _from, to} ->
          Repo.get!(Organization, id)
          |> Ecto.Changeset.change(slug: to)
          |> Repo.update!()
        end)
      end)

    {:ok, length(updates)}
  end

  defp candidate(%{slug: slug, name: name, id: id}) do
    slugify(slug) || slugify(name) || "org-" <> String.slice(to_string(id), 0, 8)
  end

  defp claim(candidate, taken, 1) do
    if MapSet.member?(taken, candidate) do
      claim(candidate, taken, 2)
    else
      candidate
    end
  end

  defp claim(base, taken, n) do
    candidate = "#{base}-#{n}"

    if MapSet.member?(taken, candidate) do
      claim(base, taken, n + 1)
    else
      candidate
    end
  end
end
