defmodule NoizuPromptLingua.MCP.VFS.Overview do
  @moduledoc """
  `overview.md` renderer for per-group VFS subtrees (design §2.23): the file
  plane's Overview node is *rendered from each group's Overview tool* — every
  group has one — so the tree cannot drift from the tool surface's self
  description. Rendering is best-effort with a static fallback; the renderer
  never raises into VFS ops.
  """

  @doc "Render `tool_module`'s Overview output as markdown for `group_id`."
  @spec md(module(), String.t()) :: String.t()
  def md(tool_module, group_id) do
    case safe_call(tool_module) do
      {:ok, data} when is_map(data) -> render(data, group_id)
      _ -> fallback(group_id)
    end
  end

  defp safe_call(module) do
    case module.call(%{}, nil) do
      {:ok, data} when is_map(data) -> {:ok, data}
      _ -> :error
    end
  rescue
    _ -> :error
  catch
    _, _ -> :error
  end

  # ── rendering ─────────────────────────────────────────────────────────────

  defp render(data, group_id) do
    title = fetch(data, :domain) || group_id

    [
      "# #{title} (#{group_id})",
      "",
      "Natural-file plane for the `#{group_id}` group (MCP-VFS-GROUP-MOUNTS.md).",
      "This node renders the group's Overview tool; entity data lives in the",
      "`record.json` / natural files beside it.",
      "",
      tools_section(fetch(data, :tools)),
      counts_section(fetch(data, :counts_by_kind)),
      kinds_section(fetch(data, :kinds))
    ]
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n")
  end

  defp tools_section(nil), do: nil
  defp tools_section([]), do: nil

  defp tools_section(tools) when is_list(tools) do
    ["## Tools", ""] ++
      Enum.map(tools, fn
        %{name: name} = t -> "- `#{name}`#{maybe_desc(t[:description])}"
        %{"name" => name} = t -> "- `#{name}`#{maybe_desc(t["description"])}"
        other -> "- #{inspect(other)}"
      end) ++ [""]
  end

  defp tools_section(_), do: nil

  defp counts_section(nil), do: nil

  defp counts_section(counts) when is_map(counts) and counts != %{} do
    rows =
      counts
      |> Enum.map(fn
        {k, v} -> "- #{k}: #{v}"
        _ -> nil
      end)
      |> Enum.reject(&is_nil/1)

    if rows == [], do: nil, else: ["## Counts", ""] ++ rows ++ [""]
  end

  defp counts_section(_), do: nil

  defp kinds_section(nil), do: nil
  defp kinds_section([]), do: nil

  defp kinds_section(kinds) when is_list(kinds) do
    ["## Kinds", "", Enum.map_join(kinds, ", ", &to_string/1), ""]
  end

  defp kinds_section(_), do: nil

  defp maybe_desc(nil), do: ""
  defp maybe_desc(desc), do: " — #{desc}"

  defp fallback(group_id) do
    """
    # #{group_id}

    Natural-file plane for the `#{group_id}` group (MCP-VFS-GROUP-MOUNTS.md).
    The group's Overview tool is unavailable; this is the static fallback.
    """
  end

  defp fetch(data, key) when is_map(data) do
    Map.get(data, key) || Map.get(data, Atom.to_string(key))
  end

  defp fetch(_, _), do: nil
end
