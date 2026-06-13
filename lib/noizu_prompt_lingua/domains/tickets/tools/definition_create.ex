defmodule NoizuPromptLingua.Domains.Tickets.Tools.DefinitionCreate do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Definition.Create",
    description: "Define a ticket type with custom field schema and status workflow.",
    hidden: true,
    category: "Tickets.Types"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "slug" => %{"type" => "string", "description" => "Unique slug (e.g. \"bug\", \"epic\")"},
      "name" => %{"type" => "string", "description" => "Display name"},
      "description" => %{"type" => "string", "description" => "Type description"},
      "icon" => %{"type" => "string", "description" => "Emoji or icon key"},
      "status_workflow" => %{"type" => "object", "description" => "{statuses: [...], transitions: {status: [targets]}}"},
      "fields" => %{"type" => "array", "description" => "Array of {slug, required} field assignments",
        "items" => %{"type" => "object", "properties" => %{
          "slug" => %{"type" => "string"},
          "required" => %{"type" => "boolean"}
        }}}
    },
    "required" => ["slug", "name"]
  }

  alias NoizuPromptLingua.Domains.Tickets.Definitions

  @impl true
  def call(args, _ctx) do
    attrs = extract(args, ~w(slug name description icon status_workflow))

    case Definitions.create_type(attrs) do
      {:ok, type_def} ->
        field_specs = args["fields"] || []
        Enum.each(field_specs, fn spec ->
          slug = spec["slug"]
          required = spec["required"] || false
          Definitions.add_field_to_type(type_def.slug, slug, required: required)
        end)
        {:ok, %{slug: type_def.slug, name: type_def.name}}

      {:error, changeset} ->
        {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end

  defp extract(args, keys) do
    Enum.reduce(keys, %{}, fn k, acc ->
      val = args[k]
      if val, do: Map.put(acc, String.to_atom(k), val), else: acc
    end)
  end
end
