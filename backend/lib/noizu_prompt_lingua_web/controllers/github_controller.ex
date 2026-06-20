defmodule NoizuPromptLinguaWeb.GithubController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Github.Client
  alias NoizuPromptLingua.Organizations

  # ── Helpers ───────────────────────────────────────────────────────────────

  defp get_user_id(conn) do
    case NoizuPromptLingua.Guardian.Plug.current_resource(conn) do
      %NoizuPromptLingua.Users.Sessions.UserSession{user: {:ref, _, id}} -> id
      %NoizuPromptLingua.Users.Sessions.UserSession{user: %{id: id}} -> id
      _ -> nil
    end
  end

  defp resolve_org_id(org_ref) do
    case Organizations.resolve_org_id(org_ref) do
      {:ok, id} -> id
      _ -> nil
    end
  end

  defp handle_error(conn, err) do
    case err do
      {:error, :repo_not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Repository not found"})

      {:error, :token_not_mapped} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: "No token mapped to this repository"})

      {:error, :forbidden} ->
        conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})

      {:error, :invalid_uuid} ->
        conn |> put_status(:bad_request) |> json(%{error: "Invalid UUID format"})

      {:error, :invalid_repo_full_name} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid repo_full_name (expected owner/name)"})

      {:error, {:github, status, body}} ->
        conn
        |> put_status(status)
        |> json(%{error: "GitHub API error", status: status, github_error: body})

      _ ->
        conn |> put_status(:internal_server_error) |> json(%{error: "Unknown error"})
    end
  end

  # ── Repos (read from DB) ─────────────────────────────────────────────────

  def index(conn, %{"org_id" => org_ref}) do
    user_id = get_user_id(conn)
    org_id = resolve_org_id(org_ref)

    case {user_id, org_id} do
      {nil, _} ->
        conn |> put_status(:unauthorized) |> json(%{error: "Unauthorized"})

      {_, nil} ->
        conn |> put_status(:not_found) |> json(%{error: "Organization not found"})

      {user, org} ->
        case Client.list_repos(user, org) do
          {:ok, result} -> conn |> put_status(:ok) |> json(result)
          error -> handle_error(conn, error)
        end
    end
  end

  # ── Pull Requests ─────────────────────────────────────────────────────────

  def list_pulls(conn, %{"org_id" => org_ref, "repo_id" => repo_ref} = params) do
    user_id = get_user_id(conn)
    org_id = resolve_org_id(org_ref)

    handle_github_call(conn, user_id, org_id, repo_ref, fn resolved_repo ->
      opts =
        params
        |> opts_from_params(["state", "head", "base", "sort", "direction", "page", "per_page"])

      Client.list_pulls(user_id, org_id, resolved_repo.id, opts)
    end)
  end

  def get_pull(conn, %{"org_id" => org_ref, "repo_id" => repo_ref, "pull_number" => pull_number}) do
    user_id = get_user_id(conn)
    org_id = resolve_org_id(org_ref)

    handle_github_call(conn, user_id, org_id, repo_ref, fn resolved_repo ->
      Client.get_pull(user_id, org_id, resolved_repo.id, parse_int(pull_number))
    end)
  end

  def create_pull(conn, %{"org_id" => org_ref, "repo_id" => repo_ref, "pull" => pull_params}) do
    user_id = get_user_id(conn)
    org_id = resolve_org_id(org_ref)
    body = Map.take(pull_params, ["title", "body", "head", "base"])

    handle_github_call(conn, user_id, org_id, repo_ref, fn resolved_repo ->
      Client.create_pull(user_id, org_id, resolved_repo.id, body)
    end)
  end

  def merge_pull(conn, %{
        "org_id" => org_ref,
        "repo_id" => repo_ref,
        "pull_number" => pull_number,
        "pull" => merge_params
      }) do
    user_id = get_user_id(conn)
    org_id = resolve_org_id(org_ref)
    body = Map.take(merge_params, ["commit_title", "commit_message", "merge_method"])

    handle_github_call(conn, user_id, org_id, repo_ref, fn resolved_repo ->
      Client.merge_pull(user_id, org_id, resolved_repo.id, parse_int(pull_number), body)
    end)
  end

  def list_pull_comments(conn, %{
        "org_id" => org_ref,
        "repo_id" => repo_ref,
        "pull_number" => pull_number
      } = params) do
    user_id = get_user_id(conn)
    org_id = resolve_org_id(org_ref)

    handle_github_call(conn, user_id, org_id, repo_ref, fn resolved_repo ->
      opts = opts_from_params(params, ["page", "per_page"])

      Client.list_pull_comments(user_id, org_id, resolved_repo.id, parse_int(pull_number), opts)
    end)
  end

  def create_pull_comment(conn, %{
        "org_id" => org_ref,
        "repo_id" => repo_ref,
        "pull_number" => pull_number,
        "comment" => comment_params
      }) do
    user_id = get_user_id(conn)
    org_id = resolve_org_id(org_ref)
    body = Map.take(comment_params, ["body"])

    handle_github_call(conn, user_id, org_id, repo_ref, fn resolved_repo ->
      Client.comment_pull(user_id, org_id, resolved_repo.id, parse_int(pull_number), body)
    end)
  end

  # ── Issues ───────────────────────────────────────────────────────────────

  def list_issues(conn, %{"org_id" => org_ref, "repo_id" => repo_ref} = params) do
    user_id = get_user_id(conn)
    org_id = resolve_org_id(org_ref)

    handle_github_call(conn, user_id, org_id, repo_ref, fn resolved_repo ->
      opts =
        opts_from_params(params, [
          "state",
          "assignee",
          "creator",
          "labels",
          "sort",
          "direction",
          "page",
          "per_page"
        ])

      Client.list_issues(user_id, org_id, resolved_repo.id, opts)
    end)
  end

  def get_issue(conn, %{"org_id" => org_ref, "repo_id" => repo_ref, "issue_number" => issue_number}) do
    user_id = get_user_id(conn)
    org_id = resolve_org_id(org_ref)

    handle_github_call(conn, user_id, org_id, repo_ref, fn resolved_repo ->
      Client.get_issue(user_id, org_id, resolved_repo.id, parse_int(issue_number))
    end)
  end

  def create_issue(conn, %{"org_id" => org_ref, "repo_id" => repo_ref, "issue" => issue_params}) do
    user_id = get_user_id(conn)
    org_id = resolve_org_id(org_ref)
    body = Map.take(issue_params, ["title", "body", "labels", "assignees"])

    handle_github_call(conn, user_id, org_id, repo_ref, fn resolved_repo ->
      Client.create_issue(user_id, org_id, resolved_repo.id, body)
    end)
  end

  def create_issue_comment(conn, %{
        "org_id" => org_ref,
        "repo_id" => repo_ref,
        "issue_number" => issue_number,
        "comment" => comment_params
      }) do
    user_id = get_user_id(conn)
    org_id = resolve_org_id(org_ref)
    body = Map.take(comment_params, ["body"])

    handle_github_call(conn, user_id, org_id, repo_ref, fn resolved_repo ->
      Client.comment_issue(user_id, org_id, resolved_repo.id, parse_int(issue_number), body)
    end)
  end

  # ── Branches ─────────────────────────────────────────────────────────────

  def list_branches(conn, %{"org_id" => org_ref, "repo_id" => repo_ref} = params) do
    user_id = get_user_id(conn)
    org_id = resolve_org_id(org_ref)

    handle_github_call(conn, user_id, org_id, repo_ref, fn resolved_repo ->
      opts = opts_from_params(params, ["page", "per_page"])
      Client.list_branches(user_id, org_id, resolved_repo.id, opts)
    end)
  end

  def create_branch(conn, %{
        "org_id" => org_ref,
        "repo_id" => repo_ref,
        "branch" => branch_params
      }) do
    user_id = get_user_id(conn)
    org_id = resolve_org_id(org_ref)
    branch_name = branch_params["name"]
    from_sha = branch_params["from_sha"]

    handle_github_call(conn, user_id, org_id, repo_ref, fn resolved_repo ->
      Client.create_branch(user_id, org_id, resolved_repo.id, branch_name, from_sha)
    end)
  end

  # ── Private helpers ──────────────────────────────────────────────────────

  defp parse_int(str) when is_binary(str) do
    case Integer.parse(str) do
      {n, _} -> n
      :error -> 0
    end
  end

  defp parse_int(n) when is_integer(n), do: n

  defp opts_from_params(params, keys) do
    keys
    |> Enum.reduce([], fn k, acc ->
      case Map.get(params, k) do
        nil -> acc
        v -> [{String.to_existing_atom(k), v} | acc]
      end
    end)
    |> Enum.reverse()
  end

  defp handle_github_call(conn, user_id, org_id, repo_ref, callback) do
    case {user_id, org_id} do
      {nil, _} ->
        conn |> put_status(:unauthorized) |> json(%{error: "Unauthorized"})

      {_, nil} ->
        conn |> put_status(:not_found) |> json(%{error: "Organization not found"})

      {user, org} ->
        case NoizuPromptLingua.Github.get_repo(org, repo_ref) do
          nil ->
            conn |> put_status(:not_found) |> json(%{error: "Repository not found"})

          repo ->
            case callback.(repo) do
              {:ok, result} -> conn |> put_status(:ok) |> json(result)
              error -> handle_error(conn, error)
            end
        end
    end
  end
end