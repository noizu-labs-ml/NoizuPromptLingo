defmodule Derobot.Redis do
  @channel_pool_size 50

  def prefix(key) do
    case Application.get_env(:derobot, :redis)[:key_prefix] do
      nil -> key
      p -> "#{p}#{key}"
    end
  end

  def get_channel() do
    (:persistent_term.get(:redis_channels, nil) || build_channels())[
      :rand.uniform(@channel_pool_size)
    ]
  end

  def build_channels() do
    Enum.map(1..@channel_pool_size, &{&1, :"redis_#{&1}"})
    |> Map.new()
    |> tap(&:persistent_term.put(:redis_channels, &1))
  end

  def child_spec(_args) do
    v = Application.get_env(:derobot, :redis)
    uri = v[:uri] || v[:host]
    settings = Redix.URI.to_start_options(uri)

    children =
      Enum.map(
        1..@channel_pool_size,
        fn index ->
          opts = put_in(settings, [:name], :"redis_#{index}")
          Supervisor.child_spec({Redix, opts}, id: {Redix, index})
        end
      )

    build_channels()

    %{
      id: RedixSupervisor,
      type: :supervisor,
      start: {Supervisor, :start_link, [children, [strategy: :one_for_one]]}
    }
  end

  def command(command), do: Redix.command(get_channel(), command)
  def flush(), do: command(["FLUSHALL"])

  def get(key), do: command(["GET", prefix(key)])
  def del(key), do: command(["DEL", prefix(key)])

  def set(key, value, options \\ []) do
    args =
      Enum.flat_map(options, fn
        {:ex, ttl} -> ["EX", to_string(ttl)]
        {:px, ttl} -> ["PX", to_string(ttl)]
        {:nx, true} -> ["NX"]
        {:xx, true} -> ["XX"]
      end)

    command(["SET", prefix(key), value | args])
  end

  def get_binary(key) do
    case get(key) do
      {:ok, nil} -> nil
      {:ok, term} -> {:ok, :erlang.binary_to_term(term)}
      _ -> nil
    end
  end

  def set_binary(key, value, options \\ []) do
    set(key, :erlang.term_to_binary(value), options)
  end
end
