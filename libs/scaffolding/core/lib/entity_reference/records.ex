defmodule Noizu.EntityReference.Records do
  @moduledoc """
  ERP record.
  """

  require Record
  Record.defrecord(:ref, module: nil, id: nil)
end
