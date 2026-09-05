defmodule NoizuPromptLingua.MCP.VFS.NPL do
  @moduledoc """
  VFS backend for the `_npl` root plane (MCP-VFS-GROUP-MOUNTS.md §2.23): NPL
  syntax as files — the most literal mapping in the catalog.

      /tobor/_npl                           → the plane root
      /tobor/_npl/conventions/              → the conventions/*.yaml source of truth
      /tobor/_npl/conventions/{section}.yaml → raw YAML, read-only
      /tobor/_npl/spec.md                   → the rendered full spec (NPLSpec path)

  ## Decisions & conventions

    * **No gating**: `_npl` sits at `/tobor/_npl` (outside every org) and
      carries public framework reference material — it serves to any
      authenticated connection, including principals with no resolvable
      client/scope (everything else fails closed; this is docs).
    * **Read-only** (§3.1): only `stat/list/read` implemented; mutating
      callbacks keep the behaviour's `:enosys` defaults.
    * **`conventions/` lists what exists**: `File.ls` over
      `NoizuPromptLingua.NPL.conventions_dir()` filtered to `*.yaml` (the
      directory is the source of truth, including `npl.yaml` itself — not the
      `valid_sections/0` list, which can drift from files on disk). Reads are
      validated against that listing, so no path escapes the directory.
    * **`spec.md`** renders through the same `NPL.Definition` path the NPLSpec
      tool drives (`new/0` + `format/2`, concise, non-XML) — the full default
      spec, identical to `NPLSpec(components: [], concise: true)`.
    * **Listings are bounded** (≤ 10 files): cursors follow the Wave 0 meta
      plane convention — nil/"" accepted, anything else is `invalid_params`.
  """

  use Noizu.MCP.VFS

  alias Noizu.MCP.Error
  alias NoizuPromptLingua.MCP.VFS.Scope
  alias NoizuPromptLingua.NPL

  @plane "_npl"
  @tobor "tobor"
  @sections_dir "conventions"
  @spec_file "spec.md"

  # ── stat/2 ────────────────────────────────────────────────────────────────

  @impl true
  def stat(path, _ctx) do
    with {:ok, [@tobor, @plane | rest]} <- split(path) do
      stat_rest(rest)
    end
  end

  defp stat_rest([]), do: {:ok, Scope.dir_node()}
  defp stat_rest([@sections_dir]), do: {:ok, Scope.dir_node()}

  defp stat_rest([@sections_dir, filename]) do
    with {:ok, yaml_files} <- yaml_files(),
         true <- filename in yaml_files do
      {:ok, Scope.file_node(size_of(Path.join(NPL.conventions_dir(), filename)))}
    else
      _fallback -> {:error, :enoent}
    end
  end

  defp stat_rest([@spec_file]) do
    with {:ok, spec} <- spec_md() do
      {:ok, Scope.file_node(byte_size(spec))}
    end
  end

  defp stat_rest(_rest), do: {:error, :enoent}

  # ── list/3 ────────────────────────────────────────────────────────────────

  @impl true
  def list(path, cursor, _ctx) do
    with {:ok, [@tobor, @plane | rest]} <- split(path),
         :ok <- reject_cursor(cursor) do
      list_rest(rest)
    end
  end

  defp list_rest([]) do
    {:ok, [Scope.dir_entry(@sections_dir), Scope.file_entry(@spec_file)], nil}
  end

  defp list_rest([@sections_dir]) do
    with {:ok, yaml_files} <- yaml_files() do
      {:ok, Scope.file_entries(Enum.sort(yaml_files)), nil}
    end
  end

  defp list_rest([@sections_dir, _filename]), do: {:error, :enotdir}
  defp list_rest([@spec_file]), do: {:error, :enotdir}
  defp list_rest(_rest), do: {:error, :enoent}

  # ── read/2 ────────────────────────────────────────────────────────────────

  @impl true
  def read(path, _ctx) do
    with {:ok, [@tobor, @plane | rest]} <- split(path) do
      read_rest(rest)
    end
  end

  defp read_rest([]), do: {:error, :eisdir}
  defp read_rest([@sections_dir]), do: {:error, :eisdir}

  defp read_rest([@sections_dir, filename]) do
    with {:ok, yaml_files} <- yaml_files(),
         true <- filename in yaml_files,
         {:ok, content} <- File.read(Path.join(NPL.conventions_dir(), filename)) do
      {:ok, content, Scope.version()}
    else
      _fallback -> {:error, :enoent}
    end
  end

  defp read_rest([@spec_file]) do
    with {:ok, spec} <- spec_md() do
      {:ok, spec, Scope.version()}
    end
  end

  defp read_rest(_rest), do: {:error, :enoent}

  # ── helpers ───────────────────────────────────────────────────────────────

  defp split(path) do
    case Scope.split_segments(path) do
      {:ok, [@tobor, @plane | _] = segments} -> {:ok, segments}
      {:ok, _other} -> {:error, :enoent}
      error -> error
    end
  end

  # Bounded listings: same cursor policy as the Wave 0 meta plane.
  defp reject_cursor(cursor) when cursor in [nil, ""], do: :ok
  defp reject_cursor(_cursor), do: {:error, Error.invalid_params("invalid cursor")}

  defp yaml_files do
    dir = NPL.conventions_dir()

    if File.dir?(dir) do
      files =
        dir
        |> File.ls!()
        |> Enum.filter(&String.ends_with?(&1, ".yaml"))

      {:ok, files}
    else
      {:error, :enoent}
    end
  end

  defp size_of(path) do
    case File.stat(path) do
      {:ok, %{size: size}} -> size
      _ -> 0
    end
  end

  # The NPLSpec tool's default render path: full spec, concise, non-XML.
  defp spec_md do
    with {:ok, defn} <- NoizuPromptLingua.NPL.Definition.new(),
         spec when is_binary(spec) <-
           NoizuPromptLingua.NPL.Definition.format(defn, flags: %{concise: true, xml: false}) do
      {:ok, spec}
    else
      _ -> {:error, :eio}
    end
  end
end
