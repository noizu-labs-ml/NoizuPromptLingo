[logo]: assets/noizu-logo2.png "Noizu Labs, Inc."

> ![Noizu Labs][logo]

Elixir Core [![CircleCI](https://dl.circleci.com/status-badge/img/gh/noizu/ElixirCore/tree/master.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/noizu/ElixirCore/tree/master)
=============================================================================
Common protocols and convenience methods leveraged by other Noizu Labs, Inc. frameworks.

## Noizu ERP Protocol

The Noizu.ERP protocol allows ref tuples `{:ref, Entity, identifier}` to be used in place of nesting full objects in other objects. It also supports encoding/decoding those ref tuples to and from strings for use in RESTful APIs.

Behind the scenes, the ref tuple `{:ref, Module, identifier}` unpacks itself by calling into Module, which must adhere to the protocol and provide local copies of the protocol options.

Example usage:

```elixir
Noizu.ERP.entity({:ref, Noizu.ElixirCore.CallerEntity, :system}) == %Noizu.ElixirCore.CallerEntity{identifier: :system}
Noizu.ERP.ref(%Noizu.ElixirCore.CallerEntity{identifier: :system}) == {:ref, Noizu.ElixirCore.CallerEntity, :system}
Noizu.ERP.sref(%Noizu.ElixirCore.CallerEntity{identifier: :system}) == "ref.noizu-caller.system"
Noizu.ERP.ref("ref.noizu-caller.system") == {:ref, Noizu.ElixirCore.CallerEntity, :system}
Noizu.ERP.ref("george") == nil
```

The methods `[id/1, ref/1, sref/1, entity/1,2, entity!/1,2, record/1,2, record!/1,2]` may all be used interchangeably on ref strings, tuples, or actual entities without having to know in advance what type of object you are accessing.

### New Additions

Recently added `id_ok/1, ref_ok/1, sref_ok/1, entity_ok/1,2, entity_ok!/1,2` mirror `id/1, ref/1, sref/1, entity/1,2, entity!/1,2` but return `{:ok, value} | {:error, details}` in their place for use in `with` and other pattern matching scenarios.

## CallingContext

The CallingContext is a context object used to track a caller's state and permissions, along with a unique request identifier for tracking requests as they travel through the layers of your application. It is useful for log collation, permission checks, and access auditing.

The basic structure of the CallingContext object is as follows:

```elixir
%CallingContext{
  caller: {:ref, User.Entity, 1234},
  token: "ajlakjfdowpoewpfjald",
  reason: "New User Setup",
  auth: %{permissions: %{admin: true, system: true, internal: true, manage_users: true}},
  options: %{},
  time: DateTime.t | nil,
  outer_context: %CallingContext{}
}
```

### Configuration

If you have custom ACL/Authorization Bearer tokens that you want to extract your caller/permissions from, you can use the following configuration settings:

* Request ID Extraction Strategy: `{:module, :function}` or `function/2` that accepts `(conn, default)` and pulls the request ID (`CallingContext.token`) from `Plug.Conn`.

  > config :noizu_core, token_strategy: {Noizu.ElixirCore.CallingContext, :extract_token}

* Request Reason Extraction Strategy: `{:module, :function}` or `function/2` that accepts `(conn, default)` and pulls the request reason (`CallingContext.reason`) from `Plug.Conn`.

  > config :noizu_core, token_strategy: {Noizu.ElixirCore.CallingContext, :extract_reason}

* Request Caller Extraction Strategy: `{:module, :function}` or `function/2` that accepts `(conn, default)` and pulls the request caller (`CallingContext.caller`) from `Plug.Conn`.

  > config :noizu_core, get_plug_caller: {Noizu.ElixirCore.CallingContext, :extract_caller}

* Request Caller's Auth Map Extraction Strategy: `{:module, :function}` or `function/2` that accepts `(conn, default)` and returns the effective permission map (`ContextCaller.auth`).

  > config :noizu_core, acl_strategy: {Noizu.ElixirCore.CallingContext, :default_auth}


Alternatively, you can extract the caller and effective permission list map on your own and use the following functions:

* `Noizu.ElixirCore.CallingContext.new_conn(your_caller, your_caller_auth_map, %Plug.Conn{}, options)`
* `Noizu.ElixirCore.CallingContext.new(your_caller, your_caller_auth_map, options)`

### Examples

#### Creation

Create a new Calling Context with the default Admin user and permissions.

> Noizu.ElixirCore.CallingContext.admin()

Create a new Calling Context with the default System user and permissions.

> Noizu.ElixirCore.CallingContext.system()

Create a new Calling Context with the default Internal user and permissions.

> Noizu.ElixirCore.CallingContext.internal()

Create a new Calling Context with the default Restricted user and permissions.

> Noizu.ElixirCore.CallingContext.restricted()

Create a new context by pulling the request caller, auth map, token, and reason from Plug.Conn using user-provided extract methods.

> Noizu.ElixirCore.CallingContext.new_conn(conn, options)

#### Logging

Add context metadata to Logger. Example: `[context_token: context.token, context_time: context.time, context_caller: context.caller] ++ context.options.log_filter`

> Noizu.ElixirCore.CallingContext.meta_update(context)

Strip context metadata from Logger.

> Noizu.ElixirCore.CallingContext.meta_strip(context)

Get context metadata to append to Logger.

> Logger.info("Your Log", Noizu.ElixirCore.CallingContext.metadata(context))

#### Guards Extensions

Check if the context has admin, internal, system, or restricted auth flags, etc.

```elixir
cond do
  is_admin_caller(context) -> :admin
  is_system_caller(context) -> :system
  is_internal_caller(context) -> :internal
  is_restricted_caller(context) -> :restricted
  permission?(context, :manage_users) -> :caller_can_manage_users
  permission?(context, :security_level, 5) -> :caller_has_level_5_clearance
  has_call_reason?(context) -> :context_has_call_reason
end
```

##### Custom Guards

Some custom guards are provided to make authentication checks and code readability cleaner:

| Custom Guard | Purpose |
| --- | --- |
| is_caller_context(context) | Check if the variable is a `%CallingContext{}` struct |
| caller_context_with_permissions(context) | Check if the variable is a `%CallingContext{}` struct with `context.auth.permissions` map |
| is_system_caller(context) | Check if the context has system-level permission |
| is_admin_caller(context) | Check if the context has admin-level permission |
| is_internal_caller(context) | Check if the context has internal-level permission |
| is_restricted_caller(context) | Check if the context has restricted-level permission |
| permission?(context, check) | Check if the context has the specified permission with a truthy value |
| permission?(context, check, value) | Check if the context has the specified permission with a specific value |
| has_call_reason?(context) | Check if the context's `call_reason` is set |
| is_ref(value) | Check if the object is a `{:ref, entity, id}` tuple |
| is_sref(value) | Check if the object is a "ref.code-name.id" string reference |
| entity_ref(value) | Check if the object is a ref tuple or struct type with a `vsn` field |

## Option Helper

Option helpers make it easier to define restricted/optional requirements and default constraints for use in metaprogramming or parameter acceptance. The following test snippet provides a detailed example of how to use option helpers:

[Test code example](test/lib/option_test.exs)

## Testing Utility - Partial Object Check

Partial Object checks allow you to compare two objects based on specific fields, with the ability to restrict allowed values or specify optional fields. This is useful for creating custom assert methods that only check specific fields of an object. The Partial Object Check scans the whole object and reports all constraint violations at once.

Here are some code examples of how to use the Partial Object Check utility:

[Test code example](test/lib/partial_object_check_test.exs)

## Convenience Structs

Noizu.ElixirCore.CallerEntity: Represents a caller entity with an identifier.

Noizu.ElixirCore.UnauthenticatedCallerEntity: Represents an unauthenticated caller entity.

Feel free to explore the code and leverage these convenient functionalities in your projects!
