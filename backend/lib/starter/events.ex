defmodule Starter.Events do
  require Logger

  @type_list [
    :user_registered,
    :user_verified,
    :org_created,
    :org_member_added,
    :org_member_removed,
    :org_member_role_changed
  ]

  def dispatch(event_type, payload) when event_type in @type_list do
    Logger.info("Event dispatched: #{event_type}")
    Phoenix.PubSub.broadcast(Starter.PubSub, "events", {event_type, payload})
  end

  def dispatch(event_type, _payload) do
    Logger.warning("Unknown event type: #{event_type}")
    :ok
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Starter.PubSub, "events")
  end
end
