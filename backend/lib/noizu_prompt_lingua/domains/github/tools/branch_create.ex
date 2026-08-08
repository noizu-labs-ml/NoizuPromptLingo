defmodule NoizuPromptLingua.Domains.Github.Tools.BranchCreate do
  use Noizu.MCP.Server.Tool,
    name: "Github.BranchCreate",
    description: "Create a new branch from a commit SHA in a repo. Requires write access.",
    hidden: false,
    category: "GitHub"

  alias NoizuPromptLingua.MCP.{Args, Resolve}
  alias NoizuPromptLingua.Github.Client

  input do
    field :caller_user_id, :string, description: "UUID of the requesting user", required: true
    field :organization, :string, description: "Organization slug or UUID", required: true
    field :repo, :string, description: "Repo UUID or full_name (owner/name)", required: true
    field :branch_name, :string, description: "Name of the branch to create", required: true
    field :from_sha, :string, description: "Commit SHA to branch from", required: true
  end

  @impl true
  def call(args, _ctx) do
    caller_user_id = Args.get(args, :caller_user_id)
    org_id = Resolve.organization_id(Args.get(args, :organization))
    repo_ref = Args.get(args, :repo)
    branch_name = Args.get(args, :branch_name)
    from_sha = Args.get(args, :from_sha)

    with {:ok, user_uuid} <- parse_uuid(caller_user_id),
         {:ok, org} <- ensure_org(org_id),
         {:ok, result} <- Client.create_branch(user_uuid, org, repo_ref, branch_name, from_sha) do
      {:ok, result}
    else
      :error -> {:error, :invalid_uuid}
      {:error, reason} -> {:error, reason}
    end
  end

  defp parse_uuid(str) do
    case NoizuPromptLingua.UUID.cast(str) do
      {:ok, uuid} -> {:ok, uuid}
      :error -> :error
    end
  end

  defp ensure_org(nil), do: {:error, :organization_not_found}
  defp ensure_org(org_id), do: {:ok, org_id}
end
