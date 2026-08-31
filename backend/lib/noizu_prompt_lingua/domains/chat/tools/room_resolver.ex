defmodule NoizuPromptLingua.Domains.Chat.Tools.RoomResolver do
  @moduledoc """
  Shared room addressing for Chat.* tools: `room_id` accepts the room's UUID or
  its immutable slug (slug preferred). Slugs are unique per (org, project) bucket
  (ADR-013 A3), so these tools also take an optional `organization` arg
  ("Org slug or UUID") that is required only when the room is addressed by slug.
  """

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @doc """
  Resolve `room_id` (slug or UUID) from tool args, using the optional
  `organization` arg for slug scope. Returns `{:ok, room}` or `{:error, ...}`.
  """
  def call(args) do
    org_ref = Args.get(args, :organization)

    cond do
      org_ref in [nil, ""] ->
        Chat.resolve_room(Args.get(args, :room_id))

      true ->
        case Resolve.organization_id(org_ref) do
          nil -> {:error, "Organization '#{org_ref}' not found"}
          org_id -> Chat.resolve_room(Args.get(args, :room_id), org_id)
        end
    end
  end
end
