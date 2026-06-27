defmodule NoizuPromptLingua.Domains.Notifications.Tools.FollowUp do
  use Noizu.MCP.Server.Tool,
    name: "Notifications.FollowUp",
    description:
      "Queue a follow-up reminder that only surfaces in the recipient's inbox once it is due. Set a relative delay (in_minutes or in_hours) OR an absolute ISO-8601 instant (at). Defaults the recipient to the sender (a note-to-self). Optionally pin it to a subject (subject_type/subject_id) so the reminder points back at the thing to revisit.",
    hidden: true,
    category: "Notifications"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :project, :string, description: "Optional project slug or UUID"
    field :sender, :string, required: true, description: "Sender agent handle"
    field :persona, :string, description: "Recipient agent handle (defaults to the sender — a note-to-self)"
    field :recipient, :string, description: "Alias for persona — recipient agent handle"
    field :body, :string, description: "Reminder text"
    field :subject_type, :string, description: "Optional subject pointer type (e.g. ticket, chat_message, wiki_page)"
    field :subject_id, :string, description: "Optional subject pointer id"
    field :in_minutes, :integer, description: "Surface this many minutes from now"
    field :in_hours, :integer, description: "Surface this many hours from now"
    field :at, :string, description: "Absolute ISO-8601 instant to surface at (e.g. 2026-07-01T09:00:00Z)"
  end

  alias NoizuPromptLingua.Domains.Notifications
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)
    project_ref = Args.get(args, :project)
    sender = Args.get(args, :sender)
    recipient = Args.get(args, :persona) || Args.get(args, :recipient) || sender

    with {:scope, {:ok, org_id, project_id}} <- {:scope, Resolve.scope(org_ref, project_ref)},
         {:when, {:ok, deliver_after}} <- {:when, deliver_after(args)} do
      attrs = %{
        organization_id: org_id,
        project_id: project_id,
        sender: sender,
        kind: "follow_up",
        recipient: recipient,
        body: Args.get(args, :body),
        subject_type: Args.get(args, :subject_type),
        subject_id: Args.get(args, :subject_id),
        deliver_after: deliver_after
      }

      case Notifications.notify(attrs) do
        {:ok, rows} ->
          {:ok,
           %{
             kind: "follow_up",
             recipient: recipient,
             deliver_after: DateTime.to_iso8601(deliver_after),
             ids: Enum.map(rows, & &1.id)
           }}

        {:error, :no_recipients} ->
          {:error, "No recipient resolved — provide persona or sender"}

        {:error, reason} ->
          {:error, "FollowUp failed: #{inspect(reason)}"}
      end
    else
      {:scope, {:error, :org_not_found}} -> {:error, "Organization '#{org_ref}' not found"}
      {:scope, {:error, :project_not_found}} -> {:error, "Project '#{project_ref}' not found"}
      {:scope, {:error, :project_not_in_org}} -> {:error, "Project does not belong to this organization"}
      {:when, {:error, :no_duration}} -> {:error, "Provide in_minutes, in_hours, or an ISO-8601 `at` instant"}
      {:when, {:error, :bad_at}} -> {:error, "`at` is not a valid ISO-8601 instant"}
    end
  end

  # Absolute instant wins; otherwise relative minutes/hours from now.
  defp deliver_after(args) do
    at = Args.get(args, :at)
    minutes = Args.get(args, :in_minutes)
    hours = Args.get(args, :in_hours)

    cond do
      is_binary(at) and at != "" ->
        case DateTime.from_iso8601(at) do
          {:ok, dt, _offset} -> {:ok, DateTime.truncate(dt, :second)}
          _ -> {:error, :bad_at}
        end

      is_integer(hours) and hours > 0 ->
        {:ok, DateTime.add(DateTime.utc_now(), hours * 3600, :second) |> DateTime.truncate(:second)}

      is_integer(minutes) and minutes > 0 ->
        {:ok, DateTime.add(DateTime.utc_now(), minutes * 60, :second) |> DateTime.truncate(:second)}

      true ->
        {:error, :no_duration}
    end
  end
end
