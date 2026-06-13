defprotocol Noizu.EntityReference.Protocol do
  @fallback_to_any true

  @spec id(any) :: {:ok, any} | {:error, any}
  def id(subject)

  @spec kind(any) :: {:ok, any} | {:error, any}
  def kind(subject)

  @spec ref(any) :: {:ok, any} | {:error, any}
  def ref(subject)

  @spec sref(any) :: {:ok, any} | {:error, any}
  def sref(subject)

  @spec entity(any, any) :: {:ok, any} | {:error, any}
  def entity(subject, context)
end
