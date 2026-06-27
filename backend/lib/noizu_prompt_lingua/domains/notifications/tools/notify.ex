defmodule NoizuPromptLingua.Domains.Notifications.Tools.Notify do
  use Noizu.MCP.Server.Tool,
    name: "Notify",
    description:
      "Send a short direct message (<=128 chars) to one or more recipients. Target a user (recipient), a list of users (recipients), a group (group), or a list of groups (groups) — groups resolve to their chat-room members, fanning out one notification per member. Set ping:true to send a ping (body optional); the recipient should reply with a pong digest via Notify pong_to:<notification_id>. Replaces the deprecated Pipe.Output.",
    hidden: true,
    category: "Notifications"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :project, :string, description: "Optional project slug or UUID (scopes group resolution)"
    field :sender, :string, required: true, description: "Sender agent handle"
    field :recipient, :string, description: "A single recipient handle"
    field :recipients, {:array, :string}, description: "A list of recipient handles"
    field :group, :string, description: "A single group name (resolves to its chat-room members)"
    field :groups, {:array, :string}, description: "A list of group names"
    field :body, :string, description: "Message body (<=128 chars). Required unless ping/pong."
    field :subject_type, :string, description: "Optional subject pointer type (e.g. chat_message, ticket)"
    field :subject_id, :string, description: "Optional subject pointer id"
    field :ping, :boolean, default: false, description: "Send a ping; recipients should reply with a pong digest"
    field :pong_to, :string, description: "Reply to a ping: the originating ping notification id"
  end

  alias NoizuPromptLingua.Domains.Notifications
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)
    project_ref = Args.get(args, :project)
    ping = Args.get(args, :ping) == true
    pong_to = Args.get(args, :pong_to)
    body = Args.get(args, :body)

    kind =
      cond do
        ping -> "ping"
        pong_to not in [nil, ""] -> "pong"
        true -> "dm"
      end

    with {:scope, {:ok, org_id, project_id}} <- {:scope, Resolve.scope(org_ref, project_ref)},
         :ok <- require_body(kind, body),
         :ok <- check_length(body) do
      {subject_type, subject_id} =
        if pong_to not in [nil, ""],
          do: {"notification", pong_to},
          else: {Args.get(args, :subject_type), Args.get(args, :subject_id)}

      attrs = %{
        organization_id: org_id,
        project_id: project_id,
        sender: Args.get(args, :sender),
        kind: kind,
        recipient: Args.get(args, :recipient),
        recipients: Args.get(args, :recipients) || [],
        group: Args.get(args, :group),
        groups: Args.get(args, :groups) || [],
        body: body,
        subject_type: subject_type,
        subject_id: subject_id
      }

      case Notifications.notify(attrs) do
        {:ok, rows} ->
          {:ok,
           %{
             kind: kind,
             delivered: length(rows),
             recipients: rows |> Enum.map(& &1.recipient) |> Enum.uniq(),
             ids: Enum.map(rows, & &1.id)
           }}

        {:error, :no_recipients} ->
          {:error, "No recipients resolved — provide recipient/recipients or a group with members"}

        {:error, reason} ->
          {:error, "Notify failed: #{inspect(reason)}"}
      end
    else
      {:scope, {:error, :org_not_found}} -> {:error, "Organization '#{org_ref}' not found"}
      {:scope, {:error, :project_not_found}} -> {:error, "Project '#{project_ref}' not found"}
      {:scope, {:error, :project_not_in_org}} -> {:error, "Project does not belong to this organization"}
      {:error, :body_required} -> {:error, "body is required for a #{kind}"}
      {:error, :too_long} -> {:error, "body exceeds 128 characters"}
    end
  end

  defp require_body(kind, body) when kind in ["ping", "pong"], do: :ok
  defp require_body(_kind, body) when is_binary(body) and body != "", do: :ok
  defp require_body(_kind, _body), do: {:error, :body_required}

  defp check_length(body) when is_binary(body) and byte_size(body) > 128, do: {:error, :too_long}
  defp check_length(_), do: :ok
end
