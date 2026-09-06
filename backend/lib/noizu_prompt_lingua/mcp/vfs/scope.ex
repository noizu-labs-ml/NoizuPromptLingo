defmodule NoizuPromptLingua.MCP.VFS.Scope do
  @moduledoc """
  Shared path-parsing, gating, and node-builder helpers for the Wave 1
  per-group VFS backends (`MCP-VFS-GROUP-MOUNTS.md` §1.2/§1.3).

  Group backends own the FULL absolute path (`/tobor/{org}/{group}/…`) and
  enforce their own gates, exactly as `Root` does for the meta plane — that is
  what keeps each backend independently conformance-testable while the Router
  dispatches by prefix. The helpers here are the extracted common core; `Root`
  keeps its private Wave 0 copies.
  """

  alias Noizu.MCP.VFS
  alias NoizuPromptLingua.MCP.VFS.Principal

  @type gate :: Principal.group_gate()

  # ── path model ────────────────────────────────────────────────────────────

  def normalize("/" <> rest), do: String.trim_trailing(rest, "/")
  def normalize(path) when is_binary(path), do: String.trim_trailing(path, "/")

  # Stable-key segments only: reject traversal and dot segments outright.
  @spec split_segments(String.t()) :: {:ok, [String.t()]} | {:error, :enoent}
  def split_segments(path) do
    segments = String.split(normalize(path), "/", trim: true)

    if Enum.any?(segments, &(&1 in [".", ".."])),
      do: {:error, :enoent},
      else: {:ok, segments}
  end

  @doc "Reassemble absolute path from already-split segments."
  @spec vpath([String.t()]) :: String.t()
  def vpath(segments), do: "/" <> Enum.join(segments, "/")

  # ── gates (§1.3) ──────────────────────────────────────────────────────────

  @doc """
  Org + group gate for a backend subtree. `{:ok, gate}` when the org is
  visible to the principal AND the group is included and visible; `:enoent`
  otherwise (excluded/hidden groups are indistinguishable from absent).
  """
  @spec gate(Noizu.MCP.Ctx.t(), String.t(), String.t()) :: {:ok, gate()} | {:error, :enoent}
  def gate(ctx, org, group_id) do
    if Principal.org_visible?(ctx, org) do
      case Principal.group_gate(ctx, group_id) do
        :ok -> {:ok, Principal.groups(ctx)[group_id]}
        error -> error
      end
    else
      {:error, :enoent}
    end
  end

  @doc "Mutating-op gate (§1.3): included-but-disabled groups refuse with `:eacces`."
  @spec require_writable(gate()) :: :ok | {:error, :eacces}
  def require_writable(%{writable: true}), do: :ok
  def require_writable(_), do: {:error, :eacces}

  # ── node builders (Root's Wave 0 conventions) ─────────────────────────────

  def dir_node, do: %VFS{type: :dir, mtime: now_ms(), version: version()}

  def file_node(size), do: %VFS{type: :file, size: size, mtime: now_ms(), version: version()}

  def dir_entry(name),
    do: %{name: name, type: :dir, size: 0, mtime: now_ms(), version: version()}

  def file_entry(name),
    do: %{name: name, type: :file, size: 0, mtime: now_ms(), version: version()}

  def file_entries(names), do: Enum.map(names, &file_entry/1)

  # Flat backend version — the dispatcher stamps its cache generation on top.
  def version, do: 1
  def now_ms, do: System.os_time(:millisecond)
end
