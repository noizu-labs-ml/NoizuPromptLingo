defmodule NoizuPromptLingua.MCP.ToolNames do
  @moduledoc """
  Server-wide MCP tool naming policy (F5): the canonical separator between the
  group segment and the action segment is the UNDERSCORE — `Session_Create`,
  `Organization_List`. Dotted forms (`Session.Create`) remain **aliases**:
  accepted everywhere at dispatch/list time, never emitted.

  Why: client agents sanitize `.` out of their own tool-name charsets, so two
  spellings for one tool were already in circulation (some clients call
  `Session_Create`, the wire name was `Session.Create`). One canonical form plus
  alias acceptance removes the fork. Emission points (`handle_list_tools`,
  `Catalog.build`, `Dispatch`) normalize through `canonical/1`; lookup points
  accept either form.

  Applies to ToolCall dispatch, list_tools, and (post-merge) Session.Manifest.
  """

  @doc """
  Canonical name for a tool identifier. `Session.Create` -> `Session_Create`;
  already-canonical and separator-free names pass through unchanged. Non-string
  input is returned as-is (tolerant of upstream map access).
  """
  @spec canonical(term) :: String.t() | term
  def canonical(name) when is_binary(name), do: String.replace(name, ".", "_")
  def canonical(name), do: name

  @doc """
  True when the name is a dotted alias form (`Session.Create`) rather than the
  canonical underscore form. Separator-free names are not aliases.
  """
  @spec alias?(term) :: boolean
  def alias?(name) when is_binary(name), do: String.contains?(name, ".")
  def alias?(_), do: false

  @doc """
  The dotted spelling of a canonical name — used only to probe legacy config
  keys (toolset configs stored with `Session.Create` keys) when a canonical
  lookup misses. Not an emission form.
  """
  @spec dotted(term) :: String.t() | term
  def dotted(name) when is_binary(name), do: String.replace(name, "_", ".")
  def dotted(name), do: name

  @doc """
  Rewrite a tool spec's definition name to canonical underscore form, for
  emission points. Specs whose name is already canonical pass through.
  """
  def canonical_spec(%{definition: %{name: name} = defn} = spec) when is_binary(name) do
    canonical_name = canonical(name)

    if canonical_name == name do
      spec
    else
      %{spec | definition: %{defn | name: canonical_name}}
    end
  end

  def canonical_spec(spec), do: spec

  @doc "Normalize a list of specs for emission (see `canonical_spec/1`)."
  @spec canonical_specs([map()]) :: [map()]
  def canonical_specs(specs) when is_list(specs), do: Enum.map(specs, &canonical_spec/1)
  def canonical_specs(specs), do: specs
end
