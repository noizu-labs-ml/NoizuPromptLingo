defmodule NPLWeb.DashboardController do
  use NPLWeb, :controller

  alias NoizuPromptLingua.Domains.{Sessions, Tickets, Assets, Artifacts, Reviews, Projects}

  def stats(conn, _params) do
    json(conn, %{
      sessions: %{active: Sessions.count_active()},
      tickets: %{by_status: Tickets.count_by_status()},
      assets: %{by_type: Assets.count_by_type(), by_status: Assets.count_by_status()},
      artifacts: %{by_kind: Artifacts.count_by_kind()},
      reviews: %{by_status: Reviews.count_by_status()},
      projects: %{total: length(Projects.list())}
    })
  end

  def activity(conn, params) do
    limit = to_int(params["limit"], 20)
    json(conn, %{events: build_activity_feed(limit)})
  end

  defp build_activity_feed(limit) do
    tickets = Tickets.list(limit: limit)
    |> Enum.map(fn t ->
      %{type: "ticket", domain: "tickets", id: t.id, title: t.title,
        status: t.status, at: t.updated_at}
    end)

    assets = Assets.list(limit: limit)
    |> Enum.map(fn a ->
      %{type: "asset", domain: "assets", id: a.id, title: a.title,
        slug: a.slug, status: a.status, asset_type: a.asset_type, at: a.updated_at}
    end)

    reviews = Reviews.list(limit: limit)
    |> Enum.map(fn r ->
      %{type: "review", domain: "review", id: r.id, status: r.status,
        reviewer: r.reviewer_persona, at: r.updated_at}
    end)

    (tickets ++ assets ++ reviews)
    |> Enum.sort_by(& &1.at, {:desc, DateTime})
    |> Enum.take(limit)
  end

  defp to_int(nil, default), do: default
  defp to_int(val, default) when is_binary(val) do
    case Integer.parse(val) do
      {n, _} -> n
      :error -> default
    end
  end
  defp to_int(val, _default) when is_integer(val), do: val
end
