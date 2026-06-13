#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.QueryStrategy.Redis do
  @behaviour Noizu.Scaffolding.QueryBehaviour
  alias Noizu.ElixirCore.CallingContext
  require Logger

  defp get_redix_client(entity_module, options) do
    options[:redix_client] || entity_module.redix_client(options)
  end

  def match(_match_sel, _entity_module, %CallingContext{} = _context, _options) do
    throw "Match NYI"
  end

  def list(_entity_module, %CallingContext{} = _context, _options) do
    throw "List NYI"
  end

  def get(identifier, entity_module,  %CallingContext{} = _context, options) do
    client = get_redix_client(entity_module, options)
    cond do
      client ->
        identifier = entity_module.sref(identifier)
        try do
          Redix.command(client, ["GET", identifier])
        catch
          :exit, e -> {:error, {:exit, e}}
          e -> {:error, e}
        end
      true -> {:error, :no_client}
    end
  end

  def update(entity, entity_module,  %CallingContext{} = _context, options) do
    client = get_redix_client(entity_module, options)
    cond do
      client ->
        identifier = entity_module.sref(entity)
        encoded = entity_module.redis_encode(entity, options)

        try do
          cond do
            options[:ttl] -> Redix.command(client, ["SET", identifier, encoded, "EX", options[:ttl]])
            true -> Redix.command(client, ["SET", identifier, encoded])
          end
        catch
          :exit, e -> {:error, {:exit, e}}
          e -> {:error, e}
        end

      true -> {:error, :no_client}
    end
  end

  def create(entity, entity_module,  %CallingContext{} = _context, options) do
    client = get_redix_client(entity_module, options)
    cond do
      client ->
        identifier = entity_module.sref(entity)
        encoded = entity_module.redis_encode(entity, options)

        try do
          cond do
            options[:ttl] -> Redix.command(client, ["SET", identifier, encoded, "EX", options[:ttl]])
            true -> Redix.command(client, ["SET", identifier, encoded])
          end
        catch
          :exit, e -> {:error, {:exit, e}}
          e -> {:error, e}
        end

      true -> {:error, :no_client}
    end
  end

  def delete(identifier, entity_module,  %CallingContext{} = _context, options) do
    client = get_redix_client(entity_module, options)
    cond do
      client ->
        identifier = entity_module.sref(identifier)

        try do
          Redix.command(client, ["DEL", identifier])
        catch
          :exit, e -> {:error, {:exit, e}}
          e -> {:error, e}
        end

      true -> {:error, :no_client}
    end
  end
end