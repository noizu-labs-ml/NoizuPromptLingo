defmodule NoizuPromptLingua.Domains.Github.Tools.IssueComment do
	use Noizu.MCP.Server.Tool,
		name: "Github.IssueComment",
		description: "Create a comment on an issue. Requires write access.",
		hidden: false,
		category: "GitHub.Issues"

	alias NoizuPromptLingua.MCP.{Args, Resolve}
	alias NoizuPromptLingua.Github.Client

	input do
		field :caller_user_id, :string, description: "UUID of the requesting user", required: true
		field :organization, :string, description: "Organization slug or UUID", required: true
		field :repo, :string, description: "Repo UUID or full_name (owner/name)", required: true
		field :issue_number, :integer, description: "Issue number", required: true
		field :body, :string, description: "Comment body", required: true
	end

	@impl true
	def call(args, _ctx) do
		caller_user_id = Args.get(args, :caller_user_id)
		org_id = Resolve.organization_id(Args.get(args, :organization))
		repo_ref = Args.get(args, :repo)
		issue_number = Args.get(args, :issue_number)
		body = Args.get(args, :body)

		case {parse_uuid(caller_user_id), ensure_org(org_id)} do
			{{:ok, user_uuid}, {:ok, org}} -> Client.comment_issue(user_uuid, org, repo_ref, issue_number, %{body: body})
			{{:ok, _}, {:error, :org_not_found}} -> {:error, :organization_not_found}
			{{:ok, _}, {:error, reason}} -> {:error, reason}
			{{:error, _}, _} -> {:error, :invalid_uuid}
		end
	end

	defp parse_uuid(str) do case NoizuPromptLingua.UUID.cast(str) do; {:ok, uuid} -> {:ok, uuid}; :error -> :error; end end
	defp ensure_org(nil), do: {:error, :org_not_found}
	defp ensure_org(org_id), do: {:ok, org_id}
end