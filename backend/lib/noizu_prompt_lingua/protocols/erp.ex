require Protocol
Protocol.derive(Jason.Encoder, Noizu.Entity.TimeStamp, [])

defimpl Jason.Encoder, for: Tuple do
  def encode({:ref, _, _} = s, {_, _, user_settings} = opts) do
    json_format = user_settings[:json_format] || :default

    with {:ok, sref} <- Noizu.EntityReference.Protocol.sref(s) do
      sref
      |> Jason.Encode.string(opts)
    else
      {:error, _} -> {:error, :invalid_sref}
    end
  end

  def encode(s = {:ref, _, _}, {_, _} = opts) do
    with {:ok, sref} <- Noizu.EntityReference.Protocol.sref(s) do
      sref
      |> Jason.Encode.string(opts)
    else
      {:error, _} -> {:error, :invalid_sref}
    end
  end

  def encode({:ref, _, _} = s, {_, _, user_settings} = opts) do
    json_format = user_settings[:json_format] || :default

    with {:ok, sref} <- Noizu.EntityReference.Protocol.sref(s) do
      sref
      |> Jason.Encode.string(opts)
    else
      {:error, _} -> {:error, :invalid_sref}
    end
  end

  def encode(s, {_, _, _} = opts) do
    "#{inspect(s)}"
    |> Jason.Encode.string(opts)
  end

  def encode(s, {_, _} = opts) do
    "#{inspect(s)}"
    |> Jason.Encode.string(opts)
  end
end

defimpl Noizu.EntityReference.Protocol, for: BitString do
  def handlers() do
    NoizuPromptLingua.EntityRepo.sref_handlers()
  end

  def handler("ref." <> _ = sref) do
    with [_, h] <- Regex.run(~r/^ref.([^.]*)/, sref) do
      h = handlers()[h]
      (h && {:ok, h}) || {:error, {:handler_not_found, sref}}
    else
      _ -> {:error, {:handler_not_found, sref}}
    end
  end

  def handler(sref), do: {:error, {:handler_not_found, sref}}

  def id(subject) do
    with {:ok, handler} <- handler(subject) do
      apply(handler, :id, [subject])
    end
  end

  def kind(subject) do
    with {:ok, handler} <- handler(subject) do
      apply(handler, :kind, [subject])
    end
  end

  def ref(subject) do
    with {:ok, handler} <- handler(subject) do
      apply(handler, :ref, [subject])
    end
  end

  def sref(subject) do
    with {:ok, handler} <- handler(subject) do
      apply(handler, :sref, [subject])
    end
  end

  def entity(subject, context) do
    with {:ok, handler} <- handler(subject) do
      apply(handler, :entity, [subject, context])
    end
  end
end
