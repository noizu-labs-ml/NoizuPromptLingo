defmodule NoizuPromptLingua.Domains.Personas.Tools.JournalAdd do
  use Noizu.MCP.Server.Tool,
    name: "Persona.Journal.Add",
    description: "Append a work-log/journal entry to a persona.",
    hidden: true,
    category: "Personas.Journal"

  input do
    field :persona, :string, required: true, description: "Slug or UUID"

    field :organization, :string,
      description: "Organization slug or UUID (needed to resolve a slug)"

    field :body, :string, required: true, description: "Entry text"
    field :category, :string, description: "work_log, reflection, decision, note"
    field :title, :string
    field :actor, :string, description: "Who logged this"
    field :tags, {:array, :string}
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
        attrs = Args.take(args, [:body, :category, :title, :actor, :tags])

        case Personas.add_journal_entry(p.id, attrs) do
          {:ok, j} -> {:ok, %{id: j.id, category: j.category, at: j.inserted_at}}
          {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
        end
    end
  end
end
