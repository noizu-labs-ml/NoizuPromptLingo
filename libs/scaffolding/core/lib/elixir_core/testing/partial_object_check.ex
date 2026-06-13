# -------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.ElixirCore.PartialObjectCheck do
  alias Noizu.ElixirCore.PartialObjectCheck.FieldConstraint

  @type t :: %__MODULE__{
          assert: :pending | :met | :unmet | :not_applicable,
          type_constraint: Noizu.ElixirCore.PartialObjectCheck.TypeConstraint.t(),
          field_constraints: %{any => Noizu.ElixirCore.PartialObjectCheck.FieldConstraint.t()}
        }

  defstruct assert: :pending,
            type_constraint: nil,
            field_constraints: nil

  def prepare(nil), do: nil
  def prepare(%__MODULE__{} = scaffolding), do: scaffolding

  def prepare(scaffolding = %{}) do
    t_c =
      cond do
        is_map(scaffolding) && !Map.has_key?(scaffolding, :__struct__) ->
          %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{constraint: {:basic, :map}}

        is_map(scaffolding) && Map.has_key?(scaffolding, :__struct__) ->
          %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{
            constraint: {:module, scaffolding.__struct__}
          }
      end

    s = (Map.has_key?(scaffolding, :__struct__) && Map.from_struct(scaffolding)) || scaffolding

    f_c =
      Enum.reduce(s, %{}, fn {k, v}, acc ->
        put_in(acc, [k], prepare_field(v))
      end)

    %__MODULE__{
      type_constraint: t_c,
      field_constraints: f_c
    }
  end

  def prepare_field({__MODULE__, opt, v}) when is_list(opt) do
    case prepare_field(v) do
      f = %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{} ->
        f = (Enum.member?(opt, :not_required) && %FieldConstraint{f | required: false}) || f
        f = (Enum.member?(opt, :any_value) && %FieldConstraint{f | value_constraint: nil}) || f
        (Enum.member?(opt, :any_type) && %FieldConstraint{f | type_constraint: nil}) || f

      v ->
        v
    end
  end

  def prepare_field({__MODULE__, :not_required}) do
    %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{
      required: false,
      type_constraint: nil,
      value_constraint: nil
    }
  end

  def prepare_field({__MODULE__, :not_required, v}) do
    case prepare_field(v) do
      f = %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{} ->
        %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{f | required: false}

      v ->
        v
    end
  end

  def prepare_field(v) do
    cond do
      is_map(v) && Map.has_key?(v, :__struct__) &&
          v.__struct__ == Noizu.ElixirCore.PartialObjectCheck.FieldConstraint ->
        v

      is_map(v) && Map.has_key?(v, :__struct__) &&
          v.__struct__ == Noizu.ElixirCore.PartialObjectCheck ->
        %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{
          required: true,
          type_constraint: nil,
          value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{constraint: v}
        }

      is_map(v) && !Map.has_key?(v, :__struct__) ->
        %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{
          required: true,
          type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{
            constraint: {:basic, :map}
          },
          value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{
            constraint: prepare(v)
          }
        }

      is_map(v) && Map.has_key?(v, :__struct__) ->
        %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{
          required: true,
          type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{
            constraint: {:module, v.__struct__}
          },
          value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{
            constraint: prepare(v)
          }
        }

      is_integer(v) ->
        %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{
          required: true,
          type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{
            constraint: {:basic, :integer}
          },
          value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{
            constraint: {:value, v}
          }
        }

      is_list(v) ->
        %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{
          required: true,
          type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{
            constraint: {:basic, :list}
          },
          value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{
            constraint: {:value, v}
          }
        }

      true ->
        %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{
          required: true,
          type_constraint: nil,
          value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{
            constraint: {:value, v}
          }
        }
    end
  end

  def check(%Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{} = c, sut) do
    Noizu.ElixirCore.PartialObjectCheck.ValueConstraint.check(c, sut)
  end

  def check(%__MODULE__{} = this, sut) do
    t = Noizu.ElixirCore.PartialObjectCheck.TypeConstraint.check(this.type_constraint, sut)
    t_c = (t && t.assert) || :not_applicable

    {f_c, f} =
      if this.field_constraints do
        Enum.reduce(this.field_constraints, {:not_applicable, %{}}, fn {k, c}, {a, acc} ->
          input =
            cond do
              is_map(sut) -> Map.get(sut, k, {Noizu.ElixirCore.PartialObjectCheck, :no_value})
              true -> {Noizu.ElixirCore.PartialObjectCheck, :no_value}
            end

          {ua, uc} =
            case c do
              checks when is_list(checks) ->
                Enum.reduce(checks, {a, []}, fn c2, {a2, acc2} ->
                  u = Noizu.ElixirCore.PartialObjectCheck.FieldConstraint.check(c2, input)
                  o = (u && u.assert) || :not_applicable

                  ua2 =
                    cond do
                      a2 == :unmet || o == :unmet -> :unmet
                      a2 == :pending || o == :pending -> :pending
                      a2 == :met || o == :met -> :met
                      true -> a2
                    end

                  {ua2, acc2 ++ [u]}
                end)

              _check ->
                uc = Noizu.ElixirCore.PartialObjectCheck.FieldConstraint.check(c, input)
                o = (uc && uc.assert) || :not_applicable

                ua =
                  cond do
                    a == :unmet || o == :unmet -> :unmet
                    a == :pending || o == :pending -> :pending
                    a == :met || o == :met -> :met
                    true -> a
                  end

                {ua, uc}
            end

          {ua, put_in(acc, [k], uc)}
        end)
      else
        {:not_applicable, this.field_constraints}
      end

    c =
      cond do
        t_c == :unmet || f_c == :unmet -> :unmet
        t_c == :pending || f_c == :pending -> :pending
        # e.g. at least one field is met, the other may be not_applicable or pending.
        t_c == :met || f_c == :met -> :met
        true -> :not_applicable
      end

    %__MODULE__{this | assert: c, type_constraint: t, field_constraints: f}
  end
