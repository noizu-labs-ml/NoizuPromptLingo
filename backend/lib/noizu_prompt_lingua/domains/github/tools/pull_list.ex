defmodule NoizuPromptLingua.Domains.Github.Tools.PullList do
	use Noizu.MCP.Server.Tool,
		name: "Github.PullList",
		description: "List pull requests for a repository. Requires read access.",
		hidden: true,
		category: "GitHub.Pulls",
		annotations: [read_only_hint: true]

	alias NoizuPromptLingua.MCP.{Args, Resolve}
	alias NoizuPromptLingua.Github.Client

	input do
		field :caller_user_id, :string, description: "UUID of the requesting user", required: true
		field :organization, :string, description: "Organization slug or UUID", required: true
		field :repo, :string, description: "Repo UUID or full_name (owner/name)", required: true
		field :state, :string, description: "Filter by state (open|closed|all)", required: false
		field :page, :integer, description: "Page number", required: false
		field :per_page, :integer, description: "Items per page", required: false
	end

	@impl true
	def call(args, _ctx) do
		caller_user_id = Args.get(args, :caller_user_id)
		org_id = Resolve.organization_id(Args.get(args, :organization))
		repo_ref = Args.get(args, :repo)

		opts = Keyword.take([state: Args.get(args, :state), page: Args.get(args, :page), per_page: Args.get(args, :per_page)], [:state, :page, :per_page])
			|> Enum.filter(fn {_, v} -> v != nil end)

		case {parse_uuid(caller_user_id), ensure_org(org_id)} do
			{{:ok, user_uuid}, {:ok, org}} -> Client.list_pulls(user_uuid, org, repo_ref, opts)
			{{:ok, _}, {:error, :org_not_found}} -> {:error, :organization_not_found}
			{{:ok, _}, {:error, reason}} -> {:error, reason}
			{{:error, _}, _} -> {:error, :invalid_uuid}
		end
	end

	defp parse_uuid(str) do case NoizuPromptLingua.UUID.cast(str) do; {:ok, uuid} -> {:ok, uuid}; :error -> :error; end end
	defp ensure_org(nil), do: {:error, :org_not_found}
	defp ensure_org(org_id), do: {:ok, org_id}
end