# Noizu Scaffolding

This library provides some general tools to reduce some boiler plate code around working with objects, performing CRUD, auditing changes, performing basic authorization checks, and working with entity references (foreign keys). It includes various concepts previously applied to some of our private projects including blade of eternity, lacrosse alerts, and solace club.

## Additional Documentation
* [Api Documentation](http://noizu.github.io/ElixirScaffolding)

## Refs
Refs provide a universal way for database records to reference other internal or external entities. They take the form of a tuple as follows: {:ref, Entity.Module, identifier} where
Entity.Module is the type of entity we are referencing and provides a method entity(nmid) that is capable of fetching the entity referenced by the listed identifier.

This makes it straight forward for a table to reference various other entity types in a generic way. Additionally the Noizu.ERP (Entity Reference Protocol) provides a straight forward
mechanism for handling references with out knowing in advance if they have been expanded or their exact type.

The EntityReferenceProtocol (alias Noizu.ERP, as: EntityReferenceProtocol) is defined as follows:

```
  defprotocol Noizu.ERP do
    @doc "Cast to noizu reference object"
    def ref(obj)

    @doc "Cast to noizu string reference object"
    def sref(obj)

    @doc "Convert to persistence object. Options may be passed to coordinate actions like expanding embedded references."
    def record(obj, options)

    @doc "Convert to persistence object Options may be passed to coordinate actions like expanding embedded references. (With transaction wrapper if required)"
    def record!(obj, options)

    @doc "Convert to scaffolding.struct object. Options may be passed to coordinate actions like expanding embedded references."
    def entity(obj, options)

    @doc "Convert to scaffolding.struct object Options may be passed to coordinate actions like expanding embedded references. (With transaction wrapper if required)"
    def entity!(obj, options)
  end # end defprotocol Noizu.ERP
```

Where the methods ref and sref convert any participating objects into {:ref, Module, id} and "ref.module.id" format respectively;  record and record! expand a reference into whatever format is used for db persistence (where options gives us a hook to dynamically adjust how records are converted to, for example, insert linked records if needed); and finally, where entity/2 and entity!/2 will insure our reference is in entity (struct) format.

It is up to the library user to provide the defimpls needed to handle sref format strings "ref.type.identifier", along with defimpls for any structs and database classes used.
Additionally it is up to the library user to ensure that their struct classes implement the Noizu.Scaffolding.EntityBehaviour and that their structs and persistence records provide defimpls of the EntityReferenceProtocl to allow their conversion into ref, sref, record and entity format.

## AuditEngine

The Noizu.Scaffolding.RepoBehaviour will automatically make auditing calls as records are accessed and modified. This makes it very straight forward (provided an AuditEngine is defined) to generate robust audits of who has modified what and when.

A possible implementation may look like the following mnesia table and defimpl. Note how the mnesia table is setup to allow us to easily search by
entity, request token, time, or editor.

```
defmodule YourProject.AuditEngine do
  @behaviour Noizu.Scaffolding.AudingEngineBehaviour

  def audit(event, details, entity, context, note \\ nil) do  
    %MnesiaDb.AuditHistory{
      entity: EntityReferenceProtocol.ref(entity),
      event: event,
      details: details,
      time_stamp: DateTime.utc_now(),
      request_token: context.token,
      editor: EntityReferenceProtocol.ref(context.caller),
      reason: context.reason,
      note: note
    } |> MnesiaDb.AuditHistory.write
    :ok
  end

  def audit!(event, details, entity, context, note \\ nil) do
    Amnesia.Fragment.transaction do
      audit(event, details, entity, context, note)
    end
  end
end


#-----------------------------------------------------------------------------
# @AuditHistory
#-----------------------------------------------------------------------------
deftable AuditHistory,
  [:entity, :event, :details, :time_stamp, :request_token, :editor, :reason, :note],
  type: :bag,
  index: [:request, :time_stamp, :editor],
  fragmentation: [number: 5, copying: %{disk!: 1}] do
  @moduledoc """
  Audit History - Basic structure for an Audit History Table
  """
  @type t :: %AuditHistory{
    entity: Types.entity_reference, # The object being modified.
    event: atom | tuple, # the event being audited, such as create table.
    details: any, # additional details about entry
    time_stamp: DateTime.t, # utc.now() of audit entry.
    request_token: String.t, # unique token that may be used to collate all audit logs related to a specific request.
    editor: Types.entity_reference, # who made the change.
    reason: String.t | nil, # calling.context reason (if any) provided when a call was made via api.
    note: String.t | nil, # internal note about audit entry. Created when entry was created or added by a moderator later on.
  }
end # end deftable
```

## Calling Context

The Noizu.Scaffolding.CallingContext structure is used to pass information about API or related requests through out the system so that it is possible to confirm that a given caller is authorized to make changes, log who the caller was, apply global options to the request (such as expanding refs where found), and pass along a request token to allow admins to easily
collate requests across systems.

```
@type t :: %CallingContext{
  caller: tuple,
  token: String.t,
  reason: String.t,
  auth: Any,
  options: Map.t,
  vsn: float
}
```

It is left to the user to implement the logic needed to populate a CallingContext with these values. A sample implementation is below.

```
  alias Noizu.Scaffolding.CallingContext, as: CallingContext
  def default_get_context(conn, params, opts \\ %{})
  def default_get_context(conn, params, _opts) do
    token = params["request-id"] || case (get_resp_header(conn, "x-request-id")) do
      [] -> CallingContext.generate_token()
      [h|_t] -> h
    end
    reason = params["call-reason"] || case (get_req_header(conn, "x-call-reason")) do
      [] -> nil
      [h|_t] -> h
    end

    expand_refs = nil # TODO - support ability for callers to request specific expansions.
    expand_all_refs = if params["expand-all-refs"] == "true" do
      true
    else
      case get_req_header(conn, "x-expand-all-refs") do
        [] -> false
        [h|_t] -> h == "true"
      end
    end

    options = %{
      expand_refs: expand_refs,
      expand_all_refs: expand_all_refs
    }

    case Guardian.Plug.current_resource(conn) do
      auth = %{"identifier" => user_identifier} ->
        %CallingContext{
          caller: {:ref, user_identifier, SolaceBackend.Repos.UserRepo},
          token: token,
          reason: reason,
          auth: auth,
          options: options
        }
      _ ->
      %CallingContext{
        caller: unauthenticated_ref(conn),
        token: token,
        reason: reason,
        auth: nil,
        options: options
      }
    end
  end # end get_context/3

  def get_ip(conn) do
    case Plug.Conn.get_req_header(conn, "x-forwarded-for") do
      [h|_] -> h
      [] -> conn.remote_ip |> Tuple.to_list |> Enum.join(".")
      nil ->  conn.remote_ip |> Tuple.to_list |> Enum.join(".")
    end
  end # end get_ip/1

  def unauthenticated_ref(conn) do
   {:ref, System.UnauthenticatedUser, get_ip(conn)}
  end # end unauthenticated_ref/1  
```

## Noizu Mnesia Identifiers (NMIDs)
Internally we often use what I call NMIDs to allow for the creation of numerical (for look up speed) unique identifiers spread across multiple systems.
You may use any id generation logic of your choice provided it can implement the Noizu.Scaffolding.NmidBehaviour

The logic I use suffixes generated ids with a number that represents the node and, optionally, the component (long lived process) making the request. With the Mnesia backend used to track per node/component the current sequential id.  

This logic and this library in turn is likely to go through heavy revision as I finalize my BladeOfEternity/NoizuRpg codebase. The current implementation I use is similiar to the following. However a simple `UUID.(:hex)` may be used if the user is not concerned with indexing/lookup efficiency. Or even a simple mnesia backed sequencer shared between all nodes.

```
defmodule Noizu.Scaffolding.Nmid do
  @behaviour Noizu.Scaffolding.NmidBehaviour
  def generate(sed = {node_id, process}, opts \\ nil) do
    MnesiaDB.NmidGenerator.wait()

    current = case MnesiaDB.NmidGenerator.read(seq) do
      %MnesiaDB.NmidGenerator{sequence: s} -> s
      :nil -> 0
    end

    current = current + 1
    %MnesiaDB.NmidGenerator{handle: seq, sequence: current}
      |> MnesiaDB.NmidGenerator.write

    node_id = @unique_per_node_numerical_id
    component_id = @component_lookup_table[sequencer] || 1

    # calculate nmid,
    # For example, (current 3, node 2, process 1 would generate 500_302), giving us 99 possible node ids, and 999 possible component ids.
    ((node_id + (component_id*100)) + current * 100_000)
  end
end
```
