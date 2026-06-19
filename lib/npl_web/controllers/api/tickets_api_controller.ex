defmodule NPLWeb.API.TicketsAPIController do
  use NPLWeb, :controller

  alias NoizuPromptLingua.Domains.Tickets
  alias NoizuPromptLingua.Domains.Tickets.Definitions

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

  def create(conn, params) do
    attrs = Map.take(params, ~w(title description ticket_type status priority assignee reporter project_id queue_id parent_id custom_fields))
    case Tickets.create(attrs) do
      {:ok, ticket} ->
        conn |> put_status(201) |> json(%{ticket: ticket_json(ticket)})
      {:error, cs} ->
        conn |> put_status(422) |> json(%{errors: format_errors(cs)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    attrs = Map.take(params, ~w(title description ticket_type status priority assignee reporter queue_id parent_id custom_fields))
    case Tickets.update(id, attrs) do
      {:ok, ticket} ->
        json(conn, %{ticket: ticket_json(ticket)})
      {:error, :not_found} ->
        conn |> put_status(404) |> json(%{error: "not_found"})
      {:error, cs} ->
        conn |> put_status(422) |> json(%{errors: format_errors(cs)})
    end
  end

  def delete(conn, %{"id" => id}) do
    case Tickets.update(id, %{status: "archived"}) do
      {:ok, _} -> json(conn, %{ok: true})
      {:error, :not_found} -> conn |> put_status(404) |> json(%{error: "not_found"})
    end
  end

  # ── Ticket Type Definitions ────────────────────────────────────

  def list_type_definitions(conn, _params) do
    types = Definitions.list_types()
    json(conn, %{ticket_type_definitions: Enum.map(types, &type_def_json/1)})
  end

  def create_type_definition(conn, params) do
    attrs = Map.take(params, ~w(slug name description status_workflow))
    case Definitions.create_type(attrs) do
      {:ok, type_def} ->
        conn |> put_status(201) |> json(%{ticket_type_definition: type_def_json(type_def)})
      {:error, cs} ->
        conn |> put_status(422) |> json(%{errors: format_errors(cs)})
    end
  end

  def update_type_definition(conn, %{"id" => slug} = params) do
    attrs = Map.take(params, ~w(name description status_workflow))
    case Definitions.update_type(slug, attrs) do
      {:ok, type_def} ->
        json(conn, %{ticket_type_definition: type_def_json(type_def)})
      {:error, :not_found} ->
        conn |> put_status(404) |> json(%{error: "not_found"})
      {:error, cs} ->
        conn |> put_status(422) |> json(%{errors: format_errors(cs)})
    end
  end

  def delete_type_definition(conn, %{"id" => slug}) do
    case Definitions.delete_type(slug) do
      {:ok, _} -> json(conn, %{ok: true})
      {:error, :not_found} -> conn |> put_status(404) |> json(%{error: "not_found"})
    end
  end

  # ── Ticket Field Definitions ───────────────────────────────────

  def list_field_definitions(conn, _params) do
    fields = Definitions.list_fields()
    json(conn, %{ticket_field_definitions: Enum.map(fields, &field_def_json/1)})
  end

  def create_field_definition(conn, params) do
    attrs = Map.take(params, ~w(slug label field_type options default_value))
    case Definitions.create_field(attrs) do
      {:ok, field} ->
        conn |> put_status(201) |> json(%{ticket_field_definition: field_def_json(field)})
      {:error, cs} ->
        conn |> put_status(422) |> json(%{errors: format_errors(cs)})
    end
  end

  def update_field_definition(conn, %{"id" => slug} = params) do
    attrs = Map.take(params, ~w(label field_type options default_value))
    case Definitions.update_field(slug, attrs) do
      {:ok, field} ->
        json(conn, %{ticket_field_definition: field_def_json(field)})
      {:error, :not_found} ->
        conn |> put_status(404) |> json(%{error: "not_found"})
      {:error, cs} ->
        conn |> put_status(422) |> json(%{errors: format_errors(cs)})
    end
  end

  def delete_field_definition(conn, %{"id" => slug}) do
    case Definitions.delete_field(slug) do
      {:ok, _} -> json(conn, %{ok: true})
      {:error, :not_found} -> conn |> put_status(404) |> json(%{error: "not_found"})
    end
  end

  defp ticket_json(t) do
    %{id: t.id, title: t.title, description: t.description, ticket_type: t.ticket_type,
      status: t.status, priority: t.priority, assignee: t.assignee, reporter: t.reporter,
      project_id: t.project_id, queue_id: t.queue_id, parent_id: t.parent_id,
      custom_fields: t.custom_fields, created_at: t.inserted_at, updated_at: t.updated_at}
  end

  defp type_def_json(t) do
    %{id: t.id, slug: t.slug, name: t.name, description: t.description,
      status_workflow: t.status_workflow}
  end

  defp field_def_json(f) do
    %{id: f.id, slug: f.slug, label: f.label, field_type: f.field_type,
      options: f.options, default_value: f.default_value}
  end

  defp to_int(nil, d), do: d
  defp to_int(v, d) when is_binary(v), do: (case Integer.parse(v) do {n,_} -> n; _ -> d end)
  defp to_int(v, _) when is_integer(v), do: v

  defp format_errors(%Ecto.Changeset{} = cs) do
    Ecto.Changeset.traverse_errors(cs, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
  defp format_errors(other), do: inspect(other)
end
