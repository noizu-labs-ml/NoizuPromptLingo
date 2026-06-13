defmodule Codefresh.Scripts do
  @moduledoc """
  Context for script authoring: head, draft script_version, nodes, edges,
  expectations. Publishing (US-006 — freezing a draft into an immutable
  version) is not yet implemented; all edits in this batch operate on the
  single auto-created draft version.

  Covers US-001 (create script), US-002 (add nodes), US-003 (attach prompt),
  US-004 (add expectation), US-005 (add edge), US-006 (publish), US-007
  (import), US-008 (export), US-041 (fork), US-042 (diff), US-043 (bulk ops),
  US-044 (auto-layout), US-045 (node comments), US-046 (export lineage),
  US-047 (validate draft).
  """

  import Ecto.Query, only: [from: 2]
  alias Ecto.Multi
  alias Codefresh.Repo

  alias Codefresh.Scripts.{
    Script,
    ScriptVersion,
    ScriptNode,
    ScriptEdge,
    Expectation,
    NodeComment,
    YamlCodec
  }

  alias Codefresh.{Prompts, Rubrics}

  # ──────────────────────────────────────────────────────────────────────────
  # US-001 — Create empty script (also creates the draft v1 version)
  # ──────────────────────────────────────────────────────────────────────────

  def create_script(attrs) do
    attrs = normalize(attrs)

    Multi.new()
    |> Multi.insert(:script, Script.create_changeset(%Script{}, attrs))
    |> Multi.insert(:draft_version, fn %{script: s} ->
      ScriptVersion.create_changeset(%ScriptVersion{}, %{
        script_id: s.id,
        organization_id: s.organization_id,
        version_number: 1,
        checksum: ScriptVersion.empty_checksum(),
        description: "draft"
      })
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{script: s, draft_version: v}} -> {:ok, s, v}
      {:error, :script, cs, _} -> {:error, cs}
      {:error, _step, reason, _} -> {:error, reason}
    end
  end

  def update_script(%Script{} = s, attrs) do
    s |> Script.update_changeset(attrs) |> Repo.update()
  end

  def archive_script(%Script{} = s), do: s |> Script.archive_changeset() |> Repo.update()

  def get_script(organization_id, id) do
    Repo.one(from s in Script, where: s.organization_id == ^organization_id and s.id == ^id)
  end

  def get_script!(organization_id, id) do
    case get_script(organization_id, id) do
      nil -> raise Ecto.NoResultsError, queryable: Script
      s -> s
    end
  end

  def list_scripts(organization_id, opts \\ []) do
    include_archived = Keyword.get(opts, :include_archived, false)

    q = from s in Script, where: s.organization_id == ^organization_id, order_by: [asc: s.name]

    q
    |> maybe_hide_archived(include_archived)
    |> Repo.all()
  end

  defp maybe_hide_archived(q, true), do: q
  defp maybe_hide_archived(q, false), do: from(s in q, where: is_nil(s.archived_at))

  @doc """
  Return the currently editable draft script_version for a script. For the
  MVP this is the most recent version regardless of publish state; once
  publishing lands (US-006) this will become "latest draft" exclusively.
  """
  def get_draft_version(%Script{id: script_id}) do
    Repo.one(
      from sv in ScriptVersion,
        where: sv.script_id == ^script_id,
        order_by: [desc: sv.version_number],
        limit: 1
    )
  end

  def get_version!(id), do: Repo.get!(ScriptVersion, id)

  # ──────────────────────────────────────────────────────────────────────────
  # US-002 — Add node (first user_turn becomes root)
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Insert a script_node into a draft version. The first `user_turn` node added
  to a version becomes its `root_node_id`.
  """
  def add_node(%ScriptVersion{} = sv, attrs) do
    attrs =
      attrs
      |> normalize()
      |> Map.put(:script_version_id, sv.id)
      |> Map.put(:organization_id, sv.organization_id)

    Multi.new()
    |> Multi.insert(:node, ScriptNode.create_changeset(%ScriptNode{}, attrs))
    |> Multi.run(:maybe_set_root, fn _repo, %{node: n} ->
      fresh = Repo.get!(ScriptVersion, sv.id)

      case fresh.root_node_id do
        nil when n.kind == "user_turn" ->
          fresh
          |> ScriptVersion.set_root_changeset(n.id)
          |> Repo.update()

        _ ->
          {:ok, fresh}
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{node: n}} -> {:ok, n}
      {:error, :node, cs, _} -> {:error, cs}
      {:error, _step, reason, _} -> {:error, reason}
    end
  end

  def get_node(organization_id, id) do
    Repo.one(
      from n in ScriptNode,
        where: n.organization_id == ^organization_id and n.id == ^id
    )
  end

  def list_nodes(%ScriptVersion{id: sv_id}) do
    Repo.all(
      from n in ScriptNode,
        where: n.script_version_id == ^sv_id,
        order_by: [asc: n.node_key]
    )
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-003 — Attach published prompt to a node
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Attach a published prompt_version to a node. The prompt must be pinnable in
  the same organization. Updates the existing node row (does not create a new
  script_version — draft-mode editing per US-003).
  """
  def attach_prompt(%ScriptNode{} = node, prompt_version_id) do
    cond do
      prompt_version_id == nil or prompt_version_id == "" ->
        {:error, :prompt_version_required}

      not Prompts.pinnable?(node.organization_id, prompt_version_id) ->
        {:error, :prompt_not_pinnable}

      true ->
        node
        |> ScriptNode.update_changeset(%{prompt_version_id: prompt_version_id})
        |> Repo.update()
    end
  end

  def update_node(%ScriptNode{} = node, attrs) do
    node |> ScriptNode.update_changeset(attrs) |> Repo.update()
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-004 — Add expectation to a node
  # ──────────────────────────────────────────────────────────────────────────

  def add_expectation(%ScriptNode{} = node, attrs) do
    attrs =
      attrs
      |> normalize()
      |> Map.put(:script_node_id, node.id)
      |> Map.put(:organization_id, node.organization_id)

    with :ok <- validate_rubric_scope(node.organization_id, attrs) do
      %Expectation{}
      |> Expectation.create_changeset(attrs)
      |> Repo.insert()
    end
  end

  def list_expectations(%ScriptNode{id: node_id}) do
    Repo.all(
      from e in Expectation,
        where: e.script_node_id == ^node_id,
        order_by: [asc: e.label]
    )
  end

  defp validate_rubric_scope(org_id, attrs) do
    method = Map.get(attrs, :scoring_method)
    rubric_id = Map.get(attrs, :rubric_version_id)

    cond do
      method != "rubric" -> :ok
      rubric_id in [nil, ""] -> {:error, :rubric_required}
      Rubrics.pinnable?(org_id, rubric_id) -> :ok
      true -> {:error, :rubric_not_pinnable}
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-005 — Add directed edge
  # ──────────────────────────────────────────────────────────────────────────

  def add_edge(%ScriptVersion{} = sv, attrs) do
    attrs =
      attrs
      |> normalize()
      |> Map.put(:script_version_id, sv.id)
      |> Map.put(:organization_id, sv.organization_id)

    with :ok <- validate_nodes_in_version(sv.id, attrs) do
      %ScriptEdge{}
      |> ScriptEdge.create_changeset(attrs)
      |> Repo.insert()
    end
  end

  def list_edges(%ScriptVersion{id: sv_id}) do
    Repo.all(
      from e in ScriptEdge,
        where: e.script_version_id == ^sv_id,
        order_by: [asc: e.from_node_id, asc: e.priority]
    )
  end

  defp validate_nodes_in_version(sv_id, attrs) do
    from_id = Map.get(attrs, :from_node_id)
    to_id = Map.get(attrs, :to_node_id)

    cond do
      from_id in [nil, ""] or to_id in [nil, ""] ->
        {:error, :from_and_to_required}

      true ->
        q =
          from n in ScriptNode,
            where: n.script_version_id == ^sv_id and n.id in ^[from_id, to_id],
            select: n.id

        case Repo.all(q) |> MapSet.new() do
          ids ->
            cond do
              not MapSet.member?(ids, from_id) -> {:error, :from_node_not_in_version}
              not MapSet.member?(ids, to_id) -> {:error, :to_node_not_in_version}
              true -> :ok
            end
        end
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-006 — Publish a script version
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Freeze the current draft into a published version. Validates the graph (root
  set + at least one expectation + edges reference existing nodes), computes
  canonical YAML + SHA-256 checksum, dedups against published versions in the
  same script. On dedup match returns `{:ok, :noop, existing}`.

  Returns:
    * `{:ok, :published, version}` — newly-published version; `scripts.current_version_id` advanced
    * `{:ok, :noop, version}` — identical canonical content already published; no-op
    * `{:error, reason}` — validation failed
  """
  def publish_version(%Script{} = script, opts \\ []) do
    published_by = Keyword.get(opts, :published_by_user_id)

    case get_draft_version(script) do
      nil ->
        {:error, :no_draft_version}

      %ScriptVersion{} = draft ->
        with :ok <- validate_graph(draft),
             yaml <- YamlCodec.to_yaml(draft),
             checksum <- :crypto.hash(:sha256, yaml),
             :no_dup <- check_duplicate(script, checksum) do
          do_publish(script, draft, yaml, checksum, published_by)
        else
          {:dup, existing} -> {:ok, :noop, existing}
          {:error, _} = err -> err
        end
    end
  end

  defp validate_graph(%ScriptVersion{} = draft) do
    nodes = list_nodes(draft)
    edges = list_edges(draft)

    exp_count =
      Repo.aggregate(
        from(e in Expectation, where: e.script_node_id in ^Enum.map(nodes, & &1.id)),
        :count,
        :id
      )

    node_ids = MapSet.new(nodes, & &1.id)

    cond do
      nodes == [] -> {:error, :no_nodes}
      is_nil(draft.root_node_id) -> {:error, :root_not_set}
      exp_count == 0 -> {:error, :no_expectations}
      bad = Enum.find(edges, fn e -> not MapSet.member?(node_ids, e.from_node_id) end) ->
        {:error, {:edge_from_missing, bad.id}}
      bad = Enum.find(edges, fn e -> not MapSet.member?(node_ids, e.to_node_id) end) ->
        {:error, {:edge_to_missing, bad.id}}
      true -> :ok
    end
  end

  defp check_duplicate(%Script{id: script_id}, checksum) do
    case Repo.one(
           from sv in ScriptVersion,
             where: sv.script_id == ^script_id and sv.checksum == ^checksum and not is_nil(sv.yaml_source),
             limit: 1
         ) do
      nil -> :no_dup
      existing -> {:dup, existing}
    end
  end

  defp do_publish(%Script{} = script, %ScriptVersion{} = draft, yaml, checksum, published_by) do
    Multi.new()
    |> Multi.update(
      :freeze_version,
      Ecto.Changeset.change(draft,
        yaml_source: yaml,
        checksum: checksum,
        published_by_user_id: published_by
      )
    )
    |> Multi.update(:advance_head, fn %{freeze_version: v} ->
      Script.advance_current_version_changeset(script, v.id)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{freeze_version: v}} -> {:ok, :published, v}
      {:error, _step, reason, _} -> {:error, reason}
    end
  end

  @doc """
  Return the currently-published version of a script (via scripts.current_version_id).
  """
  def resolve_current_version(organization_id, script_id) do
    case get_script(organization_id, script_id) do
      nil -> {:error, :not_found}
      %Script{current_version_id: nil} -> {:error, :not_published}
      %Script{current_version_id: vid} -> {:ok, Repo.get!(ScriptVersion, vid)}
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-007 — Import script from YAML
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Import a script from canonical YAML. Strict-resolution: prompts + rubrics are
  resolved by `{slug, version}` against the target org; missing refs abort.

  Returns:
    * `{:ok, :imported, script, version}` — new script head + published version created
    * `{:ok, :noop, script, version}` — same canonical YAML already published in this org
    * `{:error, reason}` — parse / resolve / validation failure
  """
  def import_yaml(yaml, organization_id, opts \\ []) do
    imported_by = Keyword.get(opts, :imported_by_user_id)

    with {:ok, decoded} <- YamlCodec.decode(yaml, organization_id),
         checksum = :crypto.hash(:sha256, yaml),
         {:ok, script, version} <- find_or_create_from_yaml(decoded, organization_id, imported_by, yaml, checksum) do
      {:ok, script, version}
    end
  end

  defp find_or_create_from_yaml(%{canonical: doc} = decoded, org_id, user_id, yaml, checksum) do
    slug = get_in(doc, ["script", "slug"])
    name = get_in(doc, ["script", "name"])
    description = get_in(doc, ["script", "description"])

    case get_script_by_slug(org_id, slug) do
      %Script{} = existing ->
        # Check for duplicate published version
        case Repo.one(
               from sv in ScriptVersion,
                 where: sv.script_id == ^existing.id and sv.checksum == ^checksum,
                 limit: 1
             ) do
          %ScriptVersion{} = v -> {:ok, :noop, existing, v}
          nil -> build_new_version(existing, decoded, user_id, yaml, checksum)
        end

      nil ->
        Multi.new()
        |> Multi.run(:script, fn _repo, _ ->
          create_head_and_draft(%{
            "organization_id" => org_id,
            "created_by_user_id" => user_id,
            "slug" => slug,
            "name" => name,
            "description" => description
          })
        end)
        |> Multi.run(:built, fn _repo, %{script: {script, draft}} ->
          build_graph(draft, decoded, yaml, checksum, user_id)
          |> case do
            {:ok, v} -> {:ok, {script, v}}
            err -> err
          end
        end)
        |> Repo.transaction()
        |> case do
          {:ok, %{built: {script, v}}} -> {:ok, :imported, script, v}
          {:error, _step, reason, _} -> {:error, reason}
        end
    end
  end

  defp create_head_and_draft(attrs) do
    case create_script(attrs) do
      {:ok, script, draft} -> {:ok, {script, draft}}
      {:error, _} = err -> err
    end
  end

  defp build_new_version(%Script{} = script, _decoded, _user_id, _yaml, _checksum) do
    # Producing a second version for an existing script would require draft-fork semantics;
    # deferred to US-041 (fork). For MVP, surface explicit conflict.
    {:error, {:script_slug_conflict, script.slug}}
  end

  defp build_graph(%ScriptVersion{} = draft, %{canonical: doc, prompts: prompts, rubrics: rubrics}, yaml, checksum, user_id) do
    nodes_spec = doc["nodes"]
    edges_spec = doc["edges"]
    root_key = doc["root"]

    Repo.transaction(fn ->
      # Insert nodes; build key → struct map
      nodes_by_key =
        Enum.reduce(nodes_spec, %{}, fn nspec, acc ->
          prompt_id = if nspec["prompt"], do: Map.fetch!(prompts, yaml_ref_key(nspec["prompt"])), else: nil

          {:ok, n} =
            add_node(draft, %{
              "node_key" => nspec["key"],
              "kind" => nspec["kind"],
              "prompt_version_id" => prompt_id,
              "tone" => nspec["tone"],
              "eval_tags" => nspec["eval_tags"],
              "freeball_policy" => nspec["freeball_policy"],
              "position" => nspec["position"],
              "metadata" => nspec["metadata"]
            })

          # Insert expectations for this node
          Enum.each(nspec["expectations"], fn espec ->
            rubric_id = if espec["rubric"], do: Map.fetch!(rubrics, yaml_ref_key(espec["rubric"])), else: nil
            {:ok, _} =
              add_expectation(n, %{
                "label" => espec["label"],
                "weight" => espec["weight"],
                "direction" => espec["direction"],
                "scoring_method" => espec["scoring_method"],
                "config" => espec["config"],
                "rubric_version_id" => rubric_id
              })
          end)

          Map.put(acc, n.node_key, n)
        end)

      # Set root if specified
      fresh_draft = Repo.get!(ScriptVersion, draft.id)

      fresh_draft =
        if root_key && Map.has_key?(nodes_by_key, root_key) do
          {:ok, updated} =
            fresh_draft
            |> ScriptVersion.set_root_changeset(nodes_by_key[root_key].id)
            |> Repo.update()

          updated
        else
          fresh_draft
        end

      # Insert edges
      Enum.each(edges_spec, fn espec ->
        {:ok, _} =
          add_edge(fresh_draft, %{
            "from_node_id" => nodes_by_key[espec["from"]].id,
            "to_node_id" => nodes_by_key[espec["to"]].id,
            "match_method" => espec["match_method"],
            "match_config" => espec["match_config"],
            "priority" => espec["priority"],
            "label" => espec["label"]
          })
      end)

      # Freeze draft as published version
      {:ok, published} =
        fresh_draft
        |> Ecto.Changeset.change(
          yaml_source: yaml,
          checksum: checksum,
          published_by_user_id: user_id
        )
        |> Repo.update()

      # Advance head
      script = Repo.get!(Script, draft.script_id)

      {:ok, _} =
        script
        |> Script.advance_current_version_changeset(published.id)
        |> Repo.update()

      published
    end)
    |> case do
      {:ok, v} -> {:ok, v}
      {:error, reason} -> {:error, reason}
    end
  end

  defp yaml_ref_key(%{"slug" => s, "version" => v}), do: {s, v}

  # ──────────────────────────────────────────────────────────────────────────
  # US-008 — Export published script as YAML
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Return the canonical YAML for a published script version. If `yaml_source` is
  populated (the normal case after publish), returns it verbatim — that's the
  load-bearing checksum basis. If missing (rare — version stored without freeze),
  re-render from the graph.
  """
  def export_yaml(%ScriptVersion{yaml_source: yaml}) when is_binary(yaml), do: yaml
  def export_yaml(%ScriptVersion{} = sv), do: YamlCodec.to_yaml(sv)

  # ──────────────────────────────────────────────────────────────────────────
  # US-041 — Fork a script to a new head
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Fork the current published version of `script` into a new script head in the
  same org. The fork gets a derived slug (`<source-slug>-fork-<short>`) and a
  fresh draft v1 with `parent_version_id` pointing at the source version.

  Returns `{:ok, forked_script, draft_version}` or `{:error, reason}`.
  """
  def fork_script(%Script{} = source, opts \\ []) do
    forked_by = Keyword.get(opts, :forked_by_user_id)

    case resolve_current_version(source.organization_id, source.id) do
      {:error, _} = err ->
        err

      {:ok, source_version} ->
        short = :crypto.strong_rand_bytes(3) |> Base.encode16(case: :lower)
        fork_slug = derive_unique_slug(source.organization_id, "#{source.slug}-fork-#{short}")

        Multi.new()
        |> Multi.insert(:fork, Script.create_changeset(%Script{}, %{
          organization_id: source.organization_id,
          name: "#{source.name} (fork)",
          slug: fork_slug,
          description: source.description,
          created_by_user_id: forked_by
        }))
        |> Multi.insert(:draft, fn %{fork: fork} ->
          ScriptVersion.create_changeset(%ScriptVersion{}, %{
            script_id: fork.id,
            organization_id: fork.organization_id,
            version_number: 1,
            checksum: ScriptVersion.empty_checksum(),
            description: "draft (forked from #{source.slug} v#{source_version.version_number})",
            parent_version_id: source_version.id
          })
        end)
        |> Multi.run(:copy_graph, fn _repo, %{draft: draft} ->
          copy_graph_from_version(source_version, draft)
        end)
        |> Repo.transaction()
        |> case do
          {:ok, %{fork: fork, draft: draft}} -> {:ok, fork, draft}
          {:error, _step, reason, _} -> {:error, reason}
        end
    end
  end

  defp derive_unique_slug(org_id, base_slug) do
    slug = String.slice(base_slug, 0, 120)

    case get_script_by_slug(org_id, slug) do
      nil -> slug
      _ ->
        suffix = :crypto.strong_rand_bytes(2) |> Base.encode16(case: :lower)
        derive_unique_slug(org_id, "#{String.slice(base_slug, 0, 115)}-#{suffix}")
    end
  end

  defp copy_graph_from_version(%ScriptVersion{} = src_ver, %ScriptVersion{} = dst_ver) do
    src_nodes = list_nodes(src_ver)
    src_edges = list_edges(src_ver)

    Repo.transaction(fn ->
      # Build old_id -> new_node map
      node_map =
        Enum.reduce(src_nodes, %{}, fn sn, acc ->
          {:ok, new_node} =
            add_node(dst_ver, %{
              node_key: sn.node_key,
              kind: sn.kind,
              tone: sn.tone,
              eval_tags: sn.eval_tags,
              freeball_policy: sn.freeball_policy,
              position: sn.position,
              metadata: sn.metadata,
              prompt_version_id: sn.prompt_version_id
            })

          Map.put(acc, sn.id, new_node)
        end)

      # Set root
      if src_ver.root_node_id && Map.has_key?(node_map, src_ver.root_node_id) do
        new_root = node_map[src_ver.root_node_id]
        fresh_dst = Repo.get!(ScriptVersion, dst_ver.id)

        fresh_dst
        |> ScriptVersion.set_root_changeset(new_root.id)
        |> Repo.update!()
      end

      # Copy edges
      Enum.each(src_edges, fn se ->
        new_from = node_map[se.from_node_id]
        new_to = node_map[se.to_node_id]

        if new_from && new_to do
          {:ok, _} =
            add_edge(Repo.get!(ScriptVersion, dst_ver.id), %{
              from_node_id: new_from.id,
              to_node_id: new_to.id,
              match_method: se.match_method,
              match_config: se.match_config,
              priority: se.priority,
              label: se.label
            })
        end
      end)

      :ok
    end)
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-042 — Diff two script versions
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Compute a structural diff between two script versions. Returns a map with
  keys: `added_nodes`, `removed_nodes`, `changed_nodes`, `added_edges`,
  `removed_edges`. Node identity is determined by `node_key`; edge identity
  by `{from_node_key, to_node_key, priority}`.
  """
  def diff_versions(%ScriptVersion{} = a, %ScriptVersion{} = b) do
    nodes_a = list_nodes(a) |> Map.new(&{&1.node_key, &1})
    nodes_b = list_nodes(b) |> Map.new(&{&1.node_key, &1})

    keys_a = MapSet.new(Map.keys(nodes_a))
    keys_b = MapSet.new(Map.keys(nodes_b))

    added_nodes = MapSet.difference(keys_b, keys_a) |> Enum.map(&nodes_b[&1])
    removed_nodes = MapSet.difference(keys_a, keys_b) |> Enum.map(&nodes_a[&1])

    changed_nodes =
      MapSet.intersection(keys_a, keys_b)
      |> Enum.filter(fn key ->
        na = nodes_a[key]
        nb = nodes_b[key]
        na.kind != nb.kind or na.tone != nb.tone or na.eval_tags != nb.eval_tags or
          na.prompt_version_id != nb.prompt_version_id or na.position != nb.position
      end)
      |> Enum.map(fn key -> %{before: nodes_a[key], after: nodes_b[key]} end)

    # Build node_id -> key lookup for edge diff
    nid_to_key_a =
      Map.values(nodes_a) |> Map.new(&{&1.id, &1.node_key})

    nid_to_key_b =
      Map.values(nodes_b) |> Map.new(&{&1.id, &1.node_key})

    edge_key_a = fn e ->
      {Map.get(nid_to_key_a, e.from_node_id), Map.get(nid_to_key_a, e.to_node_id), e.priority}
    end

    edge_key_b = fn e ->
      {Map.get(nid_to_key_b, e.from_node_id), Map.get(nid_to_key_b, e.to_node_id), e.priority}
    end

    edges_a = list_edges(a) |> Map.new(&{edge_key_a.(&1), &1})
    edges_b = list_edges(b) |> Map.new(&{edge_key_b.(&1), &1})

    ekeys_a = MapSet.new(Map.keys(edges_a))
    ekeys_b = MapSet.new(Map.keys(edges_b))

    added_edges = MapSet.difference(ekeys_b, ekeys_a) |> Enum.map(&edges_b[&1])
    removed_edges = MapSet.difference(ekeys_a, ekeys_b) |> Enum.map(&edges_a[&1])

    %{
      added_nodes: added_nodes,
      removed_nodes: removed_nodes,
      changed_nodes: changed_nodes,
      added_edges: added_edges,
      removed_edges: removed_edges
    }
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-043 — Bulk node operations
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Perform a bulk operation on a set of nodes within a script version.

  Actions:
    * `"archive"` — set `metadata["archived"] = true` on each node
    * `"retag"`   — replace `eval_tags` with supplied `tags`

  Returns `{:ok, updated_nodes}` or `{:error, reason}`.
  """
  def bulk_node_operation(%ScriptVersion{} = sv, action, node_ids, opts \\ [])
      when action in ["archive", "retag"] do
    tags = Keyword.get(opts, :tags, [])
    org_id = sv.organization_id

    nodes =
      Repo.all(
        from n in ScriptNode,
          where: n.script_version_id == ^sv.id and n.organization_id == ^org_id and n.id in ^node_ids
      )

    missing = MapSet.difference(MapSet.new(node_ids), MapSet.new(nodes, & &1.id))

    if MapSet.size(missing) > 0 do
      {:error, {:nodes_not_found, MapSet.to_list(missing)}}
    else
      results =
        Enum.map(nodes, fn node ->
          attrs =
            case action do
              "archive" -> %{metadata: Map.put(node.metadata || %{}, "archived", true)}
              "retag" -> %{eval_tags: tags}
            end

          node |> ScriptNode.update_changeset(attrs) |> Repo.update()
        end)

      errors = Enum.filter(results, &match?({:error, _}, &1))

      if errors == [] do
        {:ok, Enum.map(results, fn {:ok, n} -> n end)}
      else
        {:error, {:partial_failure, errors}}
      end
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-044 — Auto-layout node positions
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Assign positions to all nodes in a draft version using BFS from the root
  node. Returns `{:ok, updated_nodes}` or `{:error, reason}`.

  Layout algorithm: y = depth * 100, x = rank_within_depth * 150 (centered).
  Nodes unreachable from the root are placed in a row below the last BFS level.
  """
  def auto_layout(%ScriptVersion{} = sv) do
    # Reload to get current root_node_id in case caller holds a stale struct
    fresh_sv = Repo.get!(ScriptVersion, sv.id)
    nodes = list_nodes(fresh_sv)
    edges = list_edges(fresh_sv)

    if nodes == [] do
      {:ok, []}
    else
      positions = compute_bfs_positions(nodes, edges, fresh_sv.root_node_id)

      results =
        Enum.map(nodes, fn node ->
          pos = Map.get(positions, node.id, %{"x" => 0, "y" => 0})
          node |> ScriptNode.update_changeset(%{position: pos}) |> Repo.update()
        end)

      errors = Enum.filter(results, &match?({:error, _}, &1))

      if errors == [] do
        {:ok, Enum.map(results, fn {:ok, n} -> n end)}
      else
        {:error, {:layout_partial_failure, errors}}
      end
    end
  end

  defp compute_bfs_positions(nodes, edges, root_id) do
    adjacency =
      Enum.reduce(edges, %{}, fn e, acc ->
        Map.update(acc, e.from_node_id, [e.to_node_id], &[e.to_node_id | &1])
      end)

    all_ids = MapSet.new(nodes, & &1.id)

    start_id = if root_id && MapSet.member?(all_ids, root_id), do: root_id, else: hd(nodes).id

    {depth_map, _} =
      bfs([{start_id, 0}], adjacency, %{start_id => 0}, MapSet.new([start_id]))

    # Group by depth
    by_depth =
      Enum.group_by(depth_map, fn {_id, depth} -> depth end, fn {id, _} -> id end)

    max_depth = if map_size(by_depth) > 0, do: Enum.max(Map.keys(by_depth)), else: 0

    visited = MapSet.new(Map.keys(depth_map))
    orphans = MapSet.difference(all_ids, visited) |> MapSet.to_list()

    # Build position map
    positioned =
      Enum.reduce(by_depth, %{}, fn {depth, ids}, acc ->
        count = length(ids)
        ids_sorted = Enum.sort(ids)

        ids_sorted
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {id, rank}, a ->
          x = (rank - (count - 1) / 2.0) * 150
          y = depth * 100
          Map.put(a, id, %{"x" => round(x), "y" => y})
        end)
      end)

    orphan_y = (max_depth + 2) * 100

    orphans
    |> Enum.with_index()
    |> Enum.reduce(positioned, fn {id, rank}, acc ->
      Map.put(acc, id, %{"x" => rank * 150, "y" => orphan_y})
    end)
  end

  defp bfs([], _adj, depth_map, visited), do: {depth_map, visited}

  defp bfs([{id, depth} | rest], adj, depth_map, visited) do
    children = Map.get(adj, id, [])

    {new_queue, new_depth_map, new_visited} =
      Enum.reduce(children, {rest, depth_map, visited}, fn child_id, {q, dm, v} ->
        if MapSet.member?(v, child_id) do
          {q, dm, v}
        else
          {q ++ [{child_id, depth + 1}], Map.put(dm, child_id, depth + 1), MapSet.put(v, child_id)}
        end
      end)

    bfs(new_queue, adj, new_depth_map, new_visited)
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-045 — Node comments
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  List all comments on a script node, ordered by thread_id and insertion time.
  """
  def list_node_comments(organization_id, node_id) do
    Repo.all(
      from c in NodeComment,
        where: c.script_node_id == ^node_id and c.organization_id == ^organization_id,
        order_by: [asc: c.thread_id, asc: c.inserted_at]
    )
  end

  @doc """
  Add a comment to a script node. `attrs` must include `:body`, `:thread_id`,
  and optionally `:parent_comment_id`.
  """
  def add_node_comment(%ScriptNode{} = node, author_user_id, attrs) do
    attrs =
      attrs
      |> normalize()
      |> Map.put(:script_node_id, node.id)
      |> Map.put(:organization_id, node.organization_id)
      |> Map.put(:author_user_id, author_user_id)

    %NodeComment{}
    |> NodeComment.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Resolve a comment thread. Marks the root comment (or any comment in the thread)
  as resolved.
  """
  def resolve_comment(%NodeComment{} = comment, resolver_user_id) do
    comment
    |> NodeComment.resolve_changeset(resolver_user_id)
    |> Repo.update()
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-046 — Export lineage (parent_version traversal)
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Return the lineage chain for a script version — the list of ancestor
  `ScriptVersion` records reached by following `parent_version_id`, oldest
  first. The version itself is included at the tail.

  Guards against cycles (max 100 hops). Returns `{:ok, [%ScriptVersion{}]}`.
  """
  def version_lineage(%ScriptVersion{} = version, max_depth \\ 100) do
    chain = build_lineage(version, [], max_depth)
    {:ok, chain}
  end

  defp build_lineage(%ScriptVersion{parent_version_id: nil} = v, acc, _max),
    do: [v | acc]

  defp build_lineage(_v, acc, 0), do: acc

  defp build_lineage(%ScriptVersion{parent_version_id: parent_id} = v, acc, remaining) do
    case Repo.get(ScriptVersion, parent_id) do
      nil -> [v | acc]
      parent -> build_lineage(parent, [v | acc], remaining - 1)
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-047 — Validation preview (validate_draft/1)
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Public interface for graph validation that returns structured warnings and
  errors without persisting anything.

  Returns:
    * `{:ok, warnings}` — graph is valid; `warnings` is a list of string hints
    * `{:error, errors}` — graph has blocking errors; `errors` is a list of strings
  """
  def validate_draft(%ScriptVersion{} = draft) do
    nodes = list_nodes(draft)
    edges = list_edges(draft)

    exp_count =
      if nodes == [] do
        0
      else
        Repo.aggregate(
          from(e in Expectation, where: e.script_node_id in ^Enum.map(nodes, & &1.id)),
          :count,
          :id
        )
      end

    node_ids = MapSet.new(nodes, & &1.id)

    errors =
      []
      |> maybe_add_error(nodes == [], "Graph has no nodes")
      |> maybe_add_error(is_nil(draft.root_node_id), "Root node is not set")
      |> maybe_add_error(exp_count == 0, "Graph has no expectations")
      |> maybe_add_edge_errors(edges, node_ids)

    warnings =
      []
      |> maybe_add_warning(
        Enum.any?(nodes, fn n -> n.kind == "user_turn" and is_nil(n.prompt_version_id) end),
        "One or more user_turn nodes have no prompt attached"
      )
      |> maybe_add_warning(
        edges == [] and length(nodes) > 1,
        "Multiple nodes with no edges — graph may be disconnected"
      )

    if errors == [] do
      {:ok, warnings}
    else
      {:error, errors}
    end
  end

  defp maybe_add_error(acc, false, _msg), do: acc
  defp maybe_add_error(acc, true, msg), do: acc ++ [msg]

  defp maybe_add_warning(acc, false, _msg), do: acc
  defp maybe_add_warning(acc, true, msg), do: acc ++ [msg]

  defp maybe_add_edge_errors(acc, edges, node_ids) do
    Enum.reduce(edges, acc, fn e, a ->
      a
      |> maybe_add_error(
        not MapSet.member?(node_ids, e.from_node_id),
        "Edge #{e.id}: from_node_id references unknown node"
      )
      |> maybe_add_error(
        not MapSet.member?(node_ids, e.to_node_id),
        "Edge #{e.id}: to_node_id references unknown node"
      )
    end)
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Helpers
  # ──────────────────────────────────────────────────────────────────────────

  defp get_script_by_slug(organization_id, slug) when is_binary(slug) do
    Repo.get_by(Script, organization_id: organization_id, slug: slug)
  end

  defp normalize(attrs) when is_map(attrs) do
    for {k, v} <- attrs, into: %{} do
      key = if is_atom(k), do: k, else: safe_atom(to_string(k))
      {key, v}
    end
  end

  defp safe_atom(str) do
    String.to_existing_atom(str)
  rescue
    ArgumentError -> String.to_atom(str)
  end
end
