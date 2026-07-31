defmodule NoizuPromptLingua.Domains.Chat.Tools.ScheduleMessage do
  use Noizu.MCP.Server.Tool,
    name: "Chat.ScheduleMessage",
    description:
      "Schedule a message to be posted at a future instant or time-of-day rather than immediately. Released live by Chat.release_due_scheduled/0.",
    hidden: true,
    category: "Chat"

  input do
    field :room_id, :string, required: true, description: "Room UUID"
    field :content, :string, required: true, description: "Message body (markdown)"
    field :sender, :string, required: true, description: "Persona slug"
    field :scheduled_for, :string, description: "ISO8601 instant to post at"
    field :time_of_day, :string, description: "HH:MM (UTC) — next occurrence of this time"
  end

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    with {:ok, when_dt} <-
           resolve_when(Args.get(args, :scheduled_for), Args.get(args, :time_of_day)) do
      attrs = %{
        room_id: Args.get(args, :room_id),
        content: Args.get(args, :content),
        sender: Args.get(args, :sender),
        scheduled_for: when_dt
      }

      case Chat.schedule_message(attrs) do
        {:ok, msg} -> {:ok, %{id: msg.id, scheduled_for: msg.scheduled_for, room_id: msg.room_id}}
        {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
      end
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp resolve_when(nil, nil),
    do: {:error, "Provide scheduled_for (ISO8601) or time_of_day (HH:MM)"}

  defp resolve_when(iso, _) when is_binary(iso) and iso != "" do
    case DateTime.from_iso8601(iso) do
      {:ok, dt, _} -> {:ok, DateTime.truncate(dt, :second)}
      _ -> {:error, "Invalid scheduled_for; expected ISO8601"}
    end
  end

  defp resolve_when(_, tod) when is_binary(tod) and tod != "" do
    with [h, m] <- String.split(tod, ":"),
         {hour, ""} <- Integer.parse(h),
         {min, ""} <- Integer.parse(m),
         {:ok, time} <- Time.new(hour, min, 0) do
      now = DateTime.utc_now()
      today = DateTime.new!(DateTime.to_date(now), time, "Etc/UTC")

      target =
        if DateTime.compare(today, now) == :gt,
          do: today,
          else: DateTime.add(today, 86_400, :second)

      {:ok, DateTime.truncate(target, :second)}
    else
      _ -> {:error, "Invalid time_of_day; expected HH:MM"}
    end
  end

  defp resolve_when(_, _), do: {:error, "Provide scheduled_for (ISO8601) or time_of_day (HH:MM)"}
end
