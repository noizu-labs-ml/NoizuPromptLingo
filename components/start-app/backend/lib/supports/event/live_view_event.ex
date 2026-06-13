defmodule Noizu.LiveViewEvent do
  require Record

  @typedoc """
  Browser session unique identifier
  """
  @type session :: term

  @typedoc """
  The top level, subject or group message is routed to.
  """
  @type subject :: term

  @typedoc """
  The specific instance, message is routed to.
  """
  @type instance :: term

  @typedoc """
  The event.
  """
  @type event :: tuple | atom

  @typedoc """
  Payload message
  """
  @type payload :: term

  @typedoc """
  Event options
  """
  @type options :: term

  @type event_msg ::
          record(:event_msg,
            subject: subject,
            instance: instance,
            event: event,
            payload: payload,
            options: options
          )
  Record.defrecord(:event_msg, subject: :*, instance: :*, event: nil, payload: nil, options: nil)

  def subscribe(group) do
    Noizu.LiveViewEventServer.subscribe(group)
  end

  def unsubscribe(group) do
    Noizu.LiveViewEventServer.unsubscribe(group)
  end

  def publish(event_msg) do
    Noizu.LiveViewEventServer.publish(event_msg)
  end

  def publish(session, event_msg) do
    Noizu.LiveViewEventServer.publish(session, event_msg)
  end
end
