# -------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.ElixirCore.PartialObjectCheck.TypeConstraint do
  @type t :: %__MODULE__{
          assert: :met | :unmet | :pending | :not_applicable,
          constraint: nil | {:basic, atom} | {:module, atom} | list | fun
        }

  defstruct assert: :pending,
            constraint: nil

  defp perform_check(check, sut) do
    case check do
      # basic types
      nil ->
        :not_applicable

      {:basic, nil} ->
        (sut == nil && :met) || :unmet

      {:basic, :integer} ->
        (is_integer(sut) && :met) || :unmet

      {:basic, :bitstring} ->
        (is_bitstring(sut) && :met) || :unmet

      {:basic, :list} ->
        (is_list(sut) && :met) || :unmet

      {:basic, :map} ->
        (is_map(sut) && :met) || :unmet

      {:module, m} ->
        (is_map(sut) && Map.get(sut, :__struct__) == m && :met) || :unmet

      m when is_atom(m) ->
        ((sut == m || (is_map(sut) && Map.get(sut, :__struct__) == m)) && :met) || :unmet

      m when is_function(m, 1) ->
        (m.(sut) && :met) || :unmet

      l when is_list(l) ->
        Enum.reduce(l, :unmet, fn x, acc ->
          case perform_check(x, sut) do
            :met -> :met
            :not_applicable -> (acc != :met && :not_applicable) || acc
            _ -> acc
          end
        end)

      _ ->
        throw("#{__MODULE__}.perform_check #{inspect(check)} not supported")
    end
  end

  def check(nil, _sut), do: nil

  def check(%__MODULE__{} = this, sut) do
    %__MODULE__{this | assert: perform_check(this.constraint, sut)}
  end
end

if Application.get_env(:noizu_scaffolding, :inspect_partial_object, true) do
  # -----------------------------------------------------------------------------
  # Inspect Protocol
  # -----------------------------------------------------------------------------
  defimpl Inspect, for: Noizu.ElixirCore.PartialObjectCheck.TypeConstraint do
    import Inspect.Algebra
    @dont_expand MapSet.new([:met, :pending, :not_applicable])

    def inspect(entity, opts) do
      {seperator, end_seperator} =
        cond do
          opts.pretty && (opts.limit == :infinity || opts.limit > 200) ->
            {"#Noizu.ElixirCore.PartialObjectCheck.TypeConstraint<\n", "\n>"}

          opts.pretty ->
            {"#TypeConstraint<\n", "\n>"}

          opts.limit == :infinity || opts.limit > 200 ->
            {"#Noizu.ElixirCore.PartialObjectCheck.TypeConstraint<", ">"}

          true ->
            {"#TypeConstraint<", ">"}
        end

      obj =
        cond do
          opts.limit == :infinity ->
            entity |> Map.from_struct()

          opts.limit > 100 ->
            entity |> Map.from_struct()

          true ->
            cond do
              MapSet.member?(@dont_expand, entity.assert) -> %{assert: entity.assert}
              true -> entity |> Map.from_struct()
            end
        end

      concat(["#{seperator}", to_doc(obj, opts), "#{end_seperator}"])
    end

    # end inspect/2
  end

  # end defimpl
end
