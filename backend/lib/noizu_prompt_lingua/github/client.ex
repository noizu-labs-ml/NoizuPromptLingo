defmodule NoizuPromptLingua.Github.Client do
	@moduledoc """
	GitHub API client wrapper that enforces repo ACL checks and manages token mapping.

	All public functions accept:
		- `caller_user_id`: the user requesting the operation (for ACL)
		- `org_id`: the organization UUID (optional for some read operations, but enforced)
		- `repo_ref`: either the repo UUID or `repo_full_name` ("owner/name")
		- `opts`: keyword list for additional parameters (pagination, filters, etc.)

	Returns:
		- `{:ok, result}` on success (result is a map of GitHub API data)
		- `{:error, :forbidden}` if `can_access?/3` denies the operation
		- `{:error, {:github, status, body}}` if GitHub API returns non-2xx
		- `{:error, :repo_not_found}` if repo cannot be resolved or has no token
	"""

	alias NoizuPromptLingua.Schema.GithubRepo
	alias Noizu.Github.Api.{Repos, Pulls, Issues, Git}

	@type repo_ref :: String.t() | Ecto.UUID.t()

	# ── Helper: resolve and authorize ─────────────────────────────────────────

	defp resolve_repo(call_user_id, org_id, repo_ref, acl_level) do
		case NoizuPromptLingua.Github.get_repo(org_id, repo_ref) do
			nil -> {:error, :repo_not_found}
			%GithubRepo{token: nil} -> {:error, :token_not_mapped}
			repo ->
				if NoizuPromptLingua.Github.can_access?(call_user_id, repo, acl_level) do
					{:ok, repo}
				else
					{:error, :forbidden}
				end
		end
	end

	defp split_repo_full_name(full_name) when is_binary(full_name) do
		case String.split(full_name, "/", parts: 2) do
			[owner, name] -> {:ok, owner, name}
			_ -> {:error, :invalid_repo_full_name}
		end
	end

	defp build_opts(repo, extra_opts \\ []) do
		{:ok, owner, name} = split_repo_full_name(repo.repo_full_name)
		[token: repo.token.token, owner: owner, repo: name] ++ extra_opts
	end

	defp normalize_github_result(result) do
		case result do
			{:ok, struct} when is_struct(struct) -> {:ok, struct_to_map(struct)}
			{:ok, %{items: items, links: links} = map} when is_map(map) ->
				{:ok, %{items: Enum.map(items, &struct_to_map/1), links: links}}
			{:ok, %{data: _} = raw} when is_map(raw) -> {:ok, raw}  # Raw response from search
			{:ok, map} when is_map(map) -> {:ok, struct_to_map(map)}
			{:error, %Finch.Response{status: status, body: body}} ->
				{:error, {:github, status, body}}
			_ -> result
		end
	end

	defp struct_to_map(struct) when is_struct(struct) do
		Map.from_struct(struct)
	end
	defp struct_to_map(other), do: other

	# ── Repos (organization-scoped) ───────────────────────────────────────────

	@doc """
	List repos for an organization that the caller has read access to.
	This queries our local DB, not GitHub API.
	"""
	def list_repos(call_user_id, org_id) do
		repos = NoizuPromptLingua.Github.list_repos(org_id)
		filtered = Enum.filter(repos, fn repo ->
			NoizuPromptLingua.Github.can_access?(call_user_id, repo, :read)
		end)
		{:ok,
			%{
				count: length(filtered),
				repos:
					Enum.map(filtered, fn repo ->
						repo
						|> struct_to_map()
						|> Map.put(:token_preview, mask_token(repo.token))
					end)
			}
		}
	end

	defp mask_token(nil), do: nil
	defp mask_token(token) when is_binary(token) do
		len = byte_size(token)
		if len <= 4, do: String.duplicate("•", len), else: String.slice(token, 0, 4) <> String.duplicate("•", len - 4)
	end

	# ── Branches ───────────────────────────────────────────────────────────────

	@doc """
	List branches for a repo. ACL: read.
	"""
	def list_branches(call_user_id, org_id, repo_ref, opts \\ []) do
		with {:ok, repo} <- resolve_repo(call_user_id, org_id, repo_ref, :read),
					github_opts = build_opts(repo, Keyword.take(opts, [:page, :per_page])),
					{:ok, result} <- normalize_github_result(Repos.list_branches(github_opts)) do
			{:ok, result}
		end
	end

	@doc """
	Get a specific branch. ACL: read.
	"""
	def get_branch(call_user_id, org_id, repo_ref, branch_name, opts \\ []) do
		with {:ok, repo} <- resolve_repo(call_user_id, org_id, repo_ref, :read),
					github_opts = build_opts(repo),
					{:ok, result} <- normalize_github_result(Repos.get_branch(branch_name, github_opts)) do
			{:ok, result}
		end
	end

	@doc """
	Create a branch from a commit SHA. ACL: write.
	Ref format is `refs/heads/<branch_name>`.
	"""
	def create_branch(call_user_id, org_id, repo_ref, branch_name, from_sha, opts \\ []) do
		with {:ok, repo} <- resolve_repo(call_user_id, org_id, repo_ref, :write),
					ref = "refs/heads/#{branch_name}",
					github_opts = build_opts(repo),
					body = %{ref: ref, sha: from_sha},
					{:ok, result} <- normalize_github_result(Git.create_ref(body, github_opts)) do
			{:ok, result}
		end
	end

	# ── Pull Requests ─────────────────────────────────────────────────────────

	@doc """
	List pull requests for a repo. ACL: read.
	"""
	def list_pulls(call_user_id, org_id, repo_ref, opts \\ []) do
		with {:ok, repo} <- resolve_repo(call_user_id, org_id, repo_ref, :read),
					github_opts = build_opts(repo, Keyword.take(opts, [:state, :head, :base, :sort, :direction, :page, :per_page])),
					{:ok, result} <- normalize_github_result(Pulls.list(github_opts)) do
			{:ok, result}
		end
	end

	@doc """
	Get a specific pull request. ACL: read.
	"""
	def get_pull(call_user_id, org_id, repo_ref, pull_number, opts \\ []) do
		with {:ok, repo} <- resolve_repo(call_user_id, org_id, repo_ref, :read),
					github_opts = build_opts(repo),
					{:ok, result} <- normalize_github_result(Pulls.get(pull_number, github_opts)) do
			{:ok, result}
		end
	end

	@doc """
	Create a pull request. ACL: write.
	"""
	def create_pull(call_user_id, org_id, repo_ref, body, opts \\ []) do
		with {:ok, repo} <- resolve_repo(call_user_id, org_id, repo_ref, :write),
					github_opts = build_opts(repo),
					{:ok, result} <- normalize_github_result(Pulls.create(body, github_opts)) do
			{:ok, result}
		end
	end

	@doc """
	Merge a pull request. ACL: write.
	"""
	def merge_pull(call_user_id, org_id, repo_ref, pull_number, body, opts \\ []) do
		with {:ok, repo} <- resolve_repo(call_user_id, org_id, repo_ref, :write),
					github_opts = build_opts(repo),
					{:ok, result} <- normalize_github_result(Pulls.merge(pull_number, body, github_opts)) do
			{:ok, result}
		end
	end

	@doc """
	List conversation comments on a pull request. ACL: read.

	Uses the Issues comments API (a PR is also an issue) so listed comments match
	the ones created via `comment_pull/5`.
	"""
	def list_pull_comments(call_user_id, org_id, repo_ref, pull_number, opts \\ []) do
		with {:ok, repo} <- resolve_repo(call_user_id, org_id, repo_ref, :read),
					github_opts = build_opts(repo, Keyword.take(opts, [:page, :per_page])),
					{:ok, result} <- normalize_github_result(Issues.list_comments(pull_number, github_opts)) do
			{:ok, result}
		end
	end

	@doc """
	Create a general (conversation) comment on a pull request. ACL: write.

	PR conversation comments use the Issues comments API (a PR is also an issue),
	since inline review comments require diff position context that this UI does
	not collect.
	"""
	def comment_pull(call_user_id, org_id, repo_ref, pull_number, body) do
		with {:ok, repo} <- resolve_repo(call_user_id, org_id, repo_ref, :write),
					github_opts = build_opts(repo),
					{:ok, result} <- normalize_github_result(Issues.create_comment(pull_number, body, github_opts)) do
			{:ok, result}
		end
	end

	# ── Issues ───────────────────────────────────────────────────────────────

	@doc """
	List issues for a repo. ACL: read.
	Note: `list_for_repo/1` returns issues AND pull requests by default.
	Pass state/filters to differentiate.
	"""
	def list_issues(call_user_id, org_id, repo_ref, opts \\ []) do
		with {:ok, repo} <- resolve_repo(call_user_id, org_id, repo_ref, :read),
					github_opts = build_opts(repo, Keyword.take(opts, [:state, :assignee, :creator, :labels, :sort, :direction, :page, :per_page])),
					{:ok, result} <- normalize_github_result(Issues.list_for_repo(github_opts)) do
			{:ok, result}
		end
	end

	@doc """
	Get a specific issue. ACL: read.
	"""
	def get_issue(call_user_id, org_id, repo_ref, issue_number, opts \\ []) do
		with {:ok, repo} <- resolve_repo(call_user_id, org_id, repo_ref, :read),
					github_opts = build_opts(repo),
					{:ok, result} <- normalize_github_result(Issues.get(issue_number, github_opts)) do
			{:ok, result}
		end
	end

	@doc """
	Create an issue. ACL: write.
	"""
	def create_issue(call_user_id, org_id, repo_ref, body) do
		with {:ok, repo} <- resolve_repo(call_user_id, org_id, repo_ref, :write),
					github_opts = build_opts(repo),
					{:ok, result} <- normalize_github_result(Issues.create(body, github_opts)) do
			{:ok, result}
		end
	end

	@doc """
	Create a comment on an issue. ACL: write.
	"""
	def comment_issue(call_user_id, org_id, repo_ref, issue_number, body) do
		with {:ok, repo} <- resolve_repo(call_user_id, org_id, repo_ref, :write),
					github_opts = build_opts(repo),
					{:ok, result} <- normalize_github_result(Issues.create_comment(issue_number, body, github_opts)) do
			{:ok, result}
		end
	end
end