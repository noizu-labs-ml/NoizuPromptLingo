defmodule NoizuPromptLingua.Domains.UnicodeCodex do
  @moduledoc """
  Layered Unicode codex access. Effective rows resolve by project > organization
  > global precedence.
  """
  import Ecto.Query

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Unicode.{Element, ElementRelation, ElementUsage, SpecialUsage}

  @default_limit 100
  @max_limit 250
  @unsafe_visibilities ~w(control invisible space combining directional)

  # ── Public list/detail API ───────────────────────────────────

  def list_elements(opts \\ []) do
    org_id = blank_to_nil(opts[:organization_id])
    project_id = blank_to_nil(opts[:project_id])
    include_shadowed = truthy?(opts[:include_shadowed])
    limit = clamp_limit(opts[:limit])
    offset = max(parse_int(opts[:offset], 0), 0)

    query =
      Element
      |> scoped(org_id, project_id)

    rows =
      query
      |> maybe_apply_element_db_filters(opts, include_shadowed)
      |> Repo.all()
      |> Repo.preload(:special_usages)

    maps =
      rows
      |> apply_effective(include_shadowed)
      |> Enum.filter(fn {row, _layers} -> include_shadowed or element_matches?(row, opts) end)
      |> Enum.map(fn {row, layers} -> element_json(row, layers) end)
      |> Enum.sort_by(&{String.downcase(&1.title || ""), &1.slug})

    %{count: length(maps), elements: Enum.slice(maps, offset, limit)}
  end

  def get_element(slug, opts \\ []) do
    org_id = blank_to_nil(opts[:organization_id])
    project_id = blank_to_nil(opts[:project_id])

    rows =
      Element
      |> scoped(org_id, project_id)
      |> where([e], e.slug == ^normalize_slug(slug))
      |> Repo.all()
      |> Repo.preload([:special_usages, outgoing_relations: [:target_element]])

    case effective_row(rows) do
      nil ->
        {:error, :not_found}

      top ->
        {:ok,
         %{
           element: element_detail_json(top, rows),
           layers: rows |> Enum.sort_by(&scope_rank/1, :desc) |> Enum.map(&element_json(&1, rows))
         }}
    end
  end

  def list_special_usages(opts \\ []) do
    org_id = blank_to_nil(opts[:organization_id])
    project_id = blank_to_nil(opts[:project_id])
    include_shadowed = truthy?(opts[:include_shadowed])

    query =
      SpecialUsage
      |> scoped(org_id, project_id)

    rows =
      query
      |> maybe_apply_usage_db_filters(opts, include_shadowed)
      |> Repo.all()

    usages =
      rows
      |> apply_effective(include_shadowed)
      |> Enum.filter(fn {row, _layers} -> include_shadowed or usage_matches?(row, opts) end)
      |> Enum.map(fn {row, layers} -> special_usage_json(row, layers) end)
      |> Enum.sort_by(&{String.downcase(&1.title || ""), &1.slug})

    %{count: length(usages), special_usages: usages}
  end

  def get_special_usage(slug, opts \\ []) do
    org_id = blank_to_nil(opts[:organization_id])
    project_id = blank_to_nil(opts[:project_id])

    rows =
      SpecialUsage
      |> scoped(org_id, project_id)
      |> where([u], u.slug == ^normalize_slug(slug))
      |> Repo.all()

    case effective_row(rows) do
      nil ->
        {:error, :not_found}

      top ->
        {:ok,
         %{
           special_usage: special_usage_json(top, rows),
           layers:
             rows |> Enum.sort_by(&scope_rank/1, :desc) |> Enum.map(&special_usage_json(&1, rows))
         }}
    end
  end

  def related(slug, opts \\ []) do
    with {:ok, %{element: %{id: element_id}}} <- get_element(slug, opts) do
      org_id = blank_to_nil(opts[:organization_id])
      project_id = blank_to_nil(opts[:project_id])

      relations =
        ElementRelation
        |> where([r], r.source_element_id == ^element_id)
        |> Repo.all()
        |> Repo.preload(:target_element)
        |> Enum.map(fn relation ->
          target =
            effective_element_by_slug(relation.target_element.slug, org_id, project_id) ||
              relation.target_element

          %{
            id: relation.id,
            relation_type: relation.relation_type,
            description: relation.description,
            metadata: relation.metadata || %{},
            target: element_json(target, [target])
          }
        end)

      {:ok, %{relations: relations, count: length(relations)}}
    end
  end

  def count(opts \\ []) do
    list_elements(opts).count
  end

  # ── Seed helpers ─────────────────────────────────────────────

  def upsert_special_usage(attrs) do
    attrs = normalize_scope_attrs(attrs)
    existing = get_by_scope(SpecialUsage, attrs)

    (existing || %SpecialUsage{})
    |> SpecialUsage.changeset(attrs)
    |> insert_or_update(existing)
  end

  def upsert_element(attrs) do
    attrs = normalize_scope_attrs(attrs)
    existing = get_by_scope(Element, attrs)

    (existing || %Element{})
    |> Element.changeset(attrs)
    |> insert_or_update(existing)
  end

  def replace_element_usages(element, usage_slugs, org_id, project_id) do
    from(eu in ElementUsage, where: eu.element_id == ^element.id)
    |> Repo.delete_all()

    usage_slugs
    |> List.wrap()
    |> Enum.map(&normalize_slug/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.each(fn slug ->
      case effective_special_usage_by_slug(slug, org_id, project_id) do
        nil ->
          raise "Unicode special usage '#{slug}' not found for element '#{element.slug}'"

        usage ->
          %ElementUsage{}
          |> ElementUsage.changeset(%{element_id: element.id, special_usage_id: usage.id})
          |> Repo.insert(on_conflict: :nothing, conflict_target: [:element_id, :special_usage_id])
      end
    end)

    :ok
  end

  def replace_element_relations(element, relation_specs, org_id, project_id) do
    from(r in ElementRelation, where: r.source_element_id == ^element.id)
    |> Repo.delete_all()

    relation_specs
    |> List.wrap()
    |> Enum.each(fn spec ->
      target_slug = spec["target"] || spec[:target]
      relation_type = spec["type"] || spec[:type]

      case effective_element_by_slug(target_slug, org_id, project_id) do
        nil ->
          raise "Unicode relation target '#{target_slug}' not found for element '#{element.slug}'"

        target ->
          attrs = %{
            source_element_id: element.id,
            target_element_id: target.id,
            relation_type: relation_type,
            description: spec["description"] || spec[:description],
            metadata: spec["metadata"] || spec[:metadata] || %{}
          }

          %ElementRelation{}
          |> ElementRelation.changeset(attrs)
          |> Repo.insert(
            on_conflict: :nothing,
            conflict_target: [:source_element_id, :target_element_id, :relation_type]
          )
      end
    end)

    :ok
  end

  def effective_element_by_slug(slug, org_id, project_id) do
    Element
    |> scoped(org_id, project_id)
    |> where([e], e.slug == ^normalize_slug(slug))
    |> Repo.all()
    |> effective_row()
  end

  def effective_special_usage_by_slug(slug, org_id, project_id) do
    SpecialUsage
    |> scoped(org_id, project_id)
    |> where([u], u.slug == ^normalize_slug(slug))
    |> Repo.all()
    |> effective_row()
  end

  # ── JSON helpers ─────────────────────────────────────────────

  def element_json(element, layers \\ []) do
    rank = scope_rank(element)
    higher = layers |> Enum.filter(&(scope_rank(&1) > rank)) |> Enum.sort_by(&scope_rank/1, :desc)
    lower = layers |> Enum.filter(&(scope_rank(&1) < rank)) |> Enum.sort_by(&scope_rank/1, :desc)

    %{
      id: element.id,
      scope: element.scope,
      organization_id: element.organization_id,
      project_id: element.project_id,
      slug: element.slug,
      codepoint: element.codepoint,
      codepoint_int: element.codepoint_int,
      char: element.char,
      name: element.name,
      title: element.title,
      description: element.description,
      meaning: element.meaning,
      printable: element.printable,
      visibility: element.visibility,
      unicode: element.unicode_meta || %{},
      flags: element.flags || [],
      topics: element.topics || [],
      sentiments: element.sentiments || [],
      aliases: element.aliases || [],
      search_terms: element.search_terms || [],
      display: display_value(element),
      copy_value: copy_value(element),
      escape_forms: escape_forms(element),
      warnings: warnings(element),
      special_usages: Enum.map(loaded_usages(element), &special_usage_ref/1),
      special_usage_count: length(loaded_usages(element)),
      overrides: Enum.map(lower, &layer_ref/1),
      shadowed_by: higher |> List.first() |> layer_ref_or_nil()
    }
  end

  def element_detail_json(element, layers \\ []) do
    Map.merge(element_json(element, layers), %{
      relations: Enum.map(loaded_relations(element), &relation_json/1)
    })
  end

  def special_usage_json(usage, layers \\ []) do
    rank = scope_rank(usage)
    higher = layers |> Enum.filter(&(scope_rank(&1) > rank)) |> Enum.sort_by(&scope_rank/1, :desc)
    lower = layers |> Enum.filter(&(scope_rank(&1) < rank)) |> Enum.sort_by(&scope_rank/1, :desc)

    %{
      id: usage.id,
      scope: usage.scope,
      organization_id: usage.organization_id,
      project_id: usage.project_id,
      slug: usage.slug,
      name: usage.name,
      title: usage.title,
      description: usage.description,
      references: usage.references || [],
      flags: usage.flags || [],
      topics: usage.topics || [],
      overrides: Enum.map(lower, &layer_ref/1),
      shadowed_by: higher |> List.first() |> layer_ref_or_nil()
    }
  end

  def scope_rank(%{scope: "project"}), do: 2
  def scope_rank(%{scope: "organization"}), do: 1
  def scope_rank(%{scope: "global"}), do: 0
  def scope_rank(_), do: -1

  # ── Query helpers ────────────────────────────────────────────

  defp scoped(query, nil, _project_id), do: where(query, [r], r.scope == "global")

  defp scoped(query, org_id, nil) do
    where(
      query,
      [r],
      r.scope == "global" or
        (r.scope == "organization" and r.organization_id == ^org_id)
    )
  end

  defp scoped(query, org_id, project_id) do
    where(
      query,
      [r],
      r.scope == "global" or
        (r.scope == "organization" and r.organization_id == ^org_id) or
        (r.scope == "project" and r.organization_id == ^org_id and r.project_id == ^project_id)
    )
  end

  defp maybe_apply_element_db_filters(query, opts, true) do
    query
    |> maybe_filter(:printable, opts[:printable])
    |> maybe_filter(:visibility, opts[:visibility])
    |> maybe_array_filter(:flags, opts[:flag])
    |> maybe_array_filter(:topics, opts[:topic])
    |> maybe_array_filter(:sentiments, opts[:sentiment])
    |> maybe_usage_filter(opts[:usage])
    |> maybe_search(opts[:q] || opts[:query])
    |> order_by([e], asc: e.slug, desc: e.scope)
  end

  defp maybe_apply_element_db_filters(query, _opts, _include_shadowed),
    do: order_by(query, [e], asc: e.slug, desc: e.scope)

  defp maybe_apply_usage_db_filters(query, opts, true) do
    query
    |> maybe_array_filter(:flags, opts[:flag])
    |> maybe_array_filter(:topics, opts[:topic])
    |> maybe_search_usage(opts[:q] || opts[:query])
    |> order_by([u], asc: u.slug, desc: u.scope)
  end

  defp maybe_apply_usage_db_filters(query, _opts, _include_shadowed),
    do: order_by(query, [u], asc: u.slug, desc: u.scope)

  defp maybe_filter(query, _field, nil), do: query
  defp maybe_filter(query, _field, ""), do: query

  defp maybe_filter(query, :printable, value) do
    printable = truthy?(value)
    where(query, [e], e.printable == ^printable)
  end

  defp maybe_filter(query, field, value), do: where(query, [e], field(e, ^field) == ^value)

  defp maybe_array_filter(query, _field, nil), do: query
  defp maybe_array_filter(query, _field, ""), do: query

  defp maybe_array_filter(query, field, value),
    do: where(query, [e], fragment("? = ANY(?)", ^value, field(e, ^field)))

  defp maybe_usage_filter(query, nil), do: query
  defp maybe_usage_filter(query, ""), do: query

  defp maybe_usage_filter(query, usage_slug) do
    slug = normalize_slug(usage_slug)

    query
    |> join(:inner, [e], eu in ElementUsage, on: eu.element_id == e.id)
    |> join(:inner, [e, eu], u in SpecialUsage, on: u.id == eu.special_usage_id)
    |> where([e, eu, u], u.slug == ^slug)
    |> distinct(true)
  end

  defp maybe_search(query, nil), do: query
  defp maybe_search(query, ""), do: query

  defp maybe_search(query, raw) do
    pattern = "%#{raw}%"

    where(
      query,
      [e],
      ilike(e.slug, ^pattern) or ilike(e.codepoint, ^pattern) or
        ilike(e.name, ^pattern) or ilike(e.title, ^pattern) or
        ilike(e.description, ^pattern) or ilike(e.meaning, ^pattern) or
        fragment("coalesce(array_to_string(?, ' '), '') ILIKE ?", e.aliases, ^pattern) or
        fragment("coalesce(array_to_string(?, ' '), '') ILIKE ?", e.search_terms, ^pattern)
    )
  end

  defp maybe_search_usage(query, nil), do: query
  defp maybe_search_usage(query, ""), do: query

  defp maybe_search_usage(query, raw) do
    pattern = "%#{raw}%"

    where(
      query,
      [u],
      ilike(u.slug, ^pattern) or ilike(u.name, ^pattern) or
        ilike(u.title, ^pattern) or ilike(u.description, ^pattern)
    )
  end

  defp element_matches?(element, opts) do
    printable_matches?(element.printable, opts[:printable]) and
      blank_or_equal?(element.visibility, opts[:visibility]) and
      blank_or_contains?(element.flags, opts[:flag]) and
      blank_or_contains?(element.topics, opts[:topic]) and
      blank_or_contains?(element.sentiments, opts[:sentiment]) and
      usage_matches_element?(element, opts[:usage]) and
      text_matches?(
        [
          element.slug,
          element.codepoint,
          element.name,
          element.title,
          element.description,
          element.meaning
        ] ++ List.wrap(element.aliases) ++ List.wrap(element.search_terms),
        opts[:q] || opts[:query]
      )
  end

  defp usage_matches?(usage, opts) do
    blank_or_contains?(usage.flags, opts[:flag]) and
      blank_or_contains?(usage.topics, opts[:topic]) and
      text_matches?(
        [usage.slug, usage.name, usage.title, usage.description],
        opts[:q] || opts[:query]
      )
  end

  defp printable_matches?(_printable, value) when value in [nil, ""], do: true
  defp printable_matches?(printable, value), do: printable == truthy?(value)

  defp blank_or_equal?(_field, value) when value in [nil, ""], do: true
  defp blank_or_equal?(field, value), do: field == value

  defp blank_or_contains?(_field, value) when value in [nil, ""], do: true
  defp blank_or_contains?(field, value), do: value in List.wrap(field)

  defp usage_matches_element?(_element, value) when value in [nil, ""], do: true

  defp usage_matches_element?(element, value) do
    slug = normalize_slug(value)
    Enum.any?(loaded_usages(element), &(normalize_slug(&1.slug) == slug))
  end

  defp text_matches?(_fields, value) when value in [nil, ""], do: true

  defp text_matches?(fields, value) do
    needle = value |> to_string() |> String.downcase()

    Enum.any?(fields, fn
      nil -> false
      field -> field |> to_string() |> String.downcase() |> String.contains?(needle)
    end)
  end

  defp apply_effective(rows, true) do
    groups = Enum.group_by(rows, & &1.slug)
    Enum.map(rows, fn row -> {row, Map.get(groups, row.slug, [row])} end)
  end

  defp apply_effective(rows, _include_shadowed) do
    rows
    |> Enum.group_by(& &1.slug)
    |> Enum.map(fn {_slug, layers} -> {effective_row(layers), layers} end)
    |> Enum.reject(fn {row, _layers} -> is_nil(row) end)
  end

  defp effective_row([]), do: nil
  defp effective_row(rows), do: Enum.max_by(rows, &scope_rank/1)

  defp get_by_scope(schema, attrs) do
    # Upsert identity = (scope, slug, organization_id, project_id) with NULL meaning
    # "IS NULL" — Repo.get_by cannot express nil (Ecto 3.14 raises) and silently
    # dropping nils would conflate the org and project layers, so build the query
    # explicitly. Mirrors the partial unique indexes (idx_unicode_elements_org_slug etc.).
    scope = attrs[:scope] || "global"

    from(r in schema, where: r.scope == ^scope and r.slug == ^attrs[:slug])
    |> scope_filter(:organization_id, attrs[:organization_id])
    |> scope_filter(:project_id, attrs[:project_id])
    |> Repo.one()
  end

  defp scope_filter(query, field, nil), do: where(query, [r], is_nil(field(r, ^field)))
  defp scope_filter(query, field, value), do: where(query, [r], field(r, ^field) == ^value)

  defp insert_or_update(changeset, nil), do: Repo.insert(changeset)
  defp insert_or_update(changeset, _existing), do: Repo.update(changeset)

  defp normalize_scope_attrs(attrs) do
    attrs
    |> atomize_keys()
    |> Map.update(:slug, nil, &normalize_slug/1)
    |> Map.update(:scope, "global", &to_string/1)
  end

  defp atomize_keys(attrs) do
    Enum.reduce(attrs, %{}, fn
      {key, value}, acc when is_binary(key) -> Map.put(acc, String.to_atom(key), value)
      {key, value}, acc -> Map.put(acc, key, value)
    end)
  end

  defp normalize_slug(nil), do: nil
  defp normalize_slug(slug), do: slug |> to_string() |> String.trim() |> String.downcase()
  defp blank_to_nil(""), do: nil
  defp blank_to_nil(nil), do: nil
  defp blank_to_nil(value), do: value

  defp truthy?(value) when value in [true, "true", "1", 1, true], do: true
  defp truthy?(_), do: false

  defp parse_int(nil, default), do: default
  defp parse_int("", default), do: default
  defp parse_int(value, _default) when is_integer(value), do: value

  defp parse_int(value, default) when is_binary(value) do
    case Integer.parse(value) do
      {int, _} -> int
      :error -> default
    end
  end

  defp clamp_limit(value) do
    value
    |> parse_int(@default_limit)
    |> max(1)
    |> min(@max_limit)
  end

  defp loaded_usages(%{special_usages: %Ecto.Association.NotLoaded{}}), do: []
  defp loaded_usages(%{special_usages: usages}) when is_list(usages), do: usages
  defp loaded_usages(_), do: []

  defp loaded_relations(%{outgoing_relations: %Ecto.Association.NotLoaded{}}), do: []
  defp loaded_relations(%{outgoing_relations: relations}) when is_list(relations), do: relations
  defp loaded_relations(_), do: []

  defp special_usage_ref(usage), do: %{slug: usage.slug, title: usage.title, scope: usage.scope}

  defp relation_json(relation) do
    %{
      relation_type: relation.relation_type,
      description: relation.description,
      metadata: relation.metadata || %{},
      target:
        relation.target_element &&
          element_json(relation.target_element, [relation.target_element])
    }
  end

  defp layer_ref(%{
         scope: scope,
         slug: slug,
         id: id,
         organization_id: org_id,
         project_id: project_id
       }) do
    %{id: id, slug: slug, scope: scope, organization_id: org_id, project_id: project_id}
  end

  defp layer_ref_or_nil(nil), do: nil
  defp layer_ref_or_nil(row), do: layer_ref(row)

  defp display_value(%{visibility: visibility, title: title})
       when visibility in @unsafe_visibilities do
    "<#{title}>"
  end

  defp display_value(%{char: char}) when is_binary(char) and char != "", do: char
  defp display_value(%{title: title}), do: "<#{title}>"

  defp copy_value(%{printable: true, visibility: visibility, char: char})
       when visibility not in @unsafe_visibilities and is_binary(char) and char != "" do
    char
  end

  defp copy_value(_), do: nil

  defp warnings(element) do
    []
    |> maybe_warn(element.printable == false, "non_printable")
    |> maybe_warn(element.visibility in @unsafe_visibilities, "#{element.visibility}_sensitive")
    |> maybe_warn("terminal-sensitive" in (element.flags || []), "terminal_sensitive")
    |> Enum.reverse()
  end

  defp maybe_warn(warnings, true, warning), do: [warning | warnings]
  defp maybe_warn(warnings, _condition, _warning), do: warnings

  defp escape_forms(%{codepoint: nil}), do: %{}

  defp escape_forms(%{codepoint: codepoint}) do
    points =
      codepoint
      |> String.split(~r/\s+/, trim: true)
      |> Enum.map(&Element.parse_codepoint_int/1)
      |> Enum.reject(&is_nil/1)

    %{
      codepoint: codepoint,
      unicode: Enum.map(points, &("\\u" <> pad_hex(&1, 4))),
      hex: Enum.map(points, &("\\x" <> pad_hex(&1, 2))) |> Enum.filter(&(String.length(&1) <= 4)),
      html:
        Enum.map(points, fn point -> "&#x#{Integer.to_string(point, 16) |> String.upcase()};" end)
    }
  end

  defp pad_hex(value, min) do
    value
    |> Integer.to_string(16)
    |> String.upcase()
    |> String.pad_leading(min, "0")
  end
end
