defmodule NoizuPromptLingua.Domains.Projects.Tools.ProjectCreate do
  use Noizu.MCP.Server.Tool,
    name: "Project.Create",
    description: "Create a new project.",
    hidden: true,
    category: "Projects"

  input do
    field :name, :string, required: true, description: "Project name"
    field :slug, :string, required: true, description: "Unique URL slug"
    field :description, :string, description: "Project description"
    field :owner_id, :string, description: "Owner user UUID"
  end

  alias NoizuPromptLingua.Domains.Projects

  @impl true
  def call(args, _ctx) do
    attrs = extract(args, [:name, :slug, :description, :owner_id])

    case Projects.create(attrs) do
      {:ok, project} ->
        {:ok, %{id: project.id, name: project.name, slug: project.slug, status: project.status}}
      {:error, changeset} ->
        {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end

  defp extract(args, keys) do
    Enum.reduce(keys, %{}, fn k, acc ->
      val = args[k] || args[Atom.to_string(k)]
      if val, do: Map.put(acc, k, val), else: acc
    end)
  end
end
