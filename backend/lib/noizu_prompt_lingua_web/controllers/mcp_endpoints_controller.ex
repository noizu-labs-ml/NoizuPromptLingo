defmodule NoizuPromptLinguaWeb.McpEndpointsController do
  @moduledoc """
  User-facing custom MCP endpoints: list templates, personal/org clones,
  copy, edit included services, and choose the account default.
  """
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Guardian
  alias NoizuPromptLingua.Organizations
  alias NoizuPromptLingua.MCPCustomScopes

  def index(conn, _params) do
    case current_user_id(conn) do
      nil ->
        unauthorized(conn)

      user_id ->
        host = mcp_host(conn)
        default = MCPCustomScopes.ensure_account_default(user_id)

        orgs =
          try do
            Organizations.list_user_organizations(user_id)
          rescue
            _ -> []
          end

        Enum.each(orgs, fn org ->
          MCPCustomScopes.ensure_org_default(org.id, org_name(org))
        end)

        templates = MCPCustomScopes.list_templates()
        personal = MCPCustomScopes.list_for_user(user_id)
        org_ids = Enum.map(orgs, & &1.id)
        org_endpoints = MCPCustomScopes.list_for_organizations(org_ids)
        org_roles = Map.new(orgs, fn org -> {org.id, org.role} end)

        conn
        |> put_status(:ok)
        |> json(%{
          templates: Enum.map(templates, &decorate(&1, host, "template", false)),
          endpoints:
            Enum.map(personal, &decorate(&1, host, "user", true)) ++
              Enum.map(org_endpoints, fn scope ->
                decorate(
                  scope,
                  host,
                  "organization",
                  org_writable?(Map.get(org_roles, scope.organization_id))
                )
              end),
          default_scope: decorate(default, host, "user", true)
        })
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, user_id} <- require_user(conn),
         {:ok, scope, owner_kind, editable} <- load_visible(user_id, id) do
      conn
      |> put_status(:ok)
      |> json(%{endpoint: decorate(scope, mcp_host(conn), owner_kind, editable)})
    else
      {:error, :unauthorized} -> unauthorized(conn)
      {:error, :not_found} -> not_found(conn)
    end
  end

  def create(conn, params) do
    with {:ok, user_id} <- require_user(conn),
         {:ok, source} <- resolve_source(params),
         {:ok, owner_attrs} <- owner_attrs(user_id, params) do
      attrs =
        owner_attrs
        |> Map.merge(copy_attrs(params))

      use_as_default = truthy?(param(params, "use")) and is_nil(Map.get(owner_attrs, "organization_id"))

      case MCPCustomScopes.copy(source, attrs) do
        {:ok, scope} ->
          {:ok, scope} = maybe_set_default(user_id, scope, use_as_default)

          conn
          |> put_status(:created)
          |> json(%{endpoint: decorate(scope, mcp_host(conn), owner_kind_for(scope), true)})

        {:error, %Ecto.Changeset{} = cs} ->
          changeset_error(conn, cs)
      end
    else
      {:error, :unauthorized} -> unauthorized(conn)
      {:error, :not_found} -> not_found(conn, "source endpoint not found")
      {:error, :forbidden} -> forbidden(conn)
    end
  end

  def duplicate(conn, %{"id" => id} = params) do
    create(conn, Map.put(params, "source_id", id))
  end

  def update(conn, %{"id" => id} = params) do
    with {:ok, user_id} <- require_user(conn),
         {:ok, scope, _kind, editable} <- load_visible(user_id, id),
         :ok <- writable(editable),
         {:ok, updated} <- apply_update(scope, params, user_id) do
      {:ok, updated} =
        maybe_set_default(user_id, updated, truthy?(param(params, "use")) and scope.user_id == user_id)

      conn
      |> put_status(:ok)
      |> json(%{
        endpoint: decorate(updated, mcp_host(conn), owner_kind_for(updated), true),
        scope: decorate(updated, mcp_host(conn), owner_kind_for(updated), true)
      })
    else
      {:error, :unauthorized} -> unauthorized(conn)
      {:error, :not_found} -> not_found(conn)
      {:error, :forbidden} -> forbidden(conn)
      {:error, :readonly} -> forbidden(conn, "this endpoint is read-only; copy it to edit")
      {:error, :confirmation_required, groups} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "confirmation required to disable required core group(s)",
          required_groups: groups,
          confirm_required: true
        })

      {:error, %Ecto.Changeset{} = cs} ->
        changeset_error(conn, cs)
    end
  end

  def use_default(conn, %{"id" => id}) do
    with {:ok, user_id} <- require_user(conn),
         {:ok, scope, owner_kind, _editable} <- load_visible(user_id, id) do
      result =
        case owner_kind do
          "user" ->
            MCPCustomScopes.set_account_default(user_id, scope)

          _ ->
            MCPCustomScopes.copy(scope, %{
              "user_id" => user_id,
              "name" => scope.name,
              "description" => scope.description
            })
            |> case do
              {:ok, copy} -> MCPCustomScopes.set_account_default(user_id, copy)
              other -> other
            end
        end

      case result do
        {:ok, updated} ->
          conn
          |> put_status(:ok)
          |> json(%{endpoint: decorate(updated, mcp_host(conn), "user", true)})

        {:error, :forbidden} ->
          forbidden(conn)

        {:error, %Ecto.Changeset{} = cs} ->
          changeset_error(conn, cs)
      end
    else
      {:error, :unauthorized} -> unauthorized(conn)
      {:error, :not_found} -> not_found(conn)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, user_id} <- require_user(conn),
         {:ok, scope, _kind, editable} <- load_visible(user_id, id),
         :ok <- writable(editable) do
      case MCPCustomScopes.delete(scope) do
        {:ok, _} ->
          conn |> put_status(:ok) |> json(%{ok: true, id: id})

        {:error, :protected} ->
          forbidden(conn, "the standard default endpoint cannot be deleted")

        {:error, reason} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: inspect(reason)})
      end
    else
      {:error, :unauthorized} -> unauthorized(conn)
      {:error, :not_found} -> not_found(conn)
      {:error, :readonly} -> forbidden(conn)
    end
  end

  defp apply_update(scope, params, user_id) do
    attrs =
      params
      |> endpoint_params()
      |> Map.take(["name", "description", "config", "confirm"])

    if attrs == %{} do
      {:ok, scope}
    else
      MCPCustomScopes.update(scope, attrs, actor_id: user_id)
    end
  end

  defp maybe_set_default(_user_id, scope, false), do: {:ok, scope}
  defp maybe_set_default(user_id, scope, true), do: MCPCustomScopes.set_account_default(user_id, scope)

  defp resolve_source(params) do
    attrs = endpoint_params(params)

    cond do
      is_binary(attrs["source_id"]) and attrs["source_id"] != "" ->
        case MCPCustomScopes.get(attrs["source_id"]) do
          nil -> {:error, :not_found}
          scope -> {:ok, scope}
        end

      is_binary(attrs["source_slug"]) and attrs["source_slug"] != "" ->
        case MCPCustomScopes.get_by_slug(attrs["source_slug"]) do
          nil -> {:error, :not_found}
          scope -> {:ok, scope}
        end

      true ->
        {:ok, MCPCustomScopes.get_default_package()}
    end
  end

  defp owner_attrs(user_id, params) do
    org_id = param(params, "organization_id")

    cond do
      is_binary(org_id) and org_id != "" ->
        case Organizations.authorize(user_id, org_id, "admin") do
          {:ok, _} -> {:ok, %{"organization_id" => org_id}}
          _ -> {:error, :forbidden}
        end

      true ->
        {:ok, %{"user_id" => user_id}}
    end
  end

  defp copy_attrs(params) do
    params
    |> endpoint_params()
    |> Map.take(["name", "description", "slug"])
    |> Enum.reject(fn {_k, v} -> v in [nil, ""] end)
    |> Map.new()
  end

  defp load_visible(user_id, id) do
    case MCPCustomScopes.get(id) do
      nil ->
        {:error, :not_found}

      %{user_id: ^user_id} = scope ->
        {:ok, scope, "user", true}

      %{user_id: nil, organization_id: nil} = scope ->
        {:ok, scope, "template", false}

      %{user_id: nil, organization_id: org_id} = scope when is_binary(org_id) ->
        case Organizations.authorize(user_id, org_id, "viewer") do
          {:ok, _} ->
            editable =
              match?({:ok, _}, Organizations.authorize(user_id, org_id, "admin"))

            {:ok, scope, "organization", editable}

          _ ->
            {:error, :not_found}
        end

      _ ->
        {:error, :not_found}
    end
  end

  defp writable(true), do: :ok
  defp writable(false), do: {:error, :readonly}

  defp org_writable?(role) when role in ["owner", "admin"], do: true
  defp org_writable?(_), do: false

  defp owner_kind_for(%{user_id: uid}) when is_binary(uid), do: "user"
  defp owner_kind_for(%{organization_id: oid}) when is_binary(oid), do: "organization"
  defp owner_kind_for(_), do: "template"

  defp decorate(scope, host, owner_kind, editable) do
    scope
    |> MCPCustomScopes.scope_json(host)
    |> Map.put(:owner_kind, owner_kind)
    |> Map.put(:editable, editable)
  end

  defp endpoint_params(%{"endpoint" => attrs}) when is_map(attrs), do: stringify(attrs)
  defp endpoint_params(%{"scope" => attrs}) when is_map(attrs), do: stringify(attrs)
  defp endpoint_params(attrs) when is_map(attrs), do: stringify(attrs)
  defp endpoint_params(_), do: %{}

  defp param(params, key) do
    attrs = endpoint_params(params)
    Map.get(attrs, key) || Map.get(params, key)
  end

  defp stringify(map) do
    Map.new(map, fn
      {k, v} when is_atom(k) -> {Atom.to_string(k), v}
      {k, v} -> {k, v}
    end)
  end

  defp truthy?(true), do: true
  defp truthy?("true"), do: true
  defp truthy?(_), do: false

  defp org_name(%{name: name}) when is_binary(name), do: name
  defp org_name(_), do: nil

  defp require_user(conn) do
    case current_user_id(conn) do
      nil -> {:error, :unauthorized}
      id -> {:ok, id}
    end
  end

  defp current_user_id(conn) do
    case Guardian.Plug.current_resource(conn) do
      %{user: {:ref, _, id}} when is_binary(id) -> id
      %{user: %{id: id}} when is_binary(id) -> id
      _ -> nil
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

  defp unauthorized(conn), do: conn |> put_status(:unauthorized) |> json(%{error: "authentication required"})
  defp not_found(conn, msg \\ "endpoint not found"), do: conn |> put_status(:not_found) |> json(%{error: msg})
  defp forbidden(conn, msg \\ "forbidden"), do: conn |> put_status(:forbidden) |> json(%{error: msg})

  defp changeset_error(conn, cs) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{errors: Ecto.Changeset.traverse_errors(cs, fn {msg, _} -> msg end)})
  end
end
