defmodule NoizuPromptLinguaWeb.TicketController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Domains.Tickets
  alias NoizuPromptLingua.Authz

  # GET /api/v1/organizations/:org_id/tickets
  def index(conn, %{"org_id" => org_id} = params) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, "viewer") do
      opts =
        [organization_id: resolved_org_id]
        |> maybe_opt(:project_id, params["project_id"])
        |> maybe_opt(:status, params["status"])
        |> maybe_opt(:ticket_type, params["ticket_type"])
        |> maybe_opt(:priority, params["priority"])
        |> maybe_opt(:assignee, params["assignee"])
        |> maybe_opt(:queue_id, params["queue_id"])
        |> maybe_opt(:parent_id, params["parent_id"])
        |> maybe_opt(:stage_id, params["stage_id"])
        |> maybe_opt(:iteration_id, params["iteration_id"])

      tickets = Tickets.list(opts)
      json(conn, %{tickets: Enum.map(tickets, &ticket_to_json/1)})
    else
      err -> handle_error(conn, err)
    end
  end

  # POST /api/v1/organizations/:org_id/tickets
  def create(conn, %{"org_id" => org_id, "ticket" => ticket_params}) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, "member"),
         {:ok, project_id} <- validate_project(ticket_params["project_id"], resolved_org_id) do
      attrs = %{
        organization_id: resolved_org_id,
        project_id: project_id,
        title: ticket_params["title"],
        description: ticket_params["description"],
        ticket_type: ticket_params["ticket_type"] || "task",
        status: ticket_params["status"] || "open",
        priority: ticket_params["priority"],
        assignee: ticket_params["assignee"],
        reporter: ticket_params["reporter"],
        queue_id: ticket_params["queue_id"],
        parent_id: ticket_params["parent_id"],
        stage_id: ticket_params["stage_id"],
        iteration_id: ticket_params["iteration_id"],
        custom_fields: ticket_params["custom_fields"] || %{}
      }

      case Tickets.create(attrs) do
        {:ok, ticket} ->
          conn |> put_status(:created) |> json(%{ticket: ticket_to_json(ticket)})

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
      end
    else
      err -> handle_error(conn, err)
    end
  end

  # GET /api/v1/organizations/:org_id/tickets/:id
  def show(conn, %{"org_id" => org_id, "id" => id}) do
    with_org_ticket(conn, org_id, id, "viewer", fn ticket ->
      # `id` may be a human key; links resolve off the ticket's UUID.
      links = Tickets.get_links(ticket.id)
      json(conn, %{ticket: ticket_to_json(ticket), links: links_to_json(links)})
    end)
  end

  # PATCH/PUT /api/v1/organizations/:org_id/tickets/:id
  def update(conn, %{"org_id" => org_id, "id" => id, "ticket" => attrs}) do
    with_org_ticket(conn, org_id, id, "member", fn _ticket ->
      clean =
        Map.take(
          attrs,
          ~w(title description status priority assignee queue_id parent_id custom_fields stage_id iteration_id)
        )

      case Tickets.update(id, clean) do
        {:ok, ticket} ->
          json(conn, %{ticket: ticket_to_json(ticket)})

        {:error, :not_found} ->
          conn |> put_status(:not_found) |> json(%{error: "Ticket not found"})

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
      end
    end)
  end

  # Resolve org, authorize, load the ticket, and ensure it belongs to the org.
  defp with_org_ticket(conn, org_id, id, role, fun) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, role),
         ticket when not is_nil(ticket) <- fetch_ticket(resolved_org_id, id),
         true <- ticket.organization_id == resolved_org_id do
      fun.(ticket)
    else
      nil -> conn |> put_status(:not_found) |> json(%{error: "Ticket not found"})
      false -> conn |> put_status(:not_found) |> json(%{error: "Ticket not found"})
      err -> handle_error(conn, err)
    end
  end

  # :id may be a ticket UUID or a human key (NOZINF-023). Key resolution is org-scoped.
  defp fetch_ticket(org_id, id_or_key) do
    case NoizuPromptLingua.UUID.cast(id_or_key) do
      {:ok, uuid} -> Tickets.get(uuid)
      :error -> Tickets.get_by_key(org_id, id_or_key)
    end
  end

  defp ticket_to_json(t) do
    %{
      id: t.id,
      key: t.key,
      number: t.number,
      organization_id: t.organization_id,
      project_id: t.project_id,
      title: t.title,
      description: t.description,
      ticket_type: t.ticket_type,
      status: t.status,
      priority: t.priority,
      assignee: t.assignee,
      reporter: t.reporter,
      queue_id: t.queue_id,
      parent_id: t.parent_id,
      stage_id: t.stage_id,
      iteration_id: t.iteration_id,
      custom_fields: t.custom_fields,
      inserted_at: t.inserted_at,
      updated_at: t.updated_at
    }
  end

  defp links_to_json(%{outgoing: out, incoming: inc}) do
    %{
      outgoing:
        Enum.map(
          out,
          &%{id: &1.id, link_type: &1.link_type, target_ticket_id: &1.target_ticket_id}
        ),
      incoming:
        Enum.map(
          inc,
          &%{id: &1.id, link_type: &1.link_type, source_ticket_id: &1.source_ticket_id}
        )
    }
  end

  defp validate_project(nil, _org_id), do: {:ok, nil}
  defp validate_project("", _org_id), do: {:ok, nil}

  defp validate_project(project_id, org_id) do
    case NoizuPromptLingua.Projects.get_project(project_id) do
      nil -> {:error, :project_not_in_org}
      %{organization_id: ^org_id} -> {:ok, project_id}
      _ -> {:error, :project_not_in_org}
    end
  end

  defp handle_error(conn, err) do
    case err do
      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Organization not found"})

      {:error, :not_a_member} ->
        conn |> put_status(:forbidden) |> json(%{error: "Not a member of this organization"})

      {:error, :project_not_in_org} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Project does not belong to this organization"})

      _ ->
        conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  defp maybe_opt(opts, _key, nil), do: opts
  defp maybe_opt(opts, _key, ""), do: opts
  defp maybe_opt(opts, key, val), do: Keyword.put(opts, key, val)

  defp get_user_id(conn) do
    case NoizuPromptLingua.Guardian.Plug.current_resource(conn) do
      %NoizuPromptLingua.Users.Sessions.UserSession{user: {:ref, _, id}} -> id
      %NoizuPromptLingua.Users.Sessions.UserSession{user: %{id: id}} -> id
      _ -> nil
    end
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
