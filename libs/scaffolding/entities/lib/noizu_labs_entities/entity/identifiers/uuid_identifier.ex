# ================================
# ERP methods
# ================================

defmodule Noizu.UUID do
  @moduledoc """
  Wrapper around UUID provider.
  """
  @handler Application.compile_env(:noizu_labs_entities, :uuid_lib, UUID)

  defdelegate binary_to_string!(id), to: @handler
  defdelegate uuid5(prefix, seed), to: @handler
  defdelegate uuid5(prefix, seed, format), to: @handler
end

defmodule Noizu.Entity.Meta.UUIDIdentifier do
  @moduledoc """
  Logic for UUID id backed entities.
  """

  @handler Application.compile_env(
             :noizu_labs_entities,
             :uuid_id,
             Noizu.Entity.Meta.UUIDIdentifier.Common
           )

  # ----------------
  # ecto_gen_string
  # ----------------
  def ecto_gen_string(name) do
    {:ok, "#{name}:uuid"}
  end

  defdelegate format_id(m, id, index), to: @handler
  defdelegate uuid_string(id), to: @handler
  defdelegate kind(m, id), to: @handler
  defdelegate id(m, id), to: @handler
  defdelegate ref(m, id), to: @handler
  defdelegate sref(m, id), to: @handler
  defdelegate entity(m, id, context), to: @handler

  defmodule Common do
    @moduledoc """
    Default implementation of UUIDIdentifier backed entities.
    """

    unless Application.compile_env(:noizu_labs_entities, :uuid_lib) || Code.ensure_loaded?(UUID) do
      require Noizu.EntityReference.Records
      alias Noizu.EntityReference.Records, as: R

      # -----------------------------
      # format_id/3
      # -----------------------------
      def format_id(_, _, _),
        do: raise(Noizu.Entity.Identifier.Exception, message: "UUID Not Available")

      # -----------------------------
      # kind/2
      # -----------------------------
      def kind(_m, _id),
        do: raise(Noizu.Entity.Identifier.Exception, message: "UUID Not Available")

      # -----------------------------
      # id/2
      # -----------------------------
      def id(_m, _id), do: raise(Noizu.Entity.Identifier.Exception, message: "UUID Not Available")

      # -----------------------------
      # ref/2
      # -----------------------------
      def ref(_m, _id),
        do: raise(Noizu.Entity.Identifier.Exception, message: "UUID Not Available")

      # -----------------------------
      # sref/2
      # -----------------------------
      def sref(_m, _id),
        do: raise(Noizu.Entity.Identifier.Exception, message: "UUID Not Available")

      # -----------------------------
      # entity/3
      # -----------------------------
      def entity(_m, _id, _context),
        do: raise(Noizu.Entity.Identifier.Exception, message: "UUID Not Available")
    else
      require Noizu.EntityReference.Records
      alias Noizu.EntityReference.Records, as: R

      # -----------------------------
      # format_id/3
      # -----------------------------
      def format_id(m, id, index) do
        with repo <- Noizu.Entity.Meta.repo(m) do
          <<e10, e11, e12>> = Integer.to_string(index, 16) |> String.pad_leading(3, "0")

          <<a1, a2, a3, a4, a5, a6, a7, a8, ?-, b1, b2, b3, b4, ?-, c1, c2, c3, c4, ?-, d1, d2,
            d3, d4, ?-, e1, e2, e3, e4, e5, e6, e7, e8, e9, _, _,
            _>> = Noizu.UUID.uuid5(Noizu.UUID.uuid5(:dns, "#{repo}"), "#{id}", :default)

          <<a1, a2, a3, a4, a5, a6, a7, a8, ?-, b1, b2, b3, b4, ?-, c1, c2, c3, c4, ?-, d1, d2,
            d3, d4, ?-, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11, e12>>
        end
      end

      # -----------------------------
      # uuid_string/1
      # -----------------------------
      def uuid_string(<<_::binary-size(16)>> = id), do: Noizu.UUID.binary_to_string!(id)

      def uuid_string(
            <<_, _, _, _, _, _, _, _, ?-, _, _, _, _, ?-, _, _, _, _, ?-, _, _, _, _, ?-, _, _, _,
              _, _, _, _, _, _, _, _, _>> = id
          ),
          do: id

      # -----------------------------
      # kind/2
      # -----------------------------
      def kind(m, <<_::binary-size(16)>> = _id), do: {:ok, m}

      def kind(
            m,
            <<_, _, _, _, _, _, _, _, ?-, _, _, _, _, ?-, _, _, _, _, ?-, _, _, _, _, ?-, _, _, _,
              _, _, _, _, _, _, _, _, _>> = _id
          ),
          do: {:ok, m}

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
      def id(_m, <<_::binary-size(16)>> = id), do: {:ok, uuid_string(id)}

      def id(
            _m,
            <<_, _, _, _, _, _, _, _, ?-, _, _, _, _, ?-, _, _, _, _, ?-, _, _, _, _, ?-, _, _, _,
              _, _, _, _, _, _, _, _, _>> = id
          ),
          do: {:ok, id}

      def id(m, R.ref(module: m, id: <<_::binary-size(16)>>) = ref),
        do: {:ok, R.ref(ref, :id) |> uuid_string()}

      def id(
            m,
            R.ref(
              module: m,
              id:
                <<_, _, _, _, _, _, _, _, ?-, _, _, _, _, ?-, _, _, _, _, ?-, _, _, _, _, ?-, _,
                  _, _, _, _, _, _, _, _, _, _, _>>
            ) = ref
          ),
          do: {:ok, R.ref(ref, :id)}

      def id(m, R.ref(module: m, id: <<_::binary-size(16)>>) = ref),
        do: {:ok, R.ref(ref, :id) |> uuid_string()}

      def id(
            m,
            R.ref(
              module: m,
              id:
                <<_, _, _, _, _, _, _, _, ?-, _, _, _, _, ?-, _, _, _, _, ?-, _, _, _, _, ?-, _,
                  _, _, _, _, _, _, _, _, _, _, _>>
            ) = ref
          ),
          do: {:ok, R.ref(ref, :id)}

      def id(m, %{__struct__: m, id: <<_::binary-size(16)>>} = ref),
        do: {:ok, ref.id |> uuid_string()}

      def id(
            m,
            %{
              __struct__: m,
              id:
                <<_, _, _, _, _, _, _, _, ?-, _, _, _, _, ?-, _, _, _, _, ?-, _, _, _, _, ?-, _,
                  _, _, _, _, _, _, _, _, _, _, _>>
            } = ref
          ),
          do: {:ok, ref.id}

      def id(m, "ref." <> _ = ref) do
        with sref <- Noizu.Entity.Meta.sref(m),
             {:ok, sref} <- (sref && {:ok, sref}) || {:error, {:sref_undefined, m}} do
          cond do
            String.starts_with?(ref, "ref.#{sref}.") ->
              id = String.trim_leading(ref, "ref.#{sref}.")

              case ShortUUID.decode(id) do
                {:ok, value} ->
                  {:ok, value}

                _ ->
                  {:error, {:unsupported, {__MODULE__, :id, ref}}}
              end

            :else ->
              {:error, {:unsupported, {__MODULE__, :id, ref}}}
          end
        end
      end

      def id(_m, ref), do: {:error, {:unsupported, {__MODULE__, :id, ref}}}

      # -----------------------------
      # ref/2
      # -----------------------------
      def ref(m, ref) do
        with {:ok, id} <- apply(m, :id, [ref]) do
          {:ok, R.ref(module: m, id: id)}
        end
      end

      # -----------------------------
      # sref/2
      # -----------------------------
      def sref(m, ref) do
        with sref <- Noizu.Entity.Meta.sref(m),
             {:ok, sref} <- (sref && {:ok, sref}) || {:error, {:sref_undefined, m}},
             {:ok, id} <- apply(m, :id, [ref]),
             {:ok, value} <- ShortUUID.encode(id) do
          {:ok, "ref.#{sref}.#{value}"}
        end
      end

      # -----------------------------
      # entity/3
      # -----------------------------
      def entity(m, %{__struct__: m, id: <<_::binary-size(16)>>} = ref, _context),
        do: {:ok, ref}

      def entity(
            m,
            %{
              __struct__: m,
              id:
                <<_, _, _, _, _, _, _, _, ?-, _, _, _, _, ?-, _, _, _, _, ?-, _, _, _, _, ?-, _,
                  _, _, _, _, _, _, _, _, _, _, _>>
            } = ref,
            _context
          ),
          do: {:ok, ref}

      def entity(m, ref, context) do
        with {:ok, ref} <- apply(m, :ref, [ref]),
             repo <- Noizu.Entity.Meta.repo(ref),
             {:ok, repo} <- (repo && {:ok, repo}) || {:error, {m, :repo_not_found}} do
          apply(repo, :get, [ref, context, []])
        end
      end
    end
  end
end
