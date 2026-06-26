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
      {:ok, entry} -> conn |> put_status(:created) |> json(%{model: llm_model_json(entry)})
      {:error, %Ecto.Changeset{} = cs} -> conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
      {:error, reason} -> conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
    end
  end

  def update_llm_model(conn, %{"id" => id, "model" => attrs}) do
    case Models.update_catalog_entry(id, model_attrs(attrs)) do
      {:ok, entry} -> conn |> put_status(:ok) |> json(%{model: llm_model_json(entry)})
      {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Model not found"})
      {:error, %Ecto.Changeset{} = cs} -> conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
      {:error, reason} -> conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
    end
  end

  def delete_llm_model(conn, %{"id" => id}) do
    case Models.delete_catalog_entry(id) do
      {:ok, _} -> conn |> put_status(:ok) |> json(%{message: "Model removed"})
      {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Model not found"})
      {:error, reason} -> conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
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
      nil -> {:error, "OPENAI_API_KEY not configured"}
      api_key ->
        case make_openai_request(api_key, "https://api.openai.com/v1/models") do
          {:ok, %{"data" => models}} ->
            model_names = Enum.map(models, & &1["id"])
            {:ok, model_names}
          {:error, reason} -> {:error, reason}
        end
    end
  end

  defp test_openai_connection(model, custom_endpoint) do
    case get_openai_api_key() do
      nil -> {:error, "OPENAI_API_KEY not configured"}
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
          _ -> {:ok, %{"model" => model, "provider" => "openai", "status" => "connected"}}
        end
      {:error, reason} -> {:error, reason}
    end
  end

  defp make_openai_request(api_key, url, body \\ nil) do
    headers = [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"}
    ]

    opts = [timeout: 10_000, recv_timeout: 10_000]

    request = if body do
      HTTPoison.post(url, Jason.encode!(body), headers, opts)
    else
      HTTPoison.get(url, headers, opts)
    end

    case request do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, json} -> {:ok, json}
          {:error, _} -> {:error, "Invalid JSON response"}
        end
      {:ok, %HTTPoison.Response{status_code: 401}} ->
        {:error, "Invalid API key"}
      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        try do
          {:ok, json} = Jason.decode(body)
          {:error, json["error"]["message"] || "HTTP #{code}"}
        rescue
          _ -> {:error, "HTTP #{code}"}
        end
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Request failed: #{inspect(reason)}"}
    end
  end

  # ── Anthropic integration ─────────────────────────────────────────────────
  defp fetch_anthropic_models do
    case get_anthropic_api_key() do
      nil -> {:error, "ANTHROPIC_API_KEY not configured"}
      api_key ->
        case make_anthropic_request(api_key, "https://api.anthropic.com/v1/models") do
          {:ok, %{"data" => models}} ->
            model_names = Enum.map(models, & &1["id"])
            {:ok, model_names}
          {:error, reason} -> {:error, reason}
        end
    end
  end

  defp test_anthropic_connection(model, custom_endpoint) do
    case get_anthropic_api_key() do
      nil -> {:error, "ANTHROPIC_API_KEY not configured"}
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

    case HTTPoison.post(
      "#{endpoint}/messages",
      Jason.encode!(payload),
      headers,
      timeout: 10_000,
      recv_timeout: 10_000
    ) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, _json} ->
            {:ok, %{"model" => model, "provider" => "anthropic", "status" => "connected"}}
          {:error, _} -> {:error, "Invalid JSON response"}
        end
      {:ok, %HTTPoison.Response{status_code: 401}} ->
        {:error, "Invalid API key"}
      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        try do
          {:ok, json} = Jason.decode(body)
          {:error, json["error"]["message"] || "HTTP #{code}"}
        rescue
          _ -> {:error, "HTTP #{code}"}
        end
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Request failed: #{inspect(reason)}"}
    end
  end

  defp make_anthropic_request(api_key, url) do
    headers = [
      {"x-api-key", api_key},
      {"anthropic-version", "2023-06-01"},
      {"Content-Type", "application/json"}
    ]

    case HTTPoison.get(url, headers, timeout: 10_000, recv_timeout: 10_000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, json} -> {:ok, json}
          {:error, _} -> {:error, "Invalid JSON response"}
        end
      {:ok, %HTTPoison.Response{status_code: 401}} ->
        {:error, "Invalid API key"}
      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        try do
          {:ok, json} = Jason.decode(body)
          {:error, json["error"]["message"] || "HTTP #{code}"}
        rescue
          _ -> {:error, "HTTP #{code}"}
        end
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Request failed: #{inspect(reason)}"}
    end
  end

  # ── Groq integration ───────────────────────────────────────────────────────
  defp fetch_groq_models do
    case get_groq_api_key() do
      nil -> {:error, "GROQ_API_KEY not configured"}
      api_key ->
        headers = [
          {"Authorization", "Bearer #{api_key}"},
          {"Content-Type", "application/json"}
        ]

        case HTTPoison.get(
          "https://api.groq.com/openai/v1/models",
          headers,
          timeout: 10_000,
          recv_timeout: 10_000
        ) do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            case Jason.decode(body) do
              {:ok, %{"data" => models}} ->
                model_names = Enum.map(models, & &1["id"])
                {:ok, model_names}
              {:error, _} -> {:error, "Invalid JSON response"}
            end
          {:ok, %HTTPoison.Response{status_code: 401}} ->
            {:error, "Invalid API key"}
          {:error, _} -> {:error, "Request failed"}
        end
    end
  end

  defp test_groq_connection(model, _custom_endpoint) do
    case get_groq_api_key() do
      nil -> {:error, "GROQ_API_KEY not configured"}
      _ -> {:ok, %{"model" => model, "provider" => "groq", "status" => "configured"}}
    end
  end

  # ── Cerebras integration ───────────────────────────────────────────────────
  defp fetch_cerebras_models do
    case get_cerebras_api_key() do
      nil -> {:error, "CEREBRAS_API_KEY not configured"}
      _ -> {:ok, ["llama-3.3-70b", "llama-3.1-70b"]} # Cerebras uses standard models
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
      _ -> {:ok, ["deepseek-chat", "deepseek-coder"]} # DeepSeek standard models
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

    case HTTPoison.get(
      "#{endpoint}/api/tags",
      timeout: 5_000,
      recv_timeout: 5_000
    ) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"models" => models}} ->
            model_names = Enum.map(models, & &1["name"])
            effective_model = if model in model_names, do: model, else: nil
            {:ok, %{"provider" => "ollama", "model" => effective_model, "status" => "connected", "available_models" => model_names}}
          {:error, _} -> {:error, "Invalid response from Ollama"}
        end
      {:error, %HTTPoison.Error{reason: :econnrefused}} ->
        {:error, "Ollama not running at #{endpoint}"}
      {:error, _} ->
        {:error, "Failed to connect to Ollama at #{endpoint}"}
    end
  end

  # ── Helper functions ───────────────────────────────────────────────────────
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
        %{slug: p.slug, label: p.label, modality: p.modality, env_var: p.env_var, env_key_set: MediaProviders.env_key_set?(p)}
      end)

    configs = MediaProviders.list_configs(org_id) |> Enum.map(&media_config_json/1)

    conn |> put_status(:ok) |> json(%{registry: registry, configs: configs})
  end

  def create_media_provider(conn, %{"org_id" => org_id, "config" => attrs}) do
    case MediaProviders.create_config(media_attrs(attrs, org_id)) do
      {:ok, cfg} -> conn |> put_status(:created) |> json(%{config: media_config_json(cfg)})
      {:error, %Ecto.Changeset{} = cs} -> conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
      {:error, reason} -> conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
    end
  end

  def update_media_provider(conn, %{"org_id" => _org_id, "id" => id, "config" => attrs}) do
    case MediaProviders.update_config(id, media_attrs(attrs, nil)) do
      {:ok, cfg} -> conn |> put_status(:ok) |> json(%{config: media_config_json(cfg)})
      {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Config not found"})
      {:error, %Ecto.Changeset{} = cs} -> conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
      {:error, reason} -> conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
    end
  end

  def delete_media_provider(conn, %{"org_id" => _org_id, "id" => id}) do
    case MediaProviders.delete_config(id) do
      {:ok, _} -> conn |> put_status(:ok) |> json(%{message: "Config removed"})
      {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Config not found"})
      {:error, reason} -> conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
    end
  end

  # Build config attrs. A blank api_key on update means "leave unchanged" (drop it);
  # on create it is simply absent. org_id is set only on create.
  defp media_attrs(attrs, org_id) do
    base = Map.take(attrs, ["provider", "modality", "enabled", "endpoint", "default_model", "settings"])

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
