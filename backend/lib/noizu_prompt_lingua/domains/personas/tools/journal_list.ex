defmodule NoizuPromptLingua.Domains.Personas.Tools.JournalList do
  use Noizu.MCP.Server.Tool,
    name: "Persona.Journal.List",
    description: "List a persona's work-log/journal entries (most recent first).",
    hidden: true,
    category: "Personas.Journal",
    annotations: [read_only_hint: true]

  input do
    field :persona, :string, required: true, description: "Slug or UUID"

    field :organization, :string,
      description: "Organization slug or UUID (needed to resolve a slug)"

    field :category, :string, description: "Filter: work_log, reflection, decision, note"
    field :limit, :integer, description: "Max entries (default 50)"
  end

  alias NoizuPromptLingua.Domains.Personas
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    key = Args.get(args, :persona)
    org_id = Resolve.organization_id(Args.get(args, :organization))
    persona = (org_id && Personas.resolve(org_id, key)) || Personas.get(key)

    case persona do
      nil ->
        {:error, "Persona '#{key}' not found"}

      p ->
        opts = [limit: Args.get(args, :limit) || 50]
        opts = if c = Args.get(args, :category), do: Keyword.put(opts, :category, c), else: opts
        entries = Personas.list_journal(p.id, opts)

        {:ok,
         %{
           count: length(entries),
           entries:
             Enum.map(entries, fn j ->
               %{
                 id: j.id,
                 category: j.category,
                 title: j.title,
                 body: j.body,
                 actor: j.actor,
                 tags: j.tags,
                 at: j.inserted_at
               }
             end)
         }}
    end
  end
end
