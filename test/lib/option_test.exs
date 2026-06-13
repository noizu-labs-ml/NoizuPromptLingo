# -------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.ElixirCore.OptionTest do
  use ExUnit.Case, async: false
  alias Noizu.ElixirCore.OptionSettings
  alias Noizu.ElixirCore.OptionValue
  alias Noizu.ElixirCore.OptionList
  require Logger

  def prepare_options(options) do
    settings = %OptionSettings{
      option_settings: %{
        not_memberset: %OptionList{
          option: :not_memberset,
          default: [:one, :two],
          valid_members: [:one, :two, :three],
          membership_set: false
        },
        member_set: %OptionList{
          option: :member_set,
          default: [:one, :two],
          valid_members: [:one, :two, :three],
          membership_set: true
        },
        single_value: %OptionValue{option: :single_value, default: :default_value},
        restricted_required_value: %OptionValue{
          option: :restricted_required_value,
          required: true,
          valid_values: [:apple]
        },
        non_restricted_required_value: %OptionValue{
          option: :non_restricted_required_value,
          required: true
        },
        mapped_value: %OptionValue{option: :mapped_value, lookup_key: :mapped_field}
      }
    }

    OptionSettings.expand(settings, options)
  end

  @tag :lib
  @tag :options
  test "basic functionality - expansion" do
    sut = prepare_options([])
    assert sut.effective_options.not_memberset == [:one, :two]
    assert sut.effective_options.member_set == %{one: true, two: true, three: false}
    assert sut.effective_options.single_value == :default_value
    assert Map.has_key?(sut.effective_options, :restricted_required_value) == false
    assert Map.has_key?(sut.effective_options, :non_restricted_required_value) == false
    assert sut.effective_options.mapped_value == nil
  end

  @tag :lib
  @tag :options
  test "basic functionality - validation" do
    sut =
      prepare_options(
        not_memberset: [:one, :apple],
        member_set: [:one, :apple],
        restricted_required_value: :not_apple,
        non_restricted_required_value: :not_henry
      )

    assert sut.effective_options.not_memberset == [:one, :apple]
    assert sut.output.errors.not_memberset == {:unsupported_members, [:apple]}

    assert sut.effective_options.member_set == %{one: true, two: false, three: false}
    assert sut.output.errors.member_set == {:unsupported_members, [:apple]}

    assert sut.effective_options.restricted_required_value == :not_apple
    assert sut.output.errors.restricted_required_value == {:unsupported_value, :not_apple}

    assert sut.effective_options.non_restricted_required_value == :not_henry
  end

  @tag :lib
  @tag :options
  test "basic functionality - mapping" do
    sut = prepare_options(mapped_field: :assigned_to_another)
    assert sut.effective_options.mapped_value == :assigned_to_another
  end
end
