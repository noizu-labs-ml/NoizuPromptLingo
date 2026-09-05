defmodule NoizuPromptLingua.MCP.VFS.Unicode do
  @moduledoc """
  VFS backend for the `unicode` group (MCP-VFS-GROUP-MOUNTS.md §2.4) — a
  READ-ONLY natural reference tree over the `NoizuPromptLingua.Domains.UnicodeCodex`
  context, generated on demand (no static export step). Full absolute paths,
  self-enforced §1.3 gates (via `NoizuPromptLingua.MCP.VFS.Scope`).

      /tobor/{org}/unicode                             → the reference tree root
      /tobor/{org}/unicode/overview.md                 → Overview tool render
      /tobor/{org}/unicode/special-usages/             → SpecialUsageList (readdir)
      /tobor/{org}/unicode/special-usages/{slug}.md    → SpecialUsageGet (rendered doc)
      /tobor/{org}/unicode/plane-{n}/                  → elements grouped by Unicode plane
      /tobor/{org}/unicode/plane-{n}/{U+XXXX}.json     → UnicodeCodex.Get (effective element)

  ## Decisions & conventions

    * **Read-only by design** (§3.1): only `stat/list/read/search` are
      implemented; every mutating callback falls through to the behaviour's
      `:enosys` default, which the wire surfaces as EROFS-class behavior.
    * **Generated, lazily, honestly**: the tree is derived from the codex's OWN
      effective rows (global + this org's layers; project layers are not
      reachable from the mount — no project is addressed by the path). Each
      read re-derives from the DB (the codex is a bounded, seeded set), so the
      tree is never stale and never needs a generator step. Elements whose
      `codepoint` is nil/unparseable appear in search but get no `{U+XXXX}.json`
      node; multi-codepoint elements file under their FIRST codepoint (the body
      carries the full codepoint string).
    * **`{U+XXXX}.json` holds one element**: the effective row for that
      codepoint (slug-sorted first on the practically impossible shared-codepoint
      collision). The shape is the `UnicodeCodex.element_json/2` document —
      the same one `Unicode.Get` returns.
    * **`special-usages/{slug}.md`** renders the effective usage doc as
      markdown (title, scope, description, topics/flags, references, element
      back-links come through search).
    * **Search → `search/3`**: text query over the effective tree (elements by
      default; usages when the root is under `special-usages/`). Matches
      synthesize line 1 — the codex is a reference, not line-oriented text;
      the match text is `title — description`.
    * **Related stays a query tool**: `Unicode.Related` maps to an `/etc/dev`
      control write per §2.4, which arrives with the control-tree tool
      inventory (design §3.6 [C1]); the file plane has no Related node.
    * **Pagination** — lib `Features.Pagination` opaque offset cursors.
  """

  use Noizu.MCP.VFS

  alias Noizu.MCP.Server.Features.Pagination
  alias NoizuPromptLingua.Domains.UnicodeCodex
  alias NoizuPromptLingua.MCP.Resolve
  alias NoizuPromptLingua.MCP.VFS.{Overview, Scope}

  @group "unicode"
  @page_size 100

  # ── stat/2 ────────────────────────────────────────────────────────────────

  @impl true
  def stat(path, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, _gate} <- Scope.gate(ctx, org, @group) do
      stat_rest(org, rest, ctx)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  defp stat_rest(_org, [], _ctx), do: {:ok, Scope.dir_node()}

  defp stat_rest(_org, ["overview.md"], _ctx) do
    {:ok, Scope.file_node(byte_size(Overview.md(overview_tool(), @group)))}
  end

  defp stat_rest(_org, ["special-usages"], _ctx), do: {:ok, Scope.dir_node()}

  defp stat_rest(org, ["special-usages", filename], ctx) do
    with {:ok, _usage} <- resolve_usage(org, filename, ctx) do
      {:ok, Scope.file_node(usage_md_size(org, filename, ctx))}
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  defp stat_rest(org, ["plane-" <> n], ctx) do
    with {plane, ""} <- Integer.parse(n),
         {:ok, elements} <- elements(org, ctx),
         true <- plane_nonempty?(elements, plane) do
      {:ok, Scope.dir_node()}
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  defp stat_rest(org, ["plane-" <> n, filename], ctx) do
    with {plane, ""} <- Integer.parse(n),
         {:ok, codepoint} <- parse_codepoint_name(filename),
         {:ok, element} <- element_by_codepoint(org, codepoint, plane, ctx) do
      {:ok, Scope.file_node(byte_size(Jason.encode!(element)))}
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  defp stat_rest(_org, _rest, _ctx), do: {:error, :enoent}

  # ── list/3 ────────────────────────────────────────────────────────────────

  @impl true
  def list(path, cursor, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, _gate} <- Scope.gate(ctx, org, @group) do
      list_rest(org, rest, cursor, ctx)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  defp list_rest(org, [], cursor, ctx) do
    with {:ok, elements} <- elements(org, ctx) do
      planes = elements |> Enum.map(&plane_of/1) |> Enum.uniq() |> Enum.sort()

      entries =
        [Scope.file_entry("overview.md"), Scope.dir_entry("special-usages")] ++
          Enum.map(planes, &Scope.dir_entry("plane-#{&1}"))

      paginate(entries, cursor)
    end
  end

  defp list_rest(_org, ["overview.md"], _cursor, _ctx), do: {:error, :enotdir}

  defp list_rest(org, ["special-usages"], cursor, ctx) do
    with {:ok, %{special_usages: usages}} <- usages(org, ctx) do
      usages = Enum.sort_by(usages, & &1.slug)
      entries = Enum.map(usages, &Scope.file_entry("#{&1.slug}.md"))
      paginate(entries, cursor)
    end
  end

  defp list_rest(org, ["plane-" <> n], cursor, ctx) do
    with {plane, ""} <- Integer.parse(n),
         {:ok, elements} <- elements(org, ctx) do
      entries =
        elements
        |> Enum.filter(&(&1 |> plane_of() == plane && codepoint_of(&1) != nil))
        |> Enum.sort_by(&codepoint_of/1)
        |> Enum.map(&Scope.file_entry(codepoint_name(&1)))

      paginate(entries, cursor)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  defp list_rest(_org, _rest, _cursor, _ctx), do: {:error, :enotdir}

  # ── read/2 ────────────────────────────────────────────────────────────────

  @impl true
  def read(path, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, _gate} <- Scope.gate(ctx, org, @group) do
      read_rest(org, rest, ctx)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  defp read_rest(_org, [], _ctx), do: {:error, :eisdir}

  defp read_rest(_org, ["overview.md"], _ctx) do
    {:ok, Overview.md(overview_tool(), @group), Scope.version()}
  end

  defp read_rest(_org, ["special-usages"], _ctx), do: {:error, :eisdir}

  defp read_rest(org, ["special-usages", filename], ctx) do
    with {:ok, _usage} <- resolve_usage(org, filename, ctx) do
      {:ok, usage_md(org, filename, ctx), Scope.version()}
    end
  end

  defp read_rest(_org, ["plane-" <> _n], _ctx), do: {:error, :eisdir}

  defp read_rest(org, ["plane-" <> n, filename], ctx) do
    with {plane, ""} <- Integer.parse(n),
         {:ok, codepoint} <- parse_codepoint_name(filename),
         {:ok, element} <- element_by_codepoint(org, codepoint, plane, ctx) do
      {:ok, Jason.encode!(element), Scope.version()}
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  defp read_rest(_org, _rest, _ctx), do: {:error, :enoent}

  # ── search/3 ──────────────────────────────────────────────────────────────

  # Text query over the effective reference tree; matches are synthesized
  # records (line 1), rooted at the searched subtree.
  @impl true
  def search(root, query, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(root),
         {:ok, _gate} <- Scope.gate(ctx, org, @group) do
      search_rest(org, rest, query, ctx)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  defp search_rest(org, ["special-usages" | _], query, ctx) do
    with {:ok, %{special_usages: usages}} <- usages(org, ctx) do
      matches =
        usages
        |> Enum.filter(&usage_matches?(&1, query))
        |> Enum.sort_by(& &1.slug)
        |> Enum.map(fn usage ->
          %{
            path: Scope.vpath(["tobor", org, @group, "special-usages", "#{usage.slug}.md"]),
            line: 1,
            text: match_text(usage.title || usage.name, usage.description)
          }
        end)

      paginate(matches, nil)
    end
  end

  defp search_rest(org, rest, query, ctx) do
    plane = plane_filter(rest)

    with {:ok, elements} <- elements(org, ctx) do
      matches =
        elements
        |> Enum.filter(&(codepoint_of(&1) != nil))
        |> Enum.filter(&(plane == nil || plane_of(&1) == plane))
        |> Enum.filter(&element_matches?(&1, query))
        |> Enum.sort_by(&codepoint_of/1)
        |> Enum.map(fn element ->
          %{
            path:
              Scope.vpath([
                "tobor",
                org,
                @group,
                "plane-#{plane_of(element)}",
                codepoint_name(element)
              ]),
            line: 1,
            text: match_text(element.title || element.name, element.description)
          }
        end)

      paginate(matches, nil)
    end
  end

  # ── data access (effective, org-scoped) ───────────────────────────────────

  defp overview_tool, do: NoizuPromptLingua.Domains.UnicodeCodex.Tools.Overview

  defp org_id(org) do
    case Resolve.organization_id(org) do
      nil -> {:error, :enoent}
      id -> {:ok, id}
    end
  end

  # All effective elements for the org (global + org layers). The context
  # clamps its page at 250, so accumulate until `count` is satisfied.
  defp elements(org, _ctx) do
    with {:ok, org_id} <- org_id(org) do
      {:ok, all_elements(org_id, 0, [])}
    end
  end

  defp all_elements(org_id, offset, acc) do
    %{count: count, elements: page} =
      UnicodeCodex.list_elements(organization_id: org_id, limit: 250, offset: offset)

    acc = acc ++ page

    if length(acc) < count and page != [] do
      all_elements(org_id, offset + 250, acc)
    else
      acc
    end
  end

  defp usages(org, _ctx) do
    with {:ok, org_id} <- org_id(org) do
      {:ok, UnicodeCodex.list_special_usages(organization_id: org_id)}
    end
  end

  defp resolve_usage(org, filename, ctx) do
    with slug <- String.trim_trailing(filename, ".md"),
         true <- slug != "" and filename != slug,
         {:ok, %{special_usage: _}} <- fetch_usage(org, slug, ctx) do
      {:ok, slug}
    end
  end

  defp fetch_usage(org, slug, _ctx) do
    with {:ok, org_id} <- org_id(org),
         {:ok, _} = ok <- fetch_usage_by_slug(slug, org_id) do
      ok
    else
      _fallback -> {:error, :enoent}
    end
  end

  defp fetch_usage_by_slug(slug, org_id) do
    UnicodeCodex.get_special_usage(slug, organization_id: org_id)
  end

  defp usage_md_size(org, filename, ctx), do: byte_size(usage_md(org, filename, ctx))

  defp usage_md(org, filename, ctx) do
    slug = String.trim_trailing(filename, ".md")

    {:ok, %{special_usage: usage, layers: layers}} = fetch_usage(org, slug, ctx)

    overrides = Enum.map(layers, & &1.scope) -- [usage.scope]

    """
    # #{usage.title || usage.name}

    - **slug**: `#{usage.slug}`
    - **scope**: #{usage.scope}#{if overrides != [], do: "\n- **other layers**: #{Enum.join(overrides, ", ")}"}

    #{usage.description || ""}

    ## Topics

    #{Enum.map_join(usage.topics, ", ", &"`#{&1}`")}

    ## Flags

    #{Enum.map_join(usage.flags, ", ", &"`#{&1}`")}

    ## References

    #{Enum.map_join(usage.references, "\n", &reference_line/1)}
    """
  end

  defp reference_line(r) when is_map(r) do
    label = r["source"] || r["title"] || r["url"] || r["note"]
    if is_binary(label), do: "- #{label}", else: "- #{inspect(r)}"
  end

  defp reference_line(r) when is_binary(r), do: "- #{r}"
  defp reference_line(r), do: "- #{inspect(r)}"

  # ── codepoint / plane mapping ─────────────────────────────────────────────

  defp element_by_codepoint(org, codepoint, plane, ctx) do
    with {:ok, elements} <- elements(org, ctx) do
      elements
      |> Enum.filter(&(&1 |> plane_of() == plane && codepoint_of(&1) == codepoint))
      |> Enum.sort_by(& &1.slug)
      |> case do
        [element | _] -> {:ok, element}
        [] -> {:error, :enoent}
      end
    end
  end

  # plane number = codepoint ÷ 2^16; unparsable/absent → -1 (no plane match).
  defp plane_of(element), do: Integer.floor_div(raw_codepoint(element), 65_536)

  defp raw_codepoint(%{codepoint_int: int}) when is_integer(int) and int >= 0, do: int
  defp raw_codepoint(_), do: -1

  defp plane_nonempty?(elements, plane), do: Enum.any?(elements, &(plane_of(&1) == plane))

  # "U+231C" → 0x231C (nil when unparseable).
  defp codepoint_of(element) do
    case element.codepoint_int do
      int when is_integer(int) and int >= 0 -> int
      _ -> nil
    end
  end

  # "{U+XXXX}.json" → integer; strict on the U+ prefix, case-insensitive hex.
  defp parse_codepoint_name(filename) do
    with [hex] <- Regex.run(~r/^U\+([0-9a-fA-F]{1,6})\.json$/, filename, capture: :all_but_first),
         {int, ""} <- Integer.parse(hex, 16),
         true <- int >= 0 do
      {:ok, int}
    else
      _ -> {:error, :enoent}
    end
  end

  defp codepoint_name(element) do
    "U+" <>
      (element
       |> codepoint_of()
       |> Integer.to_string(16)
       |> String.upcase()
       |> String.pad_leading(4, "0")) <>
      ".json"
  end

  # ── search helpers ────────────────────────────────────────────────────────

  defp plane_filter(["plane-" <> n | _]) do
    case Integer.parse(n) do
      {plane, ""} -> plane
      _ -> nil
    end
  end

  defp plane_filter(_), do: nil

  defp element_matches?(element, query) do
    text_matches?(
      [
        element.slug,
        element.codepoint,
        element.name,
        element.title,
        element.description,
        element.meaning
      ] ++ List.wrap(element.aliases) ++ List.wrap(element.search_terms),
      query
    )
  end

  defp usage_matches?(usage, query) do
    text_matches?([usage.slug, usage.name, usage.title, usage.description], query)
  end

  defp text_matches?(fields, query) do
    needle = query |> to_string() |> String.downcase()
    needle != "" and Enum.any?(fields, &(&1 && to_string(&1) |> String.downcase() =~ needle))
  end

  defp match_text(title, description) do
    first_line = description && description |> String.split("\n") |> List.first()
    base = title || "unnamed"

    if first_line in [nil, ""],
      do: base,
      else: "#{base} — #{first_line}"
  end

  # ── pagination ────────────────────────────────────────────────────────────

  defp paginate(items, cursor) do
    cursor = if cursor == "", do: nil, else: cursor

    case Pagination.paginate(items, cursor, @page_size) do
      {:ok, page, next} -> {:ok, page, next}
      {:error, _} -> {:error, Noizu.MCP.Error.invalid_params("invalid cursor")}
    end
  end
end
