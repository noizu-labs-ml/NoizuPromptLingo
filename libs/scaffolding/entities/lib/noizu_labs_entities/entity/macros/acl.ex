# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2023 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.Entity.Macros.ACL do
  @moduledoc """
  This module provides macros for defining access control lists (ACLs) for entities and fields.
  """
  require Noizu.Entity.Meta.ACL
  require Noizu.Entity.Meta.Field

  # ----------------------------------------
  #
  # ----------------------------------------
  def register_attributes(mod) do
    Module.register_attribute(mod, :__nz_acl, accumulate: true)
    Module.register_attribute(mod, :restricted, accumulate: true)
  end

  # @todo implement
  def valid_path(x), do: {:ok, x}

  def valid_target(x) when x in [:entity, :field], do: {:ok, x}
  def valid_target(x), do: {:error, {:unsupported, {:target, x}}}

  # Restrict By Role
  def valid_acl(x) when is_atom(x), do: valid_acl({:role, x})
  def valid_acl({:ref, _, _} = x), do: valid_acl({:role, x})
  def valid_acl({:role, x}), do: valid_acl({:role, :entity, x})

  def valid_acl({:role, target, x}) do
    with {:ok, t} <- valid_target(target),
         true <- is_atom(x) || Kernel.match?({:ref, _, _}, x) || {:error, {:invalid, {:role, x}}} do
      s = Noizu.Entity.Meta.ACL.acl_settings(target: t, type: :role, requirement: [x])
      {:ok, s}
    end
  end

  # Restrict By Group
  def valid_acl({:group, x}), do: valid_acl({:group, :entity, x})

  def valid_acl({:group, target, x}) do
    with true <-
           is_atom(x) || Kernel.match?({:ref, _, _}, x) || {:error, {:invalid, {:group, x}}},
         {:ok, _} <- valid_target(target) do
      s = Noizu.Entity.Meta.ACL.acl_settings(target: target, type: :group, requirement: [x])
      {:ok, s}
    end
  end

  # Restrict By Permission
  def valid_acl({:permission, x}), do: valid_acl({:permission, :entity, x})

  def valid_acl({:permission, target, x}) do
    with true <-
           is_atom(x) || Kernel.match?({:ref, _, _}, x) || {:error, {:invalid, {:permission, x}}},
         {:ok, _} <- valid_target(target) do
      s = Noizu.Entity.Meta.ACL.acl_settings(target: target, type: :permission, requirement: [x])
      {:ok, s}
    end
  end

  # Restrict By MFA
  def valid_acl({m, f, a} = x) when is_atom(m) and is_atom(f) and is_list(a),
    do: valid_acl({:mfa, x})

  def valid_acl({:mfa, x}), do: valid_acl({:mfa, :entity, x})

  def valid_acl({:mfa, target, x}) do
    with {m, f, a} <- x,
         true <- (is_atom(m) && is_atom(f) && is_list(a)) || {:error, {:mfa, {:invalid, x}}},
         {:ok, _} <- valid_target(target) do
      s = Noizu.Entity.Meta.ACL.acl_settings(target: target, type: :mfa, requirement: [{m, f, a}])
      {:ok, s}
    end
  end

  # Target Parent
  def valid_acl({:parent, x}), do: valid_acl({:parent, 0, x})

  def valid_acl({:parent, depth, x}) when is_integer(depth) do
    case valid_acl(x) do
      [_ | _] -> x
      {:ok, x} -> [{:ok, x}]
    end
    |> Enum.map(fn {:ok, s = Noizu.Entity.Meta.ACL.acl_settings(type: t)}
                   when t in [:role, :group, :mfa, :permission] ->
      s2 = Noizu.Entity.Meta.ACL.acl_settings(s, target: {:parent, depth})
      {:ok, s2}
    end)
  end

  # Target Path
  def valid_acl({:path, path, x}) do
    case valid_acl(x) do
      [_ | _] -> x
      {:ok, x} -> [{:ok, x}]
    end
    |> Enum.map(fn {:ok, s = Noizu.Entity.Meta.ACL.acl_settings(type: t)}
                   when t in [:role, :group, :mfa, :permission] ->
      {:ok, _} = valid_path(path)
      s2 = Noizu.Entity.Meta.ACL.acl_settings(s, target: {:path, path})
      {:ok, s2}
    end)
  end

  # List
  def valid_acl(x) when is_list(x), do: Enum.map(x, &valid_acl(&1)) |> List.flatten()

  # Unsupported
  def valid_acl(x), do: {:error, {:unsupported, {:acl, x}}}

  def merge_acl__weight(target, type) do
    target_w =
      case target do
        :entity -> 10
        :field -> 20
        {:parent, x} -> 50 * (x + 1)
        {:path, x} -> 50 * length(x) + 30
      end

    type_w =
      case type do
        :role -> 1
        :group -> 2
        :permission -> 3
        :mfa -> 5
      end

    target_w + type_w
  end

  def merge_acl__inner([]), do: []
  def merge_acl__inner([h]), do: [h]

  def merge_acl__inner(l) when is_list(l) do
    requirements =
      Enum.map(l, &Noizu.Entity.Meta.ACL.acl_settings(&1, :requirement))
      |> List.flatten()

    template = List.first(l)
    Noizu.Entity.Meta.ACL.acl_settings(template, requirement: requirements)
  end

  def merge_acl(x) do
    x
    |> Enum.group_by(fn Noizu.Entity.Meta.ACL.acl_settings(target: x, type: y) -> {x, y} end)
    |> Enum.map(&{elem(&1, 0), merge_acl__inner(elem(&1, 1))})
    |> Enum.sort(fn {{ax, ay}, _}, {{bx, by}, _} ->
      a_w = merge_acl__weight(ax, ay)
      b_w = merge_acl__weight(bx, by)

      cond do
        a_w < b_w -> true
        :else -> false
      end
    end)
    |> Enum.map(&elem(&1, 1))
  end

  defmacro extract_acl(field) do
    quote bind_quoted: [field: field] do
      x =
        Module.get_attribute(__MODULE__, :restricted, [])
        |> Enum.map(&Noizu.Entity.Macros.ACL.valid_acl(&1))
        |> List.flatten()
        |> Enum.map(fn {:ok, x} -> x end)
        |> case do
          [] ->
            # if PII sensitive or than :user,
            # if transient then :system
            [{:nz, :inherit}]

          x when is_list(x) ->
            x
            |> Noizu.Entity.Macros.ACL.merge_acl()
        end
        |> List.flatten()
        |> then(&{field, &1})
        |> tap(fn _ -> Module.delete_attribute(__MODULE__, :restricted) end)

      # |> IO.inspect(label: "FINAL ACL")
    end
  end
end
