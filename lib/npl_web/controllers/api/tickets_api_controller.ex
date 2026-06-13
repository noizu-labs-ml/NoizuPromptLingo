defmodule NPLWeb.API.TicketsAPIController do
  use NPLWeb, :controller

  alias NoizuPromptLingua.Domains.Tickets

  def index(conn, params) do
    opts =
      [:status, :ticket_type, :priority, :assignee, :queue_id, :project_id]
      |> Enum.reduce([], fn k, acc ->
        val = params[Atom.to_string(k)]
        if val, do: [{k, val} | acc], else: acc
      end)
      |> Keyword.merge(limit: to_int(params["limit"], 50))

    tickets = Tickets.list(opts)
    json(conn, %{
      tickets: Enum.map(tickets, &ticket_json/1),
      count: length(tickets)
    })
  end

  def show(conn, %{"id" => id}) do
    case Tickets.get(id) do
      nil -> conn |> put_status(404) |> json(%{error: "not_found"})
      ticket -> json(conn, %{ticket: ticket_json(ticket)})
    end
  end

  defp ticket_json(t) do
    %{id: t.id, title: t.title, description: t.description, ticket_type: t.ticket_type,
      status: t.status, priority: t.priority, assignee: t.assignee, reporter: t.reporter,
      project_id: t.project_id, queue_id: t.queue_id, parent_id: t.parent_id,
      custom_fields: t.custom_fields, created_at: t.inserted_at, updated_at: t.updated_at}
  end

  defp to_int(nil, d), do: d
  defp to_int(v, d) when is_binary(v), do: (case Integer.parse(v) do {n,_} -> n; _ -> d end)
  defp to_int(v, _) when is_integer(v), do: v
end
