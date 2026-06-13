# -------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.FastGlobal.Cluster do
  @moduledoc """
  The `Noizu.FastGlobal.Cluster` module provides functionality for handling global data in a distributed cluster.

  # Functionality
  - `get_settings/0`: Retrieves the settings for the FastGlobal cluster.
  - `sync_record__write/4`: Writes a record to the FastGlobal cluster.
  - `sync_record/4`: Retrieves a record from the FastGlobal cluster.
  - `get/1`: Retrieves the value for a given identifier from the FastGlobal cluster.
  - `get/2`: Retrieves the value for a given identifier from the FastGlobal cluster with a default value.
  - `get/3`: Retrieves the value for a given identifier from the FastGlobal cluster with a default value and options.
  - `get_record/1`: Retrieves a record for a given identifier from the FastGlobal cluster.
  - `put/3`: Puts a value into the FastGlobal cluster.
  - `put/4`: Puts a value into the FastGlobal cluster with options.
  - `coordinate_put/4`: Coordinates the put operation in the FastGlobal cluster.

  # Code Review

  - 📚 Readability: The code is well-documented and includes clear explanations of each function's purpose and steps. The comments and documentation help understand the code's behavior and usage. 👍

  - 🧾 Best practices: The code follows Elixir best practices, such as using pattern matching, proper error handling, and appropriate function naming. It adheres to the conventions and guidelines of the Elixir language. 👍

  - ⚙ Code Efficiency: The code demonstrates efficient approaches, such as acquiring semaphore locks for exclusive access, parallel processing of updates on different nodes, and handling synchronization in a distributed cluster. The implementation appears to be optimized for performance. 👍

  - 👷‍♀️ Maintainability:
    - The code is relatively easy to maintain due to its clear structure, proper documentation, and adherence to best practices.
      However, there are some areas of complexity, such as nested `cond` clauses, which could benefit from refactoring to
      improve readability and maintainability. Consider breaking down complex sections into separate functions or
      improving pattern matching. 👌
    - Code Complexity: The code exhibits moderate complexity, mainly due to nested conditionals and a few long functions.
      Refactoring some of the more complex sections can further improve code maintainability and readability.
  - 👮 Safety/Security: The code includes appropriate error handling and logging, which helps identify potential issues and ensures error-free execution. It demonstrates good practices for handling distributed operations and maintaining data consistency. The code appears to be safe and secure. 👍

  - 🎪 Other: The code provides good modularity and separation of concerns by using separate functions for different operations. It follows a clear and logical structure, making it easy to understand and navigate. The use of protocols and well-defined interfaces adds flexibility and extensibility to the codebase. 👍


  Here's the updated grade for Noizu.FastGlobal.Cluster:

  ```nlp-grade
  grade:
  - rubrix: 📚=95,🧾=90,⚙=90,👷‍♀️=80,👮=90,🎪=90
  ```
  """

  @vsn 1.0
  alias Noizu.FastGlobal.Record
  require Logger

  # -------------------
  # get_settings/0
  # -------------------
  @doc """
  Retrieves the settings for the FastGlobal cluster.

  # Returns
  The settings for the FastGlobal cluster.

  # Implementation
  The logic for the `get_settings/0` function in the `Noizu.FastGlobal.Cluster` module is as follows:

  1. It first tries to retrieve the settings by calling the `FastGlobal.get/2` function with the `:fast_global_settings`
  identifier and a default value of an empty map `%{}`.
  2. If the retrieval is successful and the value is not equal to the default value, it returns the settings.
  3. If the retrieval fails or the value is equal to the default value, it logs a warning message and returns an empty
  map `%{}` as the default settings.

  The logic is designed this way to ensure that the settings for the FastGlobal cluster are retrieved correctly.
  By using the `FastGlobal.get/2` function with a default value, it provides a fallback in case the settings are not
  present or cannot be retrieved. Logging a warning message helps in identifying potential issues with the settings.
  Returning an empty map as the default settings ensures that there is always a valid value to work with, even if
  the actual settings are not available.

  # Code Review

  """
  def get_settings() do
    get(
      :fast_global_settings,
      fn ->
        try do
          with :ok <- Noizu.FastGlobal.Database.Settings.wait(100) do
            case Noizu.FastGlobal.Database.Settings.read!(:fast_global_settings) do
              %Noizu.FastGlobal.Database.Settings{value: v} ->
                v

              _ ->
                Logger.warn("""
                [Noizu.FastGlobal.Cluster]: setting value not set or readable. Try
                ```Elixir
                 %Noizu.FastGlobal.Database.Settings{identifier: :fast_global_settings, value: %{}}
                 |> Noizu.FastGlobal.Database.Settings.write!()
                ```
                """)

                {:fast_global, :no_cache, %{}}
            end
          else
            error ->
              Logger.warn("[Noizu.FastGlobal.Cluster]: Not Loaded #{inspect(error)}")
              {:fast_global, :no_cache, %{}}
          end
        rescue
          _e -> {:fast_global, :no_cache, %{}}
        catch
          _e -> {:fast_global, :no_cache, %{}}
        end
      end
    )
  end

  # -------------------
  # sync_record__write
  # -------------------
  @doc """
  Writes a record to the FastGlobal cluster.

  ## Parameters
  - `identifier`: The identifier for the record.
  - `value`: The value to be written.
  - `options`: Additional options for the write.
  - `_tsup`: Task Supervisor (optional).


  ## Implementation
  The logic for the `sync_record__write/4` function in the `Noizu.FastGlobal.Cluster` module is as follows:

  1. It takes an `identifier`, `value`, `options`, and an optional task supervisor (`_tsup`) as input.
  2. It logs a warning message indicating that a write operation is being performed for the given identifier.
  3. It retrieves the cluster settings by calling the `get_settings/0` function.
  4. It determines the origin node for the write operation based on the options or the cluster settings.
  5. It performs the following steps based on the origin node:
   - If the origin node is the current node, it calls the `get_record/1` function to retrieve the existing record for the identifier.
   - If the origin node is different from the current node, it uses RPC to call the `get_record/1` function on the origin node to retrieve the existing record.
  6. If there is an error during the retrieval of the existing record, it sets the record to `nil`.
  7. Based on the result of the record retrieval, it performs the following steps:
   - If the record is not `nil`, it updates the existing record with the new value and other information such as the revision and timestamp.
   - If the record is `nil`, it creates a new record with the identifier, origin node, pool of nodes, value, revision, and timestamp.
  8. It uses a semaphore to ensure exclusive access to the identifier for the write operation.
  9. It performs the write operation by calling the `put/3` function to update the record in the FastGlobal cluster.
  10. It handles the result of the write operation and logs a warning message indicating that the write operation is complete.

  The logic is designed this way to handle the synchronization of writing a record in the FastGlobal cluster across multiple nodes in a distributed cluster. By retrieving the existing record and updating it or creating a new record, it ensures that the most up-to-date information is stored in the cluster. The use of a semaphore helps to manage concurrent write operations and prevent conflicts. The warning messages provide visibility and monitoring of the write operations.
  """
  def sync_record__write(identifier, value, options, task_supervisor)

  def sync_record__write(identifier, value, options, _tsup) do
    Logger.warn("[Noizu.FastGlobal.Cluster] Write: #{identifier}")

    settings =
      cond do
        identifier == :fast_global_settings -> %{}
        :else -> get_settings()
      end

    origin = options[:origin] || settings[:origin]

    try do
      cond do
        origin == node() ->
          get_record(identifier)

        :else ->
          timeout = options[:timeout][:get_record] || 15_000
          :rpc.call(origin, __MODULE__, :get_record, [identifier], timeout)
      end
    rescue
      _e -> nil
    catch
      _e -> nil
    end
    |> case do
      record = %Record{} ->
        put(identifier, record)

      _ ->
        pool =
          [node() | options[:pool] || Node.list()]
          |> Enum.uniq()

        record = %Record{
          identifier: identifier,
          origin: origin || node(),
          pool: pool,
          value: value,
          revision: 1,
          ts: :os.system_time(:millisecond)
        }

        [local | remote] =
          Enum.map(
            record.pool,
            fn target ->
              cond do
                target == node() ->
                  Task.async(fn -> put(identifier, record) end)

                :else ->
                  Task.async(fn ->
                    cond do
                      options[:fg][:local_only] ->
                        :skip

                      options[:fg][:sync] ->
                        :rpc.call(
                          target,
                          Noizu.FastGlobal.Cluster,
                          :put,
                          [identifier, record],
                          :infinity
                        )

                      :else ->
                        :rpc.cast(target, Noizu.FastGlobal.Cluster, :put, [identifier, record])
                    end
                  end)
              end
            end
          )

        timeout = options[:timeout][:put_record] || 600_000

        shutdown_after =
          cond do
            v = options[:timeout][:wait_record] -> v
            is_integer(timeout) -> timeout * 2
            :else -> timeout
          end

        r =
          [local | remote]
          |> Task.yield_many(timeout)
          |> Enum.map(fn {task, res} ->
            cond do
              res ->
                {task, res}

              task == local ->
                {task, Task.await(task, :infinity)}

              :else ->
                # {task, Task.shutdown(task, shutdown_after)}
                :ignore
            end
          end)

        Logger.warn("[Noizu.FastGlobal.Cluster] Write Complete: #{identifier}")
    end
  rescue
    _e -> nil
  catch
    _e -> nil
  end

  # -------------------
  # sync_record
  # -------------------
  @doc """
  Retrieves a record from the FastGlobal cluster.

  ## Parameters
  - `identifier`: The identifier for the record.
  - `default`: The default value to be returned if the record is not found.
  - `options`: Additional options for the retrieval.
  - `tsup`: Task Supervisor (optional).

  ## Description
  This function retrieves a record from the FastGlobal cluster.

  # Implementation
  The `sync_record/4` function in the `Noizu.FastGlobal.Cluster` module is responsible for retrieving a record from the FastGlobal cluster.

  1. It first checks if a semaphore lock can be acquired for the given `identifier`. If it can, it proceeds to the next step. If not, it returns the default value.

  2. It then checks if the record exists in the FastGlobal cluster. If it does, it returns the value of the record.

  3. If the record is not found, it checks the type of the `default` value provided:
   - If `default` is a function that takes one argument, it calls the function with `false` as the argument and returns the result.
   - If `default` is a function that takes no arguments, it calls the function and returns the result.
   - If `default` is not a function, it simply returns the `default` value.

  4. If the semaphore lock can be acquired for the `identifier`, it waits for a certain period of time specified in the `options` before attempting to write the record to the cluster. This is to avoid multiple simultaneous write operations.

  5. After the specified wait period, it calls the `sync_record__write/4` function to write the record to the FastGlobal cluster.

  6. If the write operation is successful, it releases the semaphore lock and returns the value of the record.

  7. If any errors occur during the process, it returns `nil`.

  In summary, `sync_record/4` retrieves a record from the FastGlobal cluster and handles cases where the record is not found or needs to be written to the cluster. It ensures that only one write operation is performed at a time to avoid conflicts.

  """
  def sync_record(identifier, default, options, tsup \\ nil) do
    if Semaphore.acquire({:fg_write_record, identifier}, 1) do
      cond do
        is_function(default, 1) -> default.(:has_lock)
        is_function(default, 0) -> default.()
        :else -> default
      end
      |> case do
        {:fast_global, :no_cache, value} ->
          # todo deal with back pressure to avoid hitting ets to hard here.
          Semaphore.release({:fg_write_record, identifier})
          value

        value ->
          cond do
            tsup == false ->
              if w = options[:fg][:write_wait] do
                try do
                  sync_record__write(identifier, value, options, tsup)
                rescue
                  _ -> :swallow
                catch
                  :exit, _ -> :swallow
                  _ -> :swallow
                end

                Semaphore.release({:fg_write_record, identifier})
              else
                spawn(fn ->
                  try do
                    sync_record__write(identifier, value, options, tsup)
                    Semaphore.release({:fg_write_record, identifier})
                  rescue
                    _ -> :swallow
                  catch
                    :exit, _ -> :swallow
                    _ -> :swallow
                  end
                end)
              end

            :else ->
              tsup = tsup || Noizu.FastGlobal.Cluster

              t =
                Task.Supervisor.async_nolink(
                  tsup,
                  fn ->
                    task =
                      Task.Supervisor.async_nolink(
                        tsup,
                        fn ->
                          sync_record__write(identifier, value, options, tsup)
                        end
                      )

                    timeout = options[:timeout][:fg] || 700_000

                    shutdown =
                      cond do
                        v = options[:timeout][:fg_halt] -> v
                        is_integer(timeout) -> timeout * 5
                        :else -> timeout
                      end

                    o = Task.yield(task, timeout)
                    o = o || Task.yield(task, shutdown)

                    o =
                      o ||
                        Logger.error("[Noizu.FastGlobal.Cluster] Timeout on write: #{identifier}")

                    # No shutdown just let it proceed so it is eventually populated.
                    Semaphore.release({:fg_write_record, identifier})
                  end
                )

              if w = options[:fg][:write_wait] do
                timeout =
                  cond do
                    w == true -> :infinity
                    :else -> w
                  end

                Task.yield(t, timeout)
              end
          end

          value
      end
    else
      cond do
        is_function(default, 1) -> default.(false)
        is_function(default, 0) -> default.()
        :else -> default
      end
      |> case do
        {:fast_global, :no_cache, value} -> value
        value -> value
      end
    end
  end

  # -------------------
  # get
  # -------------------
  @doc """
  Retrieves the value for a given identifier from the FastGlobal cluster with a default value and options.

  ## Parameters
  - `identifier`: The identifier for the value.
  - `default`: The default value to be returned if the value is not found.
  - `options`: Additional options for the retrieval.

  ## Implementation
  The logic for the `get/1` function in the `Noizu.FastGlobal.Cluster` module is as follows:

  1. It first tries to retrieve the value for the given identifier from the FastGlobal cluster using the `FastGlobal.get/1` function.
  2. If the value is found, it returns the value.
  3. If the value is not found, it checks if a default value is provided.
   - If a default value is provided, it returns the default value.
   - If a default value is not provided, it performs the following steps:
     - It acquires a semaphore lock to ensure exclusive access to the identifier.
     - It checks if there is a default value provider function. If there is, it calls the function and returns the result.
     - If there is no default value provider function, it waits for a certain period of time to acquire the semaphore lock.
     - If the semaphore lock is acquired, it releases the semaphore lock and performs the following steps:
       - It retrieves the value for the identifier from the FastGlobal cluster again.
       - If the value is found, it returns the value.
       - If the value is still not found, it calls the `sync_record/4` function to synchronize the record in the cluster.
       - If there is an error during the synchronization, it returns the error.
     - If the semaphore lock is not acquired, it returns the default value.

  The logic is designed this way to efficiently retrieve values from the FastGlobal cluster while ensuring that only one process can update the record at a time to avoid conflicts. It also provides flexibility by allowing the use of default values and handling different scenarios such as back pressure and timeouts.
  """
  def get(identifier, default \\ nil, options \\ %{}) do
    case FastGlobal.get(identifier, :no_match) do
      %Record{value: v} ->
        v

      :no_match ->
        cond do
          Semaphore.acquire({:fg_write_record, identifier}, 1) ->
            Semaphore.release({:fg_write_record, identifier})
            sync_record(identifier, default, options, options[:tsup])

          !is_function(default) ->
            # Currently updating record, simply return default value to avoid multiple calls.
            case default do
              {:fast_global, :no_cache, v} -> v
              v -> v
            end

          is_function(default, 1) ->
            # lock state aware default value provider.
            case default.(false) do
              {:fast_global, :no_cache, v} -> v
              v -> v
            end

          Semaphore.acquire(
            {:fg_write_record_wait, identifier},
            options[:back_pressure][:fg_get_queue] || 500
          ) ->
            # force request to pool briefly while we wait for the write operation to complete
            # to avoid additional db overhead.
            # @todo improve Back pressure handling here.
            Process.sleep(10 + :rand.uniform(25))
            Semaphore.release({:fg_write_record_wait, identifier})
            wait = options[:back_pressure][:fg_get_queue_wait] || 100
            wait = wait + :rand.uniform(div(wait, 3))

            cond do
              wait > 50 ->
                Enum.reduce_while(0..div(wait, 25), false, fn _, _ ->
                  cond do
                    Semaphore.acquire({:fg_write_record, identifier}, 1) ->
                      {:halt, true}

                    :else ->
                      Process.sleep(25)
                      {:cont, false}
                  end
                end)

              :else ->
                Process.sleep(wait)
                Semaphore.acquire({:fg_write_record, identifier}, 1)
            end
            |> then(fn mutex ->
              if mutex || Semaphore.acquire({:fg_write_record, identifier}, 1) do
                Semaphore.release({:fg_write_record, identifier})

                case FastGlobal.get(identifier, :no_match) do
                  %Record{value: v} -> v
                  :no_match -> sync_record(identifier, default, options)
                  error -> error
                end
              else
                # in case the semaphore is released before we reach fg_write insure response here is not cached
                # / does not overwrite existing update.
                case default.() do
                  {:fast_global, :no_cache, v} -> v
                  v -> v
                end
              end
            end)

          :else ->
            if Semaphore.acquire({:fg_write_record_timeout, :global}, 1) do
              spawn(fn ->
                Logger.error(
                  "[Noizu.FastGlobal.Cluster] Pool Overflowing on FG write #{inspect(identifier)}"
                )

                Process.sleep(100)
                Semaphore.release({:fg_write_record_timeout, :global})
              end)
            end

            # in case the semaphore is released before we reach fg_write insure response here is not cached
            # / does not overwrite existing update.
            case default.() do
              v = {:fast_global, :no_cache, _} -> v
              v -> {:fast_global, :no_cache, v}
            end
        end

      error ->
        error
    end
  end

  # -------------------
  # get_record/1
  # -------------------
  @doc """
  Retrieves a record for a given identifier from the FastGlobal cluster.

  ## Parameters
  - `identifier`: The identifier for the record.

  ## Implementation
  Pass through to FastGlobal.get

  """
  def get_record(identifier), do: FastGlobal.get(identifier)

  # -------------------
  # put/3
  # -------------------

  @doc """
  Puts a value into the FastGlobal cluster.

  ## Parameters
  - `identifier`: The identifier for the value.
  - `value`: The value to be put into the cluster.

  ## Implementation
  The `put/3` function in the `Noizu.FastGlobal.Cluster` module is used to put a value into the FastGlobal cluster. Here is a concise explanation of how it works:

  1. Retrieve cluster settings.
  2. If the put origin is the current node, coordinate the put operation in the cluster using `coordinate_put/4`.
  3. If the origin is different, send an RPC message to the origin node to perform the put operation.
  4. In `coordinate_put/4`, update or create a record with the identifier and value.
  5. Acquire semaphores for exclusive access to write and update operations.
  6. Coordinate the put operation by putting the record into the cluster and updating local copies on other nodes.
  7. Release semaphores.
  8. Return the result of the put operation.

  The reason for this approach is to ensure that the put operation is performed consistently across the cluster and to handle cases where the origin of the put operation is different from the current node. By coordinating the put operation and updating the record in a synchronized manner, the FastGlobal cluster can maintain data consistency and handle distributed updates efficiently.

  """
  def put(identifier, value, options \\ %{})

  def put(identifier, %Record{} = record, _options) do
    FastGlobal.put(identifier, record)
  end

  def put(identifier, value, options) do
    settings = get_settings()
    origin = options[:origin] || settings[:origin] || node()

    cond do
      origin == node() ->
        coordinate_put(identifier, value, settings, options)

      origin == nil ->
        :error

      true ->
        :rpc.cast(origin, Noizu.FastGlobal.Cluster, :coordinate_put, [
          identifier,
          value,
          settings,
          options
        ])
    end
  end

  # -------------------
  # coordinate_put
  # -------------------
  @doc """
  Coordinates the put operation in the FastGlobal cluster.

  ## Parameters
  - `identifier`: The identifier for the value.
  - `value`: The value to be put into the cluster.
  - `settings`: The cluster settings.
  - `options`: Additional options for the put operation.

  ## Implementation
  The logic for the `coordinate_put/4` function in the `Noizu.FastGlobal.Cluster` module is as follows:

  1. It takes the identifier, value, cluster settings, and additional options as inputs.
  2. It checks if a record for the identifier already exists in the FastGlobal cluster.
   - If a record exists, it updates the record with the new value, origin, pool, revision, and timestamp.
   - If a record does not exist, it creates a new record with the identifier, origin, pool, value, revision, and timestamp.
  3. It acquires a semaphore lock to ensure exclusive access to the identifier for updating.
  4. It acquires a nested semaphore lock to ensure that write operations are not executed concurrently.
  5. It waits for a certain period of time to acquire the semaphore lock.
  6. If the semaphore lock is acquired, it performs the following steps:
   - It spawns asynchronous tasks to handle the update operation on each node in the cluster.
   - For the local node, it calls the `put/3` function to update the record.
   - For remote nodes, it sends an RPC call or cast to the corresponding node to update the record.
  7. It waits for the tasks to complete and returns the result.
  8. If there is an error during the update process, it logs an error message.

  The logic is designed this way to coordinate the put operation in a distributed cluster environment.
  It ensures that only one process can update the record at a time to avoid conflicts and inconsistencies.
  By acquiring semaphore locks, it provides synchronization and prevents concurrent write operations.
  The use of asynchronous tasks allows for parallel processing of updates on different nodes in the cluster,
  improving performance and scalability.
  """
  def coordinate_put(identifier, value, settings, options) do
    update =
      case get_record(identifier) do
        %Record{} = record ->
          pool = options[:pool] || settings[:pool] || Node.list()
          pool = ([node()] ++ pool) |> Enum.uniq()

          %Record{
            record
            | origin: node(),
              pool: pool,
              value: value,
              revision: record.revision + 1,
              ts: :os.system_time(:millisecond)
          }

        nil ->
          pool = options[:pool] || settings[:pool] || Node.list()
          pool = ([node()] ++ pool) |> Enum.uniq()

          %Record{
            identifier: identifier,
            origin: node(),
            pool: pool,
            value: value,
            revision: 1,
            ts: :os.system_time(:millisecond)
          }
      end

    # @TODO we actually need to wait until received, this will fail immedietly if semaphore not acquired.
    Semaphore.call({:fg_update_record, identifier}, 1, fn ->
      Semaphore.call({:fg_write_record, identifier}, 2, fn ->
        Enum.reduce_while(0..2400, false, fn _, _ ->
          cond do
            Semaphore.acquire({:fg_write_record, identifier}, 2) ->
              {:halt, true}

            :else ->
              Process.sleep(25)
              {:cont, false}
          end
        end)
        |> then(fn mutex ->
          with true <- mutex || {:error, :max} do
            tsup = options[:fg][:tsup] || Noizu.FastGlobal.Cluster

            [local_task | tasks] =
              Enum.map(
                update.pool,
                fn target ->
                  cond do
                    target == node() ->
                      Task.Supervisor.async_nolink(tsup, fn ->
                        put(identifier, update, options)
                      end)

                    :else ->
                      Task.Supervisor.async_nolink(tsup, fn ->
                        cond do
                          options[:fg][:local_only] ->
                            :skip

                          options[:fg][:sync] ->
                            :rpc.call(
                              target,
                              Noizu.FastGlobal.Cluster,
                              :put,
                              [identifier, update, options],
                              :infinity
                            )

                          :else ->
                            :rpc.cast(target, Noizu.FastGlobal.Cluster, :put, [
                              identifier,
                              update,
                              options
                            ])
                        end
                      end)
                  end
                end
              )

            r =
              cond do
                options[:fg][:write_wait] == nil ->
                  [{local_task, Task.await(local_task, :infinity)}]

                w = options[:fg][:write_wait] ->
                  timeout =
                    cond do
                      w == true -> :infinity
                      :else -> w
                    end

                  [
                    {local_task, Task.await(local_task, :infinity)}
                    | Task.yield_many([tasks], timeout)
                  ]

                :else ->
                  :ok
              end

            Semaphore.release({:fg_write_record, identifier})
            r
          else
            error ->
              Logger.error(
                "[Noizu.FastGlobal.Cluster]: Unable to obtain write for requested update."
              )

              error
          end
        end)
      end)
    end)
  end
end
