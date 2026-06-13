defmodule Noizu.Context.Records do
  @moduledoc """
  Records for the context module.
  """
  require Record

  Record.defrecord(:context,
    caller: nil,
    ts: nil,
    token: nil,
    reason: nil,
    roles: nil,
    options: nil
  )
end
