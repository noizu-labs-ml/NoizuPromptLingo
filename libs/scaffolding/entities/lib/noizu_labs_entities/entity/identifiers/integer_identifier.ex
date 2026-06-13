# ================================
# ERP methods
# ================================
defmodule Noizu.Entity.Meta.IntegerIdentifier do
  @moduledoc """
  Logic for entities that use an integer value for their id.
  """

  require Noizu.Entity.Meta.Persistence
  require Noizu.EntityReference.Records
  alias Noizu.EntityReference.Records, as: R

  # -----------------------------
  # __using__/1
  # -----------------------------
  defmacro __using__(opts) do
    entity = opts[:entity]

    quote do
      def kind(_), do: {:ok, unquote(entity)}
      def id(%{id: id}), do: {:ok, id}
      def ref(%{id: id}), do: apply(unquote(entity), :ref, [id])
      def sref(%{id: id}), do: apply(unquote(entity), :sref, [id])
      def entity(ref, context), do: apply(unquote(entity), :entity, [ref, context])
    end
  end

  # ----------------
  # ecto_gen_string
  # ----------------
  def ecto_gen_string(name) do
    {:ok, "#{name}:integer"}
  end

  # -----------------------------
  # format_id/3
  # -----------------------------
  def format_id(_, id, _) do
    id
  end

  # -----------------------------
  # kind/2
  # -----------------------------
  def kind(m, id) when is_integer(id), do: {:ok, m}
  def kind(m, R.ref(module: m)), do: {:ok, m}
  def kind(m, %{__struct__: m}), do: {:ok, m}

  def kind(m, "ref." <> _ = ref) do
    with sref <- Noizu.Entity.Meta.sref(m),
         {:ok, sref} <- (sref && {:ok, sref}) || {:error, {:sref_undefined, m}} do
      cond do
        String.starts_with?(ref, "ref.#{sref}.") ->
          String.trim_leading(ref, "ref.#{sref}.")
          |> Integer.parse()
          |> case do
            {id, ""} when is_integer(id) -> {:ok, m}
            _ -> {:error, {:unsupported, {m, :kind, ref}}}
          end

        :else ->
          {:error, {:unsupported, {m, :kind, ref}}}
      end
    end
  end

  def kind(m, ref), do: {:error, {:unsupported, {m, :kind, ref}}}

  # -----------------------------
  # id/2
  # -----------------------------
  def id(m, id)
  def id(_, id) when is_integer(id), do: {:ok, id}
  def id(m, R.ref(module: m, id: id)) when is_integer(id), do: {:ok, id}
  def id(m, %{__struct__: m, id: id}) when is_integer(id), do: {:ok, id}

  def id(m, "ref." <> _ = ref) do
    with sref <- Noizu.Entity.Meta.sref(m),
         {:ok, sref} <- (sref && {:ok, sref}) || {:error, {:sref_undefined, m}} do
      cond do
        String.starts_with?(ref, "ref.#{sref}.") ->
          String.trim_leading(ref, "ref.#{sref}.")
          |> Integer.parse()
          |> case do
            {id, ""} when is_integer(id) -> {:ok, id}
            _ -> {:error, {:unsupported, {m, :id, ref}}}
          end

        :else ->
          {:error, {:unsupported, {m, :id, ref}}}
      end
    end
  end

  def id(m, ref), do: {:error, {:unsupported, {m, :id, ref}}}

  # -----------------------------
  # ref/2
  # -----------------------------
  def ref(m, id) when is_integer(id), do: {:ok, R.ref(module: m, id: id)}

  def ref(m, R.ref(module: m, id: id)) when is_integer(id),
    do: {:ok, R.ref(module: m, id: id)}

  def ref(m, %{__struct__: m, id: id}) when is_integer(id),
    do: {:ok, R.ref(module: m, id: id)}

  def ref(m, "ref." <> _ = ref) do
    with sref <- Noizu.Entity.Meta.sref(m),
         {:ok, sref} <- (sref && {:ok, sref}) || {:error, {:sref_undefined, m}} do
      cond do
        String.starts_with?(ref, "ref.#{sref}.") ->
          String.trim_leading(ref, "ref.#{sref}.")
          |> Integer.parse()
          |> case do
            {id, ""} when is_integer(id) ->
              {:ok, R.ref(module: m, id: id)}

            _ ->
              {:error, {:unsupported, {m, :ref, ref}}}
          end

        :else ->
          {:error, {:unsupported, {m, :ref, ref}}}
      end
    end
  end

  def ref(m, ref), do: {:error, {:unsupported, {m, :ref, ref}}}

  # -----------------------------
  # sref/2
  # -----------------------------
  def sref(m, id) when is_integer(id) do
    with sref <- Noizu.Entity.Meta.sref(m),
         {:ok, sref} <- (sref && {:ok, sref}) || {:error, {:sref_undefined, m}} do
      {:ok, "ref.#{sref}.#{id}"}
    end
  end

  def sref(m, R.ref(module: m, id: id)) when is_integer(id) do
    with sref <- Noizu.Entity.Meta.sref(m),
         {:ok, sref} <- (sref && {:ok, sref}) || {:error, {:sref_undefined, m}} do
      {:ok, "ref.#{sref}.#{id}"}
    end
  end

  def sref(m, %{__struct__: m, id: id}) when is_integer(id) do
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
          String.trim_leading(ref, "ref.#{sref}.")
          |> Integer.parse()
          |> case do
            {id, ""} when is_integer(id) -> {:ok, "ref.#{sref}.#{id}"}
            _ -> {:error, {:unsupported, {m, :sref, ref}}}
          end

        :else ->
          {:error, {:unsupported, {m, :sref, ref}}}
      end
    end
  end

  def sref(m, ref), do: {:error, {:unsupported, {m, :sref, ref}}}

  # -----------------------------
  # entity/3
  # -----------------------------
  def entity(m, id, context) when is_integer(id),
    do: apply(m, :entity, [R.ref(module: m, id: id), context])

  def entity(m, R.ref(module: m, id: id) = ref, context) when is_integer(id) do
    with repo <- Noizu.Entity.Meta.repo(ref),
         {:ok, repo} <- (repo && {:ok, repo}) || {:error, {m, :repo_not_found}} do
      apply(repo, :get, [ref, context, []])
    end
  end

  def entity(m, %{__struct__: m, id: id} = ref, _context) when is_integer(id),
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
          String.trim_leading(ref, "ref.#{sref}.")
          |> Integer.parse()
          |> case do
            {id, ""} when is_integer(id) ->
              apply(m, :entity, [R.ref(module: m, id: id), context])

            _ ->
              {:error, {:unsupported, {m, :entity, ref}}}
          end

        :else ->
          {:error, {:unsupported, {m, :entity, ref}}}
      end
    end
  end

  def entity(m, ref, _context), do: {:error, {:unsupported, {m, :entity, ref}}}
end
