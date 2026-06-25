defmodule NoizuPromptLinguaWeb.ChatController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.Authz

  # GET /api/v1/organizations/:org_id/chat/rooms
  def index(conn, %{"org_id" => org_id} = params) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, "viewer") do
      opts =
        [organization_id: resolved_org_id]
        |> maybe_opt(:project_id, params["project_id"])
        |> maybe_opt(:session_id, params["session_id"])

      rooms = Chat.list_rooms(opts)
      json(conn, %{rooms: Enum.map(rooms, &room_to_json/1)})
    else
      err -> handle_error(conn, err)
    end
  end

  # POST /api/v1/organizations/:org_id/chat/rooms
  def create(conn, %{"org_id" => org_id, "room" => room_params}) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, "member"),
         {:ok, project_id} <- validate_project(room_params["project_id"], resolved_org_id) do
      attrs = %{
        organization_id: resolved_org_id,
        project_id: project_id,
        name: room_params["name"],
        description: room_params["description"],
        session_id: room_params["session_id"]
      }

      case Chat.create_room(attrs) do
        {:ok, room} -> conn |> put_status(:created) |> json(%{room: room_to_json(room)})
        {:error, changeset} -> conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
      end
    else
      err -> handle_error(conn, err)
    end
  end

  # GET /api/v1/organizations/:org_id/chat/rooms/:id
  # :id may be a room UUID or a slug.
  def show(conn, %{"org_id" => org_id, "id" => id} = params) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, "viewer"),
         room when not is_nil(room) <- fetch_room(resolved_org_id, id, params["project_id"]),
         true <- room.organization_id == resolved_org_id do
      json(conn, %{room: room_to_json(room)})
    else
      nil -> conn |> put_status(:not_found) |> json(%{error: "Room not found"})
      false -> conn |> put_status(:not_found) |> json(%{error: "Room not found"})
      err -> handle_error(conn, err)
    end
  end

  # PUT /api/v1/organizations/:org_id/chat/rooms/:id  body {room: {name, description}}
  # Editable = name + description ONLY; slug is immutable (ADR-013), enforced by
  # ChatRoom.update_changeset (slug/org/project not cast), so a rename never re-slugs
  # and the (org, project) bucket can't move. Returns the full room incl slug.
  def update(conn, %{"org_id" => org_id, "id" => id, "room" => room_params}) do
    with_room(conn, org_id, id, "member", fn room ->
      case Chat.update_room(room, %{name: room_params["name"], description: room_params["description"]}) do
        {:ok, room} -> json(conn, %{room: room_to_json(room)})
        {:error, changeset} -> conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
      end
    end)
  end

  def update(conn, _params), do: missing_field(conn, "room")

  # DELETE /api/v1/organizations/:org_id/chat/rooms/:id
  # Hard delete (cascade) — see Chat.delete_room/1. Destructive (wipes all history) +
  # LIVE-enforced, so the bar is `lead`, NOT `member` (marcus seq540). This matches the
  # eventual ADR-013/015 chat:moderate tag (required_role: :lead), so the live REST bar
  # and the RBAC tool tag are the same — no later reconciliation.
  def delete(conn, %{"org_id" => org_id, "id" => id}) do
    with_room(conn, org_id, id, "lead", fn room ->
      case Chat.delete_room(room) do
        {:ok, _deleted} -> json(conn, %{deleted: true, id: room.id})
        {:error, _reason} -> conn |> put_status(:unprocessable_entity) |> json(%{error: "Could not delete room"})
      end
    end)
  end

  # GET /api/v1/organizations/:org_id/chat/rooms/:room_id/messages
  def index_messages(conn, %{"org_id" => org_id, "room_id" => room_id} = params) do
    with_room(conn, org_id, room_id, "viewer", fn room ->
      # Slack-style channel view: top-level only; replies are fetched via the per-message
      # replies endpoint (ffa2d2f6). `?include_replies=true` opts back to the flat list.
      opts =
        [top_level: params["include_replies"] not in [true, "true"]]
        |> maybe_opt(:before, params["before"])
        |> maybe_opt(:after, params["after"])
        |> maybe_opt(:limit, parse_limit(params["limit"]))

      messages = room.id |> Chat.list_messages(opts) |> Enum.reverse()
      ids = Enum.map(messages, & &1.id)
      reactions = Chat.message_reaction_summaries(ids, actor(conn))
      # reply_count + last_reply_at per root so the FE renders thread affordances w/o N+1.
      threads = Chat.thread_summaries(ids)

      json(conn, %{
        messages: Enum.map(messages, fn m -> message_to_json(m, Map.get(reactions, m.id, []), Map.get(threads, m.id)) end)
      })
    end)
  end

  # POST /api/v1/organizations/:org_id/chat/rooms/:room_id/messages
  # A reply is just a message with a `parent_message_id` (ffa2d2f6) — one endpoint, no
  # FE branching. The parent (when present) must be in THIS room and be a ROOT (threads
  # are one level); a reply-to-reply or cross-room parent is a 422.
  def create_message(conn, %{"org_id" => org_id, "room_id" => room_id, "message" => msg_params}) do
    with_room(conn, org_id, room_id, "member", fn room ->
      case reply_parent(room.id, msg_params["parent_message_id"]) do
        {:error, reason} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: reason})

        {:ok, parent_id} ->
          attrs = %{
            room_id: room.id,
            content: msg_params["content"],
            sender: msg_params["sender"] || actor(conn),
            parent_message_id: parent_id
          }

          case Chat.send_message(attrs) do
            {:ok, msg} -> conn |> put_status(:created) |> json(%{message: message_to_json(msg, [])})
            {:error, changeset} -> conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
          end
      end
    end)
  end

  # Missing `message` body -> 422 rather than a FunctionClauseError 500.
  def create_message(conn, _params), do: missing_field(conn, "message")

  # Validate a reply's parent (ffa2d2f6): nil/"" -> top-level message; else the parent
  # must exist, be in THIS room, and be a ROOT (one-level threads). app-guarded because
  # the self-FK only guarantees existence, not same-room or depth.
  defp reply_parent(_room_id, nil), do: {:ok, nil}
  defp reply_parent(_room_id, ""), do: {:ok, nil}

  defp reply_parent(room_id, parent_id) do
    case Chat.get_message(parent_id) do
      nil -> {:error, "Parent message not found"}
      %{room_id: ^room_id, parent_message_id: nil} = parent -> {:ok, parent.id}
      %{room_id: ^room_id} -> {:error, "Cannot reply to a reply (threads are one level)"}
      _ -> {:error, "Parent message is in another room"}
    end
  end

  # GET /api/v1/organizations/:org_id/chat/rooms/:room_id/messages/:message_id/replies
  # Replies to a message, chronological, each with embedded reaction summaries.
  def index_replies(conn, %{"org_id" => org_id, "room_id" => room_id, "message_id" => message_id}) do
    with_message(conn, org_id, room_id, message_id, "viewer", fn parent ->
      replies = Chat.list_replies(parent.id)
      reactions = Chat.message_reaction_summaries(Enum.map(replies, & &1.id), actor(conn))
      json(conn, %{messages: Enum.map(replies, fn r -> message_to_json(r, Map.get(reactions, r.id, [])) end)})
    end)
  end

  # All three reaction endpoints return the FE `ChatReactionSummary[]` shape
  # (`%{reactions: [%{emoji, count, me}]}`) — identical to what the message list
  # embeds — so the client renders pills from one contract. POST/DELETE return the
  # *regrouped* summary so the FE reconciles an optimistic update to server truth in
  # one round-trip. `me` is the caller's-persona reaction state (ADR-013 R2: the
  # npl_reactions unique key is `persona`, and REST keys persona = the authed actor),
  # computed identically to the embedded message-list summaries.

  # GET /api/v1/organizations/:org_id/chat/rooms/:room_id/messages/:message_id/reactions
  def index_message_reactions(conn, %{"org_id" => org_id, "room_id" => room_id, "message_id" => message_id}) do
    with_message(conn, org_id, room_id, message_id, "viewer", fn msg ->
      json(conn, %{reactions: Chat.message_reaction_summary(msg.id, actor(conn))})
    end)
  end

  # POST /api/v1/organizations/:org_id/chat/rooms/:room_id/messages/:message_id/reactions  body: {emoji}
  #
  # persona = the authed actor, ALWAYS. We deliberately ignore any client-supplied
  # `persona` so the REST write axis == the read axis (`me`) == the npl_reactions
  # UNIQUE key (ADR-013 R2 / dmitri seq195: one identity axis end-to-end). Letting a
  # caller name an arbitrary persona would (a) let them spoof a reaction as someone
  # else and (b) split the write/read axes -> ambiguous `me` + duplicate rows. The
  # on-behalf-of path (an agent reacting as a persona) is the MCP `Chat.React` tool,
  # which calls the domain directly with a trusted persona.
  def add_message_reaction(conn, %{"org_id" => org_id, "room_id" => room_id, "message_id" => message_id, "emoji" => emoji}) do
    with_message(conn, org_id, room_id, message_id, "member", fn msg ->
      persona = actor(conn)

      case Chat.add_reaction(%{entity_type: "chat_message", entity_id: msg.id, persona: persona, emoji: emoji}) do
        {:ok, _reaction} ->
          conn |> put_status(:created) |> json(%{reactions: Chat.message_reaction_summary(msg.id, actor(conn))})

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
      end
    end)
  end

  # Missing-`emoji` fallback: without it a body-less request fails to match the head
  # above (FunctionClauseError -> 500). A missing required field is a client error
  # -> 422 (Sofia G2: missing emoji -> 422 not 500).
  def add_message_reaction(conn, _params), do: missing_field(conn, "emoji")

  # DELETE /api/v1/organizations/:org_id/chat/rooms/:room_id/messages/:message_id/reactions  body/query: {emoji}
  #
  # persona = the authed actor, ALWAYS (same one-axis rule as POST). This also closes
  # an authz gap: a client-supplied persona would let any member delete ANOTHER
  # persona's reaction (pass persona=victim). You can only remove your own.
  def remove_message_reaction(conn, %{"org_id" => org_id, "room_id" => room_id, "message_id" => message_id, "emoji" => emoji}) do
    with_message(conn, org_id, room_id, message_id, "member", fn msg ->
      persona = actor(conn)

      case Chat.remove_reaction("chat_message", msg.id, persona, emoji) do
        :ok -> json(conn, %{reactions: Chat.message_reaction_summary(msg.id, actor(conn))})
        {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Reaction not found"})
      end
    end)
  end

  def remove_message_reaction(conn, _params), do: missing_field(conn, "emoji")

  defp missing_field(conn, field) do
    conn |> put_status(:unprocessable_entity) |> json(%{errors: %{field => ["can't be blank"]}})
  end

  defp room_to_json(room) do
    %{
      id: room.id,
      organization_id: room.organization_id,
      project_id: room.project_id,
      session_id: room.session_id,
      name: room.name,
      slug: room.slug,
      description: room.description,
      inserted_at: room.inserted_at,
      updated_at: room.updated_at
    }
  end

  defp message_to_json(m, reactions, thread \\ nil) do
    %{
      id: m.id,
      room_id: m.room_id,
      content: m.content,
      sender: m.sender,
      parent_message_id: m.parent_message_id,
      inserted_at: m.inserted_at,
      reactions: reactions,
      # thread affordances on a root message (nil/absent => 0 replies).
      reply_count: (thread && thread.reply_count) || 0,
      last_reply_at: thread && thread.last_reply_at
    }
  end

  # Resolve a room by UUID or slug. Slug resolution is bucket-scoped (ADR-013 A3):
  # a slug is unique per (org, project), so a `project_id` (when supplied) selects
  # the project bucket; its absence resolves the NULL-project (org-level) bucket.
  defp fetch_room(org_id, id_or_slug, project_id \\ nil) do
    case Ecto.UUID.cast(id_or_slug) do
      {:ok, uuid} -> Chat.get_room(uuid)
      :error -> Chat.get_room_by_slug(org_id, project_id, id_or_slug)
    end
  end

  # Load + authorize a room (org-scoped) before running fun.(room).
  defp with_room(conn, org_id, room_id, role, fun) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, role),
         room when not is_nil(room) <- fetch_room(resolved_org_id, room_id),
         true <- room.organization_id == resolved_org_id do
      fun.(room)
    else
      nil -> conn |> put_status(:not_found) |> json(%{error: "Room not found"})
      false -> conn |> put_status(:not_found) |> json(%{error: "Room not found"})
      err -> handle_error(conn, err)
    end
  end

  # Load a message and verify it belongs to the (authorized) room.
  defp with_message(conn, org_id, room_id, message_id, role, fun) do
    with_room(conn, org_id, room_id, role, fn room ->
      case Chat.get_message(message_id) do
        nil -> conn |> put_status(:not_found) |> json(%{error: "Message not found"})
        msg ->
          if msg.room_id == room.id,
            do: fun.(msg),
            else: conn |> put_status(:not_found) |> json(%{error: "Message not found"})
      end
    end)
  end

  defp actor(conn), do: get_user_id(conn) || "anonymous"

  defp parse_limit(nil), do: nil
  defp parse_limit(""), do: nil
  defp parse_limit(v) when is_integer(v), do: v
  defp parse_limit(v) when is_binary(v) do
    case Integer.parse(v) do
      {n, _} -> n
      :error -> nil
    end
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
      {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Organization not found"})
      {:error, :not_a_member} -> conn |> put_status(:forbidden) |> json(%{error: "Not a member of this organization"})
      {:error, :project_not_in_org} -> conn |> put_status(:unprocessable_entity) |> json(%{error: "Project does not belong to this organization"})
      _ -> conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
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
