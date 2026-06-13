defmodule Noizu.Entity.Test.UIDProvider do
  @moduledoc false
  @foo_type Noizu.UUID.uuid5(:dns, "#{Elixir.Noizu.Support.Entities.Foos.Foo}")
  def generate(_, _), do: {:ok, {:os.system_time(:millisecond) - 1_683_495_051_937, 0}}

  def ref({:id, id, :type_id, ref_type_field}) do
    cond do
      ref_type_field == @foo_type ->
        Elixir.Noizu.Support.Entities.Foos.Foo.ref(id)

      :else ->
        {:error, {:unsupported, __MODULE__, :ref}}
    end
  end

  def ref(_), do: {:error, {:unsupported, __MODULE__, :ref}}
end
