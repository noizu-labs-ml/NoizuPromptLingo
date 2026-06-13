defmodule Noizu.FastGlobalTest do
  use ExUnit.Case, async: true
  @moduletag lib: :fast_global
  @moduletag priority: 0

  def default_cache_value(has_lock?) do
    (has_lock? && :foo) || {:fast_global, :no_cache, :bar}
  end

  describe "FastGlobal Core" do
    test "coordinate put| race condition" do
      case = :test_coordinate_put_two

      Task.async_stream(
        0..100,
        fn _ ->
          Noizu.FastGlobal.Cluster.put(case, :hello, %{})
          Noizu.FastGlobal.Cluster.get(case, :apple, %{})
        end,
        max_concurrency: 64,
        timeout: 60_000
      )
      |> Enum.map(& &1)

      r = Noizu.FastGlobal.Cluster.get(case, fn -> :wait end)
      assert r == :hello

      Noizu.FastGlobal.Cluster.put(case, :hello2, %{})
      r = Noizu.FastGlobal.Cluster.get(case, fn -> :wait end)
      assert r == :hello2
    end

    test "coordinate put" do
      case = :test_coordinate_put_one
      Noizu.FastGlobal.Cluster.put(case, :hello, %{})

      r = Noizu.FastGlobal.Cluster.get(case, fn -> :wait end)
      assert r == :hello

      Noizu.FastGlobal.Cluster.put(case, :hello2, %{})
      r = Noizu.FastGlobal.Cluster.get(case, fn -> :wait end)
      assert r == :hello2
    end

    test "lock_conditional_default_value: lock not obtained" do
      case = :im_a_little_tea_pot
      assert Semaphore.acquire({:fg_write_record, case}, 1) == true

      r = Noizu.FastGlobal.Cluster.get(case, &__MODULE__.default_cache_value/1)
      assert r == :bar

      r = Noizu.FastGlobal.Cluster.get(case, :apple)
      assert r == :apple

      r = Noizu.FastGlobal.Cluster.get(case, &__MODULE__.default_cache_value/1)
      assert r == :bar

      assert Semaphore.acquire({:fg_write_record, case}, 1) == false
      Semaphore.release({:fg_write_record, case})
    end

    test "lock_conditional_default_value: lock obtained" do
      case = :short_and_stout
      r = Noizu.FastGlobal.Cluster.get(case, &__MODULE__.default_cache_value/1)
      assert r == :foo

      # Even though FG has not completed yet the system will use the non dynamic stubbed response until fg write completes.
      r =
        Noizu.FastGlobal.Cluster.get(case, :fg_still_in_progress, %{
          back_pressure: %{fg_get_queue: 1}
        })

      assert r == :fg_still_in_progress

      # System will wait for a /0 default value provider before returning
      r = Noizu.FastGlobal.Cluster.get(case, fn -> :apple end)
      assert r == :foo

      r = Noizu.FastGlobal.Cluster.get(case, :apple2)
      assert r == :foo

      r = Noizu.FastGlobal.Cluster.get(case, &__MODULE__.default_cache_value/1)
      assert r == :foo

      lock =
        cond do
          v = Semaphore.acquire({:fg_write_record, case}, 1) ->
            v

          :else ->
            Process.sleep(25)
            r = Noizu.FastGlobal.Cluster.get(case, fn -> :apple end)
            assert r == :foo
            Process.sleep(25)
            Semaphore.acquire({:fg_write_record, case}, 1)
        end

      assert lock == true
      Semaphore.release({:fg_write_record, case})
    end

    test "lock_conditional_default_value: arity/0 with cache, lock not obtained" do
      case = :this_is_the_test_that_never_ends
      assert Semaphore.acquire({:fg_write_record, case}, 1) == true

      r = Noizu.FastGlobal.Cluster.get(case, fn -> :it_goes_on_and_on_my_friends end)
      assert r == :it_goes_on_and_on_my_friends

      r = Noizu.FastGlobal.Cluster.get(case, :apple)
      assert r == :apple

      assert Semaphore.acquire({:fg_write_record, case}, 1) == false
      Semaphore.release({:fg_write_record, case})
    end

    test "lock_conditional_default_value: arity/0 with cache, with lock" do
      case = :some_people_started_testing_it

      r = Noizu.FastGlobal.Cluster.get(case, fn -> :not_knowing_what_it_was end)
      assert r == :not_knowing_what_it_was

      r = Noizu.FastGlobal.Cluster.get(case, :too_fast)
      assert r == :too_fast

      # use &/0 default to wait on FG to complete.
      r = Noizu.FastGlobal.Cluster.get(case, fn -> :apple end)
      assert r == :not_knowing_what_it_was

      lock =
        cond do
          v = Semaphore.acquire({:fg_write_record, case}, 1) ->
            v

          :else ->
            Process.sleep(25)
            r = Noizu.FastGlobal.Cluster.get(case, fn -> :apple end)
            assert r == :not_knowing_what_it_was
            Process.sleep(25)
            Semaphore.acquire({:fg_write_record, case}, 1)
        end

      assert lock == true
      Semaphore.release({:fg_write_record, case})
    end

    test "lock_conditional_default_value: arity/0 no cache, lock not obtained" do
      case = :and_they_said_this_is_the_test_that_never_ends
      assert Semaphore.acquire({:fg_write_record, case}, 1) == true

      r =
        Noizu.FastGlobal.Cluster.get(case, fn ->
          {:fast_global, :no_cache, :it_goes_on_and_on_my_friends}
        end)

      assert r == :it_goes_on_and_on_my_friends

      r = Noizu.FastGlobal.Cluster.get(case, :apple)
      assert r == :apple

      r = Noizu.FastGlobal.Cluster.get(case, :bapple)
      assert r == :bapple

      assert Semaphore.acquire({:fg_write_record, case}, 1) == false
      Semaphore.release({:fg_write_record, case})
    end

    test "lock_conditional_default_value: arity/0 no cache, with lock" do
      case = :some_people_started_testing_it_not_knowing_what_it_was

      r =
        Noizu.FastGlobal.Cluster.get(case, fn ->
          {:fast_global, :no_cache, :and_theyre_still_testing_it}
        end)

      assert r == :and_theyre_still_testing_it

      # The default value is non cached flow above will immediately release the lock so the default value is updated here.
      r = Noizu.FastGlobal.Cluster.get(case, :still_apple)
      assert r == :still_apple

      r = Noizu.FastGlobal.Cluster.get(case, fn -> :still_apple end)
      assert r == :still_apple

      r = Noizu.FastGlobal.Cluster.get(case, fn -> :bapple end)
      assert r == :still_apple

      assert Semaphore.acquire({:fg_write_record, case}, 1) == true
      Semaphore.release({:fg_write_record, case})
    end
  end
end
