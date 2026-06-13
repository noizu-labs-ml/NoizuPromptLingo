defmodule CodefreshWeb.ScriptController do
  use CodefreshWeb, :controller

  alias Codefresh.{Scripts, Organizations}
  alias Codefresh.Scripts.{Script, ScriptNode, ScriptVersion}
  alias Codefresh.Guardian

  # ──────────────────────────────────────────────────────────────────────────
  # US-001 — Head CRUD
  # ──────────────────────────────────────────────────────────────────────────

  def index(conn, %{"organization_id" => org_id} = params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer") do
      opts = [] |> maybe_put(:include_archived, truthy?(params["include_archived"]))
      scripts = Scripts.list_scripts(org_id, opts)
      json(conn, %{scripts: Enum.map(scripts, &render_script/1)})
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def create(conn, %{"organization_id" => org_id, "script" => params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor") do
      attrs =
        params
        |> Map.put("organization_id", org_id)
        |> Map.put("created_by_user_id", user.id)

      case Scripts.create_script(attrs) do
        {:ok, script, draft} ->
          conn
          |> put_status(:created)
          |> json(%{
            script: render_script(script),
            draft_version: render_version(draft)
          })

        {:error, cs} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
      end
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def create(conn, _), do: bad_request(conn, "Expected {script: {name, slug?, description?}}")

  def show(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         %Script{} = script <- safe_get(org_id, id) do
      draft = Scripts.get_draft_version(script)
      nodes = if draft, do: Scripts.list_nodes(draft), else: []
      edges = if draft, do: Scripts.list_edges(draft), else: []

      json(conn, %{
        script: render_script(script),
        draft_version: render_version(draft),
        nodes: Enum.map(nodes, &render_node/1),
        edges: Enum.map(edges, &render_edge/1)
      })
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def update(conn, %{"organization_id" => org_id, "id" => id, "script" => params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         %Script{} = script <- safe_get(org_id, id),
         {:ok, updated} <- Scripts.update_script(script, params) do
      json(conn, %{script: render_script(updated)})
    else
      nil ->
        send_resp(conn, 404, "")

      {:error, :forbidden} ->
        send_resp(conn, 403, "")

      {:error, :not_a_member} ->
        send_resp(conn, 404, "")

      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
    end
  end

  def archive(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         %Script{} = script <- safe_get(org_id, id),
         {:ok, _} <- Scripts.archive_script(script) do
      send_resp(conn, 204, "")
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
      {:error, _} -> send_resp(conn, 422, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-002 — Add node
  # ──────────────────────────────────────────────────────────────────────────

  def add_node(conn, %{"organization_id" => org_id, "id" => script_id, "node" => params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         %Script{} = script <- safe_get(org_id, script_id),
         %{} = draft <- Scripts.get_draft_version(script) || :no_draft do
      case Scripts.add_node(draft, params) do
        {:ok, node} ->
          conn |> put_status(:created) |> json(%{node: render_node(node)})

        {:error, cs} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
      end
    else
      nil -> send_resp(conn, 404, "")
      :no_draft -> conn |> put_status(:conflict) |> json(%{error: "no draft version"})
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def add_node(conn, _),
    do: bad_request(conn, "Expected {node: {node_key, kind?, position?, metadata?}}")

  # ──────────────────────────────────────────────────────────────────────────
  # US-003 — Attach prompt to node
  # ──────────────────────────────────────────────────────────────────────────

  def attach_prompt(conn, %{
        "organization_id" => org_id,
        "id" => _script_id,
        "node_id" => node_id,
        "prompt_version_id" => pvid
      }) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         %ScriptNode{} = node <- Scripts.get_node(org_id, node_id) do
      case Scripts.attach_prompt(node, pvid) do
        {:ok, updated} ->
          json(conn, %{node: render_node(updated)})

        {:error, :prompt_version_required} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "prompt_version_id required"})

        {:error, :prompt_not_pinnable} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "prompt_version_id must resolve to a published prompt in this org"})

        {:error, cs} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
      end
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  @doc """
  PATCH node — update position / kind / tone / eval_tags / freeball_policy /
  metadata. Used by the graph editor's drag-to-reposition (persists new x/y).
  """
  def update_node(conn, %{
        "organization_id" => org_id,
        "id" => _script_id,
        "node_id" => node_id,
        "node" => params
      }) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         %ScriptNode{} = node <- Scripts.get_node(org_id, node_id),
         {:ok, updated} <- Scripts.update_node(node, params) do
      json(conn, %{node: render_node(updated)})
    else
      nil ->
        send_resp(conn, 404, "")

      {:error, :forbidden} ->
        send_resp(conn, 403, "")

      {:error, :not_a_member} ->
        send_resp(conn, 404, "")

      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
    end
  end

  def update_node(conn, _),
    do: bad_request(conn, "Expected {node: {position?, kind?, tone?, eval_tags?, metadata?}}")

  @doc "List expectations attached to a node (rehydrates the inspector on reload)."
  def list_node_expectations(conn, %{
        "organization_id" => org_id,
        "id" => _script_id,
        "node_id" => node_id
      }) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         %ScriptNode{} = node <- Scripts.get_node(org_id, node_id) do
      expectations = Scripts.list_expectations(node)
      json(conn, %{expectations: Enum.map(expectations, &render_expectation/1)})
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-004 — Add expectation to node
  # ──────────────────────────────────────────────────────────────────────────

  def add_expectation(conn, %{
        "organization_id" => org_id,
        "id" => _script_id,
        "node_id" => node_id,
        "expectation" => params
      }) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         %ScriptNode{} = node <- Scripts.get_node(org_id, node_id) do
      case Scripts.add_expectation(node, params) do
        {:ok, exp} ->
          conn |> put_status(:created) |> json(%{expectation: render_expectation(exp)})

        {:error, :rubric_required} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "rubric_version_id required when scoring_method is 'rubric'"})

        {:error, :rubric_not_pinnable} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "rubric_version_id must resolve to a rubric in this org"})

        {:error, cs} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
      end
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-005 — Add edge
  # ──────────────────────────────────────────────────────────────────────────

  def add_edge(conn, %{"organization_id" => org_id, "id" => script_id, "edge" => params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         %Script{} = script <- safe_get(org_id, script_id),
         %{} = draft <- Scripts.get_draft_version(script) || :no_draft do
      case Scripts.add_edge(draft, params) do
        {:ok, edge} ->
          conn |> put_status(:created) |> json(%{edge: render_edge(edge)})

        {:error, reason}
        when reason in [
               :from_and_to_required,
               :from_node_not_in_version,
               :to_node_not_in_version
             ] ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})

        {:error, cs} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
      end
    else
      nil -> send_resp(conn, 404, "")
      :no_draft -> conn |> put_status(:conflict) |> json(%{error: "no draft version"})
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def add_edge(conn, _),
    do:
      bad_request(
        conn,
        "Expected {edge: {from_node_id, to_node_id, match_method, match_config?, priority?, label?}}"
      )

  # ──────────────────────────────────────────────────────────────────────────
  # US-006 — Publish a script version
  # ──────────────────────────────────────────────────────────────────────────

  def publish(conn, %{"organization_id" => org_id, "id" => script_id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         %Script{} = script <- safe_get(org_id, script_id) do
      case Scripts.publish_version(script, published_by_user_id: user.id) do
        {:ok, :published, v} ->
          conn
          |> put_status(:created)
          |> json(%{
            version: render_version(v),
            status: "published",
            checksum: Base.encode16(v.checksum, case: :lower)
          })

        {:ok, :noop, v} ->
          conn
          |> put_status(:ok)
          |> json(%{
            version: render_version(v),
            status: "noop",
            note: "identical canonical YAML already published",
            checksum: Base.encode16(v.checksum, case: :lower)
          })

        {:error, :no_draft_version} ->
          conn |> put_status(:conflict) |> json(%{error: "no draft to publish"})

        {:error, :no_nodes} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: "script has no nodes"})

        {:error, :no_expectations} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "script has no expectations — add at least one before publishing"})

        {:error, :root_not_set} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "root node not set"})

        {:error, reason} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: inspect(reason)})
      end
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def current_version(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer") do
      case Scripts.resolve_current_version(org_id, id) do
        {:ok, v} ->
          json(conn, %{version: render_version(v)})

        {:error, :not_found} ->
          send_resp(conn, 404, "")

        {:error, :not_published} ->
          conn
          |> put_status(:conflict)
          |> json(%{error: "script has no published version"})
      end
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-007 — Import script from YAML
  # ──────────────────────────────────────────────────────────────────────────

  def import_yaml(conn, %{"organization_id" => org_id, "yaml" => yaml}) when is_binary(yaml) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor") do
      case Scripts.import_yaml(yaml, org_id, imported_by_user_id: user.id) do
        {:ok, :imported, script, v} ->
          conn
          |> put_status(:created)
          |> json(%{
            script: render_script(script),
            version: render_version(v),
            status: "imported"
          })

        {:ok, :noop, script, v} ->
          json(conn, %{
            script: render_script(script),
            version: render_version(v),
            status: "noop",
            note: "identical YAML already published"
          })

        {:error, {:prompt_not_found, slug, version}} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{
            error: "prompt reference not found",
            slug: slug,
            version: version,
            hint: "publish the prompt in this org before importing"
          })

        {:error, {:rubric_not_found, slug, version}} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{
            error: "rubric reference not found",
            slug: slug,
            version: version,
            hint: "publish the rubric in this org before importing"
          })

        {:error, reason} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: inspect(reason)})
      end
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def import_yaml(conn, _),
    do: bad_request(conn, "Expected {yaml: \"...\"}")

  # ──────────────────────────────────────────────────────────────────────────
  # US-008 — Export published script as YAML
  # ──────────────────────────────────────────────────────────────────────────

  def export_yaml(conn, %{"organization_id" => org_id, "id" => script_id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         {:ok, v} <- Scripts.resolve_current_version(org_id, script_id) do
      yaml = Scripts.export_yaml(v)

      conn
      |> put_resp_content_type("application/x-yaml")
      |> put_resp_header(
        "content-disposition",
        ~s(attachment; filename="script-#{script_id}-v#{v.version_number}.yaml")
      )
      |> send_resp(200, yaml)
    else
      {:error, :not_found} -> send_resp(conn, 404, "")
      {:error, :not_published} -> conn |> put_status(:conflict) |> json(%{error: "not published"})
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-041 — Fork a script
  # ──────────────────────────────────────────────────────────────────────────

  def fork(conn, %{"organization_id" => org_id, "id" => script_id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         %Script{} = script <- safe_get(org_id, script_id) do
      case Scripts.fork_script(script, forked_by_user_id: user.id) do
        {:ok, fork, draft} ->
          conn
          |> put_status(:created)
          |> json(%{script: render_script(fork), draft_version: render_version(draft)})

        {:error, :not_published} ->
          conn |> put_status(:conflict) |> json(%{error: "source script has no published version to fork"})

        {:error, reason} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: inspect(reason)})
      end
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-042 — Diff two script versions
  # ──────────────────────────────────────────────────────────────────────────

  def diff_versions(conn, %{"organization_id" => org_id, "id" => _script_id,
                             "version_a_id" => va_id, "version_b_id" => vb_id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         %ScriptVersion{organization_id: ^org_id} = va <- safe_get_version(org_id, va_id),
         %ScriptVersion{organization_id: ^org_id} = vb <- safe_get_version(org_id, vb_id) do
      diff = Scripts.diff_versions(va, vb)

      json(conn, %{
        diff: %{
          added_nodes: Enum.map(diff.added_nodes, &render_node/1),
          removed_nodes: Enum.map(diff.removed_nodes, &render_node/1),
          changed_nodes: Enum.map(diff.changed_nodes, fn %{before: a, after: b} ->
            %{before: render_node(a), after: render_node(b)}
          end),
          added_edges: Enum.map(diff.added_edges, &render_edge/1),
          removed_edges: Enum.map(diff.removed_edges, &render_edge/1)
        }
      })
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def diff_versions(conn, _), do: bad_request(conn, "Expected version_a_id and version_b_id query params")

  # ──────────────────────────────────────────────────────────────────────────
  # US-043 — Bulk node operations
  # ──────────────────────────────────────────────────────────────────────────

  def bulk_nodes(conn, %{"organization_id" => org_id, "id" => script_id,
                          "action" => action, "node_ids" => node_ids} = params)
      when action in ["archive", "retag"] do
    user = Guardian.Plug.current_resource(conn)
    tags = Map.get(params, "tags", [])

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         %Script{} = script <- safe_get(org_id, script_id),
         %{} = draft <- Scripts.get_draft_version(script) || :no_draft do
      case Scripts.bulk_node_operation(draft, action, node_ids, tags: tags) do
        {:ok, nodes} ->
          json(conn, %{nodes: Enum.map(nodes, &render_node/1)})

        {:error, {:nodes_not_found, ids}} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: "nodes not found", ids: ids})

        {:error, reason} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: inspect(reason)})
      end
    else
      nil -> send_resp(conn, 404, "")
      :no_draft -> conn |> put_status(:conflict) |> json(%{error: "no draft version"})
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def bulk_nodes(conn, _),
    do: bad_request(conn, "Expected {action: 'archive'|'retag', node_ids: [...], tags?: [...]}")

  # ──────────────────────────────────────────────────────────────────────────
  # US-044 — Auto-layout node positions
  # ──────────────────────────────────────────────────────────────────────────

  def auto_layout(conn, %{"organization_id" => org_id, "id" => script_id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         %Script{} = script <- safe_get(org_id, script_id),
         %{} = draft <- Scripts.get_draft_version(script) || :no_draft do
      case Scripts.auto_layout(draft) do
        {:ok, nodes} ->
          json(conn, %{nodes: Enum.map(nodes, &render_node/1)})

        {:error, reason} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: inspect(reason)})
      end
    else
      nil -> send_resp(conn, 404, "")
      :no_draft -> conn |> put_status(:conflict) |> json(%{error: "no draft version"})
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-045 — Node comments
  # ──────────────────────────────────────────────────────────────────────────

  def list_node_comments(conn, %{"organization_id" => org_id, "node_id" => node_id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer") do
      comments = Scripts.list_node_comments(org_id, node_id)
      json(conn, %{comments: Enum.map(comments, &render_comment/1)})
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def add_node_comment(conn, %{"organization_id" => org_id, "node_id" => node_id,
                                "comment" => params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         %ScriptNode{} = node <- Scripts.get_node(org_id, node_id) do
      case Scripts.add_node_comment(node, user.id, params) do
        {:ok, comment} ->
          conn |> put_status(:created) |> json(%{comment: render_comment(comment)})

        {:error, cs} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
      end
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def add_node_comment(conn, _),
    do: bad_request(conn, "Expected {comment: {thread_id, body, parent_comment_id?}}")

  # ──────────────────────────────────────────────────────────────────────────
  # US-046 — Export lineage
  # ──────────────────────────────────────────────────────────────────────────

  def export_lineage(conn, %{"organization_id" => org_id, "id" => script_id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         {:ok, v} <- Scripts.resolve_current_version(org_id, script_id),
         {:ok, chain} <- Scripts.version_lineage(v) do
      json(conn, %{lineage: Enum.map(chain, &render_version/1)})
    else
      {:error, :not_found} -> send_resp(conn, 404, "")
      {:error, :not_published} -> conn |> put_status(:conflict) |> json(%{error: "not published"})
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-047 — Validation preview
  # ──────────────────────────────────────────────────────────────────────────

  def validate_draft(conn, %{"organization_id" => org_id, "id" => script_id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         %Script{} = script <- safe_get(org_id, script_id),
         %{} = draft <- Scripts.get_draft_version(script) || :no_draft do
      case Scripts.validate_draft(draft) do
        {:ok, warnings} ->
          json(conn, %{valid: true, warnings: warnings})

        {:error, errors} ->
          json(conn, %{valid: false, errors: errors})
      end
    else
      nil -> send_resp(conn, 404, "")
      :no_draft -> conn |> put_status(:conflict) |> json(%{error: "no draft version"})
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Renderers
  # ──────────────────────────────────────────────────────────────────────────

  defp render_script(s) do
    %{
      id: s.id,
      slug: s.slug,
      name: s.name,
      description: s.description,
      current_version_id: s.current_version_id,
      archived_at: s.archived_at,
      created_at: s.inserted_at,
      updated_at: s.updated_at
    }
  end

  defp render_version(nil), do: nil

  defp render_version(v) do
    %{
      id: v.id,
      version_number: v.version_number,
      description: v.description,
      root_node_id: v.root_node_id,
      checksum: if(v.checksum, do: Base.encode16(v.checksum, case: :lower), else: nil)
    }
  end

  defp render_node(n) do
    %{
      id: n.id,
      script_version_id: n.script_version_id,
      node_key: n.node_key,
      kind: n.kind,
      tone: n.tone,
      eval_tags: n.eval_tags,
      freeball_policy: n.freeball_policy,
      position: n.position,
      metadata: n.metadata,
      prompt_version_id: n.prompt_version_id
    }
  end

  defp render_edge(e) do
    %{
      id: e.id,
      script_version_id: e.script_version_id,
      from_node_id: e.from_node_id,
      to_node_id: e.to_node_id,
      priority: e.priority,
      match_method: e.match_method,
      match_config: e.match_config,
      label: e.label
    }
  end

  defp render_expectation(exp) do
    %{
      id: exp.id,
      script_node_id: exp.script_node_id,
      label: exp.label,
      weight: if(is_struct(exp.weight, Decimal), do: Decimal.to_float(exp.weight), else: exp.weight),
      direction: case exp.direction do
        "positive" -> "maximize"
        "negative" -> "minimize"
        other -> other
      end,
      scoring_method: exp.scoring_method,
      config: exp.config,
      rubric_version_id: exp.rubric_version_id
    }
  end

  defp render_comment(c) do
    %{
      id: c.id,
      script_node_id: c.script_node_id,
      thread_id: c.thread_id,
      parent_comment_id: c.parent_comment_id,
      author_user_id: c.author_user_id,
      body: c.body,
      resolved_at: c.resolved_at,
      inserted_at: c.inserted_at
    }
  end

  defp safe_get(org_id, id) do
    Scripts.get_script(org_id, id)
  rescue
    Ecto.Query.CastError -> nil
  end

  defp safe_get_version(org_id, id) do
    case Codefresh.Repo.get(ScriptVersion, id) do
      %ScriptVersion{organization_id: ^org_id} = v -> v
      _ -> nil
    end
  rescue
    Ecto.Query.CastError -> nil
  end

  defp bad_request(conn, msg), do: conn |> put_status(:bad_request) |> json(%{error: msg})

  defp maybe_put(opts, _k, false), do: opts
  defp maybe_put(opts, k, v), do: Keyword.put(opts, k, v)

  defp truthy?(v) when v in [true, "true", "1", 1], do: true
  defp truthy?(_), do: false
end
