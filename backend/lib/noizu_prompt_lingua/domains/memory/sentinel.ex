defmodule NoizuPromptLingua.Domains.Memory.Sentinel do
  @moduledoc """
  Access-control authority for memory. Ownership is a structured scope
  `{organization_id, scope_type, scope_id}`:

    * `persona` / `team_member` — sees only its own memories (org + scope_type + scope_id).
    * `weego` (the orchestrator) — sees ALL memories within its organization (supervisory read).

  The scope predicate is applied in-query by the recall paths (`scope_filter/2`) and as a
  Weaviate `where` filter (`weaviate_filters/1`); `authorize/2` is the post-fusion backstop.
  """
  import Ecto.Query

  @doc "Extract a normalized scope map from a context, or nil when underspecified."
  def scope(%{organization_id: org, scope_type: st, scope_id: sid})
      when not is_nil(org) and not is_nil(st) and not is_nil(sid) do
    %{organization_id: org, scope_type: normalize_type(st), scope_id: sid}
  end

  def scope(_), do: nil

  defp normalize_type(t) when is_atom(t), do: t
  defp normalize_type(t) when is_binary(t), do: String.to_existing_atom(t)

  @doc "Apply the scope predicate to an Ecto memory query (no lifecycle/state filtering)."
  def scope_filter(query, nil), do: where(query, [m], m.classification == :open)

  def scope_filter(query, %{scope_type: :weego, organization_id: org}),
    do: where(query, [m], m.organization_id == ^org)

  def scope_filter(query, %{organization_id: org, scope_type: st, scope_id: sid}),
    do: where(query, [m], m.organization_id == ^org and m.scope_type == ^st and m.scope_id == ^sid)

  @doc "Weaviate `where` property filter mirroring the scope predicate."
  def weaviate_filters(nil), do: %{}

  def weaviate_filters(%{scope_type: :weego, organization_id: org}),
    do: %{"organization_id" => to_string(org)}

  def weaviate_filters(%{organization_id: org, scope_type: st, scope_id: sid}),
    do: %{"organization_id" => to_string(org), "scope_type" => to_string(st), "scope_id" => to_string(sid)}

  @doc "Backstop filter applied to hydrated rows after fusion."
  def authorize(memories, context) when is_list(memories) do
    Enum.filter(memories, &allowed?(&1, scope(context)))
  end

  defp allowed?(mem, nil), do: classification(mem) in [:open, "open"]

  defp allowed?(mem, %{scope_type: :weego, organization_id: org}),
    do: uuid(field(mem, :organization_id)) == uuid(org)

  defp allowed?(mem, %{organization_id: org, scope_type: st, scope_id: sid}) do
    uuid(field(mem, :organization_id)) == uuid(org) and
      to_string(field(mem, :scope_type)) == to_string(st) and
      uuid(field(mem, :scope_id)) == uuid(sid)
  end

  defp field(mem, key), do: Map.get(mem, key) || Map.get(mem, to_string(key))
  defp classification(mem), do: Map.get(mem, :classification) || Map.get(mem, "classification")
  defp uuid(nil), do: nil
  defp uuid(v), do: to_string(v)
end
