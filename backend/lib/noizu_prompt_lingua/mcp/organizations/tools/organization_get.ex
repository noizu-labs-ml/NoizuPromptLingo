defmodule NoizuPromptLingua.MCP.Organizations.Tools.OrganizationGet do
  use Noizu.MCP.Server.Tool,
    name: "Organization.Get",
    description: "Get an organization by slug or UUID.",
    hidden: false,
    category: "Organizations",
    annotations: [read_only_hint: true]

  alias NoizuPromptLingua.MCP.{Args, Resolve}

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
  end

  @impl true
  def call(args, _ctx) do
    ref = Args.get(args, :organization)

    case Resolve.organization(ref) do
      nil ->
        {:error, "Organization '#{ref}' not found"}

      # TRP degrades as error tuples (un-activated deploys: {:error,
      # :trp_not_configured}; transport failures: {:error, {:transport, _}}).
      # Those must render the graceful error family (same phrasing as the REST
      # side's TRP response helper), not crash — a crash surfaces as the opaque
      # "Tool execution failed" wrapper (seen live on stage, 2026-09-04).
      {:error, :trp_not_configured} ->
        {:error, "PM backend not configured"}

      {:error, _reason} ->
        {:error, "PM backend unavailable"}

      org ->
        # Post-TRP-cutover (W4) orgs are `Shapes.organization` maps
        # (id/slug/name/role/owner); the legacy pm_core schema's `settings`
        # map has no TRP shared-key counterpart (spec §4.1), so the key is
        # preserved with a %{} default instead of dropped — the MCP response
        # shape stays stable and dot-access never crashes on the new shape.
        {:ok,
         %{
           id: org.id,
           name: org.name,
           slug: org.slug,
           settings: Map.get(org, :settings, %{}),
           role: Map.get(org, :role),
           owner: Map.get(org, :owner)
         }}
    end
  end
end
