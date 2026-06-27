defmodule NoizuPromptLingua.Domains.Notifications.Dispatch do
  @moduledoc """
  Fan-out engine: the single place domain writes call to turn an event into
  notifications. Resolves *who* to notify (entity owner/assignee/author + watchers
  + thread participants) and calls `Notifications.notify/1`.

  STUB — interface contract only. Stream B replaces the bodies with real
  resolution + mention parsing + digest coalescing + watch-filter evaluation.
  Every hook is best-effort and must never raise into its caller's write path.
  """

  @doc "A chat message was posted. Mentions notify immediately; ordinary traffic folds into a 5-min digest."
  def chat_message(_message, _room), do: :ok

  @doc "A reaction was added to an entity (chat_message/ticket/artifact/asset/wiki_page/review)."
  def reaction(_reaction), do: :ok

  @doc "A comment was added to an entity."
  def comment(_comment), do: :ok

  @doc "A ticket was assigned to a persona."
  def ticket_assigned(_ticket), do: :ok

  @doc "A ticket was updated."
  def ticket_update(_ticket), do: :ok

  @doc "A watched entity changed; fan out to its watchers (honoring per-watch filters)."
  def watch_update(_entity_type, _entity_id, _change), do: :ok

  @doc "An agent's presence transitioned online/offline; notify its watchers."
  def presence(_handle, _status), do: :ok
end
