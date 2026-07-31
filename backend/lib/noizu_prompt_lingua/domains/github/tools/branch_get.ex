defmodule NoizuPromptLingua.Domains.Github.Tools.BranchGet do
  use Noizu.MCP.Server.Tool,
    name: "Github.BranchGet",
    description: "Get details of a specific branch in a repo. Requires read access.",
    hidden: true,
    category: "GitHub",
    annotations: [read_only_hint: true]

  alias NoizuPromptLingua.MCP.{Args, Resolve}
  alias NoizuPromptLingua.Github.Client

  input do
    field :caller_user_id, :string, description: "UUID of the requesting user", required: true
    field :organization, :string, description: "Organization slug or UUID", required: true
    field :repo, :string, description: "Repo UUID or full_name (owner/name)", required: true
    field :branch_name, :string, description: "Name of the branch to fetch", required: true
  end

  @impl true
  def call(args, _ctx) do
    caller_user_id = Args.get(args, :caller_user_id)
    org_id = Resolve.organization_id(Args.get(args, :organization))
    repo_ref = Args.get(args, :repo)
    branch_name = Args.get(args, :branch_name)

    case {parse_uuid(caller_user_id), ensure_org(org_id)} do
      {{:ok, user_uuid}, {:ok, org}} -> Client.get_branch(user_uuid, org, repo_ref, branch_name)
      {{:ok, _}, {:error, :org_not_found}} -> {:error, :organization_not_found}
      {{:ok, _}, {:error, reason}} -> {:error, reason}
      {:error, _} -> {:error, :invalid_uuid}
    end
  end

  defp parse_uuid(str) do
    case NoizuPromptLingua.UUID.cast(str) do
      {:ok, uuid} -> {:ok, uuid}
      :error -> :error
    end
  end

  defp ensure_org(nil), do: {:error, :org_not_found}
  defp ensure_org(org_id), do: {:ok, org_id}
end
