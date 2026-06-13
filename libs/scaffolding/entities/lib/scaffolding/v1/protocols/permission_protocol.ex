#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defprotocol Noizu.Permissions do
  @doc "Check with object to determine if user has required permission"
  def has_permission(obj, permission, context, options \\ %{})

  @doc "Check with object to determine if user has required permission"
  def has_permission!(obj, permission, context, options \\ %{})

end # end defprotocol Noizu.ERP

#-------------------------------------------------------------------------------
# Useful default implementations
#-------------------------------------------------------------------------------
defimpl Noizu.Permissions, for: List do
  def has_permission(entities, permission, context, options \\ nil) do
    for obj <- entities do
      Noizu.Permissions.has_permission(obj, permission, context, options)
    end
  end

  def has_permission!(entities, permission, context, options \\ nil) do
    for obj <- entities do
      Noizu.Permissions.has_permission!(obj, permission, context, options)
    end
  end
end # end defimpl EntityReferenceProtocol, for: List

defimpl Noizu.Permissions, for: Tuple do
  def has_permission(ref, permission, context, options \\ nil) do
    case ref do
      {:ref, manager, _identifier} when is_atom(manager)->
        manager.has_permission(ref, permission, context, options)
      {:ext_ref, manager, _identifier} when is_atom(manager) ->
        manager.has_permission(ref, permission, context, options)
    end
  end

  def has_permission!(ref, permission, context, options \\ nil) do
    case ref do
      {:ref, manager, _identifier} when is_atom(manager)->
        manager.has_permission!(ref, permission, context, options)
      {:ext_ref, manager, _identifier} when is_atom(manager) ->
        manager.has_permission!(ref, permission, context, options)
    end
  end
end # end defimpl EntityReferenceProtocol, for: Tuple
