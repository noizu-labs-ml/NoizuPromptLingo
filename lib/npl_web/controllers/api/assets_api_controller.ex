defmodule NPLWeb.API.AssetsAPIController do
  use NPLWeb, :controller

  alias NoizuPromptLingua.Domains.Assets

  def index(conn, params) do
    opts =
      [:asset_type, :status, :tag, :project_id]
      |> Enum.reduce([], fn k, acc ->
        val = params[Atom.to_string(k)]
        if val, do: [{k, val} | acc], else: acc
      end)
      |> Keyword.merge(limit: to_int(params["limit"], 50), offset: to_int(params["offset"], 0))

    assets = Assets.list(opts)
    json(conn, %{
      assets: Enum.map(assets, &asset_json/1),
      count: length(assets)
    })
  end

  def show(conn, %{"id" => id}) do
    case Assets.get(id) do
      nil -> conn |> put_status(404) |> json(%{error: "not_found"})
      entry ->
        outputs = Assets.list_outputs(entry.id)
        json(conn, %{
          asset: asset_json(entry),
          outputs: Enum.map(outputs, &output_json/1)
        })
    end
  end

  def history(conn, %{"id" => id}) do
    events = Assets.list_history(id)
    json(conn, %{
      events: Enum.map(events, fn h ->
        %{id: h.id, action: h.action, actor: h.actor, details: h.details, at: h.inserted_at}
      end)
    })
  end

  defp asset_json(e) do
    %{id: e.id, slug: e.slug, title: e.title, asset_type: e.asset_type,
      status: e.status, quality: e.quality, tags: e.tags,
      product_targets: e.product_targets, project_id: e.project_id,
      active_output_id: e.active_output_id,
      created_at: e.inserted_at, updated_at: e.updated_at}
  end

  defp output_json(o) do
    %{id: o.id, artifact_id: o.artifact_id, provider: o.provider, model: o.model,
      variant_number: o.variant_number, eval_score: o.eval_score,
      eval_status: o.eval_status, status: o.status, created_at: o.inserted_at}
  end

  defp to_int(nil, d), do: d
  defp to_int(v, d) when is_binary(v), do: (case Integer.parse(v) do {n,_} -> n; _ -> d end)
  defp to_int(v, _) when is_integer(v), do: v
end
