defmodule NoizuPromptLingua.Domains.Tickets.Tools.DefinitionUpdate do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Definition.Update",
    description: "Update a ticket type definition.",
    hidden: true,
    category: "Tickets.Types"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "slug" => %{"type" => "string", "description" => "Type slug to update"},
      "name" => %{"type" => "string", "description" => "New display name"},
      "description" => %{"type" => "string", "description" => "New description"},
      "icon" => %{"type" => "string", "description" => "New icon"},
      "status_workflow" => %{"type" => "object", "description" => "New status workflow"}
    },
    "required" => ["slug"]
  }

  alias NoizuPromptLingua.Domains.Tickets.Definitions

  @impl true
  def call(args, _ctx) do
    slug = args["slug"]
    attrs = extract(args, ~w(name description icon status_workflow))

    case Definitions.update_type(slug, attrs) do
      {:ok, type_def} -> {:ok, %{slug: type_def.slug, name: type_def.name}}
      {:error, :not_found} -> {:error, "Type '#{slug}' not found"}
      {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end

  defp extract(args, keys) do
    Enum.reduce(keys, %{}, fn k, acc ->
      val = args[k]
      if val, do: Map.put(acc, String.to_atom(k), val), else: acc
    end)
  end
end
