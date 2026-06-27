defmodule NoizuPromptLingua.Services.Watch do
  import Ecto.Query
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Watch

  @doc """
  Register a watch. An optional `filter` (a substring string or a
  `%{"type" => "regex", "pattern" => ...}` map) restricts which updates fire a
  notification — see `matches_filter?/2`. When a watch already exists the filter
  is updated to the supplied value.
  """
  def watch(entity_type, entity_id, persona, filter \\ nil) do
    %Watch{}
    |> Watch.changeset(%{
      entity_type: entity_type,
      entity_id: entity_id,
      persona: persona,
      filter: filter
    })
    |> Repo.insert(
      on_conflict: {:replace, [:filter, :updated_at]},
      conflict_target: [:entity_type, :entity_id, :persona]
    )
  end

  def unwatch(entity_type, entity_id, persona) do
    case Repo.get_by(Watch, entity_type: entity_type, entity_id: entity_id, persona: persona) do
      nil -> {:error, :not_found}
      watch -> Repo.delete(watch)
    end
  end

  def watchers(entity_type, entity_id) do
    Watch
    |> where([w], w.entity_type == ^entity_type and w.entity_id == ^entity_id)
    |> select([w], w.persona)
    |> Repo.all()
  end

  @doc "Return `[{persona, filter}]` tuples for every watcher of the entity."
  def watchers_with_filter(entity_type, entity_id) do
    Watch
    |> where([w], w.entity_type == ^entity_type and w.entity_id == ^entity_id)
    |> select([w], {w.persona, w.filter})
    |> Repo.all()
  end

  def watching?(entity_type, entity_id, persona) do
    Watch
    |> where([w], w.entity_type == ^entity_type and w.entity_id == ^entity_id and w.persona == ^persona)
    |> Repo.exists?()
  end

  @doc """
  Evaluate a watch filter against a piece of text.

    * `nil` (no filter) always matches.
    * a substring filter — either a bare string or
      `%{"type" => "substring", "value" => str}` — matches when `text`
      contains the substring.
    * `%{"type" => "regex", "pattern" => pat}` matches when the compiled
      regex matches `text`.

  Any malformed filter (e.g. a bad regex) is treated as a non-match.
  """
  def matches_filter?(nil, _text), do: true
  def matches_filter?(_filter, nil), do: false

  def matches_filter?(filter, text) when is_binary(filter) do
    String.contains?(text, filter)
  end

  def matches_filter?(%{"type" => "regex", "pattern" => pattern}, text)
      when is_binary(pattern) do
    case Regex.compile(pattern) do
      {:ok, regex} -> Regex.match?(regex, text)
      _ -> false
    end
  end

  def matches_filter?(%{"type" => "substring", "value" => value}, text)
      when is_binary(value) do
    String.contains?(text, value)
  end

  # Atom-keyed variants (in case a filter is supplied in-memory).
  def matches_filter?(%{type: "regex", pattern: pattern}, text),
    do: matches_filter?(%{"type" => "regex", "pattern" => pattern}, text)

  def matches_filter?(%{type: "substring", value: value}, text),
    do: matches_filter?(%{"type" => "substring", "value" => value}, text)

  def matches_filter?(_filter, _text), do: false
end
