defmodule NoizuPromptLingua.Domains.Chat.Slug do
  @moduledoc """
  Canonical chat-room slug normalization (ADR-013) — the single source of truth.

  Pure: no DB, no side effects. The on-insert path AND the backfill task both call
  `slugify/1`; collision ordinals go through `with_suffix/2`. Keeping this in one
  pure, public module is exactly devon/dmitri's "one canonical slugify" — and makes
  it unit/property-testable in isolation.

  Output invariant: `slugify/1` always returns a string matching
  `^[a-z0-9](-?[a-z0-9])*$` OR `^room-[a-z0-9]+$`; never empty, never a leading/
  trailing '-', length <= #{80} including any collision suffix.
  """

  # Length is an app guarantee (the column is TEXT). The FINAL stored slug,
  # INCLUDING any collision suffix, is <= @slug_max.
  @slug_max 80

  # Latin-extended letters with no NFKD decomposition that would otherwise mangle
  # ('Straße' -> 'stra-e', 'Łódź' -> 'od'). Applied BEFORE NFKD, both cases (ADR-013 H2).
  @translit %{
    "ß" => "ss", "ẞ" => "ss",
    "ø" => "o", "Ø" => "o",
    "æ" => "ae", "Æ" => "ae",
    "œ" => "oe", "Œ" => "oe",
    "ł" => "l", "Ł" => "l",
    "đ" => "d", "Đ" => "d",
    "ð" => "d", "Ð" => "d",
    "þ" => "th", "Þ" => "th"
  }

  @doc """
  Normalize a name into a URL-safe slug.

  Order (ADR-013, dmitri seq99): transliteration map -> NFKD decompose ->
  strip combining marks -> lowercase -> collapse non-[a-z0-9] runs to '-' ->
  trim '-' -> length cap. Empty/degenerate (emoji / CJK / Cyrillic / pure
  punctuation) falls back to `room-<shortid>`.
  """
  @spec slugify(term()) :: binary()
  def slugify(name) do
    base =
      name
      |> to_string()
      |> transliterate()
      |> :unicode.characters_to_nfkd_binary()
      |> String.replace(~r/\p{Mn}/u, "")
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9]+/u, "-")
      |> String.trim("-")
      |> cap_to(@slug_max)

    if base == "", do: "room-" <> shortid(), else: base
  end

  @doc """
  Apply a 1-indexed collision ordinal to a base slug (ADR-013 H1).

  `n <= 1` -> base unchanged (the first room of a name keeps the bare slug).
  `n >= 2` -> `"<base>-<n>"` with the WHOLE result <= #{@slug_max}; the base is
  re-trimmed on a '-' boundary per suffix width, so the cap holds for ANY n.
  """
  @spec with_suffix(binary() | nil, integer()) :: binary() | nil
  def with_suffix(base, n) when n <= 1, do: base

  def with_suffix(base, n) do
    suffix = "-#{n}"
    cap_to(base, @slug_max - byte_size(suffix)) <> suffix
  end

  defp transliterate(s) do
    s |> String.graphemes() |> Enum.map_join(fn g -> Map.get(@translit, g, g) end)
  end

  # Safe: cap_to only runs once the string is pure ASCII [a-z0-9-], so byte_size
  # equals character count and binary_part won't split a codepoint.
  defp cap_to(s, max) when byte_size(s) <= max, do: s
  defp cap_to(s, max), do: s |> binary_part(0, max) |> String.trim_trailing("-")

  # Lowercase hex so the fallback honors slugify's own output invariant (ADR-013 F1).
  defp shortid do
    Ecto.UUID.generate() |> String.replace("-", "") |> binary_part(0, 8) |> String.downcase()
  end
end
