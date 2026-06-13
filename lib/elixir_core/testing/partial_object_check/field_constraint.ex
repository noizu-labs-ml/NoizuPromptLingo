# -------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.ElixirCore.PartialObjectCheck.FieldConstraint do
  @type t :: %__MODULE__{
          assert: :pending | :met | :unmet | :not_applicable,
          required: true | false,
          type_constraint: Noizu.ElixirCore.PartialObjectCheck.TypeConstraint.t() | nil,
          value_constraint: Noizu.ElixirCore.PartialObjectCheck.ValueConstraint.t() | nil
        }

  defstruct assert: :pending,
            required: true,
            type_constraint: nil,
            value_constraint: nil

  def check(%__MODULE__{} = this, sut) do
    cond do
      sut == {Noizu.ElixirCore.PartialObjectCheck, :no_value} ->
        %__MODULE__{this | assert: (this.required && :unmet) || :not_applicable}

      true ->
        t = Noizu.ElixirCore.PartialObjectCheck.TypeConstraint.check(this.type_constraint, sut)
        v = Noizu.ElixirCore.PartialObjectCheck.ValueConstraint.check(this.value_constraint, sut)

        t_a = (t && t.assert) || :not_applicable
        v_a = (v && v.assert) || :not_applicable

        c =
          cond do
            t_a == :unmet || v_a == :unmet -> :unmet
            t_a == :pending || v_a == :pending -> :pending
            # e.g. at least one field is met, the other may be not_applicable or pending.
            t_a == :met || v_a == :met -> :met
            true -> :met
          end

        %__MODULE__{this | assert: c, type_constraint: t, value_constraint: v}
    end
  end
end

if Application.get_env(:noizu_scaffolding, :inspect_partial_object, true) do
  # -----------------------------------------------------------------------------
  # Inspect Protocol
  # -----------------------------------------------------------------------------
  defimpl Inspect, for: Noizu.ElixirCore.PartialObjectCheck.FieldConstraint do
    import Inspect.Algebra
    @dont_expand MapSet.new([:met, :pending, :not_applicable])

    def inspect(entity, opts) do
      {seperator, end_seperator} =
        cond do
          opts.pretty && (opts.limit == :infinity || opts.limit > 200) ->
            {"#Noizu.ElixirCore.PartialObjectCheck.FieldConstraint<\n", "\n>"}

          opts.pretty ->
            {"#FieldConstraint<\n", "\n>"}

          opts.limit == :infinity || opts.limit > 200 ->
            {"#Noizu.ElixirCore.PartialObjectCheck.FieldConstraint<", ">"}

          true ->
            {"#FieldConstraint<", ">"}
        end

      t_c = entity.type_constraint
      v_c = entity.value_constraint

      obj =
        cond do
          opts.limit == :infinity ->
            entity |> Map.from_struct()

          opts.limit > 100 ->
            cond do
              v_c && t_c ->
                %{
                  assert: entity.assert,
                  required: entity.required,
                  value_constraint: v_c,
                  type_constraint: t_c
                }

              v_c ->
                %{assert: entity.assert, required: entity.required, value_constraint: v_c}

              t_c ->
                %{assert: entity.assert, required: entity.required, type_constraint: t_c}

              true ->
                %{assert: entity.assert, required: entity.required}
            end

          true ->
            cond do
              MapSet.member?(@dont_expand, entity.assert) ->
                %{assert: entity.assert}

              true ->
                inject_v_c = v_c && !MapSet.member?(@dont_expand, v_c.assert)
                inject_t_c = t_c && !MapSet.member?(@dont_expand, t_c.assert)
                obj = %{assert: entity.assert, required: entity.required}
                obj = (inject_v_c && put_in(obj, [:value_constraint], v_c)) || obj
                (inject_t_c && put_in(obj, [:type_constraint], t_c)) || obj
            end
        end

      concat(["#{seperator}", to_doc(obj, opts), "#{end_seperator}"])
    end

    # end inspect/2
  end

  # end defimpl
end
