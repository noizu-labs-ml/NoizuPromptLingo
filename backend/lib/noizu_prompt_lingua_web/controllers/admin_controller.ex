defmodule NoizuPromptLinguaWeb.AdminController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Schema.Users.User, as: UserSchema
  alias NoizuPromptLingua.Schema.Organizations.Organization, as: OrgSchema
  alias NoizuPromptLingua.MCPCustomScopes
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
        conn
        |> put_status(:ok)
        |> json(%{
          user: %{
            id: user.id,
            email: user.email,
            user_name: user.user_name,
            handle: user.handle,
            status: user.status,
            verified: user.verified,
            role: user.role,
            created_at: user.inserted_at
          }
        })
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
                |> json(%{
                  user: %{
                    id: updated.id,
                    email: updated.email,
                    user_name: updated.user_name,
                    handle: updated.handle,
                    status: updated.status,
                    verified: updated.verified,
                    role: updated.role,
                    created_at: updated.inserted_at
                  }
                })
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

    conn
    |> put_status(:ok)
    |> json(%{organizations: orgs, total: total, page: page, per_page: per_page})
  end

  def show_organization(conn, %{"id" => id}) do
    case NoizuPromptLingua.Repo.get(OrgSchema, id) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: "Organization not found"})

      org ->
        members = NoizuPromptLingua.Organizations.list_members(org.id)

        conn
        |> put_status(:ok)
        |> json(%{
          organization: %{
            id: org.id,
            slug: org.slug,
            name: org.name,
            created_at: org.inserted_at
          },
          members: members
        })
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
        conn
        |> put_status(:created)
        |> json(%{repo: repo_json(NoizuPromptLingua.Repo.preload(repo, :token))})

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
        conn
        |> put_status(:ok)
        |> json(%{repo: repo_json(NoizuPromptLingua.Repo.preload(repo, :token))})

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

  def grant_github_repo_access(conn, %{
        "org_id" => _org_id,
        "repo_id" => repo_id,
        "group_id" => group_id,
        "level" => level
      }) do
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

  def revoke_github_repo_access(conn, %{
        "org_id" => _org_id,
        "repo_id" => _repo_id,
        "id" => grant_id
      }) do
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

  def show_user_default_mcp(conn, %{"user_id" => user_id}) do
    scope = MCPCustomScopes.ensure_account_default(user_id)
    host = mcp_host(conn)

    conn
    |> put_status(:ok)
    |> json(%{
      scope: MCPCustomScopes.scope_json(scope, host),
      servers: [
        scope
        |> NoizuPromptLingua.MCPServers.scope_entry(host)
        |> Map.merge(%{required: true, default: true})
      ],
      ala_carte: NoizuPromptLingua.MCPServers.ala_carte(host)
    })
  end

  def create_mcp_key(conn, %{"user_id" => user_id, "key" => key_params}) do
    if not NoizuPromptLingua.MCP.LegacyKeys.create_enabled?() do
      conn
      |> put_status(:gone)
      |> json(NoizuPromptLingua.MCP.LegacyKeys.disabled_response())
    else
      label = Map.get(key_params, "label", "default")

      case NoizuPromptLingua.MCPApiKeys.parse_expires_at(Map.get(key_params, "expires_at")) do
        {:ok, expires_at} ->
          case NoizuPromptLingua.MCPApiKeys.generate_api_key(user_id, label,
                 expires_at: expires_at
               ) do
            {:ok, key, raw_key} ->
              # Return the raw key exactly once, alongside the masked record.
              conn
              |> put_status(:created)
              |> json(%{key: mcp_key_json(key), raw_key: raw_key})

            {:error, changeset} when is_struct(changeset, Ecto.Changeset) ->
              conn
              |> put_status(:unprocessable_entity)
              |> json(%{errors: format_errors(changeset)})

            {:error, reason} ->
              conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
          end

        :error ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "expires_at must be a future ISO8601 timestamp"})
      end
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

  # ── Per-key toolset management (cross-user) ───────────────────────────────
  # Symmetric with the Key.* MCP tools but admin-scoped: any user's keys.
  # Responses are masked (prefix only; raw key values are never returned).

  def list_all_mcp_keys(conn, _params) do
    keys =
      NoizuPromptLingua.MCPApiKeys.list_all()
      |> Enum.map(&mcp_key_json/1)

    conn |> put_status(:ok) |> json(%{keys: keys})
  end

  def show_mcp_key(conn, %{"id" => id}) do
    case NoizuPromptLingua.MCPApiKeys.get(id) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: "Key not found"})

      key ->
        conn |> put_status(:ok) |> json(%{key: mcp_key_json(key)})
    end
  end

  def update_mcp_key(conn, %{"id" => id} = params) do
    case NoizuPromptLingua.MCPApiKeys.get(id) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: "Key not found"})

      key ->
        with {:ok, key} <- apply_mcp_key_updates(key, params) do
          conn |> put_status(:ok) |> json(%{key: mcp_key_json(key)})
        else
          {:error, %Ecto.Changeset{} = cs} ->
            conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})

          {:error, reason} ->
            conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
        end
    end
  end

  def clone_mcp_key(conn, %{"id" => id} = params) do
    case NoizuPromptLingua.MCPApiKeys.get(id) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: "Key not found"})

      key ->
        owner_id = Map.get(params, "user_id") || key.user_id

        with {:ok, key, raw_key} <-
               NoizuPromptLingua.MCPApiKeys.clone(key,
                 user_id: owner_id,
                 label: Map.get(params, "label")
               ) do
          conn |> put_status(:created) |> json(%{key: mcp_key_json(key), raw_key: raw_key})
        else
          {:error, %Ecto.Changeset{} = cs} ->
            conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})

          {:error, reason} ->
            conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
        end
    end
  end

  defp apply_mcp_key_updates(key, params) do
    attrs =
      %{}
      |> maybe_put_param(:label, params["label"])
      |> maybe_put_param(:status, params["status"])
      |> maybe_put_param(:toolset_config, params["toolset_config"])

    with {:ok, key} <- NoizuPromptLingua.MCPApiKeys.update(key, attrs) do
      case params["toolset_from_scope"] do
        nil -> {:ok, key}
        scope_ref -> NoizuPromptLingua.MCPApiKeys.copy_toolset_from(key, scope_ref)
      end
    end
  end

  defp maybe_put_param(attrs, _key, nil), do: attrs
  defp maybe_put_param(attrs, key, value), do: Map.put(attrs, key, value)

  # ── OAuth clients (DCR + first-party) ─────────────────────────────────────
  # Admin visibility into registered OAuth 2.1 clients. Revoking a client
  # cascades to its active pairing grants and unexpired refresh tokens, so
  # already-issued tokens stop working immediately.

  alias NoizuPromptLingua.OAuth.Clients, as: OAuthClients

  def list_oauth_clients(conn, _params) do
    clients =
      OAuthClients.list_all()
      |> Enum.map(fn {client, grant_count} -> oauth_client_json(client, grant_count) end)

    conn |> put_status(:ok) |> json(%{clients: clients})
  end

  def revoke_oauth_client(conn, %{"client_id" => client_id}) do
    case OAuthClients.revoke_client(client_id) do
      {:ok, client} ->
        conn |> put_status(:ok) |> json(%{client: oauth_client_json(client, 0)})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Client not found"})
    end
  end

  defp oauth_client_json(client, grant_count) do
    %{
      client_id: client.client_id,
      client_name: client.client_name,
      token_endpoint_auth_method: client.token_endpoint_auth_method,
      redirect_uris: client.redirect_uris,
      is_first_party: client.is_first_party,
      status: client.status,
      grant_count: grant_count,
      inserted_at: client.inserted_at
    }
  end

  # ── LLM model catalog (global) ────────────────────────────────────────────
  # Editable catalog of selectable provider/model pairs surfaced in the Mock MCP
  # picker / MCP ListModels (Domains.MockMCP.Models reads this table).

  alias NoizuPromptLingua.Domains.MockMCP.Models
  alias NoizuPromptLingua.Domains.Assets.MediaProviders

  def list_llm_models(conn, _params) do
    models = Models.catalog() |> Enum.map(&llm_model_json/1)
    conn |> put_status(:ok) |> json(%{models: models})
  end

  def create_llm_model(conn, %{"model" => attrs}) do
    case Models.create_catalog_entry(model_attrs(attrs)) do
      {:ok, entry} ->
        conn |> put_status(:created) |> json(%{model: llm_model_json(entry)})

      {:error, %Ecto.Changeset{} = cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})

      {:error, reason} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
    end
  end

  def update_llm_model(conn, %{"id" => id, "model" => attrs}) do
    case Models.update_catalog_entry(id, model_attrs(attrs)) do
      {:ok, entry} ->
        conn |> put_status(:ok) |> json(%{model: llm_model_json(entry)})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Model not found"})

      {:error, %Ecto.Changeset{} = cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})

      {:error, reason} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
    end
  end

  def delete_llm_model(conn, %{"id" => id}) do
    case Models.delete_catalog_entry(id) do
      {:ok, _} ->
        conn |> put_status(:ok) |> json(%{message: "Model removed"})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Model not found"})

      {:error, reason} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
    end
  end

  defp model_attrs(attrs) do
    Map.take(attrs, ["provider", "model", "label", "endpoint", "enabled", "sort_order", "notes"])
  end

  defp llm_model_json(m) do
    %{
      id: m.id,
      provider: m.provider,
      model: m.model,
      label: m.label,
      endpoint: m.endpoint,
      enabled: m.enabled,
      sort_order: m.sort_order,
      notes: m.notes,
      inserted_at: m.inserted_at
    }
  end

  # ── Marketing signups + caps (landing email capture) ──────────────────────
  # The singleton settings row gates public acceptance/promo awarding; the
  # signups listing powers the admin console table. See Domains.Marketing.Signups.

  alias NoizuPromptLingua.Domains.Marketing.Signups, as: MarketingSignups

  def marketing_settings(conn, _params) do
    settings = MarketingSignups.get_settings!()

    conn
    |> put_status(:ok)
    |> json(%{settings: marketing_settings_json(settings), counts: MarketingSignups.counts()})
  end

  def update_marketing_settings(conn, %{"settings" => attrs}) do
    attrs =
      attrs
      |> Map.take(["beta_signup_cap", "promo_cap", "signups_open", "promo_active"])
      |> coerce_optional_integer("beta_signup_cap")
      |> coerce_optional_integer("promo_cap")

    case MarketingSignups.update_settings(attrs) do
      {:ok, settings} ->
        conn
        |> put_status(:ok)
        |> json(%{settings: marketing_settings_json(settings), counts: MarketingSignups.counts()})

      {:error, %Ecto.Changeset{} = cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})

      {:error, reason} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
    end
  end

  def update_marketing_settings(conn, _params) do
    conn |> put_status(:unprocessable_entity) |> json(%{error: "Expected a \"settings\" object"})
  end

  def list_marketing_signups(conn, params) do
    page = parse_int(Map.get(params, "page"), 1)
    per_page = parse_int(Map.get(params, "per_page"), 50)

    filters = %{
      source: params["source"],
      waitlisted: params["waitlisted"]
    }

    {rows, total} = MarketingSignups.list_signups(filters, page, per_page)

    conn
    |> put_status(:ok)
    |> json(%{
      signups: Enum.map(rows, &marketing_signup_json/1),
      total: total,
      page: page,
      per_page: per_page
    })
  end

  # Empty string clears an optional cap (NULL = unlimited); otherwise integer.
  defp coerce_optional_integer(attrs, key) do
    case Map.fetch(attrs, key) do
      {:ok, value} when is_binary(value) ->
        trimmed = String.trim(value)

        cond do
          trimmed == "" -> Map.put(attrs, key, nil)
          Regex.match?(~r/^\d+$/, trimmed) -> Map.put(attrs, key, String.to_integer(trimmed))
          true -> Map.put(attrs, key, value)
        end

      _ ->
        attrs
    end
  end

  defp parse_int(nil, default), do: default

  defp parse_int(value, default) when is_binary(value) do
    case Integer.parse(value) do
      {n, ""} when n > 0 -> n
      _ -> default
    end
  end

  defp parse_int(value, _default) when is_integer(value) and value > 0, do: value
  defp parse_int(_, default), do: default

  defp marketing_settings_json(s) do
    %{
      beta_signup_cap: s.beta_signup_cap,
      promo_cap: s.promo_cap,
      signups_open: s.signups_open,
      promo_active: s.promo_active,
      updated_at: s.updated_at
    }
  end

  defp marketing_signup_json(row) do
    %{
      id: row.id,
      email: row.email,
      source: row.source,
      promo_awarded: row.promo_awarded,
      waitlisted: row.waitlisted,
      created_at: row.inserted_at
    }
  end

  # ── LLM provider introspection ───────────────────────────────────────────────
  # Fetch available models from provider APIs and test LLM configuration.

  def fetch_provider_models(conn, %{"provider" => provider}) do
    case fetch_models_from_provider(provider) do
      {:ok, models} ->
        conn |> put_status(:ok) |> json(%{models: models, provider: provider})

      {:error, reason} ->
        conn |> put_status(422) |> json(%{error: to_string(reason), provider: provider})
    end
  end

  def test_llm_configuration(conn, %{"provider" => provider} = params) do
    model = Map.get(params, "model")
    endpoint = Map.get(params, "endpoint")

    case test_provider_connection(provider, model, endpoint) do
      {:ok, result} ->
        conn |> put_status(:ok) |> json(%{valid: true, result: result})

      {:error, reason} ->
        conn |> put_status(422) |> json(%{valid: false, error: to_string(reason)})
    end
  end

  # Provider-specific model fetching
  defp fetch_models_from_provider(provider) do
    case String.downcase(provider) do
      "openai" -> fetch_openai_models()
      "anthropic" -> fetch_anthropic_models()
      "groq" -> fetch_groq_models()
      "openrouter" -> fetch_openrouter_models()
      "cerebras" -> fetch_cerebras_models()
      "deepseek" -> fetch_deepseek_models()
      _ -> {:error, "Provider not supported for model fetching"}
    end
  end

  # Connection testing
  defp test_provider_connection(provider, model, endpoint) do
    cond do
      is_nil(model) or model == "" ->
        {:error, "Model name is required for testing"}

      String.downcase(provider) in ["ollama", "custom"] and (is_nil(endpoint) or endpoint == "") ->
        {:error, "Custom endpoint URL is required for this provider"}

      true ->
        case String.downcase(provider) do
          "openai" -> test_openai_connection(model, endpoint)
          "anthropic" -> test_anthropic_connection(model, endpoint)
          "groq" -> test_groq_connection(model, endpoint)
          "openrouter" -> test_openrouter_connection(model, endpoint)
          "cerebras" -> test_cerebras_connection(model, endpoint)
          "deepseek" -> test_deepseek_connection(model, endpoint)
          "ollama" -> test_ollama_connection(model, endpoint)
          _ -> {:ok, "Configuration validated (provider doesn't support live testing)"}
        end
    end
  end

  # ── OpenAI integration ─────────────────────────────────────────────────────
  defp fetch_openai_models do
    case get_openai_api_key() do
      nil ->
        {:error, "OPENAI_API_KEY not configured"}

      api_key ->
        case make_openai_request(api_key, "https://api.openai.com/v1/models") do
          {:ok, %{"data" => models}} ->
            model_names = Enum.map(models, & &1["id"])
            {:ok, model_names}

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  defp test_openai_connection(model, custom_endpoint) do
    case get_openai_api_key() do
      nil ->
        {:error, "OPENAI_API_KEY not configured"}

      api_key ->
        endpoint = normalize_endpoint(custom_endpoint, "https://api.openai.com/v1")
        test_openai_inference(api_key, endpoint, model)
    end
  end

  defp test_openai_inference(api_key, endpoint, model) do
    # Perform a minimal chat completion test
    payload = %{
      "model" => model,
      "messages" => [%{"role" => "user", "content" => "ok"}],
      "max_tokens" => 5
    }

    case make_openai_request(api_key, "#{endpoint}/chat/completions", payload) do
      {:ok, response} ->
        case response do
          %{"choices" => choices} when is_list(choices) and length(choices) > 0 ->
            {:ok, %{"model" => model, "provider" => "openai", "status" => "connected"}}

          %{"error" => error} ->
            {:error, error["message"] || "Unknown API error"}

          _ ->
            {:ok, %{"model" => model, "provider" => "openai", "status" => "connected"}}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp make_openai_request(api_key, url, body \\ nil) do
    headers = [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"}
    ]

    method = if body, do: :post, else: :get
    request_json(method, url, headers, body)
  end

  # ── Anthropic integration ─────────────────────────────────────────────────
  defp fetch_anthropic_models do
    case get_anthropic_api_key() do
      nil ->
        {:error, "ANTHROPIC_API_KEY not configured"}

      api_key ->
        case make_anthropic_request(api_key, "https://api.anthropic.com/v1/models") do
          {:ok, %{"data" => models}} ->
            model_names = Enum.map(models, & &1["id"])
            {:ok, model_names}

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  defp test_anthropic_connection(model, custom_endpoint) do
    case get_anthropic_api_key() do
      nil ->
        {:error, "ANTHROPIC_API_KEY not configured"}

      api_key ->
        endpoint = normalize_endpoint(custom_endpoint, "https://api.anthropic.com/v1")
        test_anthropic_inference(api_key, endpoint, model)
    end
  end

  defp test_anthropic_inference(api_key, endpoint, model) do
    # Anthropic uses version header
    headers = [
      {"x-api-key", api_key},
      {"anthropic-version", "2023-06-01"},
      {"Content-Type", "application/json"}
    ]

    payload = %{
      "model" => model,
      "max_tokens" => 5,
      "messages" => [%{"role" => "user", "content" => "ok"}]
    }

    case request_json(:post, "#{endpoint}/messages", headers, payload) do
      {:ok, _json} ->
        {:ok, %{"model" => model, "provider" => "anthropic", "status" => "connected"}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp make_anthropic_request(api_key, url) do
    headers = [
      {"x-api-key", api_key},
      {"anthropic-version", "2023-06-01"},
      {"Content-Type", "application/json"}
    ]

    request_json(:get, url, headers)
  end

  # ── Groq integration ───────────────────────────────────────────────────────
  defp fetch_groq_models do
    case get_groq_api_key() do
      nil ->
        {:error, "GROQ_API_KEY not configured"}

      api_key ->
        headers = [
          {"Authorization", "Bearer #{api_key}"},
          {"Content-Type", "application/json"}
        ]

        case request_json(:get, "https://api.groq.com/openai/v1/models", headers) do
          {:ok, %{"data" => models}} ->
            model_names = Enum.map(models, & &1["id"])
            {:ok, model_names}

          {:ok, _} ->
            {:error, "Invalid JSON response"}

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  defp test_groq_connection(model, _custom_endpoint) do
    case get_groq_api_key() do
      nil -> {:error, "GROQ_API_KEY not configured"}
      _ -> {:ok, %{"model" => model, "provider" => "groq", "status" => "configured"}}
    end
  end

  defp fetch_openrouter_models do
    case get_openrouter_api_key() do
      nil ->
        {:error, "OPENROUTER_API_KEY not configured"}

      api_key ->
        headers = [
          {"Authorization", "Bearer #{api_key}"},
          {"Content-Type", "application/json"}
        ]

        case request_json(:get, "https://openrouter.ai/api/v1/models", headers) do
          {:ok, %{"data" => models}} ->
            {:ok, Enum.map(models, & &1["id"])}

          {:ok, _} ->
            {:error, "Invalid JSON response"}

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  defp test_openrouter_connection(model, _custom_endpoint) do
    case get_openrouter_api_key() do
      nil -> {:error, "OPENROUTER_API_KEY not configured"}
      _ -> {:ok, %{"model" => model, "provider" => "openrouter", "status" => "configured"}}
    end
  end

  # ── Cerebras integration ───────────────────────────────────────────────────
  defp fetch_cerebras_models do
    case get_cerebras_api_key() do
      nil -> {:error, "CEREBRAS_API_KEY not configured"}
      # Cerebras uses standard models
      _ -> {:ok, ["llama-3.3-70b", "llama-3.1-70b"]}
    end
  end

  defp test_cerebras_connection(_model, _custom_endpoint) do
    case get_cerebras_api_key() do
      nil -> {:error, "CEREBRAS_API_KEY not configured"}
      _ -> {:ok, %{"provider" => "cerebras", "status" => "configured"}}
    end
  end

  # ── DeepSeek integration ───────────────────────────────────────────────────
  defp fetch_deepseek_models do
    case get_deepseek_api_key() do
      nil -> {:error, "DEEPSEEK_API_KEY not configured"}
      # DeepSeek standard models
      _ -> {:ok, ["deepseek-chat", "deepseek-coder"]}
    end
  end

  defp test_deepseek_connection(_model, _custom_endpoint) do
    case get_deepseek_api_key() do
      nil -> {:error, "DEEPSEEK_API_KEY not configured"}
      _ -> {:ok, %{"provider" => "deepseek", "status" => "configured"}}
    end
  end

  # ── Ollama integration (local) ─────────────────────────────────────────────
  defp test_ollama_connection(model, custom_endpoint) do
    endpoint = custom_endpoint || "http://localhost:11434"

    case request_json(:get, "#{endpoint}/api/tags", [], nil, 5_000) do
      {:ok, %{"models" => models}} ->
        model_names = Enum.map(models, & &1["name"])
        effective_model = if model in model_names, do: model, else: nil

        {:ok,
         %{
           "provider" => "ollama",
           "model" => effective_model,
           "status" => "connected",
           "available_models" => model_names
         }}

      {:ok, _} ->
        {:error, "Invalid response from Ollama"}

      {:error, reason} ->
        if String.contains?(reason, "econnrefused") do
          {:error, "Ollama not running at #{endpoint}"}
        else
          {:error, "Failed to connect to Ollama at #{endpoint}"}
        end
    end
  end

  # ── Helper functions ───────────────────────────────────────────────────────
  defp request_json(method, url, headers, body \\ nil, timeout \\ 10_000) do
    opts =
      [
        method: method,
        url: url,
        headers: headers,
        receive_timeout: timeout
      ]
      |> then(fn opts -> if body, do: Keyword.put(opts, :json, body), else: opts end)

    case Req.request(opts) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        decode_response_body(body)

      {:ok, %Req.Response{status: 401}} ->
        {:error, "Invalid API key"}

      {:ok, %Req.Response{status: code, body: body}} ->
        {:error, response_error(body, code)}

      {:error, reason} ->
        {:error, "Request failed: #{inspect(reason)}"}
    end
  end

  defp decode_response_body(body) when is_map(body) or is_list(body), do: {:ok, body}

  defp decode_response_body(body) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, json} -> {:ok, json}
      {:error, _} -> {:error, "Invalid JSON response"}
    end
  end

  defp decode_response_body(_), do: {:error, "Invalid JSON response"}

  defp response_error(%{"error" => %{"message" => message}}, _code) when is_binary(message),
    do: message

  defp response_error(%{"message" => message}, _code) when is_binary(message), do: message

  defp response_error(body, code) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, decoded} -> response_error(decoded, code)
      {:error, _} -> "HTTP #{code}"
    end
  end

  defp response_error(_body, code), do: "HTTP #{code}"

  defp normalize_endpoint(custom_endpoint, default) do
    case custom_endpoint do
      nil -> default
      "" -> default
      url -> String.trim(url)
    end
  end

  defp get_openai_api_key do
    System.get_env("OPENAI_API_KEY") || Application.get_env(:genai, :openai, [])[:api_key]
  end

  defp get_anthropic_api_key do
    System.get_env("ANTHROPIC_API_KEY") || Application.get_env(:genai, :anthropic, [])[:api_key]
  end

  defp get_groq_api_key do
    System.get_env("GROQ_API_KEY") || Application.get_env(:genai, :groq, [])[:api_key]
  end

  defp get_openrouter_api_key do
    System.get_env("OPENROUTER_API_KEY") || Application.get_env(:genai, :openrouter, [])[:api_key]
  end

  defp get_cerebras_api_key do
    System.get_env("CEREBRAS_API_KEY") || Application.get_env(:genai, :cerebras, [])[:api_key]
  end

  defp get_deepseek_api_key do
    System.get_env("DEEPSEEK_API_KEY") || Application.get_env(:genai, :deepseek, [])[:api_key]
  end

  # ── Media provider config (org-scoped) ────────────────────────────────────
  # Per-org overrides (api_key / model / settings + on/off) for the registered
  # genai media providers used by asset generation. api_key is masked on output.

  def list_media_providers(conn, %{"org_id" => org_id}) do
    registry =
      MediaProviders.registry()
      |> Enum.map(fn p ->
        %{
          slug: p.slug,
          label: p.label,
          modality: p.modality,
          env_var: p.env_var,
          env_key_set: MediaProviders.env_key_set?(p)
        }
      end)

    configs = MediaProviders.list_configs(org_id) |> Enum.map(&media_config_json/1)

    conn |> put_status(:ok) |> json(%{registry: registry, configs: configs})
  end

  def create_media_provider(conn, %{"org_id" => org_id, "config" => attrs}) do
    case MediaProviders.create_config(media_attrs(attrs, org_id)) do
      {:ok, cfg} ->
        conn |> put_status(:created) |> json(%{config: media_config_json(cfg)})

      {:error, %Ecto.Changeset{} = cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})

      {:error, reason} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
    end
  end

  def update_media_provider(conn, %{"org_id" => _org_id, "id" => id, "config" => attrs}) do
    case MediaProviders.update_config(id, media_attrs(attrs, nil)) do
      {:ok, cfg} ->
        conn |> put_status(:ok) |> json(%{config: media_config_json(cfg)})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Config not found"})

      {:error, %Ecto.Changeset{} = cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})

      {:error, reason} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
    end
  end

  def delete_media_provider(conn, %{"org_id" => _org_id, "id" => id}) do
    case MediaProviders.delete_config(id) do
      {:ok, _} ->
        conn |> put_status(:ok) |> json(%{message: "Config removed"})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Config not found"})

      {:error, reason} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
    end
  end

  # ── Custom MCP include scopes (global admin presets) ──────────────────────

  def mcp_custom_scope_catalog(conn, _params) do
    conn |> put_status(:ok) |> json(%{groups: MCPCustomScopes.catalog()})
  end

  def list_mcp_custom_scopes(conn, _params) do
    host = mcp_host(conn)
    _ = MCPCustomScopes.get_default_package()
    _ = MCPCustomScopes.get_core_variant()
    scopes = MCPCustomScopes.list() |> Enum.map(&MCPCustomScopes.scope_json(&1, host))
    conn |> put_status(:ok) |> json(%{scopes: scopes})
  end

  def show_mcp_custom_scope(conn, %{"slug" => slug}) do
    case MCPCustomScopes.get_by_slug(slug) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: "Scope not found"})

      scope ->
        conn
        |> put_status(:ok)
        |> json(%{scope: MCPCustomScopes.scope_json(scope, mcp_host(conn))})
    end
  end

  def create_mcp_custom_scope(conn, %{"scope" => attrs}) do
    case MCPCustomScopes.create(attrs) do
      {:ok, scope} ->
        conn
        |> put_status(:created)
        |> json(%{scope: MCPCustomScopes.scope_json(scope, mcp_host(conn))})

      {:error, %Ecto.Changeset{} = cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
    end
  end

  def create_mcp_custom_scope(conn, _params) do
    conn |> put_status(:bad_request) |> json(%{error: "scope required"})
  end

  @doc """
  Clone a custom scope into a new endpoint (config copied verbatim, original
  untouched). Mirrors `clone_mcp_key`. `scope` attrs may override `name`,
  `slug`, `description`, `kind`. `/copy` is kept as a legacy alias route.
  """
  def clone_mcp_custom_scope(conn, %{"slug" => slug} = params) do
    attrs = Map.get(params, "scope") || %{}

    case MCPCustomScopes.copy(slug, attrs) do
      {:ok, scope} ->
        conn
        |> put_status(:created)
        |> json(%{scope: MCPCustomScopes.scope_json(scope, mcp_host(conn))})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Scope not found"})

      {:error, %Ecto.Changeset{} = cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
    end
  end

  def update_mcp_custom_scope(conn, %{"slug" => slug, "scope" => attrs} = params) do
    # `confirm` may arrive at the top level or inside the scope map; thread the
    # acting admin so a confirmed disable records who authorized it.
    attrs = maybe_merge_confirm(attrs, params)
    actor_id = conn.assigns[:admin_user] && conn.assigns[:admin_user].id

    case MCPCustomScopes.update(slug, attrs, actor_id: actor_id) do
      {:ok, scope} ->
        conn
        |> put_status(:ok)
        |> json(%{scope: MCPCustomScopes.scope_json(scope, mcp_host(conn))})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Scope not found"})

      {:error, :confirmation_required, groups} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "confirmation required to disable required core group(s)",
          required_groups: groups,
          confirm_required: true
        })

      {:error, %Ecto.Changeset{} = cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
    end
  end

  def update_mcp_custom_scope(conn, _params) do
    conn |> put_status(:bad_request) |> json(%{error: "scope required"})
  end

  def delete_mcp_custom_scope(conn, %{"slug" => slug}) do
    case MCPCustomScopes.delete(slug) do
      {:ok, _} ->
        conn |> put_status(:ok) |> json(%{message: "Scope deleted"})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Scope not found"})

      {:error, :protected} ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "The default Tobor Locker package cannot be deleted"})
    end
  end

  # ── D3: per-scope client permissions + ACL group admin ────────────────────
  #
  # Clients that can hit a scope's MCP endpoint: user MCP API keys (PATs) and
  # OAuth clients. No scope↔client association table exists (api keys are
  # user-scoped credentials; oauth clients carry only an OIDC scope string),
  # so every client is listed with `linked: false` — the Manage Clients UI
  # treats the list as the addressable client universe and each client's
  # `toolset_config` jsonb as the permission surface (F2 EffectiveToolset
  # cascade layer 3).
  #
  # The toolset_config PUT normalizes on write: dotted tool keys collapse to
  # canonical underscore (F5), unknown fields are rejected (strict 422 — the
  # scope-side normalizer is silent-drop; client configs are admin-written so
  # strictness is cheap), and an empty map resets to %{}.

  alias NoizuPromptLingua.Schema.McpApiKey
  alias NoizuPromptLingua.Schema.OAuthClient
  alias NoizuPromptLingua.Schema.Acl.Group
  alias NoizuPromptLingua.Schema.Acl.GroupMember
  alias NoizuPromptLingua.Acl
  alias NoizuPromptLingua.Acl.ERPRef
  alias NoizuPromptLingua.MCP.ToolNames
  alias NoizuPromptLingua.MCP.Window

  @client_kinds %{
    "api_key" => :api_key,
    "api-key" => :api_key,
    "oauth_client" => :oauth_client,
    "oauth-client" => :oauth_client
  }

  # "enabled_at" rides along (Window's enable_for_hours anchor, stamped on
  # write) so fetched configs round-trip through PUT without unknown-field 422s.
  @tool_entry_keys ~w(disabled hidden name_override description_override hide_until enable_for_hours enabled_at)

  def list_scope_clients(conn, %{"slug" => slug}) do
    case MCPCustomScopes.get_by_slug(slug) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: "Scope not found"})

      _scope ->
        keys =
          NoizuPromptLingua.Repo.all(from k in McpApiKey, order_by: [desc: k.inserted_at])
          |> Enum.map(&api_key_client_json/1)

        oauth =
          NoizuPromptLingua.Repo.all(from c in OAuthClient, order_by: [desc: c.inserted_at])
          |> Enum.map(&oauth_client_client_json/1)

        conn |> put_status(:ok) |> json(%{clients: keys ++ oauth})
    end
  end

  defp api_key_client_json(key) do
    %{
      id: key.id,
      kind: "api_key",
      label: String.trim_trailing("#{key.label}#{key_prefix_suffix(key)}"),
      status: key.status,
      inserted_at: key.inserted_at,
      linked: false
    }
  end

  defp key_prefix_suffix(%{key_prefix: nil}), do: ""
  defp key_prefix_suffix(%{key_prefix: ""}), do: ""
  defp key_prefix_suffix(%{key_prefix: prefix}), do: " (#{prefix})"

  defp oauth_client_client_json(client) do
    %{
      id: client.id,
      kind: "oauth_client",
      label: client.client_name,
      status: client.status,
      inserted_at: client.inserted_at,
      linked: false
    }
  end

  def show_client_toolset_config(conn, %{"kind" => kind, "id" => id}) do
    case fetch_client(kind, id) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: "Client not found"})

      client ->
        conn |> put_status(:ok) |> json(%{toolset_config: client.toolset_config || %{}})
    end
  end

  def update_client_toolset_config(conn, %{"kind" => kind, "id" => id, "toolset_config" => cfg}) do
    client = fetch_client(kind, id)

    with %{toolset_config: _} <- client || :not_found,
         {:ok, normalized} <- normalize_toolset_config(cfg) do
      changeset =
        case client do
          %McpApiKey{} = key -> McpApiKey.toolset_changeset(key, %{"toolset_config" => normalized})
          %OAuthClient{} = oc -> OAuthClient.changeset(oc, %{"toolset_config" => normalized})
        end

      case NoizuPromptLingua.Repo.update(changeset) do
        {:ok, updated} ->
          conn |> put_status(:ok) |> json(%{toolset_config: updated.toolset_config || %{}})

        {:error, %Ecto.Changeset{} = cs} ->
          conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
      end
    else
      :not_found ->
        conn |> put_status(:not_found) |> json(%{error: "Client not found"})

      {:error, errors} when is_list(errors) ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: errors})

      {:error, changeset} ->
        conn |> put_status(:bad_request) |> json(%{error: inspect(changeset)})
    end
  end

  def update_client_toolset_config(conn, _params),
    do: conn |> put_status(:bad_request) |> json(%{error: "toolset_config required"})

  defp fetch_client(kind, id) when is_binary(id) do
    case @client_kinds[kind] do
      :api_key -> NoizuPromptLingua.Repo.get(McpApiKey, id)
      # The W7 editor route may carry either the row uuid or the public
      # client_id string (DCR identifier).
      :oauth_client ->
        NoizuPromptLingua.Repo.get(OAuthClient, id) ||
          NoizuPromptLingua.Repo.one(from c in OAuthClient, where: c.client_id == ^id)
      _ -> nil
    end
  end

  defp fetch_client(_, _), do: nil

  # Empty config = reset (client inherits scope/template layers untouched).
  defp normalize_toolset_config(cfg) when cfg == %{}, do: {:ok, %{}}

  defp normalize_toolset_config(%{"groups" => groups} = cfg) when is_map(groups) do
    unknown = Map.keys(cfg) -- ["groups"]

    cond do
      unknown != [] ->
        {:error, ["unknown field(s): #{Enum.join(unknown, ", ")} (only \"groups\" is supported)"]}

      true ->
        normalize_groups(groups)
    end
  end

  defp normalize_toolset_config(_),
    do: {:error, ["toolset_config must be an object with a \"groups\" map, or empty to reset"]}

  defp normalize_groups(groups) do
    groups
    |> Enum.reduce_while({:ok, %{}}, fn {gid, group_cfg}, {:ok, acc} ->
      case normalize_group(group_cfg) do
        {:ok, normalized} -> {:cont, {:ok, Map.put(acc, to_string(gid), normalized)}}
        {:error, errs} -> {:halt, {:error, Enum.map(errs, &"groups.#{gid}.#{&1}")}}
      end
    end)
    |> case do
      {:ok, wrapped} -> {:ok, %{"groups" => wrapped}}
      error -> error
    end
  end

  defp normalize_group(group_cfg) when is_map(group_cfg) do
    unknown = Map.keys(group_cfg) -- ["disabled", "hidden", "tools"]

    cond do
      unknown != [] ->
        {:error, ["unknown field(s): #{Enum.join(unknown, ", ")}"]}

      true ->
        with {:ok, flags} <- bool_fields(group_cfg, ["disabled", "hidden"]),
             {:ok, tools} <- normalize_tools(Map.get(group_cfg, "tools") || %{}) do
          {:ok, flags |> maybe_put_tools(tools)}
        end
    end
  end

  defp normalize_group(_), do: {:error, ["must be an object"]}

  defp maybe_put_tools(flags, tools) when tools == %{}, do: flags
  defp maybe_put_tools(flags, tools), do: Map.put(flags, "tools", tools)

  # Collapse dotted (F5-alias) tool keys into their canonical underscore form
  # so repeated edits stop accumulating both spellings. A dotted alias merges
  # under its canonical key (field-level: canonical values win).
  defp normalize_tools(tools) when is_map(tools) do
    {canonical_list, dotted_list} =
      Enum.split_with(tools, fn {name, _} -> not ToolNames.alias?(name) end)

    canonical = Map.new(canonical_list)

    dotted_list
    |> Enum.map(fn {name, entry} -> {ToolNames.canonical(name), entry} end)
    |> Enum.into(canonical, fn {key, dotted_entry} ->
      {key, Map.merge(dotted_entry, Map.get(canonical, key, %{}))}
    end)
    |> Enum.reduce_while({:ok, %{}}, fn {name, entry}, {:ok, acc} ->
      case normalize_tool_entry(entry) do
        {:ok, normalized} -> {:cont, {:ok, Map.put(acc, name, normalized)}}
        {:error, errs} -> {:halt, {:error, Enum.map(errs, &"tools.#{name}.#{&1}")}}
      end
    end)
  end

  defp normalize_tools(_), do: {:error, ["tools must be an object"]}

  defp normalize_tool_entry(entry) when is_map(entry) do
    unknown = Map.keys(entry) -- @tool_entry_keys

    cond do
      unknown != [] ->
        {:error, ["unknown field(s): #{Enum.join(unknown, ", ")}"]}

      true ->
        with {:ok, flags} <- bool_fields(entry, ["disabled", "hidden"]),
             {:ok, overrides} <- string_fields(entry, ["name_override", "description_override"]),
             {:ok, window} <- window_fields(entry) do
          {:ok, flags |> Map.merge(overrides) |> Window.normalize_entry(entry) |> Map.merge(window)}
        end
    end
  end

  defp normalize_tool_entry(_), do: {:error, ["must be an object"]}

  defp bool_fields(map, keys) do
    Enum.reduce_while(keys, {:ok, %{}}, fn key, {:ok, acc} ->
      case Map.get(map, key) do
        nil -> {:cont, {:ok, acc}}
        value when is_boolean(value) -> {:cont, {:ok, Map.put(acc, key, value)}}
        other -> {:halt, {:error, ["#{key}: must be a boolean (got #{inspect(other)})"]}}
      end
    end)
  end

  defp string_fields(map, keys) do
    Enum.reduce_while(keys, {:ok, %{}}, fn key, {:ok, acc} ->
      case Map.get(map, key) do
        nil -> {:cont, {:ok, acc}}
        value when is_binary(value) -> {:cont, {:ok, Map.put(acc, key, value)}}
        other -> {:halt, {:error, ["#{key}: must be a string (got #{inspect(other)})"]}}
      end
    end)
  end

  # Strict window validation (unlike the silent-drop scope-side path): invalid
  # values are rejected with 422 so the admin UI surfaces them. Valid values
  # are then stored via Window.normalize_entry (ISO8601 UTC + enabled_at anchor).
  defp window_fields(entry) do
    case Window.validate_entry(entry) do
      [] ->
        {:ok, %{}}

      errs ->
        {:error, errs}
    end
  end

  # ── D3: ACL group admin (F1 NoizuPromptLingua.Acl context) ────────────────

  def list_acl_groups(conn, _params) do
    groups =
      NoizuPromptLingua.Repo.all(from g in Group, where: g.status == "active", order_by: g.name)

    members_by_group =
      NoizuPromptLingua.Repo.all(from m in GroupMember, order_by: m.inserted_at)
      |> Enum.group_by(& &1.group_id)

    conn
    |> put_status(:ok)
    |> json(%{
      groups:
        Enum.map(groups, fn g ->
          acl_group_json(g, Map.get(members_by_group, g.id, []))
        end)
    })
  end

  def create_acl_group(conn, %{"group" => attrs}) do
    case Acl.create_group(filter_nils(%{"name" => attrs["name"], "description" => attrs["description"]})) do
      {:ok, group} ->
        conn |> put_status(:created) |> json(%{group: acl_group_json(group, [])})

      {:error, %Ecto.Changeset{} = cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
    end
  end

  def create_acl_group(conn, _params),
    do: conn |> put_status(:bad_request) |> json(%{error: "group required"})

  def update_acl_group(conn, %{"id" => id, "group" => attrs}) do
    group = Acl.get_group(id)

    cond do
      is_nil(group) or group.status == "archived" ->
        conn |> put_status(:not_found) |> json(%{error: "Group not found"})

      true ->
        case Acl.update_group(
               group,
               filter_nils(%{
                 "name" => attrs["name"],
                 "description" => attrs["description"],
                 "status" => attrs["status"]
               })
             ) do
          {:ok, updated} ->
            conn
            |> put_status(:ok)
            |> json(%{group: acl_group_json(updated, Acl.members(updated))})

          {:error, %Ecto.Changeset{} = cs} ->
            conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
        end
    end
  end

  def update_acl_group(conn, _params),
    do: conn |> put_status(:bad_request) |> json(%{error: "group required"})

  # Soft-disable (archive) — archived groups stop resolving; rows survive for
  # audit/membership history.
  def delete_acl_group(conn, %{"id" => id}) do
    case Acl.archive_group(id) do
      {:ok, _group} ->
        conn |> put_status(:ok) |> json(%{message: "Group archived"})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Group not found"})

      {:error, %Ecto.Changeset{} = cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
    end
  end

  def add_acl_group_member(conn, %{"id" => id, "member" => member} = params) do
    with {:ok, ref} <- parse_ref(member),
         {:ok, expires_at} <- parse_member_expires_at(params["expires_at"]),
         {:ok, _member} <- Acl.add_member(id, ref, expires_at: expires_at) do
      group = Acl.get_group(id)
      conn |> put_status(:created) |> json(%{group: acl_group_json(group, Acl.members(group))})
    else
      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Group not found"})

      {:error, %Ecto.Changeset{} = cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})

      {:error, :invalid_ref} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "member must be {type, id} or \"type:id\" (ERP ref)"})

      {:error, :invalid_expires_at} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "expires_at must be an ISO8601 datetime"})
    end
  end

  def add_acl_group_member(conn, _params),
    do: conn |> put_status(:bad_request) |> json(%{error: "member required"})

  def remove_acl_group_member(conn, %{"id" => id, "member" => member}) do
    with {:ok, ref} <- parse_ref(member),
         {:ok, count} <- Acl.remove_member(id, ref) do
      conn |> put_status(:ok) |> json(%{removed: count})
    else
      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Group not found"})

      {:error, :invalid_ref} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "member must be {type, id} or \"type:id\" (ERP ref)"})
    end
  end

  def remove_acl_group_member(conn, _params),
    do: conn |> put_status(:bad_request) |> json(%{error: "member required"})

  defp acl_group_json(group, members) do
    %{
      id: group.id,
      name: group.name,
      description: group.description,
      status: group.status,
      ref: ERPRef.dump_map(group.ref),
      inserted_at: group.inserted_at,
      members:
        Enum.map(members, fn m ->
          %{
            ref: ERPRef.dump_map(m.member_ref),
            ref_string: ref_string(m.member_ref),
            expires_at: m.expires_at
          }
        end)
    }
  end

  # Member refs arrive as jsonb maps ({"type", "id"} — ERPRef.load form) or
  # opaque "type:id" strings (TS side treats refs as plain strings).
  defp filter_nils(map), do: Map.reject(map, fn {_k, v} -> is_nil(v) end)

  defp parse_ref(%{"type" => type, "id" => id}) when is_binary(type) and is_binary(id),
    do: ERPRef.load(%{"type" => type, "id" => id})

  defp parse_ref(ref) when is_binary(ref) do
    case String.split(ref, ":", parts: 2) do
      [type, id] -> parse_ref(%{"type" => type, "id" => id})
      _ -> {:error, :invalid_ref}
    end
  end

  defp parse_ref(_), do: {:error, :invalid_ref}

  defp parse_member_expires_at(nil), do: {:ok, nil}

  defp parse_member_expires_at(bin) when is_binary(bin) do
    case DateTime.from_iso8601(bin) do
      {:ok, dt, _} -> {:ok, dt}
      _ -> {:error, :invalid_expires_at}
    end
  end

  defp parse_member_expires_at(_), do: {:error, :invalid_expires_at}

  defp ref_string(ref) do
    case ERPRef.dump_map(ref) do
      %{"type" => type, "id" => id} -> "#{type}:#{id}"
      _ -> nil
    end
  end

  # ── W4 MCP entities: versioned prompts, resources, resource templates ─────

  def list_mcp_prompts(conn, _params) do
    prompts =
      NoizuPromptLingua.MCPrompts.list()
      |> Enum.map(&NoizuPromptLingua.MCPrompts.prompt_json/1)

    conn |> put_status(:ok) |> json(%{prompts: prompts})
  end

  def create_mcp_prompt(conn, %{"prompt" => attrs}) do
    case NoizuPromptLingua.MCPrompts.create(attrs) do
      {:ok, prompt} ->
        conn
        |> put_status(:created)
        |> json(%{prompt: NoizuPromptLingua.MCPrompts.prompt_json(prompt)})

      {:error, %Ecto.Changeset{} = cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
    end
  end

  def create_mcp_prompt(conn, _params),
    do: conn |> put_status(:bad_request) |> json(%{error: "prompt required"})

  def update_mcp_prompt(conn, %{"slug" => slug, "prompt" => attrs}) do
    case NoizuPromptLingua.MCPrompts.update_prompt(slug, attrs) do
      {:ok, prompt} ->
        conn
        |> put_status(:ok)
        |> json(%{prompt: NoizuPromptLingua.MCPrompts.prompt_json(prompt)})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Prompt not found"})

      {:error, %Ecto.Changeset{} = cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
    end
  end

  def update_mcp_prompt(conn, _params),
    do: conn |> put_status(:bad_request) |> json(%{error: "prompt required"})

  def delete_mcp_prompt(conn, %{"slug" => slug}) do
    case NoizuPromptLingua.MCPrompts.delete_prompt(slug) do
      {:ok, _} ->
        conn |> put_status(:ok) |> json(%{message: "Prompt deleted"})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Prompt not found"})
    end
  end

  def publish_mcp_prompt_version(conn, %{"slug" => slug} = params) do
    template = params["template"] || get_in(params, ["version", "template"])
    change_note = params["change_note"] || get_in(params, ["version", "change_note"])

    cond do
      not (is_binary(template) && template != "") ->
        conn |> put_status(:bad_request) |> json(%{error: "template required"})

      true ->
        case NoizuPromptLingua.MCPrompts.publish_version(slug, template, change_note) do
          {:ok, _version} ->
            prompt = NoizuPromptLingua.MCPrompts.get_by_slug(slug)

            conn
            |> put_status(:created)
            |> json(%{prompt: NoizuPromptLingua.MCPrompts.prompt_json(prompt)})

          {:error, :not_found} ->
            conn |> put_status(:not_found) |> json(%{error: "Prompt not found"})

          {:error, %Ecto.Changeset{} = cs} ->
            conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
        end
    end
  end

  def list_mcp_resources(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{
      resources:
        NoizuPromptLingua.MCPResources.list_resources()
        |> Enum.map(&NoizuPromptLingua.MCPResources.resource_json/1)
    })
  end

  def create_mcp_resource(conn, %{"resource" => attrs}) do
    case NoizuPromptLingua.MCPResources.create_resource(attrs) do
      {:ok, resource} ->
        conn
        |> put_status(:created)
        |> json(%{resource: NoizuPromptLingua.MCPResources.resource_json(resource)})

      {:error, %Ecto.Changeset{} = cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
    end
  end

  def create_mcp_resource(conn, _params),
    do: conn |> put_status(:bad_request) |> json(%{error: "resource required"})

  def update_mcp_resource(conn, %{"id" => id, "resource" => attrs}) do
    case NoizuPromptLingua.MCPResources.update_resource(id, attrs) do
      {:ok, resource} ->
        conn
        |> put_status(:ok)
        |> json(%{resource: NoizuPromptLingua.MCPResources.resource_json(resource)})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Resource not found"})

      {:error, %Ecto.Changeset{} = cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
    end
  end

  def update_mcp_resource(conn, _params),
    do: conn |> put_status(:bad_request) |> json(%{error: "resource required"})

  def delete_mcp_resource(conn, %{"id" => id}) do
    case NoizuPromptLingua.MCPResources.delete_resource(id) do
      {:ok, _} ->
        conn |> put_status(:ok) |> json(%{message: "Resource deleted"})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Resource not found"})
    end
  end

  def list_mcp_resource_templates(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{
      templates:
        NoizuPromptLingua.MCPResources.list_templates()
        |> Enum.map(&NoizuPromptLingua.MCPResources.template_json/1)
    })
  end

  def create_mcp_resource_template(conn, %{"template" => attrs}) do
    case NoizuPromptLingua.MCPResources.create_template(attrs) do
      {:ok, template} ->
        conn
        |> put_status(:created)
        |> json(%{template: NoizuPromptLingua.MCPResources.template_json(template)})

      {:error, %Ecto.Changeset{} = cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
    end
  end

  def create_mcp_resource_template(conn, _params),
    do: conn |> put_status(:bad_request) |> json(%{error: "template required"})

  def update_mcp_resource_template(conn, %{"id" => id, "template" => attrs}) do
    case NoizuPromptLingua.MCPResources.update_template(id, attrs) do
      {:ok, template} ->
        conn
        |> put_status(:ok)
        |> json(%{template: NoizuPromptLingua.MCPResources.template_json(template)})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Template not found"})

      {:error, %Ecto.Changeset{} = cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
    end
  end

  def update_mcp_resource_template(conn, _params),
    do: conn |> put_status(:bad_request) |> json(%{error: "template required"})

  def delete_mcp_resource_template(conn, %{"id" => id}) do
    case NoizuPromptLingua.MCPResources.delete_template(id) do
      {:ok, _} ->
        conn |> put_status(:ok) |> json(%{message: "Template deleted"})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Template not found"})
    end
  end

  # Build config attrs. A blank api_key on update means "leave unchanged" (drop it);
  # on create it is simply absent. org_id is set only on create.
  defp media_attrs(attrs, org_id) do
    base =
      Map.take(attrs, ["provider", "modality", "enabled", "endpoint", "default_model", "settings"])

    base =
      case Map.get(attrs, "api_key") do
        key when is_binary(key) and key != "" -> Map.put(base, "api_key", key)
        _ -> base
      end

    if org_id, do: Map.put(base, "organization_id", org_id), else: base
  end

  defp media_config_json(c) do
    %{
      id: c.id,
      provider: c.provider,
      modality: c.modality,
      enabled: c.enabled,
      api_key_set: c.api_key not in [nil, ""],
      endpoint: c.endpoint,
      default_model: c.default_model,
      settings: c.settings,
      inserted_at: c.inserted_at
    }
  end

  # Accept the typed-confirm phrase at the top level of the request too, folding it
  # into the scope attrs the context reads.
  defp maybe_merge_confirm(attrs, params) do
    case Map.get(params, "confirm") do
      nil -> attrs
      confirm -> Map.put(attrs, "confirm", confirm)
    end
  end

  defp mcp_host(conn) do
    Application.get_env(:noizu_prompt_lingua, :frontend_url)
    |> derive_host() ||
      derive_host(conn) ||
      "localhost"
  end

  defp derive_host(nil), do: nil

  defp derive_host(url) when is_binary(url) do
    case URI.parse(url) do
      %URI{host: host} when is_binary(host) and host != "" -> host
      _ -> nil
    end
  end

  defp derive_host(conn) do
    case conn.host do
      host when is_binary(host) and host != "" -> host
      _ -> nil
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
      toolset_config: key.toolset_config,
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

    if len <= 4,
      do: String.duplicate("•", len),
      else: String.slice(token, 0, 4) <> String.duplicate("•", max(len - 4, 4))
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
