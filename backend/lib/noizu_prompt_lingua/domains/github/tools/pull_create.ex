defmodule NoizuPromptLingua.Domains.Github.Tools.PullCreate do
	use Noizu.MCP.Server.Tool,
		name: "Github.PullCreate",
		description: "Create a new pull request. Requires write access.",
		hidden: false,
		category: "GitHub.Pulls"

	alias NoizuPromptLingua.MCP.{Args, Resolve}
	alias NoizuPromptLingua.Github.Client

	input do
		field :caller_user_id, :string, description: "UUID of the requesting user", required: true
		field :organization, :string, description: "Organization slug or UUID", required: true
		field :repo, :string, description: "Repo UUID or full_name (owner/name)", required: true
		field :title, :string, description: "PR title", required: true
		field :body, :string, description: "PR description", required: false
		field :head, :string, description: "Head branch", required: true
		field :base, :string, description: "Base branch", required: true
	end

	@impl true
	def call(args, _ctx) do
		caller_user_id = Args.get(args, :caller_user_id)
		org_id = Resolve.organization_id(Args.get(args, :organization))
		repo_ref = Args.get(args, :repo)
		body = Map.take([title: Args.get(args, :title), body: Args.get(args, :body), head: Args.get(args, :head), base: Args.get(args, :base)], [:title, :body, :head, :base])
			|> Enum.filter(fn {_, v} -> v != nil end)
			|> Enum.into(%{})

		case {parse_uuid(caller_user_id), ensure_org(org_id)} do
			{{:ok, user_uuid}, {:ok, org}} -> Client.create_pull(user_uuid, org, repo_ref, body)
			{{:ok, _}, {:error, :org_not_found}} -> {:error, :organization_not_found}
			{{:ok, _}, {:error, reason}} -> {:error, reason}
			{:error, _} -> {:error, :invalid_uuid}
		end
	end

	defp parse_uuid(str) do case NoizuPromptLingua.UUID.cast(str) do; {:ok, uuid} -> {:ok, uuid}; :error -> :error; end end
	defp ensure_org(nil), do: {:error, :org_not_found}
	defp ensure_org(org_id), do: {:ok, org_id}
end