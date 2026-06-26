defmodule NoizuPromptLingua.Domains.Customers.Tools.SegmentUpdate do
  use Noizu.MCP.Server.Tool,
    name: "CustomerSegment.Update",
    description: "Update fields on a customer segment.",
    hidden: true,
    category: "Customers.Segments"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "id" => %{"type" => "string", "description" => "Segment UUID"},
      "name" => %{"type" => "string", "description" => "Name"},
      "description" => %{"type" => "string", "description" => "Description"},
      "criteria" => %{"type" => "object", "description" => "Filter criteria"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Tags"},
      "status" => %{"type" => "string", "description" => "active or archived"}
    },
    "required" => ["id"]
  }

  alias NoizuPromptLingua.Domains.Customers
  alias NoizuPromptLingua.MCP.Args

  @fields ~w(name description criteria tags status)a

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :id)

    case Customers.update_segment(id, Args.take(args, @fields)) do
      {:ok, s} -> {:ok, %{id: s.id, slug: s.slug, name: s.name, status: s.status}}
      {:error, :not_found} -> {:error, "Customer segment '#{id}' not found"}
      {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end
end
