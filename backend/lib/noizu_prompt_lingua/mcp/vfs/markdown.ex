defmodule NoizuPromptLingua.MCP.VFS.Markdown do
  @moduledoc """
  VFS backend for the `markdown` group (MCP-VFS-GROUP-MOUNTS.md §2.20) — a
  control/query subtree over the stateless `NoizuPromptLingua.Domains.Markdown`
  transforms. Full absolute paths, self-enforced §1.3 gates (via
  `NoizuPromptLingua.MCP.VFS.Scope`).

      /tobor/{org}/markdown                      → the query tree root (ro)
      /tobor/{org}/markdown/overview.md          → Overview tool render
      /tobor/{org}/markdown/convert/             → the query dir
      /tobor/{org}/markdown/convert/request.json → write = Convert/View op
      /tobor/{org}/markdown/convert/result.md    → read = buffered result

  ## Decisions & conventions

    * **Query-dir semantics** (§2.20): a write to `request.json` runs the
      conversion SYNCHRONOUSLY (the transforms are fast and stateless — no
      job-dir needed) and buffers the rendered markdown for THIS connection;
      the next read of `result.md` consumes the buffer. Reading `request.json`
      returns a self-describing request-schema document (a mounter snapshot
      can read every node it can stat).
    * **Per-connection buffering** — the `Control.take_buffer` pattern: the
      result slot is a `:persistent_term` keyed by connection (session id,
      else pid), and a read ERASES it, so each mount connection sees only its
      own results. `result.md` only stats when this connection holds a
      buffer, and re-reads after consumption are `:enoent`.
    * **Known wrapper caveat (design §0.2/P1, flagged upstream)**: the lib's
      `Features.VFS` read cache is identity-blind (`{backend, kind, path}`
      keys, no `__mcp_vfs__(:cacheable)` opt-out in the pinned dep), so a
      cached `result.md` replay can cross connections within the 60 s TTL.
      Isolation is guaranteed at THIS backend's layer (and direct backend
      calls bypass the cache); the clean fix is the upstream cache opt-out.
    * **Request document**: one JSON object — `{"url"|"html"|"markdown"|"source":
      <string>, ...}` plus optional `type` (`auto|url|html|markdown`) and the
      `Markdown.View` params (`filter`, `bare`, `depth`, `filter_inner_depth`).
      A view op is selected by `"op": "view"` or the presence of any view
      param; otherwise the source runs through `Markdown.Convert`. Malformed
      requests (bad JSON, non-object, no source field, failed conversion) are
      `:eio` and buffer nothing.
    * **Read-only otherwise** (§3.1/§2.20): `overview.md` and the tree itself
      never mutate; `create/3` on `request.json` mirrors `write/3` (a mounter
      pushes locally-new files via create), every other create and all
      remove/search fall through to `:enosys`.
  """

  use Noizu.MCP.VFS

  alias Noizu.MCP.Ctx
  alias Noizu.MCP.Server.Features.Pagination
  alias Noizu.MCP.VFS
  alias NoizuPromptLingua.Domains.Markdown
  alias NoizuPromptLingua.MCP.VFS.{Overview, Scope}

  @group "markdown"

  @request "request.json"
  @result "result.md"

  @buffer_key {__MODULE__, :result}
  @source_fields ["url", "html", "markdown", "source"]
  @view_params ["filter", "bare", "depth", "filter_inner_depth"]
  @types ~w(auto url html markdown)

  # ── stat/2 ────────────────────────────────────────────────────────────────

  @impl true
  def stat(path, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, gate} <- Scope.gate(ctx, org, @group) do
      stat_rest(org, rest, gate, ctx)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  defp stat_rest(_org, [], _gate, _ctx), do: {:ok, Scope.dir_node()}
  defp stat_rest(_org, ["overview.md"], _gate, _ctx), do: {:ok, Scope.file_node(overview_size())}
  defp stat_rest(_org, ["convert"], _gate, _ctx), do: {:ok, Scope.dir_node()}

  defp stat_rest(_org, ["convert", @request], gate, _ctx) do
    {:ok, %{control_node() | writable: gate.writable}}
  end

  defp stat_rest(_org, ["convert", @result], _gate, ctx) do
    if buffered?(ctx), do: {:ok, Scope.file_node(buffered_size(ctx))}, else: {:error, :enoent}
  end

  defp stat_rest(_org, _rest, _gate, _ctx), do: {:error, :enoent}

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

  defp list_rest(_org, [], cursor, _ctx) do
    paginate([Scope.file_entry("overview.md"), Scope.dir_entry("convert")], cursor)
  end

  defp list_rest(_org, ["convert"], cursor, ctx) do
    entries =
      [Scope.file_entry(@request)] ++
        if buffered?(ctx), do: [Scope.file_entry(@result)], else: []

    paginate(entries, cursor)
  end

  defp list_rest(_org, ["overview.md"], _cursor, _ctx), do: {:error, :enotdir}
  defp list_rest(_org, ["convert", _file], _cursor, _ctx), do: {:error, :enotdir}
  defp list_rest(_org, _rest, _cursor, _ctx), do: {:error, :enoent}

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

  defp read_rest(_org, ["convert"], _ctx), do: {:error, :eisdir}

  # Self-describing node: a snapshot can read anything it can stat. The
  # request itself is write-only — its schema document is what a read returns.
  defp read_rest(_org, ["convert", @request], _ctx) do
    {:ok, request_schema_doc(), Scope.version()}
  end

  # Consume-once per connection: the read takes (and erases) this
  # connection's buffered result. No buffer → the node does not exist.
  defp read_rest(_org, ["convert", @result], ctx) do
    case take_buffer(ctx) do
      {:ok, md} -> {:ok, md, Scope.version()}
      :none -> {:error, :enoent}
    end
  end

  defp read_rest(_org, _rest, _ctx), do: {:error, :enoent}

  # ── write/3 — the Convert/View op (§2.20) ─────────────────────────────────

  @impl true
  def write(path, data, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, gate} <- Scope.gate(ctx, org, @group),
         :ok <- Scope.require_writable(gate) do
      write_rest(org, rest, data, ctx)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  defp write_rest(_org, ["convert", @request], data, ctx) when is_binary(data) do
    with {:ok, request} <- decode_request(data),
         {:ok, md} <- run(request) do
      buffer_result(ctx, md)
      {:ok, %{Scope.file_node(byte_size(md)) | writable: true}}
    end
  end

  defp write_rest(_org, ["convert", @result], _data, _ctx), do: {:error, :enosys}
  defp write_rest(_org, ["overview.md"], _data, _ctx), do: {:error, :enosys}
  defp write_rest(_org, _rest, _data, _ctx), do: {:error, :enoent}

  # ── create/3 ──────────────────────────────────────────────────────────────

  # A mounter pushes locally-new files as create — creating `request.json`
  # is the same op as writing it. Every other node is not creatable.
  @impl true
  def create(path, data, ctx) when is_binary(data), do: write(path, data, ctx)

  def create(_path, _data, _ctx), do: {:error, :enosys}

  # ── request decoding + execution ──────────────────────────────────────────

  defp decode_request(data) do
    case Jason.decode(data) do
      {:ok, %{} = request} -> validate_request(request)
      _ -> {:error, :eio}
    end
  end

  defp validate_request(%{"op" => op}) when op not in ["convert", "view"], do: {:error, :eio}

  defp validate_request(request) do
    with {:ok, source} <- source_of(request),
         {:ok, type} <- type_of(request),
         :ok <- view_params_ok(request) do
      {:ok, %{source: source, type: type, view?: view?(request), request: request}}
    end
  end

  defp source_of(request) do
    field = Enum.find(@source_fields, &is_binary(request[&1]))

    if field,
      do: {:ok, %{field: field, value: request[field]}},
      else: {:error, :eio}
  end

  defp type_of(request) do
    case request["type"] do
      nil -> {:ok, :auto}
      type when type in @types -> {:ok, String.to_atom(type)}
      _ -> {:error, :eio}
    end
  end

  defp view_params_ok(request) do
    if Enum.any?(@view_params, &Map.has_key?(request, &1)) or Map.has_key?(request, "op") do
      valid_view_params?(request)
    else
      :ok
    end
  end

  defp valid_view_params?(request) do
    bare_ok? = request["bare"] in [nil, true, false, "true", "false"]
    depths_ok? = Enum.all?(["depth", "filter_inner_depth"], &depth_ok?(request[&1]))
    filter_ok? = request["filter"] in [nil] or is_binary(request["filter"])

    if bare_ok? and depths_ok? and filter_ok?, do: :ok, else: {:error, :eio}
  end

  defp depth_ok?(nil), do: true

  defp depth_ok?(depth) do
    case Integer.parse(to_string(depth)) do
      {n, ""} -> n in 1..6
      _ -> false
    end
  end

  # `op` wins; otherwise any view param selects the view transform.
  defp view?(%{"op" => "view"}), do: true
  defp view?(%{"op" => "convert"}), do: false

  defp view?(request), do: Enum.any?(@view_params, &Map.has_key?(request, &1))

  defp run(%{source: source, request: request, type: type, view?: view?}) do
    if view? do
      run_view(source, request)
    else
      run_convert(source, type)
    end
  end

  defp run_view(source, request) do
    # Markdown.view/2 is a pure transform — it always succeeds.
    {:ok, %{markdown: md}} = Markdown.view(source.value, view_opts(request))
    {:ok, md}
  end

  defp run_convert(source, type) do
    # A "url"/"html"/"markdown" request key doubles as an explicit type hint;
    # a generic "source" (or explicit "type") resolves through the domain's
    # own inference.
    type = if source.field in @types, do: String.to_atom(source.field), else: type

    case Markdown.convert(source.value, type: type) do
      {:ok, %{markdown: md}} -> {:ok, md}
      {:error, _} -> {:error, :eio}
    end
  end

  defp view_opts(request) do
    [
      filter: request["filter"],
      bare: request["bare"],
      depth: parse_int(request["depth"]),
      filter_inner_depth: parse_int(request["filter_inner_depth"])
    ]
  end

  defp parse_int(nil), do: nil
  defp parse_int(n) when is_integer(n), do: n
  defp parse_int(s) when is_binary(s), do: Integer.parse(s) |> elem(0)

  # ── the per-connection result buffer (Control.take_buffer pattern) ────────

  defp buffer_key(ctx), do: {@buffer_key, session_key(ctx)}

  defp buffered?(ctx), do: :persistent_term.get(buffer_key(ctx), :none) != :none

  defp buffered_size(ctx) do
    case :persistent_term.get(buffer_key(ctx), :none) do
      {_at, md} -> byte_size(md)
      :none -> 0
    end
  end

  defp buffer_result(ctx, md),
    do: :persistent_term.put(buffer_key(ctx), {System.os_time(:millisecond), md})

  defp take_buffer(ctx) do
    key = buffer_key(ctx)

    case :persistent_term.get(key, :none) do
      :none ->
        :none

      {_at, md} ->
        :persistent_term.erase(key)
        {:ok, md}
    end
  end

  # Same resolution order as `Noizu.MCP.VFS.Control`: stable session id, else
  # the connection pid, else a shared default.
  defp session_key(%Ctx{session_id: id}) when is_binary(id), do: {:sid, id}
  defp session_key(%Ctx{session: pid}) when is_pid(pid), do: {:pid, pid}
  defp session_key(_), do: :default

  defp control_node, do: %VFS{type: :control, mtime: Scope.now_ms(), version: Scope.version()}

  # ── overview + schema docs ────────────────────────────────────────────────

  defp overview_tool, do: NoizuPromptLingua.Domains.Markdown.Tools.Overview

  defp overview_size, do: byte_size(Overview.md(overview_tool(), @group))

  # Lib `Features.Pagination` opaque offset cursors (the Wave 1 convention).
  defp paginate(items, cursor) do
    cursor = if cursor == "", do: nil, else: cursor

    case Pagination.paginate(items, cursor) do
      {:ok, page, next} -> {:ok, page, next}
      {:error, _} -> {:error, Noizu.MCP.Error.invalid_params("invalid cursor")}
    end
  end

  defp request_schema_doc do
    Jason.encode!(%{
      "node" => "convert/request.json",
      "write" => "one JSON object; the rendered result buffers on result.md for this connection",
      "fields" => %{
        "url" => "fetch a URL server-side and convert it to Markdown",
        "html" => "convert an HTML string",
        "markdown" => "passthrough/view source",
        "source" => "generic source; the type is inferred when omitted",
        "type" => "auto | url | html | markdown",
        "op" => "convert | view (view is inferred when any view param is set)",
        "filter" =>
          "view: heading selector (\"Parent > Child\", \"Heading\", \"Parent > *\", \"h2\")",
        "bare" => "view: return only the matched sections",
        "depth" => "view: collapse headings deeper than this level (1-6)",
        "filter_inner_depth" => "view: collapse within matched sections"
      },
      "read" => "convert/result.md — per-connection, consume-once"
    })
  end
end
