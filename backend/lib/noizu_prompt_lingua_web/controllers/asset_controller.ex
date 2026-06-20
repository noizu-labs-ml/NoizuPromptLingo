defmodule NoizuPromptLinguaWeb.AssetController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Domains.Assets
  alias NoizuPromptLingua.Schema.AssetEntry
  alias NoizuPromptLingua.Authz

  # GET /api/v1/organizations/:org_id/assets[?project_id=&asset_type=&status=&tag=]
  def index(conn, %{"org_id" => org_id} = params) do
    with_org(conn, org_id, "viewer", fn resolved_org_id ->
      opts =
        [organization_id: resolved_org_id]
        |> maybe_opt(:project_id, params["project_id"])
        |> maybe_opt(:asset_type, params["asset_type"])
        |> maybe_opt(:status, params["status"])
        |> maybe_opt(:tag, params["tag"])

      entries = Assets.list(opts)
      json(conn, %{assets: Enum.map(entries, &entry_json/1), asset_types: AssetEntry.asset_types(), statuses: AssetEntry.statuses()})
    end)
  end

  # POST /api/v1/organizations/:org_id/assets
  def create(conn, %{"org_id" => org_id, "asset" => params}) do
    with_org(conn, org_id, "member", fn resolved_org_id ->
      with {:ok, project_id} <- validate_project(params["project_id"], resolved_org_id) do
        attrs = take_attrs(params) |> Map.merge(%{organization_id: resolved_org_id, project_id: project_id})

        case Assets.create(attrs, actor: actor(conn)) do
          {:ok, entry} -> conn |> put_status(:created) |> json(%{asset: entry_json(entry)})
          {:error, changeset} -> conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
        end
      else
        {:error, :project_not_in_org} -> conn |> put_status(:unprocessable_entity) |> json(%{error: "Project does not belong to this organization"})
      end
    end)
  end

  # GET /api/v1/organizations/:org_id/assets/:id
  def show(conn, %{"org_id" => org_id, "id" => id}) do
    with_owned_entry(conn, org_id, id, "viewer", fn entry ->
      json(conn, %{asset: entry_json(entry), outputs: Enum.map(Assets.list_outputs(id), &output_json/1)})
    end)
  end

  # PUT /api/v1/organizations/:org_id/assets/:id
  def update(conn, %{"org_id" => org_id, "id" => id, "asset" => params}) do
    with_owned_entry(conn, org_id, id, "member", fn _entry ->
      case Assets.update(id, take_attrs(params), actor: actor(conn)) do
        {:ok, entry} -> json(conn, %{asset: entry_json(entry)})
        {:error, :not_found} -> not_found(conn)
        {:error, changeset} -> conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
      end
    end)
  end

  # DELETE /api/v1/organizations/:org_id/assets/:id
  def delete(conn, %{"org_id" => org_id, "id" => id}) do
    with_owned_entry(conn, org_id, id, "member", fn _entry ->
      case Assets.delete(id) do
        {:ok, _} -> json(conn, %{message: "Asset deleted"})
        {:error, :not_found} -> not_found(conn)
      end
    end)
  end

  # GET /api/v1/organizations/:org_id/assets/:asset_id/outputs
  def outputs(conn, %{"org_id" => org_id, "asset_id" => id}) do
    with_owned_entry(conn, org_id, id, "viewer", fn _entry ->
      json(conn, %{outputs: Enum.map(Assets.list_outputs(id), &output_json/1)})
    end)
  end

  # POST /api/v1/organizations/:org_id/assets/:asset_id/generate
  def generate(conn, %{"org_id" => org_id, "asset_id" => id} = params) do
    with_owned_entry(conn, org_id, id, "member", fn _entry ->
      opts = [actor: actor(conn), provider: params["provider"], model: params["model"], content: params["content"]]

      case Assets.generate(id, opts) do
        {:ok, output} -> conn |> put_status(:created) |> json(%{output: output_json(output)})
        {:error, :not_found} -> not_found(conn)
        {:error, reason} -> conn |> put_status(:unprocessable_entity) |> json(%{error: inspect(reason)})
      end
    end)
  end

  # GET /api/v1/organizations/:org_id/assets/:asset_id/history
  def history(conn, %{"org_id" => org_id, "asset_id" => id}) do
    with_owned_entry(conn, org_id, id, "viewer", fn _entry ->
      json(conn, %{history: Enum.map(Assets.list_history(id), &history_json/1)})
    end)
  end

  # POST /api/v1/organizations/:org_id/assets/:asset_id/outputs/:output_id/accept
  def accept_output(conn, %{"org_id" => org_id, "asset_id" => id, "output_id" => oid}) do
    with_owned_entry(conn, org_id, id, "member", fn _entry ->
      case Assets.accept_output(oid) do
        {:ok, output} -> json(conn, %{output: output_json(output)})
        {:error, :not_found} -> not_found(conn)
        {:error, cs} -> conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
      end
    end)
  end

  # POST /api/v1/organizations/:org_id/assets/:asset_id/outputs/:output_id/reject
  def reject_output(conn, %{"org_id" => org_id, "asset_id" => id, "output_id" => oid}) do
    with_owned_entry(conn, org_id, id, "member", fn _entry ->
      case Assets.reject_output(oid) do
        {:ok, output} -> json(conn, %{output: output_json(output)})
        {:error, :not_found} -> not_found(conn)
        {:error, cs} -> conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
      end
    end)
  end

  # POST /api/v1/organizations/:org_id/assets/:asset_id/active
  def set_active(conn, %{"org_id" => org_id, "asset_id" => id, "output_id" => oid}) do
    with_owned_entry(conn, org_id, id, "member", fn _entry ->
      case Assets.set_active(id, oid, actor: actor(conn)) do
        {:ok, entry} -> json(conn, %{asset: entry_json(entry)})
        {:error, :not_found} -> not_found(conn)
        {:error, cs} -> conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
      end
    end)
  end

  # ── JSON ──────────────────────────────────────────────────────

  defp entry_json(e) do
    %{
      id: e.id,
      organization_id: e.organization_id,
      project_id: e.project_id,
      slug: e.slug,
      title: e.title,
      asset_type: e.asset_type,
      status: e.status,
      quality: e.quality,
      prompt_yaml: e.prompt_yaml,
      tags: e.tags,
      product_targets: e.product_targets,
      active_output_id: e.active_output_id,
      inserted_at: e.inserted_at,
      updated_at: e.updated_at
    }
  end

  defp output_json(o) do
    %{
      id: o.id,
      entry_id: o.entry_id,
      artifact_id: o.artifact_id,
      provider: o.provider,
      model: o.model,
      variant_number: o.variant_number,
      eval_score: o.eval_score,
      eval_status: o.eval_status,
      status: o.status,
      inserted_at: o.inserted_at
    }
  end

  defp history_json(h),
    do: %{id: h.id, action: h.action, actor: h.actor, details: h.details, inserted_at: h.inserted_at}

  defp take_attrs(params) do
    params
    |> Map.take(~w(slug title asset_type status quality prompt_yaml tags product_targets))
    |> Map.new(fn {k, v} -> {String.to_existing_atom(k), v} end)
  end

  defp validate_project(nil, _org_id), do: {:ok, nil}
  defp validate_project("", _org_id), do: {:ok, nil}
  defp validate_project(project_id, org_id) do
    case NoizuPromptLingua.Projects.get_project(project_id) do
      %{organization_id: ^org_id} -> {:ok, project_id}
      _ -> {:error, :project_not_in_org}
    end
  end

  defp with_owned_entry(conn, org_id, id, role, fun) do
    with_org(conn, org_id, role, fn resolved_org_id ->
      case Assets.get(id) do
        nil -> not_found(conn)
        %{organization_id: ^resolved_org_id} = entry -> fun.(entry)
        _ -> conn |> put_status(:not_found) |> json(%{error: "Asset not found"})
      end
    end)
  end

  defp not_found(conn), do: conn |> put_status(:not_found) |> json(%{error: "Asset not found"})

  defp maybe_opt(opts, _key, nil), do: opts
  defp maybe_opt(opts, _key, ""), do: opts
  defp maybe_opt(opts, key, val), do: Keyword.put(opts, key, val)

  defp with_org(conn, org_id, role, fun) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, role) do
      fun.(resolved_org_id)
    else
      {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Organization not found"})
      {:error, :not_a_member} -> conn |> put_status(:forbidden) |> json(%{error: "Not a member of this organization"})
      {:error, _} -> conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  defp actor(conn), do: get_user_id(conn)

  defp get_user_id(conn) do
    case NoizuPromptLingua.Guardian.Plug.current_resource(conn) do
      %NoizuPromptLingua.Users.Sessions.UserSession{user: {:ref, _, id}} -> id
      %NoizuPromptLingua.Users.Sessions.UserSession{user: %{id: id}} -> id
      _ -> nil
    end
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
