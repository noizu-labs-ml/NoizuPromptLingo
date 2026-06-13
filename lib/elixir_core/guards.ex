defmodule Noizu.ElixirCore.Guards do
  @moduledoc """
  Provides guards for caller context and reference checks.

  ## Calling Context Guards

  The following guards are used to validate the caller context:
  - `is_caller_context/1`: Checks if the value is a struct of type `Noizu.ElixirCore.CallingContext`.
  - `caller_context_with_permissions/1`: Checks if the value is a caller context struct with a `permissions` map.

  The following guards are used to validate specific caller types:
  - `is_system_caller/1`: Checks if the value is a system caller with the `system` permission.
  - `is_admin_caller/1`: Checks if the value is an admin caller with the `admin` permission.
  - `is_internal_caller/1`: Checks if the value is an internal caller with the `internal` permission.
  - `is_restricted_caller/1`: Checks if the value is a restricted caller without any permissions or with the `restricted` permission set to true.

  ## Caller Permission Macros

  The following macros are used to check caller permissions:
  - `caller_permission?(term, permission)`: Checks if the given `term` has the specified `permission`.
  - `caller_permission_value?(term, permission, value)`: Checks if the given `term` has the specified `permission` with the specified `value`.

  ## Ref Guards

  The following guards are used for reference checks:
  - `is_ref/1`: Checks if the value is a reference tuple of the form `{:ref, Module, identifier}`.
  - `is_sref/1`: Checks if the value is a reference string of the form `"ref.module.identifier"`.
  - `entity_ref/1`: Checks if the value is a reference tuple, reference string, or a struct with a `vsn` field.

  # Code Review
  - The code is well-documented and follows the Elixir naming conventions.
  - The guards are defined clearly and provide useful abstractions for caller context and reference checks.

  """

  # -----------------------
  # Calling Context Guards
  # -----------------------
  defguard is_caller_context(value)
           when value != nil and is_struct(value, Noizu.ElixirCore.CallingContext)

  defguard caller_context_with_permissions(value)
           when is_caller_context(value) and is_map(value.auth) and
                  is_map_key(value.auth, :permissions) and is_map(value.auth.permissions)

  defguard is_system_caller(value)
           when caller_context_with_permissions(value) and
                  is_map_key(value.auth.permissions, :system) and
                  value.auth.permissions.system == true

  defguard is_admin_caller(value)
           when caller_context_with_permissions(value) and
                  is_map_key(value.auth.permissions, :admin) and
                  value.auth.permissions.admin == true

  defguard is_internal_caller(value)
           when caller_context_with_permissions(value) and
                  is_map_key(value.auth.permissions, :internal) and
                  value.auth.permissions.internal == true

  defguard is_restricted_caller(value)
           when not caller_context_with_permissions(value) or
                  (is_map_key(value.auth.permissions, :restricted) and
                     value.auth.permissions.restricted == true)

  defmacro caller_permission?(term, permission) do
    case __CALLER__.context do
      nil ->
        quote generated: true do
          case unquote(permission) do
            permission when is_atom(permission) or is_tuple(permission) ->
              case unquote(term) do
                %{auth: %{permissions: p}} -> p[permission]
                _ -> false
              end

            _ ->
              raise ArgumentError
          end
        end

      :match ->
        raise ArgumentError,
              "invalid expression in match, #{:has_permission?} is not allowed in patterns " <>
                "such as function clauses, case clauses or on the left side of the = operator"

      :guard ->
        quote do
          is_map(unquote(term)) and
            (is_atom(unquote(permission)) or is_tuple(unquote(permission)) or :fail) and
            :erlang.is_map_key(:auth, unquote(term)) and
            :erlang.is_map(unquote(term).auth) and
            :erlang.is_map_key(:permissions, unquote(term).auth) and
            :erlang.is_map(unquote(term).auth.permissions) and
            :erlang.is_map_key(unquote(permission), unquote(term).auth.permissions) and
            :erlang.map_get(unquote(permission), unquote(term).auth.permissions) == true
        end
    end
  end

  defmacro caller_permission_value?(term, permission, value) do
    case __CALLER__.context do
      nil ->
        quote generated: true do
          case unquote(permission) do
            permission when is_atom(permission) or is_tuple(permission) ->
              case unquote(term) do
                %{auth: %{permissions: p}} -> p[permission] === unquote(value)
                _ -> false
              end

            _ ->
              raise ArgumentError
          end
        end

      :match ->
        raise ArgumentError,
              "invalid expression in match, #{:has_permission?} is not allowed in patterns " <>
                "such as function clauses, case clauses or on the left side of the = operator"

      :guard ->
        quote do
          is_map(unquote(term)) and
            (is_atom(unquote(permission)) or is_tuple(unquote(permission)) or :fail) and
            :erlang.is_map_key(:auth, unquote(term)) and
            :erlang.is_map(unquote(term).auth) and
            :erlang.is_map_key(:permissions, unquote(term).auth) and
            :erlang.is_map(unquote(term).auth.permissions) and
            :erlang.is_map_key(unquote(permission), unquote(term).auth.permissions) and
            :erlang.map_get(unquote(permission), unquote(term).auth.permissions) ===
              unquote(value)
        end
    end
  end

  defguard permission?(context, permission) when caller_permission?(context, permission)

  defguard permission?(context, permission, value)
           when caller_permission_value?(context, permission, value)

  defguard has_call_reason?(value)
           when is_map(value) and is_map_key(value, :reason) and value.reason != :none and
                  value.reason != nil

  # -----------------------
  # Ref Guard
  # -----------------------
  defguard is_ref(value)
           when is_tuple(value) and tuple_size(value) == 3 and elem(value, 0) == :ref

  defguard is_sref(value) when is_bitstring(value) and binary_part(value, 0, 4) == "ref."

  defguard entity_ref(value)
           when is_ref(value) or is_sref(value) or
                  (is_struct(value) and is_map_key(value, :vsn) and value.vsn != nil)
end
