defmodule NoizuLabs.Entities.Helpers do
  @moduledoc """
  Helper utilities for entities.
  """

  @doc """
  Wait until condition lambda returns an ok tuple or timeout exceeded.
  """
  def wait_for_condition(condition, timeout \\ 5_000, options \\ nil)

  def wait_for_condition(condition, timeout, options) do
    reference = make_ref()
    task = Task.async(fn -> wait_loop(condition, reference, options) end)

    case Task.yield(task, timeout) do
      {:ok, response} ->
        {:ok, response}

      _ ->
        response =
          receive do
            {:condition_not_met, response} -> {:timeout, response}
            e -> {:timeout, e}
          after
            50 -> {:timeout, :timeout}
          end

        Task.shutdown(task, 0)
        response
    end
  end

  defp wait_loop(condition, reference, options) do
    case condition.() do
      true ->
        :ok

      :ok ->
        :ok

      {:ok, details} ->
        {:ok, details}

      response ->
        send(reference, {:condition_not_met, response})
        :timer.sleep(options[:poll] || 100)
        wait_loop(condition, reference, options)
    end
  end
end
