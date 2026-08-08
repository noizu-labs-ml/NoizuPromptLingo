defmodule Mix.Tasks.Npl.SeedPersonaMembers do
  @shortdoc "Seed an org's personas as scoped members of the org (+ a project)"
  @moduledoc """
  Seeds every persona in an organization as a PBAC scoped member of BOTH that
  organization AND one of its projects, so they surface in the agents/members
  view (the persona-as-member path, ccaf5684 / ADR-017). Built for the
  work-group demo: the ~13 work-group personas become members of org
  `noizu-labs` and project `noizu-infra`.

      mix npl.seed_persona_members                       # noizu-labs / noizu-infra
      mix npl.seed_persona_members <org_slug>            # org only (no project scope)
      mix npl.seed_persona_members <org_slug> <proj_slug>

  Roles: 'member' for everyone, except the lane-lead personas
  (`marcus-dev`, `priya-frontend`, `dmitri-architect`, `hana-pm`) which are
  seeded as 'lead' — a best-effort map of the coordinator/lead handles per
  marcus's dispatch; everyone else falls back to 'member'.

  **Idempotent / re-runnable.** Each add goes through
  `ScopedMemberships.add_persona_member/4`, which inserts `on_conflict: :nothing`
  on the (resource, member) unique key, so re-running never duplicates a row.
  A row that already exists is reported as `existing`, not `added`.

  This is a WRITE task. Running it against prod is gated on demo-prep — do not
  run it against a production DB unprompted.
  """
  use Mix.Task

  alias NoizuPromptLingua.Domains.Personas
  alias NoizuPromptLingua.Authz.ScopedMemberships
  alias NoizuPromptLingua.Schema.Authz.ScopedMembership, as: MembershipSchema

  @requirements ["app.start"]

  @default_org "noizu-labs"
  @default_project "noizu-infra"

  # Best-effort lead mapping: the lane-lead / coordinator personas get 'lead',
  # the rest 'member'. Public so the @moduledoc and tests can reference it.
  @lead_slugs ~w(marcus-dev priya-frontend dmitri-architect hana-pm)
  def lead_slugs, do: @lead_slugs

  @impl Mix.Task
  def run(args) do
    {org_slug, project_slug} =
      case args do
        [] -> {@default_org, @default_project}
        [org] -> {org, nil}
        [org, project | _] -> {org, project}
      end

    with {:ok, org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_slug),
         {:ok, project_id} <- resolve_project(org_id, project_slug) do
      summary = seed_members(org_id, project_id)
      report(org_slug, project_slug, summary)
    else
      {:error, :not_found} ->
        Mix.raise("Organization '#{org_slug}' not found")

      {:error, {:project_not_found, slug}} ->
        Mix.raise("Project '#{slug}' not found in organization '#{org_slug}'")
    end
  end

  # Resolve a project slug to its id WITHIN the org (projects are unique per
  # org/slug). nil slug -> org-only seed (project_id nil).
  defp resolve_project(_org_id, nil), do: {:ok, nil}

  defp resolve_project(org_id, slug) do
    case NoizuPromptLingua.Repo.get_by(NoizuPromptLingua.Schema.Projects.Project,
           organization_id: org_id,
           slug: slug
         ) do
      nil -> {:error, {:project_not_found, slug}}
      project -> {:ok, project.id}
    end
  end

  @doc """
  Core, side-effecting seed. Takes already-resolved UUIDs (so it has no slug-cache
  / Redis dependency and is directly testable). Seeds every persona in `org_id`
  as a member of the org, and — when `project_id` is non-nil — of the project too.
  Returns a summary map: `%{personas: n, organization: counts, project: counts | nil}`
  where each `counts` is `%{added: a, existing: e, errors: [..]}`.
  """
  def seed_members(org_id, project_id, _opts \\ []) do
    personas = Personas.list(organization_id: org_id, limit: 1000)

    org_counts = seed_scope("organization", org_id, personas)

    project_counts =
      if project_id, do: seed_scope("project", project_id, personas), else: nil

    %{personas: length(personas), organization: org_counts, project: project_counts}
  end

  defp seed_scope(resource_type, resource_id, personas) do
    Enum.reduce(personas, %{added: 0, existing: 0, errors: []}, fn persona, acc ->
      role = role_for(persona.slug)
      pre_existing? = member?(resource_type, resource_id, persona.id)

      case ScopedMemberships.add_persona_member(resource_type, resource_id, persona.id, role) do
        {:ok, _} when pre_existing? ->
          %{acc | existing: acc.existing + 1}

        {:ok, _} ->
          %{acc | added: acc.added + 1}

        {:error, reason} ->
          %{acc | errors: [{persona.slug, reason} | acc.errors]}
      end
    end)
  end

  defp member?(resource_type, resource_id, persona_id) do
    NoizuPromptLingua.Repo.get_by(MembershipSchema,
      resource_type: resource_type,
      resource_id: resource_id,
      member_type: "persona",
      member_id: persona_id
    ) != nil
  end

  defp role_for(slug) when slug in @lead_slugs, do: "lead"
  defp role_for(_slug), do: "member"

  defp report(org_slug, project_slug, %{personas: n, organization: org, project: proj}) do
    Mix.shell().info("Seeded #{n} persona(s) from org '#{org_slug}':")
    Mix.shell().info("  organization: #{scope_line(org)}")

    if proj do
      Mix.shell().info("  project '#{project_slug}': #{scope_line(proj)}")
    else
      Mix.shell().info("  project: (skipped — no project slug given)")
    end

    for {scope, %{errors: errors}} <- [{"organization", org}, {"project", proj}],
        is_list(errors) and errors != [] do
      Mix.shell().error("  #{scope} errors: #{inspect(errors)}")
    end
  end

  defp scope_line(%{added: a, existing: e, errors: errs}),
    do: "#{a} added, #{e} already present, #{length(errs)} error(s)"
end
