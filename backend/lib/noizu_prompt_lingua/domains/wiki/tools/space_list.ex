defmodule NoizuPromptLingua.Domains.Wiki.Tools.SpaceList do
  use Noizu.MCP.Server.Tool,
    name: "Wiki.SpaceList",
    description: "List wiki spaces in an organization, optionally filtered by project or search.",
    hidden: true,
    category: "Wiki",
    annotations: [read_only_hint: true]

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :project, :string, description: "Filter by project slug or UUID"
    field :search, :string, description: "Search in name or slug"
    field :limit, :integer, description: "Max results (default 100)"
  end

  alias NoizuPromptLingua.Domains.Wiki
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)

    case Resolve.organization_id(org_ref) do
      nil ->
        {:error, "Organization '#{org_ref}' not found"}

      org_id ->
        project = Resolve.project(Args.get(args, :project))

        opts =
          [organization_id: org_id]
          |> put_opt(:search, Args.get(args, :search))
          |> put_opt(:limit, Args.get(args, :limit))
          |> then(fn opts -> if project, do: [{:project_id, project.id} | opts], else: opts end)

        spaces = Wiki.list_spaces(opts)

        {:ok, %{
          spaces: Enum.map(spaces, fn s ->
            %{id: s.id, slug: s.slug, name: s.name, description: s.description, project_id: s.project_id}
          end),
          count: length(spaces)
        }}
    end
  end

  defp put_opt(opts, _k, nil), do: opts
  defp put_opt(opts, k, v), do: [{k, v} | opts]
end
