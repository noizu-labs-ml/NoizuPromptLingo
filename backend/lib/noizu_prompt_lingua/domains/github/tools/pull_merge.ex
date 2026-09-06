defmodule NoizuPromptLingua.Domains.Github.Tools.PullMerge do
  use Noizu.MCP.Server.Tool,
    name: "Github.PullMerge",
    description: "Merge a pull request. Requires write access.",
    hidden: false,
    category: "GitHub.Pulls"

  alias NoizuPromptLingua.MCP.{Args, Resolve}
  alias NoizuPromptLingua.Github.Client

  input do
    field :caller_user_id, :string, description: "UUID of the requesting user", required: true
    field :organization, :string, description: "Organization slug or UUID", required: true
    field :repo, :string, description: "Repo UUID or full_name (owner/name)", required: true
    field :pull_number, :integer, description: "Pull request number", required: true
    field :commit_title, :string, description: "Merge commit title", required: false

    field :merge_method, :string,
      description: "Merge method (merge|squash|rebase)",
      required: false
  end

  @impl true
  def call(args, _ctx) do
    caller_user_id = Args.get(args, :caller_user_id)
    org_id = Resolve.organization_id(Args.get(args, :organization))
    repo_ref = Args.get(args, :repo)
    pull_number = Args.get(args, :pull_number)

    # Map.new/1 first: the literal was a keyword list, and Map.take/2 requires a
    # map — as written these tools raised BadMapError on every call (cov/w5b).
    body =
      Map.new(
        commit_title: Args.get(args, :commit_title),
        merge_method: Args.get(args, :merge_method)
      )
      |> Map.take([:commit_title, :merge_method])
      |> Enum.filter(fn {_, v} -> v != nil end)
      |> Enum.into(%{})

    case {parse_uuid(caller_user_id), ensure_org(org_id)} do
      {{:ok, user_uuid}, {:ok, org}} ->
        Client.merge_pull(user_uuid, org, repo_ref, pull_number, body)

      {{:ok, _}, {:error, :org_not_found}} ->
        {:error, :organization_not_found}

      {{:ok, _}, {:error, reason}} ->
        {:error, reason}

      {:error, _} ->
        {:error, :invalid_uuid}
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
