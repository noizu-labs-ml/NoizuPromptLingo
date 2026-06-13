# -------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2023 Noizu Labs, Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.StateMachineTest do
  use ExUnit.Case, async: false

  require Noizu.StateMachine.Records
  import Noizu.StateMachine.Records

  @moduletag :wip_sm

  describe "State" do
    test "acceptance" do
      h = Noizu.TestSM.initialize(:default)
      nsm(modules: m, global: g) = Agent.get(h, &(&1))
      assert g == Noizu.TestSM.scenario(:default)
      assert m[Noizu.TestSM.Foo] == Noizu.TestSM.Foo.scenario(:default)
      assert m[Noizu.TestSM.Boo] == Noizu.TestSM.Boo.scenario(:default)
    end

    test "e2e" do
      h = Noizu.TestSM.StateTest.initialize(:default)
      nsm = nsm(handle: h)
      assert Noizu.TestSM.StateTest.test(nsm, :next) == {:one, :next}
      Noizu.TestSM.StateTest.Alpha.test(nsm, :next) == {:local, {:one, :one, :next}}
      Noizu.TestSM.StateTest.Alpha.test(nsm, :keep) == {:local, {:one, :two, :next}}
      Noizu.TestSM.StateTest.Alpha.test(nsm, :next_global) == {:local, {:one, :two, :next}}
      Noizu.TestSM.StateTest.Alpha.test(nsm, :next) == {:local, {:two, :two, :next}}
      Noizu.TestSM.StateTest.Alpha.test(nsm, :keep) == {:local, {:two, :one, :next}}
    end

  end

  describe "Meta Methods" do
    test "acceptance" do
      assert Noizu.TestSM.__nsm_info__(:modules) == [Noizu.TestSM.Foo,Noizu.TestSM.Boo]
    end
  end

  describe "Scenario Support" do
    test "fall through logic" do
      assert Noizu.TestSM.scenario(:other) == %{bop: :bop, flag_2: :first_wrapper_inner_wrapper, flag_3: 3840, foo: 1}
      assert Noizu.TestSM.scenario(:default) == %{bop: :bop, flag_2: :first_wrapper_inner_wrapper, flag_3: 3840, foo: 1}
      assert Noizu.TestSM.scenario(:scenario_one) == %{bop: :fiz, flag_2: :first_wrapper_inner_wrapper, flag_3: 3840, foo: 1}

      assert Noizu.TestSM.Foo.scenario(:other) == %{bop: :bop, flag_2: :local, flag_3: 3840, foo: 1}
      assert Noizu.TestSM.Foo.scenario(:default) == %{bop: :bop, flag_2: :local, flag_3: 3840, foo: 1}
      assert Noizu.TestSM.Foo.scenario(:scenario_two) == %{bop: :fizzy_time, flag_2: :local, flag_3: 3840, foo: 1}

      assert Noizu.TestSM.Boo.scenario(:other) == %{}
      assert Noizu.TestSM.Boo.scenario(:default) == %{}
      assert Noizu.TestSM.Boo.scenario(:scenario_two) == %{bop: :fizzy_time, flag_2: :local, flag_3: 3840, foo: 1}
      assert Noizu.TestSM.Boo.scenario(:scenario_three) == %{bop: :fizzy_time, flag_2: :local, flag_3: 3840, foo: 1}


    end
  end

  describe "verify Module nesting" do
    test "acceptance pass" do

      assert :ok_module_2_1_b == Noizu.TestSM.Foo.__nsm_def__well(
               nsm(global: %{flag_2: :first_wrapper_inner_wrapper, foo: 1, bop: :fiz}, local: %{flag: :first_wrapper, bop: :boop}),
               :not_second_a_when_guard,
               :second_b_when_guard,
               :c_alternative,
               5
             )
      assert :module_catch_all == Noizu.TestSM.Foo.__nsm_def__well(
               nsm(global: %{flag_2: :first_wrapper_inner_wrapper, foo: 1, bop: :fiz}, local: %{flag: :not_first_wrapper, bop: :boop}),
               66,
               :second_b_when_guard,
               :second_c_arg_guard,
               5
             )

    end
  end

  describe "verify statemachine state sections" do
    test "global/default implementations" do
      assert :ok_1 == Noizu.TestSM.__nsm_def__well(
               nsm(global: %{flag: 1}, local: %{flag: true}),
               :first_a_when_guard,
               :first_b_when_guard,
               :first_c_arg_guard,
               5
             )

      # Insure not incorrectly matched when not all guards met
      assert :catch_all == Noizu.TestSM.__nsm_def__well(
               nsm(global: %{flag: false, flag_2: :first_wrapper_inner_wrapper, foo: :error, bop: :fiz}, local: %{flag: :first_wrapper, bop: :boop}),
               :alt_second_a_when_guard,
               :second_b_when_guard,
               :second_c_arg_guard,
               5
             )

      assert :catch_all == Noizu.TestSM.__nsm_def__well(
               nsm(global: %{flag_2: :first_wrapper_inner_wrapper, foo: 1, bop: :fiz}, local: %{flag: :not_first_wrapper, bop: :boop}),
               66,
               :second_b_when_guard,
               :second_c_arg_guard,
               5
             )
    end

    test "state_behaviour(nsm(local: %{flag: :first_wrapper})) when (global.foo in [1,2,3] or global.flag == true) : defaults" do

      assert {:ok_2, self(), 999} == Noizu.TestSM.__nsm_def__well(
               nsm(global: %{flag_2: :first_wrapper_inner_wrapper, foo: 1, bop: :not_fiz, flag_3: 0xF00}, local: %{flag: :first_wrapper, flag_3: 31337, bop: :boop}),
               999,
               :second_b_when_guard,
               :not_c_alternative,
               5
             )
      assert {:ok_2_catch_all, self(), 99} == Noizu.TestSM.__nsm_def__well(
               nsm(global: %{flag_2: :first_wrapper_inner_wrapper, foo: 1, bop: :not_fiz, flag_3: 0xF00}, local: %{flag: :first_wrapper, flag_3: 31337, bop: :boop}),
               99,
               :second_b_when_guard,
               :not_c_alternative,
               5
             )
    end

    test "state -> nested" do


      assert :ok_2_1 == Noizu.TestSM.__nsm_def__well(
               nsm(global: %{flag_2: :first_wrapper_inner_wrapper, foo: 1, bop: :fiz}, local: %{flag: :first_wrapper, bop: :boop}),
               :second_a_when_guard,
               :second_b_when_guard,
               :second_c_arg_guard,
               5
             )
      assert :ok_2_1 == Noizu.TestSM.__nsm_def__well(
               nsm(global: %{flag_2: :first_wrapper_inner_wrapper, foo: 1, bop: :fiz}, local: %{flag: :first_wrapper, bop: :boop}),
               :alt_second_a_when_guard,
               :second_b_when_guard,
               :second_c_arg_guard,
               5
             )
      assert :ok_2_1 == Noizu.TestSM.__nsm_def__well(
               nsm(global: %{flag: true, flag_2: :first_wrapper_inner_wrapper, foo: :error, bop: :fiz}, local: %{flag: :first_wrapper, bop: :boop}),
               :alt_second_a_when_guard,
               :second_b_when_guard,
               :second_c_arg_guard,
               5
             )


      assert :ok_2_1_b == Noizu.TestSM.__nsm_def__well(
               nsm(global: %{flag_2: :first_wrapper_inner_wrapper, foo: 1, bop: :fiz}, local: %{flag: :first_wrapper, bop: :boop}),
               :not_second_a_when_guard,
               :second_b_when_guard,
               :c_alternative,
               5
             )

      assert {:ok_2_1_1, self(), 1} == Noizu.TestSM.__nsm_def__well(
               nsm(global: %{flag_2: :first_wrapper_inner_wrapper, foo: 1, bop: :fiz, flag_3: 0xF00}, local: %{flag: :first_wrapper, flag_3: 31337, bop: :boop}),
               1,
               :second_b_when_guard,
               :not_c_alternative,
               5
             )

      assert {:ok_2_1_catch_all, self(), 99} == Noizu.TestSM.__nsm_def__well(
               nsm(global: %{flag_2: :first_wrapper_inner_wrapper, foo: 1, bop: :fiz, flag_3: 0xF00}, local: %{flag: :first_wrapper, flag_3: 31337, bop: :boop}),
               99,
               :second_b_when_guard,
               :not_c_alternative,
               5
             )
    end

    test "state -> nested -> nested" do

      assert {:ok_2_1_1x, self(), 1} == Noizu.TestSM.__nsm_def__well(
               nsm(global: %{flag_2: :first_wrapper_inner_wrapper, foo: 1, bop: :fiz, flag_3: 0xF00, flag_5: :sentinel}, local: %{flag: :first_wrapper, flag_3: 31337, bop: :boop}),
               1,
               :second_b_when_guard,
               :not_c_alternative,
               5
             )

      assert {:ok_2_1_1, self(), 1} == Noizu.TestSM.__nsm_def__well(
               nsm(global: %{flag_2: :first_wrapper_inner_wrapper, foo: 1, bop: :fiz, flag_3: 0xF00}, local: %{flag: :first_wrapper, flag_3: 31337, bop: :boop}),
               1,
               :second_b_when_guard,
               :not_c_alternative,
               5
             )
    end
  end
end
