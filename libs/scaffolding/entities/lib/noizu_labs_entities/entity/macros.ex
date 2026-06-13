# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2023 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.Entity.Macros do
  @moduledoc """
  This module provides macros for defining entities and their fields.
  """
  require Noizu.Entity.Meta.Identifier
  require Noizu.Entity.Meta.Field
  require Noizu.Entity.Meta.Json
  require Noizu.Entity.Meta.ACL
  require Noizu.Entity.Meta.Persistence

  require Noizu.Entity.Macros.Json
  require Noizu.Entity.Macros.ACL

  defmacro jason_encoder(_opts \\ nil) do
    quote do
      defimpl Jason.Encoder do
        def encode(s, {_, _, user_settings} = opts) do
          json_format = user_settings[:json_format] || :default

          settings =
            cond do
              x = Noizu.Entity.Meta.json(s)[json_format] -> x
              x = Noizu.Entity.Meta.json(s)[:default] -> x
            end

          Noizu.Entity.Json.Protocol.prep(
            s,
            settings,
            user_settings[:context],
            user_settings[:settings]
          )
          |> Jason.Encode.map(opts)
        end

        def encode(s, {_, _} = opts) do
          settings = Noizu.Entity.Meta.json(s)[:default]
          Noizu.Entity.Json.Protocol.prep(s, settings, Noizu.Context.system(), [])
          |> Jason.Encode.map(opts)
        end
      end
    end
  end

  # ----------------------------------------
  # def_entity
  # ----------------------------------------
  defmacro def_entity(do: block) do
    quote do
      import Noizu.Entity.Macros,
        only: [
          {:id, 1},
          {:id, 2},
          {:field, 1},
          {:field, 2},
          {:field, 3},
          {:field, 4},
          {:transient, 1},
          {:pii, 1},
          {:pii, 2},
          {:jason_encoder, 0},
          {:jason_encoder, 1}
        ]

      require Noizu.Entity.Meta.Identifier
      require Noizu.Entity.Meta.Field
      require Noizu.Entity.Meta.Json
      require Noizu.Entity.Meta.ACL
      require Noizu.Entity.Meta.Persistence
      require Noizu.Entity.Macros.Json
      require Noizu.Entity.Macros.ACL

      Noizu.Entity.Macros.register_attributes(__MODULE__)

      # Persistence
      Noizu.Entity.Macros.extract_persistence()

      # Repo
      Noizu.Entity.Macros.extract_repo()

      # Sref
      Noizu.Entity.Macros.extract_sref()

      # Set Fields
      unquote(block)

      # --------------------------
      # Default Fields
      # --------------------------
      declared = Module.get_attribute(__MODULE__, :__nz_fields, [])

      unless Noizu.Entity.Macros.field_set?(:vsn, declared) do
        field(:vsn, Module.get_attribute(__MODULE__, :vsn, 1.0))
      end

      unless Noizu.Entity.Macros.field_set?(:meta, declared) do
        field(:meta, nil)
      end

      unless Noizu.Entity.Macros.field_set?(:__transient__, declared) do
        @transient true
        field(:__transient__, nil)
      end

      # --------------------------
      # Emit Struct
      # --------------------------
      @derive Noizu.EntityReference.Protocol
      Module.get_attribute(__MODULE__, :__nz_fields, [])
      |> Noizu.Entity.Macros.prepare_struct()
      |> defstruct

      # --------------------------
      # Noizu.Entity Behavior
      # --------------------------
      {vsn, nz_meta} =
        Noizu.Entity.Macros.inject_entity_impl(
          @__nz_ids,
          @__nz_persistence,
          @__nz_fields,
          @__nz_json,
          @__nz_acl,
          @__nz_repo,
          @__nz_sref
        )

      @vsn vsn
      @nz_meta nz_meta
      def vsn(), do: @vsn
      def __noizu_meta__(), do: @nz_meta

      # ERP Hooks
      Noizu.Entity.Macros.erp(@__nz_ids)
    end
  end

  # ----------------------------------------
  #
  # ----------------------------------------
  defmacro extract_simple(attribute, attribute_default, default \\ false) do
    quote bind_quoted: [
            attribute: attribute,
            attribute_default: attribute_default,
            default: default
          ] do
      case Module.get_attribute(__MODULE__, attribute, {:attribute, :blank}) do
        {:attribute, :blank} ->
          Module.get_attribute(__MODULE__, attribute_default, default)

        x ->
          Module.delete_attribute(__MODULE__, attribute)
          x
      end
    end
  end

  # ==========================================================
  # def_entity macros
  # ==========================================================

  @doc """
  Todo support different id types
  """
  defmacro erp(ids) do
    quote do
      require Noizu.Entity.Meta
      require Noizu.Entity.Meta.Identifier
      alias Noizu.Entity.Meta, as: Meta

      @erp_type_handlers %{
        uuid: Noizu.Entity.Meta.UUIDIdentifier,
        integer: Noizu.Entity.Meta.IntegerIdentifier,
        atom: Noizu.Entity.Meta.AtomIdentifier,
        ref: Noizu.Entity.Meta.RefIdentifier,
        dual_ref: Noizu.Entity.Meta.DualRefIdentifier
      }

      @erp_type_handler (case unquote(ids) do
                           [{:id, Meta.Identifier.id_settings(type: type)}] ->
                             @erp_type_handlers[type] || type
                         end)

      def kind(ref),
        do: @erp_type_handler.kind(__MODULE__, ref)

      def id(ref),
        do: @erp_type_handler.id(__MODULE__, ref)

      def ref(ref),
        do: @erp_type_handler.ref(__MODULE__, ref)

      def sref(ref),
        do: @erp_type_handler.sref(__MODULE__, ref)

      def entity(ref, context),
        do: @erp_type_handler.entity(__MODULE__, ref, context)

      def stub(),
        do: {:ok, %__MODULE__{}}

      def stub(ref, _, _) do
        with {:ok, id} <- __MODULE__.id(ref) do
          {:ok, %__MODULE__{id: id}}
        end
      end

      defoverridable kind: 1,
                     id: 1,
                     ref: 1,
                     sref: 1,
                     entity: 2,
                     stub: 0,
                     stub: 3
    end
  end

  defmacro common() do
    quote do
      def id(_), do: :nyi
    end
  end

  # ----------------------------------------
  # id
  # ----------------------------------------
  defmacro id(type, opts \\ []) do
    name = opts[:name] || :id

    quote do
      Module.put_attribute(
        __MODULE__,
        :__nz_ids,
        {unquote(name),
         Noizu.Entity.Meta.Identifier.id_settings(
           name: unquote(name),
           type: unquote(type)
         )}
      )

      Module.put_attribute(
        __MODULE__,
        :__nz_fields,
        {unquote(name), Noizu.Entity.Meta.Field.field_settings(name: unquote(name), default: nil)}
      )
    end
  end

  # ----------------------------------------
  # field
  # ----------------------------------------
  defmacro field(name, default \\ nil, type \\ nil, opts \\ []) do
    quote bind_quoted: [name: name, type: type, default: default, opts: opts] do
      Noizu.Entity.Macros.Json.extract_json(name)
      acl = {field, field_acl} = Noizu.Entity.Macros.ACL.extract_acl(name)
      Module.put_attribute(__MODULE__, :__nz_acl, acl)

      reported_type =
        case type do
          nil ->
            nil

          x
          when x in [
                 :integer,
                 :float,
                 :string,
                 :boolean,
                 :binary,
                 :date,
                 :time,
                 :naive_datetime,
                 :utc_datetime,
                 :utc_datetime_usec,
                 :uuid,
                 :map,
                 :array,
                 :decimal,
                 :json,
                 :jsonb,
                 :any
               ] ->
            {:ecto, x}

          {:enum, values} = x ->
            {:ecto, x}

          {:array, _} = x ->
            {:ecto, x}

          _ ->
            type
        end

      # Extract any storage attributes.
      store =
        case Noizu.Entity.Macros.extract_simple(:store, :store_default, []) do
          v when is_list(v) ->
            Enum.map(
              v,
              fn
                {store, settings} ->
                  {store, settings}

                settings ->
                  case @__nz_persistence do
                    [store | _] ->
                      Noizu.Entity.Meta.Persistence.persistence_settings(store: store) = store
                      {store, settings}
                  end
              end
            )

          _ ->
            nil
        end

      # Extract any config attributes
      config =
        case Noizu.Entity.Macros.extract_simple(:config, :config_default, []) do
          v when is_list(v) ->
            Enum.map(
              v,
              fn
                v when is_list(v) -> v
                {config, settings} -> {config, settings}
                _ -> nil
              end
            )
            |> Enum.reject(&is_nil/1)
            |> List.flatten()

          _ ->
            nil
        end ++ (opts || [])

      Module.put_attribute(
        __MODULE__,
        :__nz_fields,
        {
          name,
          Noizu.Entity.Meta.Field.field_settings(
            name: name,
            default: default,
            store: store,
            type: reported_type,
            pii: Noizu.Entity.Macros.extract_simple(:pii, :pii_default),
            transient: Noizu.Entity.Macros.extract_simple(:transient, :transient_default),
            acl: field_acl,
            options: config
          )
        }
      )
    end
  end

  # ----------------------------------------
  # transient
  # ----------------------------------------
  defmacro transient(do: block) do
    quote do
      Noizu.Entity.Macros.push_attribute_queue(
        __MODULE__,
        :transient_default,
        :transient_default_queue,
        true
      )

      unquote(block)

      Noizu.Entity.Macros.pop_attribute_queue(
        __MODULE__,
        :transient_default,
        :transient_default_queue
      )
    end
  end

  # ----------------------------------------
  # pii
  # ----------------------------------------
  defmacro pii(level \\ :sensitive, do: block) do
    quote do
      Noizu.Entity.Macros.push_attribute_queue(
        __MODULE__,
        :pii_default,
        :pii_default_queue,
        unquote(level)
      )

      unquote(block)
      Noizu.Entity.Macros.pop_attribute_queue(__MODULE__, :pii_default, :pii_default_queue)
    end
  end

  # ==========================================================
  # internal macros
  # ==========================================================

  # ----------------------------------------
  #
  # ----------------------------------------
  def push_attribute_queue(module, a_d, a_d_q, value) do
    q = [value | Module.get_attribute(module, a_d_q, [])]
    Module.put_attribute(module, a_d_q, q)
    Module.put_attribute(module, a_d, value)
  end

  # ----------------------------------------
  #
  # ----------------------------------------
  def pop_attribute_queue(module, a_d, a_d_q) do
    with [_ | t] <- Module.get_attribute(module, a_d_q, []) do
      Module.put_attribute(module, a_d_q, t)

      with [h | _] <- t do
        Module.put_attribute(module, a_d, h)
      else
        _ ->
          Module.delete_attribute(module, a_d)
      end
    else
      _ ->
        # invalid
        Module.delete_attribute(module, a_d_q)
        Module.delete_attribute(module, a_d)
    end
  end

  # ----------------------------------------
  #
  # ----------------------------------------
  defmacro extract_persistence() do
    quote do
      case Noizu.Entity.Macros.extract_simple(:persistence, :persistence, []) do
        v when is_list(v) ->
          layers =
            Enum.map(
              v,
              fn x ->
                case x do
                  Noizu.Entity.Meta.Persistence.persistence_settings(kind: nil) ->
                    Noizu.Entity.Meta.Persistence.persistence_settings(x, kind: __MODULE__)

                  Noizu.Entity.Meta.Persistence.persistence_settings() ->
                    x

                  _ ->
                    nil
                end
              end
            )
            |> Enum.filter(& &1)

          Module.put_attribute(__MODULE__, :__nz_persistence, layers)

        _ ->
          Module.put_attribute(__MODULE__, :__nz_persistence, [])
      end
    end
  end

  # ----------------------------------------
  #
  # ----------------------------------------
  defmacro extract_repo() do
    quote do
      case Noizu.Entity.Macros.extract_simple(:repo, :repo, []) do
        v when is_atom(v) ->
          Module.put_attribute(__MODULE__, :__nz_repo, v)

        _ ->
          cond do
            Application.compile_env(:noizu_labs_entities, :legacy_mode) ->
              Module.put_attribute(__MODULE__, :__nz_repo, Module.concat([__MODULE__, Repo]))

            :else ->
              repo =
                Module.split(__MODULE__)
                |> Enum.slice(0..-2//1)
                |> Module.concat()

              Module.put_attribute(__MODULE__, :__nz_repo, repo)
          end
      end
    end
  end

  # ----------------------------------------
  #
  # ----------------------------------------
  defmacro extract_sref() do
    quote do
      case Noizu.Entity.Macros.extract_simple(:sref, :sref, nil) do
        v when is_bitstring(v) ->
          Module.put_attribute(__MODULE__, :__nz_sref, v)

        _ ->
          Module.put_attribute(__MODULE__, :__nz_sref, nil)
      end
    end
  end

  # ----------------------------------------
  #
  # ----------------------------------------
  def register_attributes(mod) do
    Module.register_attribute(mod, :__nz_ids, accumulate: true)
    Module.register_attribute(mod, :__nz_fields, accumulate: true)
    Module.register_attribute(mod, :__nz_persistence, accumulate: false)
    Module.register_attribute(mod, :__nz_repo, accumulate: false)
    Module.register_attribute(mod, :__nz_sref, accumulate: false)
    Module.register_attribute(mod, :store, accumulate: true)
    Module.register_attribute(mod, :config, accumulate: true)
    Noizu.Entity.Macros.Json.register_attributes(mod)
    Noizu.Entity.Macros.ACL.register_attributes(mod)
  end

  # ----------------------------------------
  #
  # ----------------------------------------
  def field_set?(field, declared_fields) do
    get_in(declared_fields, [field])
  end

  # ----------------------------------------
  #
  # ----------------------------------------
  def prepare_struct(fields) do
    fields
    |> Enum.map(fn {name, Noizu.Entity.Meta.Field.field_settings(default: dv)} -> {name, dv} end)
    |> Enum.reverse()
  end

  # ----------------------------------------
  #
  # ----------------------------------------
  def inject_entity_impl(
        v__nz_ids,
        v__nz_persistence,
        v__nz_fields,
        v__nz_json,
        v__nz_acl,
        v__nz_repo,
        v__nz_sref
      ) do
    # v__nz_fields = Module.get_attribute(module, :__nz_fields, [])
    Noizu.Entity.Meta.Field.field_settings(default: vsn) = get_in(v__nz_fields, [:vsn])
    # Module.put_attribute(module, :vsn, vsn)

    # __noizu_meta__\0
    nz_entity__persistence = Enum.reverse(v__nz_persistence)
    nz_entity__fields = Enum.reverse(v__nz_fields)
    # v__nz_ids = Module.get_attribute(module, :__nz_ids, [])
    nz_entity__id =
      case(v__nz_ids) do
        [x] -> x
        x -> Enum.reverse(x)
      end

    # (Module.get_attribute(module, :__nz_json, [])
    nz_entity__json =
      v__nz_json
      |> Noizu.Entity.Macros.Json.expand_json_settings(nz_entity__fields)

    # todo this should be done in function close.
    acl =
      Enum.map(
        v__nz_acl,
        fn
          {field, [nz: :inherit]} ->
            with Noizu.Entity.Meta.Field.field_settings(transient: t, pii: p) <-
                   nz_entity__fields[field] do
              x =
                cond do
                  t ->
                    Noizu.Entity.Meta.ACL.acl_settings(
                      target: :entity,
                      type: :role,
                      requirement: [:admin, :system]
                    )

                  p in [:sensitive, :private] ->
                    Noizu.Entity.Meta.ACL.acl_settings(
                      target: :entity,
                      type: :role,
                      requirement: [:user, :admin, :system]
                    )

                  :else ->
                    Noizu.Entity.Meta.ACL.acl_settings(
                      target: :entity,
                      type: :unrestricted,
                      requirement: :unrestricted
                    )
                end

              {field, x}
            end

          {field, x} ->
            {field, x}
        end
      )

    changeset_fields =
      Enum.map(
        v__nz_fields,
        fn
          {field, Noizu.Entity.Meta.Field.field_settings(type: {:ecto, type})} ->
            {field, type}

          {field, _} ->
            {field, :any}
        end
      )
      |> Map.new()

    nz_meta = %{
      id: nz_entity__id,
      fields: nz_entity__fields,
      json: nz_entity__json,
      persistence: nz_entity__persistence,
      acl: acl,
      repo: v__nz_repo,
      sref: v__nz_sref,
      changeset_fields: changeset_fields
    }

    # Module.put_attribute(module, :nz_meta, nz_meta)
    {vsn, nz_meta}
  end
end
