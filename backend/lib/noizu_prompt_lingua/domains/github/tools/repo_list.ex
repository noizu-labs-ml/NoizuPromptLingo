defmodule NoizuPromptLingua.Domains.Github.Tools.RepoList do
	use Noizu.MCP.Server.Tool,
		name: "Github.RepoList",
		description: "List repositories the caller has read access to within an organization. Reads from local DB.",
		hidden: true,
		category: "GitHub",
		annotations: [read_only_hint: true]

	alias NoizuPromptLingua.MCP.{Args, Resolve}
	alias NoizuPromptLingua.Github.Client

	input do
		field :caller_user_id, :string, description: "UUID of the requesting user"
		field :organization, :string, description: "Organization slug or UUID"
	end

	@impl true
	def call(args, _ctx) do
		caller_user_id = Args.get(args, :caller_user_id)
		org_id = Resolve.organization_id(Args.get(args, :organization))

		case {caller_user_id, org_id} do
			{nil, _} -> {:error, :caller_user_id_required}
			{_, nil} -> {:error, :organization_not_found}
			{user_id, org} when is_binary(user_id) and is_binary(org) ->
				with {:ok, user_uuid} <- parse_uuid(user_id),
						{:ok, result} <- Client.list_repos(user_uuid, org) do
					{:ok, result}
				else
					:error -> {:error, :invalid_uuid}
					error -> error
				end
		end
	end

	defp parse_uuid(str) do
		case Ecto.UUID.cast(str) do
			{:ok, uuid} -> {:ok, uuid}
			:error -> :error
		end
	end
end