
defmodule Noizu.TestSM.StateTest do
  use Noizu.StateMachine

  @scenariodoc """
  Alternative Scenario - One
  """
  scenario_initial_state :scenario_one do
    %{flag_1: 2}
  end

  @scenariodoc """
  Alternative Scenario - Default
  """
  scenario_initial_state :default do
    %{flag_1: 1}
  end

  defsm_module Alpha do
    @scenariodoc """
    Default Scenario (FOO) - Default
    """
    scenario_initial_state :default do
      %{local_flag_1: :local_1}
    end
    scenario_initial_state :scenario_one do
      %{local_flag_1: :local_2}
    end

  end



  for_state "state 1" when global.flag_1 == 1 do
    defsm test(arg) do
      {:one, arg}
    end

    defsm_module Alpha do

      for_state "local state 1.1" when local.local_flag_1 == :local_1 do
        defsm test(arg) do
          var!(nsm) = var!(nsm)
          if arg == :next do
            nsm_set_local_state([:local_flag_1], :local_2)
          end
          if arg == :next_global do
            nsm_set_global_state([:flag_1], 2)
          end
          {:local, {:one, :one, arg}}
        end
      end
      for_state "local state 1.2" when local.local_flag_1 == :local_2 do
        defsm test(arg) do
          if arg == :next do
            nsm_set_local_state([:local_flag_1], :local_1)
          end
          if arg == :next_global do
            nsm_set_global_state([:flag_1], 2)
          end
          {:local, {:one, :two, arg}}
        end
      end
    end
  end


  for_state "state 2" when global.flag_1 == 2 do
    defsm test(arg) do
      {:two, arg}
    end

    defsm_module Alpha do

      for_state "local state 2.1" when local.local_flag_1 == :local_1 do
        defsm test(arg) do
          if arg == :next do
            nsm_set_local_state([:local_flag_1], :local_2)
          end
          if arg == :next_global do
            nsm_set_global_state([:flag_1], 1)
          end
          {:local, {:two, :one, arg}}
        end
      end
      for_state "local state 2.2" when local.local_flag_1 == :local_2 do
        defsm test(arg) do
          if arg == :next do
            nsm_set_local_state([:local_flag_1], :local_1)
          end
          if arg == :next_global do
            nsm_set_global_state([:flag_1], 1)
          end
          {:local, {:two, :two, arg}}
        end
      end
    end
  end

  defsm test(arg) do
    {:error, arg}
  end

  defsm_module Alpha do

    for_state "local state catch.1" when local.local_flag_1 == :local_1 do
      defsm test(arg) do
        {:local, {:error, :one, arg}}
      end
    end
    for_state "local state catch.2" when local.local_flag_1 == :local_2 do
      defsm test(arg) do
        {:local, {:error, :two, arg}}
      end
    end
    defsm test(arg) do
      {:local, {:error, :error, arg}}
    end
  end

end
