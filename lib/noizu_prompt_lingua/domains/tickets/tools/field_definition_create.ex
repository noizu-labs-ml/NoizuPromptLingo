defmodule NoizuPromptLingua.Domains.Tickets.Tools.FieldDefinitionCreate do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Field.Definition.Create",
    description: "Define a custom field type for use in ticket type definitions.",
    hidden: true,
    category: "Tickets.Fields"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "slug" => %{"type" => "string", "description" => "Unique slug (e.g. \"story_points\")"},
      "label" => %{"type" => "string", "description" => "Display label"},
      "field_type" => %{"type" => "string", "description" => "One of: text, rich_text, markdown, radio, select, multi_select, number, date, persona, url"},
      "options" => %{"type" => "object", "description" => "For select/radio/multi_select: {values: [{value, label}]}"},
      "default_value" => %{"type" => "string", "description" => "Default value"},
      "description" => %{"type" => "string", "description" => "Help text"}
    },
    "required" => ["slug", "label", "field_type"]
  }

  alias NoizuPromptLingua.Domains.Tickets.Definitions

  @impl true
  def call(args, _ctx) do
    attrs = extract(args, ~w(slug label field_type options default_value description))

    case Definitions.create_field(attrs) do
      {:ok, field} ->
        {:ok, %{slug: field.slug, label: field.label, field_type: field.field_type}}
      {:error, changeset} ->
        {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end

  defp extract(args, keys) do
    Enum.reduce(keys, %{}, fn k, acc ->
      val = args[k] || args[String.to_atom(k)]
      if val, do: Map.put(acc, String.to_atom(k), val), else: acc
    end)
  end
end
