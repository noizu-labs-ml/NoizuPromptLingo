defmodule NoizuPromptLingua.Domains.Tickets.TicketKey do
  @moduledoc """
  Canonical human-readable ticket key generation (f8bc7fab / 055). A key is
  `<PREFIX>-<zero-padded number>` (e.g. NOZINF-023), immutable once assigned.

  Pure helpers only — the atomic per-scope counter + prefix claim live in the
  Tickets domain (they need Repo). This module owns the two deterministic
  transforms so on-insert and the backfill produce identical keys.
  """

  @prefix_max 6
  @pad 3

  @doc """
  Derive a default key prefix from a slug: uppercase, strip to A-Z0-9, cap at
  #{@prefix_max} (e.g. "noizu-infra" -> "NOIZUI"). Falls back to "TKT" when a slug
  yields nothing (empty / non-latin). Callers collision-suffix within the scope.
  """
  @spec derive_prefix(term()) :: binary()
  def derive_prefix(slug) do
    base =
      slug
      |> to_string()
      |> String.upcase()
      |> String.replace(~r/[^A-Z0-9]/, "")
      |> String.slice(0, @prefix_max)

    # >= 2 chars so it always satisfies the key_prefix format (single-char/empty slugs
    # fall back rather than produce an invalid 1-char prefix).
    if String.length(base) < 2, do: "TKT", else: base
  end

  @doc "Append a collision suffix to a base prefix (n<=1 -> base; n>=2 -> base<>n)."
  @spec prefix_variant(binary(), integer()) :: binary()
  def prefix_variant(base, n) when n <= 1, do: base
  def prefix_variant(base, n), do: "#{base}#{n}"

  @doc "Format the full immutable key: PREFIX + '-' + zero-padded(number), min #{@pad} digits."
  @spec format_key(binary(), integer()) :: binary()
  def format_key(prefix, number) do
    "#{prefix}-#{number |> Integer.to_string() |> String.pad_leading(@pad, "0")}"
  end
end
