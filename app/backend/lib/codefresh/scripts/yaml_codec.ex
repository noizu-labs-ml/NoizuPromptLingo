defmodule Codefresh.Scripts.YamlCodec do
  @moduledoc """
  Canonical YAML encode/decode for script versions (US-007 import, US-008 export).

  The canonical form is load-bearing: its SHA-256 drives version-level dedup and
  round-trip equivalence (import → export → checksum must equal original).

  Shape:

      script:
        slug: greeter-flow
        name: Greeter Flow
        description: null
        version: 1
      root: start                    # node_key of root_node
      nodes:
        - key: start
          kind: user_turn
          prompt: { slug: welcome, version: 1 }   # or null
          tone: neutral
          eval_tags: [smoke]
          freeball_policy: allow
          position: { x: 0, y: 0 }
          metadata: {}
          expectations:
            - label: contains greeting
              weight: "1.000"
              direction: positive
              scoring_method: regex
              config: { pattern: "(?i)hello" }
              rubric: null                          # or { slug: ..., version: N }
      edges:
        - from: start
          to: end
          match_method: always
          match_config: {}
          priority: 0
          label: null

  Referenced prompt/rubric are recorded by `{slug, version}` (not UUID). On
  decode, resolution is strict: missing slugs / versions abort with an
  actionable error. Ordering is stabilized (nodes by node_key, expectations by
  label, edges by from_key/priority/to_key) so re-encode is deterministic.
  """

  alias Codefresh.Repo
  alias Codefresh.Scripts.{Script, ScriptVersion, ScriptNode, ScriptEdge, Expectation}
  alias Codefresh.Prompts.{Prompt, PromptVersion}
  alias Codefresh.Rubrics.{Rubric, RubricVersion}

  import Ecto.Query, only: [from: 2]

  @doc """
  Encode a `script_version` to a canonical Elixir map (not yet serialized).
  Use `to_yaml/1` for the serialized form.
  """
  def encode(%ScriptVersion{} = sv) do
    script = Repo.get!(Script, sv.script_id)

    nodes =
      Repo.all(
        from n in ScriptNode,
          where: n.script_version_id == ^sv.id,
          order_by: [asc: n.node_key]
      )

    edges =
      Repo.all(
        from e in ScriptEdge,
          where: e.script_version_id == ^sv.id,
          order_by: [asc: e.from_node_id, asc: e.priority, asc: e.to_node_id]
      )

    node_by_id = Map.new(nodes, fn n -> {n.id, n} end)

    expectations_by_node =
      Repo.all(
        from e in Expectation,
          where: e.script_node_id in ^Enum.map(nodes, & &1.id),
          order_by: [asc: e.script_node_id, asc: e.label]
      )
      |> Enum.group_by(& &1.script_node_id)

    prompt_ref_map = build_prompt_ref_map(nodes)
    rubric_ref_map = build_rubric_ref_map(expectations_by_node)

    root_key =
      case sv.root_node_id && Map.get(node_by_id, sv.root_node_id) do
        %ScriptNode{node_key: key} -> key
        _ -> nil
      end

    %{
      "script" => %{
        "slug" => script.slug,
        "name" => script.name,
        "description" => script.description,
        "version" => sv.version_number
      },
      "root" => root_key,
      "nodes" =>
        Enum.map(nodes, fn n ->
          %{
            "key" => n.node_key,
            "kind" => n.kind,
            "prompt" => prompt_ref_map[n.prompt_version_id],
            "tone" => n.tone,
            "eval_tags" => n.eval_tags,
            "freeball_policy" => n.freeball_policy,
            "position" => n.position,
            "metadata" => n.metadata,
            "expectations" =>
              (expectations_by_node[n.id] || [])
              |> Enum.map(fn e ->
                %{
                  "label" => e.label,
                  "weight" => to_string(e.weight),
                  "direction" => e.direction,
                  "scoring_method" => e.scoring_method,
                  "config" => e.config,
                  "rubric" => rubric_ref_map[e.rubric_version_id]
                }
              end)
          }
        end),
      "edges" =>
        Enum.map(edges, fn edge ->
          %{
            "from" => node_by_id[edge.from_node_id].node_key,
            "to" => node_by_id[edge.to_node_id].node_key,
            "match_method" => edge.match_method,
            "match_config" => edge.match_config,
            "priority" => edge.priority,
            "label" => edge.label
          }
        end)
    }
  end

  @doc "Encode to the canonical YAML string. Deterministic — drives checksum."
  def to_yaml(%ScriptVersion{} = sv), do: sv |> encode() |> Ymlr.document!()

  def to_yaml(%{} = canonical), do: Ymlr.document!(canonical)

  @doc """
  Compute the canonical checksum for a script_version. Reads the graph from
  the DB, renders canonical YAML, hashes SHA-256. Used for publish dedup.
  """
  def compute_checksum(%ScriptVersion{} = sv) do
    :crypto.hash(:sha256, to_yaml(sv))
  end

  @doc """
  Parse canonical YAML into a validated map. Returns `{:ok, map}` or
  `{:error, reason}`. Resolves prompt/rubric slug+version references against
  `organization_id`; missing references produce structured errors.
  """
  def decode(yaml, organization_id) when is_binary(yaml) and is_binary(organization_id) do
    with {:ok, parsed} <- parse_yaml(yaml),
         {:ok, normalized} <- normalize(parsed),
         {:ok, prompt_lookup} <- resolve_prompts(normalized, organization_id),
         {:ok, rubric_lookup} <- resolve_rubrics(normalized, organization_id),
         :ok <- validate_structure(normalized) do
      {:ok, %{canonical: normalized, prompts: prompt_lookup, rubrics: rubric_lookup}}
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # private
  # ──────────────────────────────────────────────────────────────────────────

  defp build_prompt_ref_map(nodes) do
    ids = nodes |> Enum.map(& &1.prompt_version_id) |> Enum.reject(&is_nil/1) |> Enum.uniq()

    if ids == [] do
      %{}
    else
      Repo.all(
        from pv in PromptVersion,
          join: p in Prompt,
          on: p.id == pv.prompt_id,
          where: pv.id in ^ids,
          select: {pv.id, %{"slug" => p.slug, "version" => pv.version_number}}
      )
      |> Map.new()
    end
  end

  defp build_rubric_ref_map(exps_by_node) do
    ids =
      exps_by_node
      |> Map.values()
      |> List.flatten()
      |> Enum.map(& &1.rubric_version_id)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    if ids == [] do
      %{}
    else
      Repo.all(
        from rv in RubricVersion,
          join: r in Rubric,
          on: r.id == rv.rubric_id,
          where: rv.id in ^ids,
          select: {rv.id, %{"slug" => r.slug, "version" => rv.version_number}}
      )
      |> Map.new()
    end
  end

  defp parse_yaml(yaml) do
    case YamlElixir.read_from_string(yaml) do
      {:ok, %{} = doc} -> {:ok, doc}
      {:ok, _} -> {:error, :yaml_root_must_be_mapping}
      {:error, reason} -> {:error, {:yaml_parse_error, reason}}
    end
  rescue
    e -> {:error, {:yaml_parse_crash, Exception.message(e)}}
  end

  defp normalize(doc) do
    with %{"script" => script} when is_map(script) <- doc,
         slug when is_binary(slug) <- Map.get(script, "slug"),
         name when is_binary(name) <- Map.get(script, "name") do
      nodes = doc |> Map.get("nodes") |> normalize_nodes()
      edges = doc |> Map.get("edges") |> normalize_edges()

      {:ok,
       %{
         "script" => %{
           "slug" => slug,
           "name" => name,
           "description" => Map.get(script, "description"),
           "version" => Map.get(script, "version", 1)
         },
         "root" => Map.get(doc, "root"),
         "nodes" => nodes,
         "edges" => edges
       }}
    else
      _ -> {:error, :yaml_missing_script_fields}
    end
  end

  defp normalize_nodes(nil), do: []
  defp normalize_nodes(list) when is_list(list), do: Enum.map(list, &normalize_node/1)

  defp normalize_node(n) when is_map(n) do
    %{
      "key" => Map.get(n, "key"),
      "kind" => Map.get(n, "kind", "user_turn"),
      "prompt" => Map.get(n, "prompt"),
      "tone" => Map.get(n, "tone"),
      "eval_tags" => Map.get(n, "eval_tags", []),
      "freeball_policy" => Map.get(n, "freeball_policy", "allow"),
      "position" => Map.get(n, "position", %{}),
      "metadata" => Map.get(n, "metadata", %{}),
      "expectations" =>
        (Map.get(n, "expectations") || [])
        |> Enum.map(&normalize_expectation/1)
    }
  end

  defp normalize_expectation(e) when is_map(e) do
    %{
      "label" => Map.get(e, "label"),
      "weight" => Map.get(e, "weight", "1.000"),
      "direction" => Map.get(e, "direction", "positive"),
      "scoring_method" => Map.get(e, "scoring_method"),
      "config" => Map.get(e, "config", %{}),
      "rubric" => Map.get(e, "rubric")
    }
  end

  defp normalize_edges(nil), do: []
  defp normalize_edges(list) when is_list(list), do: Enum.map(list, &normalize_edge/1)

  defp normalize_edge(e) when is_map(e) do
    %{
      "from" => Map.get(e, "from"),
      "to" => Map.get(e, "to"),
      "match_method" => Map.get(e, "match_method"),
      "match_config" => Map.get(e, "match_config", %{}),
      "priority" => Map.get(e, "priority", 0),
      "label" => Map.get(e, "label")
    }
  end

  defp validate_structure(%{"nodes" => nodes, "edges" => edges, "root" => root}) do
    keys = nodes |> Enum.map(& &1["key"]) |> MapSet.new()

    cond do
      nodes == [] ->
        {:error, :no_nodes}

      root && not MapSet.member?(keys, root) ->
        {:error, {:root_not_in_nodes, root}}

      bad = Enum.find(edges, fn e -> not MapSet.member?(keys, e["from"]) end) ->
        {:error, {:edge_from_missing, bad["from"]}}

      bad = Enum.find(edges, fn e -> not MapSet.member?(keys, e["to"]) end) ->
        {:error, {:edge_to_missing, bad["to"]}}

      true ->
        :ok
    end
  end

  defp resolve_prompts(%{"nodes" => nodes}, org_id) do
    refs =
      nodes
      |> Enum.map(& &1["prompt"])
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    resolve_refs(refs, org_id, :prompt)
  end

  defp resolve_rubrics(%{"nodes" => nodes}, org_id) do
    refs =
      nodes
      |> Enum.flat_map(fn n ->
        Enum.map(n["expectations"], & &1["rubric"])
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    resolve_refs(refs, org_id, :rubric)
  end

  defp resolve_refs([], _org_id, _type), do: {:ok, %{}}

  defp resolve_refs(refs, org_id, type) do
    Enum.reduce_while(refs, {:ok, %{}}, fn ref, {:ok, acc} ->
      case resolve_single(ref, org_id, type) do
        {:ok, version_id} ->
          {:cont, {:ok, Map.put(acc, ref_key(ref), version_id)}}

        {:error, reason} ->
          {:halt, {:error, reason}}
      end
    end)
  end

  defp ref_key(%{"slug" => s, "version" => v}), do: {s, v}

  defp resolve_single(%{"slug" => slug, "version" => version}, org_id, :prompt) do
    q =
      from pv in PromptVersion,
        join: p in Prompt,
        on: p.id == pv.prompt_id,
        where:
          p.organization_id == ^org_id and p.slug == ^slug and pv.version_number == ^version,
        select: pv.id

    case Repo.one(q) do
      nil -> {:error, {:prompt_not_found, slug, version}}
      id -> {:ok, id}
    end
  end

  defp resolve_single(%{"slug" => slug, "version" => version}, org_id, :rubric) do
    q =
      from rv in RubricVersion,
        join: r in Rubric,
        on: r.id == rv.rubric_id,
        where:
          r.organization_id == ^org_id and r.slug == ^slug and rv.version_number == ^version,
        select: rv.id

    case Repo.one(q) do
      nil -> {:error, {:rubric_not_found, slug, version}}
      id -> {:ok, id}
    end
  end

  defp resolve_single(other, _org_id, type),
    do: {:error, {:"#{type}_ref_must_be_slug_version_map", other}}
end
