defmodule NoizuPromptLinguaWeb.AdminController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Schema.Users.User, as: UserSchema
  alias NoizuPromptLingua.Schema.Organizations.Organization, as: OrgSchema
  import Ecto.Query

  # Full set of assignable roles. Admins may grant any of these. The elevated
  # roles (:admin, :owner) confer admin-area access.
  @valid_roles ~w(user moderator admin owner service other)a

  def list_users(conn, params) do
    page = String.to_integer(Map.get(params, "page", "1"))
    per_page = String.to_integer(Map.get(params, "per_page", "50"))
    offset = (page - 1) * per_page

    users =
      from(u in UserSchema,
        order_by: [desc: u.inserted_at],
        limit: ^per_page,
        offset: ^offset,
        select: %{
          id: u.id,
          email: u.email,
          user_name: u.user_name,
          status: u.status,
          verified: u.verified,
          role: u.role,
          created_at: u.inserted_at
        }
      )
      |> NoizuPromptLingua.Repo.all()

    total = NoizuPromptLingua.Repo.aggregate(UserSchema, :count, :id)

    conn |> put_status(:ok) |> json(%{users: users, total: total, page: page, per_page: per_page})
  end

  def show_user(conn, %{"id" => id}) do
    case NoizuPromptLingua.Repo.get(UserSchema, id) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: "User not found"})

      user ->
        conn |> put_status(:ok) |> json(%{user: %{
          id: user.id,
          email: user.email,
          user_name: user.user_name,
          handle: user.handle,
          status: user.status,
          verified: user.verified,
          role: user.role,
          created_at: user.inserted_at
        }})
    end
  end

  # Admin sets a user's role. Accepts any valid role; an admin cannot change
  # their own role here (prevents accidental self-lockout from the admin area).
  def update_user(conn, %{"id" => id, "user" => %{"role" => role}}) do
    admin = conn.assigns[:admin_user]

    cond do
      admin && to_string(admin.id) == to_string(id) ->
        conn |> put_status(:forbidden) |> json(%{error: "You cannot change your own role"})

      true ->
        case parse_role(role) do
          {:ok, role_atom} ->
            case NoizuPromptLingua.Repo.get(UserSchema, id) do
              nil ->
                conn |> put_status(:not_found) |> json(%{error: "User not found"})

              user ->
                from(u in UserSchema, where: u.id == ^user.id)
                |> NoizuPromptLingua.Repo.update_all(set: [role: role_atom])

                updated = NoizuPromptLingua.Repo.get(UserSchema, id)

                conn
                |> put_status(:ok)
                |> json(%{user: %{
                  id: updated.id,
                  email: updated.email,
                  user_name: updated.user_name,
                  handle: updated.handle,
                  status: updated.status,
                  verified: updated.verified,
                  role: updated.role,
                  created_at: updated.inserted_at
                }})
            end

          :error ->
            conn |> put_status(:unprocessable_entity) |> json(%{error: "Invalid role"})
        end
    end
  end

  def update_user(conn, _params) do
    conn |> put_status(:bad_request) |> json(%{error: "user.role required"})
  end

  defp parse_role(role) when is_binary(role) do
    atom = String.to_existing_atom(role)
    if atom in @valid_roles, do: {:ok, atom}, else: :error
  rescue
    ArgumentError -> :error
  end

  defp parse_role(_), do: :error

  def list_organizations(conn, params) do
    page = String.to_integer(Map.get(params, "page", "1"))
    per_page = String.to_integer(Map.get(params, "per_page", "50"))
    offset = (page - 1) * per_page

    orgs =
      from(o in OrgSchema,
        order_by: [desc: o.inserted_at],
        limit: ^per_page,
        offset: ^offset,
        select: %{
          id: o.id,
          slug: o.slug,
          name: o.name,
          created_at: o.inserted_at
        }
      )
      |> NoizuPromptLingua.Repo.all()

    total = NoizuPromptLingua.Repo.aggregate(OrgSchema, :count, :id)

    conn |> put_status(:ok) |> json(%{organizations: orgs, total: total, page: page, per_page: per_page})
  end

  def show_organization(conn, %{"id" => id}) do
    case NoizuPromptLingua.Repo.get(OrgSchema, id) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: "Organization not found"})

      org ->
        members = NoizuPromptLingua.Organizations.list_members(org.id)
        conn |> put_status(:ok) |> json(%{organization: %{
          id: org.id,
          slug: org.slug,
          name: org.name,
          created_at: org.inserted_at
        }, members: members})
    end
  end

  # ── GitHub integration (tokens + repos) ──────────────────────────────────
  # Org-scoped raw PATs and the repos mapped to them. No GitHub API work yet —
  # these are raw text values. Token values are NEVER returned (masked only).

  def list_github_tokens(conn, %{"org_id" => org_id}) do
    tokens =
      NoizuPromptLingua.Github.list_tokens(org_id)
      |> Enum.map(&token_json/1)

    conn |> put_status(:ok) |> json(%{tokens: tokens})
  end

  def create_github_token(conn, %{"org_id" => org_id, "token" => token_params}) do
    attrs = %{
      organization_id: org_id,
      label: token_params["label"],
      token: token_params["token"]
    }

    case NoizuPromptLingua.Github.create_token(attrs) do
      {:ok, token} ->
        conn |> put_status(:created) |> json(%{token: token_json(token)})

      {:error, changeset} when is_struct(changeset, Ecto.Changeset) ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})

      {:error, reason} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
    end
  end

  def delete_github_token(conn, %{"org_id" => _org_id, "id" => id}) do
    case NoizuPromptLingua.Github.delete_token(id) do
      {:ok, _} ->
        conn |> put_status(:ok) |> json(%{message: "Token deleted"})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Token not found"})

      {:error, reason} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
    end
  end

  def list_github_repos(conn, %{"org_id" => org_id}) do
    repos =
      NoizuPromptLingua.Github.list_repos(org_id)
      |> Enum.map(&repo_json/1)

    conn |> put_status(:ok) |> json(%{repos: repos})
  end

  def create_github_repo(conn, %{"org_id" => org_id, "repo" => repo_params}) do
    attrs = %{
      organization_id: org_id,
      repo_full_name: repo_params["repo_full_name"],
      token_id: repo_params["token_id"],
      default_acl: repo_params["default_acl"] || "private"
    }

    case NoizuPromptLingua.Github.create_repo(attrs) do
      {:ok, repo} ->
        conn |> put_status(:created) |> json(%{repo: repo_json(NoizuPromptLingua.Repo.preload(repo, :token))})

      {:error, changeset} when is_struct(changeset, Ecto.Changeset) ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})

      {:error, reason} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
    end
  end

  def update_github_repo(conn, %{"org_id" => _org_id, "id" => repo_id, "repo" => repo_params}) do
    attrs = Map.take(repo_params, ["token_id", "default_acl"])

    case NoizuPromptLingua.Github.update_repo(repo_id, attrs) do
      {:ok, repo} ->
        conn |> put_status(:ok) |> json(%{repo: repo_json(NoizuPromptLingua.Repo.preload(repo, :token))})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Repo not found"})

      {:error, changeset} when is_struct(changeset, Ecto.Changeset) ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})

      {:error, reason} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
    end
  end

  def list_github_repo_grants(conn, %{"org_id" => _org_id, "repo_id" => repo_id}) do
    grants = NoizuPromptLingua.Github.list_repo_grants(repo_id)
    conn |> put_status(:ok) |> json(%{grants: grants})
  end

  def grant_github_repo_access(conn, %{"org_id" => _org_id, "repo_id" => repo_id, "group_id" => group_id, "level" => level}) do
    case normalize_level(level) do
      {:ok, lvl} ->
        case NoizuPromptLingua.Github.grant_repo_access(repo_id, group_id, lvl) do
          {:ok, _} ->
            grants = NoizuPromptLingua.Github.list_repo_grants(repo_id)
            conn |> put_status(:created) |> json(%{grants: grants})

          {:error, changeset} when is_struct(changeset, Ecto.Changeset) ->
            conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})

          {:error, reason} ->
            conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
        end

      {:error, _} ->
        conn |> put_status(:bad_request) |> json(%{error: "level must be 'read' or 'write'"})
    end
  end

  def revoke_github_repo_access(conn, %{"org_id" => _org_id, "repo_id" => _repo_id, "id" => grant_id}) do
    case NoizuPromptLingua.Github.revoke_repo_grant(grant_id) do
      {:ok, _} ->
        conn |> put_status(:ok) |> json(%{message: "Grant revoked"})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Grant not found"})

      {:error, reason} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
    end
  end

  defp normalize_level("read"), do: {:ok, :read}
  defp normalize_level("write"), do: {:ok, :write}
  defp normalize_level(_), do: {:error, :invalid_level}

  def delete_github_repo(conn, %{"org_id" => _org_id, "id" => id}) do
    case NoizuPromptLingua.Github.delete_repo(id) do
      {:ok, _} ->
        conn |> put_status(:ok) |> json(%{message: "Repo removed"})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Repo not found"})

      {:error, reason} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
    end
  end

  # ── MCP API keys ──────────────────────────────────────────────────────────
  # Long-lived credentials a user presents to mint short-lived MCP JWTs via
  # POST /api/mcp/token. The raw key is returned ONCE at creation; subsequent
  # reads only expose the prefix (for recognition) and status.

  def list_mcp_keys(conn, %{"user_id" => user_id}) do
    keys =
      NoizuPromptLingua.MCPApiKeys.list_for_user(user_id)
      |> Enum.map(&mcp_key_json/1)

    conn |> put_status(:ok) |> json(%{keys: keys})
  end

  def create_mcp_key(conn, %{"user_id" => user_id, "key" => key_params}) do
    label = Map.get(key_params, "label", "default")

    case NoizuPromptLingua.MCPApiKeys.generate_api_key(user_id, label) do
      {:ok, key, raw_key} ->
        # Return the raw key exactly once, alongside the masked record.
        conn
        |> put_status(:created)
        |> json(%{key: mcp_key_json(key), raw_key: raw_key})

      {:error, changeset} when is_struct(changeset, Ecto.Changeset) ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})

      {:error, reason} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
    end
  end

  def revoke_mcp_key(conn, %{"user_id" => _user_id, "id" => id}) do
    case NoizuPromptLingua.MCPApiKeys.revoke(id) do
      {:ok, key} ->
        conn |> put_status(:ok) |> json(%{key: mcp_key_json(key)})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Key not found"})

      {:error, reason} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
    end
  end

  defp mcp_key_json(key) do
    %{
      id: key.id,
      label: key.label,
      key_prefix: key.key_prefix,
      status: key.status,
      last_used_at: key.last_used_at,
      expires_at: key.expires_at,
      inserted_at: key.inserted_at
    }
  end

  # Returns a token with its value masked — the raw token is never serialized.
  defp token_json(token) do
    %{
      id: token.id,
      label: token.label,
      token_preview: mask(token.token),
      inserted_at: token.inserted_at
    }
  end

  defp repo_json(repo) do
    %{
      id: repo.id,
      repo_full_name: repo.repo_full_name,
      token_id: repo.token_id,
      token_label: repo.token && repo.token.label,
      default_acl: repo.default_acl,
      inserted_at: repo.inserted_at
    }
  end

  defp mask(nil), do: nil
  defp mask(""), do: ""
  defp mask(token) when is_binary(token) do
    len = byte_size(token)
    if len <= 4, do: String.duplicate("•", len), else: String.slice(token, 0, 4) <> String.duplicate("•", max(len - 4, 4))
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
