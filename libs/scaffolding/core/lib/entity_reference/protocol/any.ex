defimpl Noizu.EntityReference.Protocol, for: Any do
  @spec id(any) :: {:ok, any} | {:error, any}
  def id(subject), do: {:error, {Noizu.EntityReference.Protocol, {:unsupported, {:id, subject}}}}

  @spec kind(any) :: {:ok, any} | {:error, any}
  def kind(subject),
    do: {:error, {Noizu.EntityReference.Protocol, {:unsupported, {:kind, subject}}}}

  @spec ref(any) :: {:ok, any} | {:error, any}
  def ref(subject),
    do: {:error, {Noizu.EntityReference.Protocol, {:unsupported, {:ref, subject}}}}

  @spec sref(any) :: {:ok, any} | {:error, any}
  def sref(subject),
    do: {:error, {Noizu.EntityReference.Protocol, {:unsupported, {:sref, subject}}}}

  @spec entity(any, any) :: {:ok, any} | {:error, any}
  def entity(subject, _),
    do: {:error, {Noizu.EntityReference.Protocol, {:unsupported, {:entity, subject}}}}

  defmacro __deriving__(module, _, _) do
    # we should be defining a provider rather than requiring these methods be defined for each struct
    quote do
      defimpl Noizu.EntityReference.Protocol, for: [unquote(module)] do
        @spec id(any) :: {:ok, any} | {:error, any}
        def id(subject), do: unquote(module).id(subject)

        @spec kind(any) :: {:ok, any} | {:error, any}
        def kind(subject), do: unquote(module).kind(subject)

        @spec ref(any) :: {:ok, any} | {:error, any}
        def ref(subject), do: unquote(module).ref(subject)

        @spec sref(any) :: {:ok, any} | {:error, any}
        def sref(subject), do: unquote(module).sref(subject)

        @spec entity(any, any) :: {:ok, any} | {:error, any}
        def entity(subject, context), do: unquote(module).entity(subject, context)
      end
    end
  end
end
