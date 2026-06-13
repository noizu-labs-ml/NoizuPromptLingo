defmodule NoizuPromptLingua.Domains.Projects.Tools.ProjectUpdate do
  use Noizu.MCP.Server.Tool,
    name: "Project.Update",
    description: "Update a project's name, description, or status.",
    hidden: true,
    category: "Projects"

  input do
    field :project, :string, required: true, description: "Project slug or UUID"
    field :name, :string, description: "New name"
    field :description, :string, description: "New description"
    field :status, :string, description: "New status (active|archived)"
  end

  alias NoizuPromptLingua.Domains.Projects

  @impl true
  def call(args, _ctx) do
    key = args[:project] || args["project"]
    attrs = extract(args, [:name, :description, :status])

    case Projects.update(key, attrs) do
      {:ok, project} -> {:ok, %{id: project.id, name: project.name, slug: project.slug, status: project.status}}
      {:error, :not_found} -> {:error, "Project '#{key}' not found"}
      {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end

  defp extract(args, keys) do
    Enum.reduce(keys, %{}, fn k, acc ->
      val = args[k] || args[Atom.to_string(k)]
      if val, do: Map.put(acc, k, val), else: acc
    end)
  end
end
