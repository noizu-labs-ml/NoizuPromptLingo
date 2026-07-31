defmodule NoizuPromptLingua.Domains.Notifications.Tools.Share do
  use Noizu.MCP.Server.Tool,
    name: "Notifications.Share",
    description:
      "Share a source entity (artifact / chat_message / chat_room / asset / wiki_page) to a target — a chat room (target_type: chat_room, target: room slug or id), a thread/parent message (target_type: thread, target: message id), or a person (target_type: dm, target: handle). Records an attachment pointer on the target and emits a `share` notification to the target's recipients (room members or the handle).",
    hidden: true,
    category: "Notifications"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :project, :string, description: "Optional project slug or UUID (scopes room lookup)"
    field :sender, :string, required: true, description: "Sharer agent handle"

    field :subject_type, :string,
      required: true,
      description: "Source entity type: artifact, chat_message, chat_room, asset, wiki_page"

    field :subject_id, :string, required: true, description: "Source entity id"
    field :target_type, :string, required: true, description: "Target: chat_room, thread, or dm"

    field :target, :string,
      required: true,
      description:
        "Room slug/id (chat_room), parent message id (thread), or recipient handle (dm)"

    field :note, :string, description: "Optional note to accompany the share"
  end

  alias NoizuPromptLingua.Domains.Notifications
  alias NoizuPromptLingua.Services.Attach
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @source_types ~w(artifact chat_message chat_room asset wiki_page)

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)
    project_ref = Args.get(args, :project)
    sender = Args.get(args, :sender)
    subject_type = Args.get(args, :subject_type)
    subject_id = Args.get(args, :subject_id)
    target_type = Args.get(args, :target_type)
    target = Args.get(args, :target)
    note = Args.get(args, :note)

    with {:scope, {:ok, org_id, project_id}} <- {:scope, Resolve.scope(org_ref, project_ref)},
         {:source, true} <- {:source, subject_type in @source_types},
         {:target, {:ok, resolved}} <-
           {:target, resolve_target(org_id, project_id, target_type, target)} do
      # (a) Record an attachment pointer on the TARGET that points at the SOURCE.
      attachment = attach_pointer(resolved, subject_type, subject_id, sender, note)

      # (b) Emit a `share` notification to the target's recipients.
      attrs =
        %{
          organization_id: org_id,
          project_id: project_id,
          sender: sender,
          kind: "share",
          subject_type: subject_type,
          subject_id: subject_id,
          body: share_body(sender, subject_type, note),
          payload: %{"target_type" => target_type, "target" => target}
        }
        |> Map.merge(recipient_attrs(resolved))

      case Notifications.notify(attrs) do
        {:ok, rows} ->
          {:ok,
           %{
             shared: subject_type,
             subject_id: subject_id,
             target_type: target_type,
             notified: rows |> Enum.map(& &1.recipient) |> Enum.uniq(),
             ids: Enum.map(rows, & &1.id),
             attachment_id: attachment && attachment.id
           }}

        {:error, :no_recipients} ->
          {:error,
           "Shared (attachment recorded) but no recipients resolved for target '#{target}'"}

        {:error, reason} ->
          {:error, "Share failed: #{inspect(reason)}"}
      end
    else
      {:scope, {:error, :org_not_found}} ->
        {:error, "Organization '#{org_ref}' not found"}

      {:scope, {:error, :project_not_found}} ->
        {:error, "Project '#{project_ref}' not found"}

      {:scope, {:error, :project_not_in_org}} ->
        {:error, "Project does not belong to this organization"}

      {:source, false} ->
        {:error, "subject_type must be one of: #{Enum.join(@source_types, ", ")}"}

      {:target, {:error, :unknown_target_type}} ->
        {:error, "target_type must be one of: chat_room, thread, dm"}

      {:target, {:error, :not_found}} ->
        {:error, "Target '#{target}' not found"}
    end
  end

  # ── Target resolution ───────────────────────────────────────────
  # Returns {:ok, resolved} where resolved is one of:
  #   {:room, room_id, [recipient_handles]}
  #   {:dm, handle}

  defp resolve_target(org_id, project_id, "chat_room", target),
    do: resolve_room(org_id, project_id, target)

  defp resolve_target(org_id, project_id, "thread", message_id) do
    chat = NoizuPromptLingua.Domains.Chat

    case safe(fn -> chat.get_message(message_id) end) do
      %{room_id: room_id} when not is_nil(room_id) ->
        {:ok, {:room, room_id, room_members(room_id)}}

      _ ->
        {:error, :not_found}
    end
  end

  defp resolve_target(_org_id, _project_id, "dm", handle) when is_binary(handle) and handle != "",
    do: {:ok, {:dm, handle}}

  defp resolve_target(_org_id, _project_id, t, _target)
       when t in ["chat_room", "thread", "dm"],
       do: {:error, :not_found}

  defp resolve_target(_org_id, _project_id, _t, _target), do: {:error, :unknown_target_type}

  defp resolve_room(org_id, project_id, target) do
    chat = NoizuPromptLingua.Domains.Chat

    room =
      safe(fn ->
        (project_id && chat.get_room_by_slug(org_id, project_id, target)) ||
          chat.get_room_by_slug(org_id, nil, target) ||
          chat.get_room(target)
      end)

    case room do
      %{id: room_id} -> {:ok, {:room, room_id, room_members(room_id)}}
      _ -> {:error, :not_found}
    end
  end

  defp room_members(room_id) do
    safe(fn ->
      room_id
      |> NoizuPromptLingua.Domains.Chat.list_members()
      |> Enum.map(& &1.persona)
    end) || []
  end

  # ── Notification recipient shaping ──────────────────────────────

  defp recipient_attrs({:room, _room_id, members}), do: %{recipients: members}
  defp recipient_attrs({:dm, handle}), do: %{recipient: handle}

  # ── Attachment pointer on the target ────────────────────────────

  defp attach_pointer({:room, room_id, _members}, subject_type, subject_id, sender, note) do
    do_attach("chat_room", room_id, subject_type, subject_id, sender, note)
  end

  # DMs have no entity to attach to — the notification carries the pointer.
  defp attach_pointer({:dm, _handle}, _subject_type, _subject_id, _sender, _note), do: nil

  defp do_attach(entity_type, entity_id, subject_type, subject_id, sender, note) do
    description =
      ["shared #{subject_type} by #{sender}", note]
      |> Enum.reject(&(&1 in [nil, ""]))
      |> Enum.join(" — ")

    attrs = %{
      artifact_type: "url",
      url: "npl://#{subject_type}/#{subject_id}",
      description: description,
      created_by: sender
    }

    case safe(fn -> Attach.add(entity_type, entity_id, attrs) end) do
      {:ok, att} -> att
      _ -> nil
    end
  end

  defp share_body(sender, subject_type, note) do
    base = "#{sender} shared a #{subject_type}"
    if note in [nil, ""], do: base, else: base <> ": " <> note
  end

  defp safe(fun) do
    fun.()
  rescue
    _ -> nil
  end
end
