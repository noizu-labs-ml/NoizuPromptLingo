defmodule NoizuPromptLingua.Domains.Campaigns.Tools.DomainNameUpdate do
  use Noizu.MCP.Server.Tool,
    name: "DomainName.Update",
    description: "Update fields on a domain name.",
    hidden: true,
    category: "Campaigns.Domains"

  input_schema(%{
    "type" => "object",
    "properties" => %{
      "id" => %{"type" => "string", "description" => "Domain name UUID"},
      "name" => %{"type" => "string", "description" => "FQDN"},
      "status" => %{
        "type" => "string",
        "description" => "candidate, available, registered, in_use, expired"
      },
      "registrar" => %{"type" => "string", "description" => "Registrar"},
      "registered_at" => %{"type" => "string", "description" => "Registration date (YYYY-MM-DD)"},
      "expires_at" => %{"type" => "string", "description" => "Expiry date (YYYY-MM-DD)"},
      "campaign_id" => %{"type" => "string", "description" => "Campaign UUID"},
      "metadata" => %{"type" => "object", "description" => "Metadata"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Tags"}
    },
    "required" => ["id"]
  })

  alias NoizuPromptLingua.Domains.Campaigns
  alias NoizuPromptLingua.MCP.Args

  @fields ~w(name status registrar registered_at expires_at campaign_id metadata tags)a

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :id)

    case Campaigns.update_domain_name(id, Args.take(args, @fields)) do
      {:ok, d} -> {:ok, %{id: d.id, slug: d.slug, name: d.name, status: d.status}}
      {:error, :not_found} -> {:error, "Domain name '#{id}' not found"}
      {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end
end
