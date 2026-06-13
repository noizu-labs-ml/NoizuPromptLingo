

defprotocol Noizu.RestrictedProtocol do
  @fallback_to_any true
  def restricted_view(entity, context, options \\ nil)
  def restricted_update(entity, current, context, options \\ nil)
  def restricted_create(entity, context, options \\ nil)
end

defimpl Noizu.RestrictedProtocol, for: List do
  def restricted_view(entity, context, options \\ nil) do
    {max_concurrency, options} = cond do
      options[:sync] -> {1, options}
      is_integer(options[:async]) && length(entity) < options[:async] -> {1, options}
      :else -> Noizu.Scaffolding.Helpers.expand_concurrency(options)
    end
    if max_concurrency == 1 do
      entity
      |> Enum.map(
           fn(v) ->
             Noizu.RestrictedProtocol.restricted_view(v, context, options)
           end
         )
    else
      timeout = options[:timeout] || 30_000
      ordered = options[:ordered] || true
      entity
      |> Task.async_stream(
           fn(v) ->
             Noizu.RestrictedProtocol.restricted_view(v, context, options)
           end,
           max_concurrency: max_concurrency, timeout: timeout, ordered: ordered
         )
      |> Enum.map(fn({:ok, v}) -> v end)
    end
  end

  def restricted_update(_entity, _current, _context, _options \\ nil) do
    throw :not_supported
  end

  def restricted_create(entity, context, options \\ nil) do
    {max_concurrency, options} = cond do
      options[:sync] -> {1, options}
      is_integer(options[:async]) && length(entity) < options[:async] -> {1, options}
      :else -> Noizu.Scaffolding.Helpers.expand_concurrency(options)
    end
    if max_concurrency == 1 do
      entity
      |> Enum.map(
           fn(v) ->
             Noizu.RestrictedProtocol.restricted_create(v, context, options)
           end
         )
    else
      timeout = options[:timeout] || 30_000
      ordered = options[:ordered] || true
      entity
      |> Task.async_stream(
           fn(v) ->
             Noizu.RestrictedProtocol.restricted_create(v, context, options)
           end,
           max_concurrency: max_concurrency, timeout: timeout, ordered: ordered
         )
      |> Enum.map(fn({:ok, v}) -> v end)
    end
  end
end

# Default unlimited access.
#defimpl Noizu.RestrictedProtocol, for: Any do
#  def restricted_view(%{__struct__: kind} = entity, _context, _options), do: put_in(Map.from_struct(entity), [:kind], kind)
#  def restricted_view(entity, _context, _options), do: entity
#  def restricted_edit(entity, _current, _context, _options), do: entity
#  def restricted_create(entity, _context, _options), do: entity
#end
