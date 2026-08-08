defmodule NoizuPromptLingua.Domains.Instructions.Tools.InstructionList do
  use Noizu.MCP.Server.Tool,
    name: "Instruction.List",
    description: "List/search instructions in an organization (optional project/tag/query).",
    hidden: true,
    category: "Instructions",
    annotations: [read_only_hint: true]

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :project, :string, description: "Optional project slug or UUID filter"
    field :status, :string, description: "active or archived"
    field :tag, :string
    field :query, :string, description: "Text search over slug/title/description"
  end

  alias NoizuPromptLingua.Domains.Instructions
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    case Resolve.scope(Args.get(args, :organization), Args.get(args, :project)) do
      {:ok, org_id, project_id} ->
        opts =
          [organization_id: org_id]
          |> put_opt(:project_id, project_id)
          |> put_opt(:status, Args.get(args, :status))
          |> put_opt(:tag, Args.get(args, :tag))
          |> put_opt(:query, Args.get(args, :query))

        instructions = Instructions.list(opts)

        {:ok,
         %{
           count: length(instructions),
           instructions:
             Enum.map(instructions, fn i ->
               %{
                 id: i.id,
                 slug: i.slug,
                 title: i.title,
                 description: i.description,
                 tags: i.tags,
                 status: i.status,
                 active_version: i.active_version,
                 param_count: length(i.parameters || [])
               }
             end)
         }}

      {:error, :org_not_found} ->
        {:error, "Organization not found"}

      {:error, _} ->
        {:error, "Invalid project"}
    end
  end

  defp put_opt(opts, _k, nil), do: opts
  defp put_opt(opts, k, v), do: Keyword.put(opts, k, v)
end
