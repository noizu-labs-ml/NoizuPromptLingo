defmodule NoizuPromptLingua.Domains.Tickets.Tools.FieldDefinitionUpdate do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Field.Definition.Update",
    description: "Update an existing custom field definition.",
    hidden: true,
    category: "Tickets.Fields"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "slug" => %{"type" => "string", "description" => "Field slug to update"},
      "label" => %{"type" => "string", "description" => "New label"},
      "options" => %{"type" => "object", "description" => "New options"},
      "default_value" => %{"type" => "string", "description" => "New default"},
      "description" => %{"type" => "string", "description" => "New help text"}
    },
    "required" => ["slug"]
  }

  alias NoizuPromptLingua.Domains.Tickets.Definitions

  @impl true
  def call(args, _ctx) do
    slug = args["slug"]
    attrs = extract(args, ~w(label options default_value description))

    case Definitions.update_field(slug, attrs) do
      {:ok, field} -> {:ok, %{slug: field.slug, label: field.label, field_type: field.field_type}}
      {:error, :not_found} -> {:error, "Field '#{slug}' not found"}
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
