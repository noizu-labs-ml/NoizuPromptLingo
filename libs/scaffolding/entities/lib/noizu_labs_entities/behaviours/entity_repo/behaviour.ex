defmodule Noizu.EntityRepoBehaviour do
  @moduledoc """
  Define Entity Repo Crud Behaviour.
  """

  @callback create(entity :: any, context :: any, options :: any) :: {:ok, any} | {:error, any}
  @callback update(entity :: any, context :: any, options :: any) :: {:ok, any} | {:error, any}
  @callback delete(entity :: any, context :: any, options :: any) :: {:ok, any} | {:error, any}

  @doc """
  Runtime cache sref to handler map.
  """
  def rebuild_sref_handlers(application, module) do
    mod_s = Module.split(module)
    schema_mod = Module.concat(module, "Schema") |> Module.split()
    mnesia_mod = Module.concat(module, "Mnesia") |> Module.split()

    :application.get_key(application, :modules)
    |> elem(1)
    |> Enum.reject(fn mod ->
      split = Module.split(mod)

      cond do
        List.starts_with?(split, schema_mod) -> true
        List.starts_with?(split, mnesia_mod) -> true
        List.starts_with?(split, mod_s) -> false
        :else -> true
      end
    end)
    |> Enum.map(fn m ->
      Code.ensure_loaded?(m)

      if function_exported?(m, :__noizu_meta__, 0) do
        if sref = apply(m, :__noizu_meta__, [])[:sref] do
          {sref, m}
        end
      end
    end)
    |> Enum.reject(&is_nil(&1))
    |> Map.new()
  end

  @doc """
  Implement Entity Repo Behaviour.
  """
  defmacro __using__(options \\ nil) do
    options[:application] || raise "No Application Provided"
    options[:module] || raise "No Module Provided"

    quote do
      @behaviour Noizu.EntityRepoBehaviour
      import Noizu.EntityRepoBehaviour

      @doc """
      Rebuild Sref Handlers Lookup Table
      """
      def rebuild_sref_handlers() do
        rebuild_sref_handlers(unquote(options[:application]), unquote(options[:module]))
      end

      @doc """
      Get Sref Handlers Lookup Table
      """
      def sref_handlers() do
        with :undefined <- :persistent_term.get({__MODULE__, :handlers}, :undefined) do
          if Semaphore.acquire({:sref_handlers, :lock}, 1) do
            handlers = rebuild_sref_handlers()
            :persistent_term.put({__MODULE__, :handlers}, handlers)
            Semaphore.release({:sref_handlers, :lock})
            handlers
          else
            %{}
          end
        end
      end

      @doc """
      Get Entity (pass to Repo Module for Entity)
      """
      def get(entity, context, options \\ nil)

      def get(%Ecto.Changeset{data: entity} = cs, context, options) do
        if r = Noizu.Entity.Meta.repo(entity.__struct__) do
          # Note CS not supported yet pass entity - may cause issues if get depends on mutated entity.
          apply(r, :get, [entity, context, options])
        else
          {:error, {:no_repo, entity.__struct__}}
        end
      end

      def get(entity, context, options) do
        with {:ok, kind} <- Noizu.EntityReference.Protocol.kind(entity) do
          if r = Noizu.Entity.Meta.repo(kind) do
            apply(r, :get, [entity, context, options])
          else
            {:error, {:no_repo, kind}}
          end
        else
          _ -> {:error, :no_kind}
        end
      end

      @doc """
      Create Entity (pass to Repo Module for Entity)
      """
      def create(entity, context, options \\ nil)

      def create(%Ecto.Changeset{data: entity} = cs, context, options) do
        if r = Noizu.Entity.Meta.repo(entity.__struct__) do
          apply(r, :create, [cs, context, options])
        else
          {:error, {:no_repo, entity.__struct__}}
        end
      end

      def create(entity, context, options) do
        if r = Noizu.Entity.Meta.repo(entity.__struct__) do
          apply(r, :create, [entity, context, options])
        else
          {:error, {:no_repo, entity.__struct__}}
        end
      end

      @doc """
      Update Entity (pass to Repo Module for Entity)
      """
      def update(entity, context, options \\ nil)

      def update(%Ecto.Changeset{data: entity} = cs, context, options) do
        if r = Noizu.Entity.Meta.repo(entity.__struct__) do
          apply(r, :update, [cs, context, options])
        else
          {:error, {:no_repo, entity.__struct__}}
        end
      end

      def update(entity, context, options) do
        if r = Noizu.Entity.Meta.repo(entity.__struct__) do
          apply(r, :update, [entity, context, options])
        else
          {:error, {:no_repo, entity.__struct__}}
        end
      end

      @doc """
      Delete Entity (pass to Repo Module for Entity)
      """
      def delete(entity, context, options \\ nil)

      def delete(%Ecto.Changeset{data: entity} = cs, context, options) do
        if r = Noizu.Entity.Meta.repo(entity.__struct__) do
          # NOT CS not supported yet pass entity
          apply(r, :delete, [entity, context, options])
        else
          {:error, {:no_repo, entity.__struct__}}
        end
      end

      def delete(entity, context, options) do
        if r = Noizu.Entity.Meta.repo(entity.__struct__) do
          apply(r, :delete, [entity, context, options])
        else
          {:error, {:no_repo, entity.__struct__}}
        end
      end
    end
  end
end
