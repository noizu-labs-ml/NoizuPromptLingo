# ================================
# ERP methods
# ================================
defmodule Noizu.Entity.Meta.AtomIdentifier do
  @moduledoc """
  Logic for atom id backed entities.
  """

  require Noizu.Entity.Meta.Persistence
  require Noizu.EntityReference.Records
  alias Noizu.EntityReference.Records, as: R

  # -----------------------------
  # __using___/1
  # -----------------------------
  defmacro __using__(opts) do
    entity = opts[:entity]

    quote do
      def kind(_), do: {:ok, unquote(entity)}
      def id(%{id: id}), do: {:ok, id}
      def ref(%{id: id}), do: unquote(entity).ref(id)
      def sref(%{id: id}), do: unquote(entity).sref(id)
      def entity(ref, context), do: unquote(entity).entity(ref, context)
    end
  end

  # -----------------------------
  # format_id/3
  # -----------------------------
  @doc """
  String format id for sref
  """
  def format_id(_m, id, _) do
    "#{id}"
  end

  # ----------------
  # ecto_gen_string
  # ----------------
  def ecto_gen_string(name) do
    # TODO enum:[list]
    {:ok, "#{name}:string"}
  end

  # ----------------
  # kind/2
  # ----------------
  @doc """
  Returns the kind of the entity.
  """
  def kind(m, id) when not is_nil(id) and is_atom(id), do: {:ok, m}
  def kind(m, R.ref(module: m)), do: {:ok, m}
  def kind(m, %{__struct__: m}), do: {:ok, m}

  def kind(m, "ref." <> _ = ref) do
    with sref <- Noizu.Entity.Meta.sref(m),
         {:ok, sref} <- (sref && {:ok, sref}) || {:error, {:sref_undefined, m}} do
      cond do
        String.starts_with?(ref, "ref.#{sref}.") ->
          {:ok, m}

        :else ->
          {:error, {:unsupported, {__MODULE__, :kind, ref}}}
      end
    end
  end

  def kind(_m, ref), do: {:error, {:unsupported, {__MODULE__, :kind, ref}}}

  # -----------------------------
  # id/2
  # -----------------------------
  def id(_m, id) when not is_nil(id) and is_atom(id), do: {:ok, id}
  def id(m, R.ref(module: m, id: id)) when not is_nil(id) and is_atom(id), do: {:ok, id}
  def id(m, %{__struct__: m, id: id}) when not is_nil(id) and is_atom(id), do: {:ok, id}

  def id(m, "ref." <> _ = ref) do
    with sref <- Noizu.Entity.Meta.sref(m),
         {:ok, sref} <- (sref && {:ok, sref}) || {:error, {:sref_undefined, m}} do
      cond do
        String.starts_with?(ref, "ref.#{sref}.") ->
          x =
            String.trim_leading(ref, "ref.#{sref}.")
            |> String.to_existing_atom()

          {:ok, x}

        :else ->
          {:error, {:unsupported, {m, :id, ref}}}
      end
    end
  end

  def id(m, ref), do: {:error, {:unsupported, {m, :id, ref}}}

  # -----------------------------
  # ref/2
  # -----------------------------
  def ref(m, id) when not is_nil(id) and is_atom(id), do: {:ok, R.ref(module: m, id: id)}

  def ref(m, R.ref(module: m, id: id)) when not is_nil(id) and is_atom(id),
    do: {:ok, R.ref(module: m, id: id)}

  def ref(m, %{__struct__: m, id: id}) when not is_nil(id) and is_atom(id),
    do: {:ok, R.ref(module: m, id: id)}

  def ref(m, "ref." <> _ = ref) do
    with sref <- Noizu.Entity.Meta.sref(m),
         {:ok, sref} <- (sref && {:ok, sref}) || {:error, {:sref_undefined, m}} do
      cond do
        String.starts_with?(ref, "ref.#{sref}.") ->
          x =
            String.trim_leading(ref, "ref.#{sref}.")
            |> String.to_existing_atom()

          {:ok, R.ref(module: m, id: x)}

        :else ->
          {:error, {:unsupported, {m, :ref, ref}}}
      end
    end
  end

  def ref(m, ref), do: {:error, {:unsupported, {m, :ref, ref}}}

  # -----------------------------
  # sref/2
  # -----------------------------
  def sref(m, id) when not is_nil(id) and is_atom(id) do
    with sref <- Noizu.Entity.Meta.sref(m),
         {:ok, sref} <- (sref && {:ok, sref}) || {:error, {:sref_undefined, m}} do
      {:ok, "ref.#{sref}.#{id}"}
    end
  end

  def sref(m, R.ref(module: m, id: id)) when not is_nil(id) and is_atom(id) do
    with sref <- Noizu.Entity.Meta.sref(m),
         {:ok, sref} <- (sref && {:ok, sref}) || {:error, {:sref_undefined, m}} do
      {:ok, "ref.#{sref}.#{id}"}
    end
  end

  def sref(m, %{__struct__: m, id: id}) when not is_nil(id) and is_atom(id) do
    with sref <- Noizu.Entity.Meta.sref(m),
         {:ok, sref} <- (sref && {:ok, sref}) || {:error, {:sref_undefined, m}} do
      {:ok, "ref.#{sref}.#{id}"}
    end
  end

  def sref(m, "ref." <> _ = ref) do
    with sref <- Noizu.Entity.Meta.sref(m),
         {:ok, sref} <- (sref && {:ok, sref}) || {:error, {:sref_undefined, m}} do
      cond do
        String.starts_with?(ref, "ref.#{sref}.") ->
          x =
            String.trim_leading(ref, "ref.#{sref}.")
            |> String.to_existing_atom()

          {:ok, "ref.#{sref}.#{x}"}

        :else ->
          {:error, {:unsupported, {m, :sref, ref}}}
      end
    end
  end

  def sref(m, ref), do: {:error, {:unsupported, {m, :sref, ref}}}

  # -----------------------------
  # entity/3
  # -----------------------------
  def entity(m, id, context) when not is_nil(id) and is_atom(id),
    do: apply(m, :entity, [R.ref(module: m, id: id), context])

  def entity(m, R.ref(module: m, id: id) = ref, context) when not is_nil(id) and is_atom(id) do
    with repo <- Noizu.Entity.Meta.repo(ref),
         {:ok, repo} <- (repo && {:ok, repo}) || {:error, {m, :repo_not_found}} do
      apply(repo, :get, [ref, context, []])
    end
  end

  def entity(m, %{__struct__: m, id: id} = ref, _context) when not is_nil(id) and is_atom(id),
    do: {:ok, ref}

  def entity(m, %{__struct__: record_type} = ref, context) do
    with {:ok, settings = Noizu.Entity.Meta.Persistence.persistence_settings(type: type)} <-
           Noizu.Entity.Meta.Persistence.by_table(m, record_type) do
      protocol = Module.concat(type, EntityProtocol)
      stub = apply(m, :stub, [])
      apply(protocol, :as_entity, [stub, ref, settings, context, []])
    else
      _ -> {:error, {:unsupported, {m, :entity, ref}}}
    end
  end

  def entity(m, "ref." <> _ = ref, context) do
    with sref <- Noizu.Entity.Meta.sref(m),
         {:ok, sref} <- (sref && {:ok, sref}) || {:error, {:sref_undefined, m}} do
      cond do
        String.starts_with?(ref, "ref.#{sref}.") ->
          x =
            String.trim_leading(ref, "ref.#{sref}.")
            |> String.to_existing_atom()

          apply(m, :entity, [R.ref(module: m, id: x), context])

        :else ->
          {:error, {:unsupported, {__MODULE__, :entity, ref}}}
      end
    end
  end

  def entity(_m, ref, _context), do: {:error, {:unsupported, {__MODULE__, :entity, ref}}}
end
