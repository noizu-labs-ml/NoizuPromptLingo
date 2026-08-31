defmodule NoizuPromptLingua.Acl.ERPRef do
  @moduledoc """
  Ecto custom type for polymorphic Noizu ERP references — the
  `{:ref, Type, id}` record from `Noizu.EntityReference.Records` — persisted as
  a JSONB object `{"type": "<Type>", "id": "<id>"}`.

  Used for the ACL subject/resource bindings (`acl_rules.subject_ref`,
  `acl_rules.resource_ref`, `acl_groups.ref`, `acl_group_members.member_ref`)
  so a permission can attach to ANY arbitrary entity (user, persona, api key,
  organization, project, another group…) without schema changes.

  Conventions:

    * `Type` is an entity module atom (`NoizuPromptLingua.Users.User`), stored
      without the `Elixir.` prefix. On load it round-trips via
      `String.to_existing_atom/1`, so only modules actually present in the
      running node can be restored (which is the only interesting case).
    * The kind atom `:any` is a wildcard (`{"type": "any"}`) — used by rules to
      grant/deny an entire entity kind or, as `{:ref, :any, :any}`, globally.
    * ids are stored as strings and loaded back as strings; `:any` ids load
      back as the `:any` atom wildcard.
  """

  use Ecto.Type
  require Noizu.EntityReference.Records
  alias Noizu.EntityReference.Records, as: R

  @wildcard :any

  @doc "Underlying database column type (jsonb)."
  def type, do: :map

  # ──────────────────────────────────────────────────────────────────
  # cast — in-memory values into a canonical ref record
  # ──────────────────────────────────────────────────────────────────

  def cast(nil), do: {:ok, nil}

  # Already a ref record (bare tuple form included).
  def cast(R.ref(module: m, id: i)) when (is_atom(m) or is_binary(m)) and not is_nil(i) do
    {:ok, R.ref(module: normalize_kind(m), id: i)}
  end

  # Entity structs / wrapped refs — normalize through the ERP protocol.
  def cast(value) when is_struct(value) do
    case Noizu.EntityReference.Protocol.ref(value) do
      {:ok, R.ref() = ref} -> cast(ref)
      _ -> :error
    end
  end

  def cast(_), do: :error

  # ──────────────────────────────────────────────────────────────────
  # dump — ref record → jsonb map
  # ──────────────────────────────────────────────────────────────────

  def dump(nil), do: {:ok, nil}

  def dump(R.ref(module: m, id: i)) do
    {:ok, %{"type" => kind_to_string(m), "id" => to_string(i)}}
  end

  def dump(_), do: :error

  # ──────────────────────────────────────────────────────────────────
  # load — jsonb map → ref record
  # ──────────────────────────────────────────────────────────────────

  def load(nil), do: {:ok, nil}

  def load(%{"type" => t, "id" => i}) do
    with {:ok, kind} <- string_to_kind(t) do
      {:ok, R.ref(module: kind, id: string_to_id(i))}
    end
  end

  def load(_), do: :error

  # ──────────────────────────────────────────────────────────────────
  # Public helpers (SQL fragments + pure comparisons)
  # ──────────────────────────────────────────────────────────────────

  @doc "Canonical jsonb map for a ref — used for equality comparisons in queries."
  def dump_map(ref) do
    case cast(ref) do
      {:ok, R.ref() = canonical} ->
        {:ok, canonical} = dump(canonical)
        canonical

      _ ->
        nil
    end
  end

  @doc "The stored type string for a kind/module (wildcard aware)."
  def kind_to_string(@wildcard), do: "any"
  def kind_to_string(m) when is_atom(m), do: m |> Atom.to_string() |> String.trim_leading("Elixir.")
  def kind_to_string(m) when is_binary(m), do: m

  @doc """
  Restore a kind/module from its stored type string. Module strings must map
  to an already-loaded module atom (to_existing_atom keeps the atom table safe);
  `\"any\"` restores the `:any` wildcard.
  """
  def string_to_kind("any"), do: {:ok, @wildcard}

  def string_to_kind(t) when is_binary(t) do
    try do
      {:ok, String.to_existing_atom("Elixir." <> t)}
    rescue
      ArgumentError ->
        try do
          {:ok, String.to_existing_atom(t)}
        rescue
          ArgumentError -> :error
        end
    end
  end

  def string_to_kind(_), do: :error

  defp string_to_id("any"), do: @wildcard
  defp string_to_id(i), do: i

  defp normalize_kind(@wildcard), do: @wildcard
  defp normalize_kind(m) when is_atom(m), do: m
  defp normalize_kind(m) when is_binary(m), do: m
end
