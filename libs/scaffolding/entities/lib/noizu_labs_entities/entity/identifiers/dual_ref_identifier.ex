# ================================
# ERP methods
# ================================
defmodule Noizu.Entity.Meta.DualRefIdentifier do
  @moduledoc """
  This module provides methods for generating and parsing identifiers for entities with dual references.
  """

  require Noizu.EntityReference.Records
  alias Noizu.EntityReference.Records, as: R

  # -----------------------------
  # format_id/3
  # -----------------------------
  def format_id(m, _, _) do
    raise Noizu.Entity.Identifier.Exception,
      message: "#{m.__struct__} Generate Identifier with dual_ref type not supported"
  end

  # ----------------
  # ecto_gen_string
  # ----------------
  def ecto_gen_string(name) do
    [
      {:ok, "#{name}:tuple"}
    ]
  end

  # -----------------------------
  #  kind/2
  # -----------------------------
  def kind(m, R.ref(module: m)), do: {:ok, m}
  def kind(m, {R.ref(), R.ref()}), do: {:ok, m}
  def kind(m, %{__struct__: m}), do: {:ok, m}

  def kind(m, "ref." <> _ = ref) do
    # @TODO - verify ref.<is_sref>.{ref}
    with sref <- Noizu.Entity.Meta.sref(m),
         {:ok, sref} <- (sref && {:ok, sref}) || {:error, {:sref_undefined, m}} do
      cond do
        String.starts_with?(ref, "ref.#{sref}.") ->
          {:ok, m}

        :else ->
          {:error, {:unsupported, {m, :kind, ref}}}
      end
    end
  end

  def kind(m, ref), do: {:error, {:unsupported, {m, :kind, ref}}}

  # -----------------------------
  # id/2
  # -----------------------------
  def id(_, {R.ref(), R.ref()} = ref), do: {:ok, ref}

  def id(m, R.ref(module: m, id: {R.ref(), R.ref()}) = ref),
    do: {:ok, R.ref(ref, :id)}

  def id(m, %{__struct__: m, id: {R.ref(), R.ref()}} = ref), do: {:ok, ref.id}

  def id(m, "ref." <> _ = ref) do
    with sref <- Noizu.Entity.Meta.sref(m),
         {:ok, sref} <- (sref && {:ok, sref}) || {:error, {:sref_undefined, m}} do
      cond do
        String.starts_with?(ref, "ref.#{sref}.") ->
          #          inner_sref = String.trim_leading(ref, "ref.#{sref}{")
          #          with {:ok, inner_ref} <- Noizu.EntityReference.Protocol.ref(inner_sref) do
          #            {:ok, inner_ref}
          #          else
          #            _ ->
          {:error, {:unsupported, {m, :id, ref}}}

        # end
        :else ->
          {:error, {:unsupported, {m, :id, ref}}}
      end
    end
  end

  def id(m, ref), do: {:error, {:unsupported, {m, :id, ref}}}

  # -----------------------------
  # ref/2
  # -----------------------------
  def ref(m, {R.ref(), R.ref()} = inner_ref), do: {:ok, R.ref(module: m, id: inner_ref)}
  def ref(m, R.ref(module: m, id: {R.ref(), R.ref()}) = ref), do: {:ok, ref}

  def ref(m, %{__struct__: m, id: {R.ref(), R.ref()}} = ref),
    do: {:ok, R.ref(module: m, id: ref.id)}

  def ref(m, "ref." <> _ = ref) do
    with sref <- Noizu.Entity.Meta.sref(m),
         {:ok, sref} <- (sref && {:ok, sref}) || {:error, {:sref_undefined, m}} do
      cond do
        String.starts_with?(ref, "ref.#{sref}.") ->
          #          inner_sref = String.trim_leading(ref, "ref.#{sref}.")
          #          with {:ok, inner_ref} <- Noizu.EntityReference.Protocol.ref(inner_sref) do
          #            {:ok, R.ref(module: m, id: inner_ref)}
          #          else
          #            _ ->
          {:error, {:unsupported, {m, :ref, ref}}}

        # end
        :else ->
          {:error, {:unsupported, {m, :ref, ref}}}
      end
    end
  end

  def ref(m, ref), do: {:error, {:unsupported, {m, :ref, ref}}}

  # -----------------------------
  # sref/2
  # -----------------------------
  def sref(m, ref) do
    with sref <- Noizu.Entity.Meta.sref(m),
         {:ok, sref} <- (sref && {:ok, sref}) || {:error, {:sref_undefined, m}},
         {:ok, {inner_ref_a, inner_ref_b}} <- apply(m, :id, [ref]),
         {:ok, inner_sref_a} <- Noizu.EntityReference.Protocol.sref(inner_ref_a),
         {:ok, inner_sref_b} <- Noizu.EntityReference.Protocol.sref(inner_ref_b) do
      {:ok, "ref.#{sref}.{#{inner_sref_a},#{inner_sref_b}}"}
    else
      _ -> {:error, {:unsupported, {m, :sref, ref}}}
    end
  end

  # -----------------------------
  # entity/2
  # -----------------------------
  def entity(m, %{__struct__: m} = ref, _context) do
    {:ok, ref}
  end

  def entity(m, ref, context) do
    with {:ok, ref} <- apply(m, :ref, [ref]),
         repo <- Noizu.Entity.Meta.repo(ref),
         {:ok, repo} <- (repo && {:ok, repo}) || {:error, {m, :repo_not_found}} do
      apply(repo, :get, [ref, context, []])
    else
      _ -> {:error, {:unsupported, {m, :entity, ref}}}
    end
  end
end
