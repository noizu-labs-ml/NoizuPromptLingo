# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2025 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------

defprotocol Noizu.Entity.ACL.Protocol do
  @moduledoc """
  ACL protocol is used to strip/removed fields context user does not have access to.
  """
  @fallback_to_any true
  @spec restrict(for :: term, entity :: term, settings :: term, context :: term, options :: term) ::
          {:ok, any} | {:error, any}
  def restrict(for, entity, acl_settings, context, options)
end

defimpl Noizu.Entity.ACL.Protocol, for: [Any] do
  def restrict(for, entity, settings, context, options)

  def restrict(:read, entity, _, _, _) do
    {:ok, entity}
  end
end
