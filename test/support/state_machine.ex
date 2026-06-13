
defmodule Noizu.TestSM do
  use Noizu.StateMachine

  @apple 5

  @scenariodoc """
  Alternative Scenario - One
  """
  scenario_initial_state :scenario_one do
    %{flag_2: :first_wrapper_inner_wrapper, foo: 1, bop: :fiz, flag_3: 0xF00}
  end

  @scenariodoc """
  Alternative Scenario - Default
  """
  scenario_initial_state :default do
    %{flag_2: :first_wrapper_inner_wrapper, foo: 1, bop: :bop, flag_3: 0xF00}
  end

  defsm_module Foo do
    @scenariodoc """
    Default Scenario (FOO) - Default
    """
    scenario_initial_state :default do
      %{flag_2: :local, foo: 1, bop: :bop, flag_3: 0xF00}
    end


    @scenariodoc """
    Alternative Scenario (FOO) - Two
    """
    scenario_initial_state :scenario_two do
      %{flag_2: :local, foo: 1, bop: :fizzy_time, flag_3: 0xF00}
    end

  end

  defsm_module Boo do

    @scenariodoc """
    Alternative Scenario (FOO) - Two - NO DEFAULT
    """
    scenario_initial_state :scenario_two do
      %{flag_2: :local, foo: 1, bop: :fizzy_time, flag_3: 0xF00}
    end


    @scenariodoc """
    Alternative Scenario (FOO) - Three
    """
    scenario_initial_state :scenario_three do
      scenario(:scenario_two)
    end
  end

  defsm well(a,b,c,d \\ 7)
  defsm well(a,b,:first_c_arg_guard, _) when a in [:first_a_when_guard] and b == :first_b_when_guard do
    :ok_1
  end

  for_state "state 2" ~> nsm(local: %{flag: :first_wrapper}) when (global.foo in [@apple, 1,2,3] or global.flag == true) do

  #defsm state_behaviour(nsm(local: %{flag: :first_wrapper})) when (global.foo in [@apple, 1,2,3] or global.flag == true) do

    defsm well(a,_b, _c, _d) when a in [999] do
      {:ok_2, self(), a}
    end


    for_state "state 2.1" ~> nsm(global: %{flag_2: :first_wrapper_inner_wrapper}) when global.bop in [:fiz, :biz, :bop] and local.bop == :boop do
    #defsm state_behaviour(nsm(global: %{flag_2: :first_wrapper_inner_wrapper})) when global.bop in [:fiz, :biz, :bop] and local.bop == :boop do
      defsm well(a,b,:second_c_arg_guard, _d) when a in [:second_a_when_guard,:alt_second_a_when_guard] and b == :second_b_when_guard do
        :ok_2_1
      end

      defsm well(_a,_b,:c_alternative, _d) do
        :ok_2_1_b
      end

      defsm_module Foo do
        defsm well(_a,_b,:c_alternative, _d) do
          :ok_module_2_1_b
        end
      end

      for_state "state 2.1.1.1", nsm(global: %{flag_5: :sentinel}) when global.flag_3 == 0xF00 and local.flag_3 == 31337 do
        defsm well(a,_b,_c,_d) when a in [1,2,3,4,5] do
          {:ok_2_1_1x, self(), a}
        end
      end

      for_state "state 2.1.1.2" when global.flag_3 == 0xF00 and local.flag_3 == 31337 do
        defsm well(a,_b,_c,_d) when a in [1,2,3,4,5] do
          {:ok_2_1_1, self(), a}
        end
      end

      defsm well(a,_b,_c, _d) do
        {:ok_2_1_catch_all, self(), a}
      end
    end

    defsm well(a,_b,_c,_d) do
      {:ok_2_catch_all, self(), a}
    end


  end

  # TODO it would be cleaner to be able to place this below the initial declaration
  # And push entries outside of a state behavior to the bottom of the defs
  # Further inside of a state behavior push non nested defsm to bottom
  defsm well(_a,_b,_c,_d) do
    :catch_all
  end

  defsm_module Foo do
    defsm well(_a,_b,_c,_d) do
      :module_catch_all
    end
  end


  defsm_module Boo do
    defsm well(_a,_b,_c,_d) do
      :module_catch_all
    end
  end

end