end

if Application.get_env(:noizu_scaffolding, :inspect_partial_object, true) do
  # -----------------------------------------------------------------------------
  # Inspect Protocol
  # -----------------------------------------------------------------------------
  defimpl Inspect, for: Noizu.ElixirCore.PartialObjectCheck do
    import Inspect.Algebra
    @dont_expand MapSet.new([:met, :pending, :not_applicable])

    def inspect(entity, opts) do
      {seperator, end_seperator} =
        cond do
          opts.pretty && (opts.limit == :infinity || opts.limit > 200) ->
            {"#Noizu.ElixirCore.PartialObjectCheck<\n", "\n>"}

          opts.pretty ->
            {"#PartialObjectCheck<\n", "\n>"}

          opts.limit == :infinity || opts.limit > 200 ->
            {"#Noizu.ElixirCore.PartialObjectCheck<", ">"}

          true ->
            {"#PartialObjectCheck<", ">"}
        end

      assert = entity.assert
      t_c = entity.type_constraint
      f_c = entity.field_constraints

      obj =
        cond do
          opts.limit == :infinity ->
            entity |> Map.from_struct()

          opts.limit > 100 ->
            cond do
              is_map(f_c) && f_c != %{} && t_c ->
                %{assert: assert, type_constraint: t_c, field_constraints: f_c}

              is_map(f_c) && f_c != %{} ->
                %{assert: assert, field_constraints: f_c}

              t_c ->
                %{assert: assert, type_constraint: t_c}

              true ->
                %{assert: assert}
            end

          true ->
            cond do
              MapSet.member?(@dont_expand, assert) ->
                %{assert: assert}

              is_map(f_c) ->
                f_c =
                  Enum.reduce(f_c, %{}, fn {k, v}, a ->
                    (v && !MapSet.member?(@dont_expand, v.assert) && put_in(a, [k], v)) || a
                  end)

                cond do
                  # this should never happen.
                  f_c == %{} && (t_c == nil || MapSet.member?(@dont_expand, t_c.assert)) ->
                    %{assert: assert}

                  f_c == %{} ->
                    %{assert: assert, type_constraint: t_c}

                  t_c == nil || MapSet.member?(@dont_expand, t_c.assert) ->
                    %{assert: assert, field_constraints: f_c}

                  true ->
                    %{assert: assert, type_constraint: t_c, field_constraints: f_c}
                end

              true ->
                cond do
                  # this should never happen
                  t_c == nil || MapSet.member?(@dont_expand, t_c.assert) -> %{assert: assert}
                  true -> %{assert: assert, type_constraint: t_c}
                end
            end
        end

      concat(["#{seperator}", to_doc(obj, opts), "#{end_seperator}"])
    end

    # end inspect/2
  end

  # end defimpl
end
