defprotocol Noizu.EntityProtocol do
  @fallback_to_any true
  def expand!(entity, options \\ %{})
end

defimpl Noizu.EntityProtocol, for: Any do
  def expand!(entity, _options \\ %{}), do: entity
end

defimpl Noizu.EntityProtocol, for: List do
  def expand!(entity, options \\ %{}) do
    {max_concurrency, options} = cond do
      options[:sync] -> {1, options}
      is_integer(options[:async]) && length(entity) < options[:async] -> {1, options}
      :else -> Noizu.Scaffolding.Helpers.expand_concurrency(options)
    end
    if max_concurrency == 1 do
      entity
      |> Enum.map(
        fn(v) ->
          Noizu.EntityProtocol.expand!(v, options)
        end
      )
    else
      timeout = options[:timeout] || 30_000
      ordered = options[:ordered] || true
      entity
      |> Task.async_stream(
        fn(v) ->
          Noizu.EntityProtocol.expand!(v, options)
        end,
        max_concurrency: max_concurrency, timeout: timeout, ordered: ordered
      )
      |> Enum.map(fn({:ok, v}) -> v end)
    end
  end
end

defimpl Noizu.EntityProtocol, for: Tuple do
  def expand!(ref, options \\ %{})
  def expand!({:ext_ref, m, _} = ref, options) when is_atom(m) do
    cond do
      Noizu.Scaffolding.Helpers.expand_ref?(Noizu.Scaffolding.Helpers.update_expand_options(m, options)) ->
        Noizu.EntityProtocol.expand!(m.entity!(ref, options))
      :else -> ref
    end
  end
  def expand!({:ref, m, _} = ref, options) when is_atom(m) do
      cond do
        Noizu.Scaffolding.Helpers.expand_ref?(Noizu.Scaffolding.Helpers.update_expand_options(m, options)) ->
            Noizu.EntityProtocol.expand!(m.entity!(ref, options))
        :else -> ref
      end
  end
  def expand!(ref, _) do
    ref
  end
end

defimpl Noizu.EntityProtocol, for: Map do
  def expand!(entity, options \\ %{})

  def expand!(%{__struct__: m} = entity, %{structs: true} = options) do
    options = Noizu.Scaffolding.Helpers.update_expand_options(m, options)
    Enum.reduce(entity, entity,
      fn({k,v}, acc) ->
        Map.put(acc, k, Noizu.EntityProtocol.expand!(v, options))
      end)
  end

  def expand!(%{__struct__: _m} = entity, _options) do
    entity
  end

  def expand!(%{} = entity, %{maps: true} = options) do
    {max_concurrency, options} = cond do
      options[:sync] -> {1, options}
      is_integer(options[:async]) && length(Map.keys(entity)) < options[:async] -> {1, options}
      :else -> Noizu.Scaffolding.Helpers.expand_concurrency(options)
    end
    if max_concurrency == 1 do
      entity
      |> Enum.map(
           fn({k,v}) ->
             {k, Noizu.EntityProtocol.expand!(v, options)}
           end
         )
      |> Map.new
    else
      max_concurrency = options[:max_concurrency] || System.schedulers_online()
      timeout = options[:timeout] || 30_000
      ordered = options[:ordered] || true
      entity
      |> Task.async_stream(
           fn({k,v}) ->
             {k, Noizu.EntityProtocol.expand!(v, options)}
           end,
           max_concurrency: max_concurrency, timeout: timeout, ordered: ordered
         )
      |> Enum.map(fn({:ok, v}) -> v end)
      |> Map.new
    end
  end

  def expand!(entity, _options) do
    entity
  end

end
