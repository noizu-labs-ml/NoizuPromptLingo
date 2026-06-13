defmodule Codefresh.Datasets do
  @moduledoc """
  Stage 9 context: datasets + manual flagged captures.

  Covers:
    * Head/version pattern (US-101 / US-102 / US-109 / US-110)
    * Manual entry authoring (US-103)
    * CSV + JSONL imports (US-104)
    * HF stub (US-149 — accept params + insert placeholder; real fetch deferred)
    * Parquet export stub (US-150 — deferred)
    * Manual flag + browse + promote (US-106 / US-107 / US-108 / US-109)
    * Auto-flag-rule linkage (US-147 — manual only here; rule engine is
      implemented downstream in `Codefresh.Webhooks`/runs stages)
    * Dataset-run persona fan-out helper (US-125 — scope validation only; the
      Stage 5 runner consumes it)
    * Digest-email stub (US-148 — deferred to mailer pipeline)

  Mirrors the head/version pattern of `Codefresh.Personas` / `Codefresh.Rubrics`.
  Cross-org queries return `nil` → controllers translate to 404.
  """

  import Ecto.Query, only: [from: 2]
  alias Ecto.Multi
  alias Codefresh.Repo
  alias Codefresh.Datasets.{Dataset, DatasetVersion, DatasetEntry, FlaggedCapture}
  alias Codefresh.Rubrics

  # ──────────────────────────────────────────────────────────────────────────
  # Head CRUD (US-101)
  # ──────────────────────────────────────────────────────────────────────────

  def create_dataset(attrs) do
    %Dataset{}
    |> Dataset.create_changeset(attrs)
    |> Repo.insert()
  end

  def update_dataset(%Dataset{} = d, attrs) do
    d |> Dataset.update_changeset(attrs) |> Repo.update()
  end

  def archive_dataset(%Dataset{} = d), do: d |> Dataset.archive_changeset() |> Repo.update()
  def unarchive_dataset(%Dataset{} = d), do: d |> Dataset.unarchive_changeset() |> Repo.update()

  def get_dataset(organization_id, id) do
    Repo.one(from d in Dataset, where: d.organization_id == ^organization_id and d.id == ^id)
  rescue
    Ecto.Query.CastError -> nil
  end

  def get_dataset!(organization_id, id) do
    case get_dataset(organization_id, id) do
      nil -> raise Ecto.NoResultsError, queryable: Dataset
      d -> d
    end
  end

  def get_dataset_by_slug(organization_id, slug) when is_binary(slug) do
    Repo.get_by(Dataset, organization_id: organization_id, slug: slug)
  end

  def list_datasets(organization_id, opts \\ []) do
    include_archived = Keyword.get(opts, :include_archived, false)
    search = Keyword.get(opts, :search)
    type = Keyword.get(opts, :type)

    q = from d in Dataset, where: d.organization_id == ^organization_id, order_by: [asc: d.name]

    q
    |> maybe_hide_archived(include_archived)
    |> maybe_type_filter(type)
    |> maybe_search(search)
    |> Repo.all()
  end

  defp maybe_hide_archived(q, true), do: q
  defp maybe_hide_archived(q, false), do: from(d in q, where: is_nil(d.archived_at))

  defp maybe_type_filter(q, nil), do: q
  defp maybe_type_filter(q, ""), do: q
  defp maybe_type_filter(q, type), do: from(d in q, where: d.type == ^type)

  defp maybe_search(q, nil), do: q
  defp maybe_search(q, ""), do: q

  defp maybe_search(q, s) do
    like = "%#{String.downcase(s)}%"

    from d in q,
      where:
        fragment("lower(?) LIKE ?", d.name, ^like) or
          fragment("lower(coalesce(?, '')) LIKE ?", d.description, ^like)
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Entry authoring (US-103)
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Stage an entry against the dataset's open draft version. Creates a new draft
  (next version_number, forking from the current published version) if one does
  not exist yet. Returns `{:ok, {draft_version, entry}}`.

  An entry's `input` must be present and non-empty. For `request_response`
  datasets, `expected_output` is required by the dataset.type contract — see
  `validate_entry_contract/2`.
  """
  def add_entry(%Dataset{} = dataset, attrs) do
    attrs = normalize(attrs)

    Multi.new()
    |> Multi.run(:draft, fn _repo, _ -> ensure_draft(dataset) end)
    |> Multi.run(:contract, fn _repo, %{draft: _} ->
      validate_entry_contract(dataset, attrs)
    end)
    |> Multi.insert(:entry, fn %{draft: draft} ->
      DatasetEntry.create_changeset(%DatasetEntry{}, %{
        dataset_version_id: draft.id,
        organization_id: dataset.organization_id,
        entry_key: Map.get(attrs, :entry_key) || default_entry_key(),
        input: Map.get(attrs, :input) || %{},
        expected_output: Map.get(attrs, :expected_output),
        tags: Map.get(attrs, :tags) || [],
        notes: Map.get(attrs, :notes)
      })
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{draft: draft, entry: entry}} -> {:ok, {draft, entry}}
      {:error, :entry, cs, _} -> {:error, cs}
      {:error, _step, reason, _} -> {:error, reason}
    end
  end

  defp default_entry_key do
    "entry-" <> (:crypto.strong_rand_bytes(5) |> Base.url_encode64(padding: false))
  end

  defp validate_entry_contract(%Dataset{type: "request_response"}, attrs) do
    case Map.get(attrs, :expected_output) do
      nil -> {:error, :expected_output_required}
      %{} = eo when map_size(eo) == 0 -> {:error, :expected_output_required}
      _ -> {:ok, :ok}
    end
  end

  defp validate_entry_contract(_, _), do: {:ok, :ok}

  @doc """
  Returns the open draft version for a dataset. Creates one if the dataset has
  no unpublished version (forks from current published version if present).
  """
  def ensure_draft(%Dataset{} = dataset) do
    case open_draft(dataset) do
      %DatasetVersion{} = v ->
        {:ok, v}

      nil ->
        parent_version_id = dataset.current_version_id
        parent_id = parent_version_id

        insert_draft(dataset, parent_id)
    end
  end

  defp open_draft(%Dataset{id: did, current_version_id: cvid}) do
    q =
      from dv in DatasetVersion,
        where: dv.dataset_id == ^did,
        order_by: [desc: dv.version_number],
        limit: 1

    case Repo.one(q) do
      nil -> nil
      %DatasetVersion{id: ^cvid} -> nil
      %DatasetVersion{} = v when is_nil(cvid) -> v
      %DatasetVersion{} = v -> if v.id == cvid, do: nil, else: v
    end
  end

  defp insert_draft(dataset, parent_version_id) do
    next = next_version_number(dataset.id)
    # Checksum for an empty draft is a unique per-dataset seed so two concurrent
    # empty drafts don't collide on the (dataset_id, checksum) unique index. We
    # recompute the real content-checksum at publish time (US-102).
    seed_checksum = :crypto.hash(:sha256, "draft:#{dataset.id}:#{next}:#{System.unique_integer()}")

    changeset =
      DatasetVersion.create_changeset(%DatasetVersion{}, %{
        dataset_id: dataset.id,
        organization_id: dataset.organization_id,
        version_number: next,
        parent_version_id: parent_version_id,
        checksum: seed_checksum
      })

    case Repo.insert(changeset) do
      {:ok, v} -> {:ok, v}
      {:error, cs} -> {:error, cs}
    end
  end

  defp next_version_number(dataset_id) do
    q =
      from dv in DatasetVersion,
        where: dv.dataset_id == ^dataset_id,
        select: max(dv.version_number)

    (Repo.one(q) || 0) + 1
  end

  def list_entries(%DatasetVersion{id: dvid}) do
    Repo.all(
      from e in DatasetEntry,
        where: e.dataset_version_id == ^dvid,
        order_by: [asc: e.entry_key]
    )
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Publish (US-102 + US-110 rubric pin)
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Publish the current draft version of a dataset. Recomputes the checksum over
  the draft's entries (sorted by entry_key), deduplicates against prior
  published versions of the same dataset, and — on a genuine new body — pins
  the version via `current_version_id`.

  `default_rubric_version_id` (US-110) pins a same-org rubric version as the
  dataset's default scorer; cross-org rubric pins are rejected.

  Returns `{:ok, :published, v}` | `{:ok, :noop, v}` | `{:error, reason}`.
  """
  def publish_version(%Dataset{} = dataset, attrs \\ %{}) do
    attrs = normalize(attrs)
    rubric_pin = Map.get(attrs, :default_rubric_version_id)
    published_by = Map.get(attrs, :published_by_user_id)

    with :ok <- validate_rubric_pin(dataset.organization_id, rubric_pin),
         {:ok, draft} <- fetch_open_draft(dataset) do
      entries = list_entries(draft)
      checksum = DatasetVersion.compute_checksum(entries, rubric_pin)

      case Repo.get_by(DatasetVersion, dataset_id: dataset.id, checksum: checksum) do
        %DatasetVersion{id: id} = existing when id != draft.id ->
          # A prior published version has identical body — discard the empty
          # draft by returning the existing version as a noop.
          {:ok, :noop, existing}

        _ ->
          do_publish(dataset, draft, checksum, rubric_pin, published_by)
      end
    end
  end

  defp fetch_open_draft(dataset) do
    case open_draft(dataset) do
      nil -> {:error, :no_draft}
      %DatasetVersion{} = v -> {:ok, v}
    end
  end

  defp validate_rubric_pin(_org_id, nil), do: :ok

  defp validate_rubric_pin(org_id, rvid) do
    if Rubrics.pinnable?(org_id, rvid), do: :ok, else: {:error, :rubric_not_pinnable}
  end

  defp do_publish(dataset, draft, checksum, rubric_pin, published_by) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    Multi.new()
    |> Multi.update_all(
      :finalize_draft,
      from(dv in DatasetVersion, where: dv.id == ^draft.id),
      set: [
        checksum: checksum,
        default_rubric_version_id: rubric_pin,
        published_by_user_id: published_by,
        inserted_at: now
      ]
    )
    |> Multi.run(:finalized, fn _repo, _ ->
      {:ok, Repo.get!(DatasetVersion, draft.id)}
    end)
    |> Multi.update(:advance_head, fn %{finalized: v} ->
      Dataset.advance_current_version_changeset(dataset, v.id)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{finalized: v}} -> {:ok, :published, v}
      {:error, :finalize_draft, reason, _} -> {:error, reason}
      {:error, _step, reason, _} -> {:error, reason}
    end
  end

  def list_versions(%Dataset{id: did}) do
    Repo.all(
      from dv in DatasetVersion,
        where: dv.dataset_id == ^did,
        order_by: [desc: dv.version_number]
    )
  end

  def get_version!(id), do: Repo.get!(DatasetVersion, id)

  def resolve_current_version(organization_id, dataset_id) do
    case get_dataset(organization_id, dataset_id) do
      nil -> {:error, :not_found}
      %Dataset{current_version_id: nil} -> {:error, :not_published}
      %Dataset{current_version_id: vid} -> {:ok, Repo.get!(DatasetVersion, vid)}
    end
  end

  @doc "Is this dataset_version pinnable (same org)? Used by run config + rubric attach."
  def pinnable?(organization_id, version_id) do
    case Repo.get(DatasetVersion, version_id) do
      %DatasetVersion{organization_id: ^organization_id} -> true
      _ -> false
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # CSV / JSONL import (US-104)
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Import CSV rows into the dataset's open draft version. `raw` is the full CSV
  text; `mapping` maps target fields to column headers: `%{"input" => "col_a",
  "expected_output" => "col_b", "tags" => "col_tags", "notes" => "col_notes"}`.

  Tags are split on `|`. Returns `{:ok, %{version: v, inserted: N, skipped: M}}`
  or `{:error, {:row, row_number, reason}}`.
  """
  def import_csv(%Dataset{} = dataset, raw, mapping \\ %{}) when is_binary(raw) do
    rows = parse_csv(raw)

    case rows do
      [] ->
        {:error, :empty_csv}

      [header | body] ->
        input_col = Map.get(mapping, "input") || "input"
        expected_col = Map.get(mapping, "expected_output") || "expected_output"
        tags_col = Map.get(mapping, "tags") || "tags"
        notes_col = Map.get(mapping, "notes") || "notes"

        with {:ok, draft} <- ensure_draft(dataset) do
          do_import_rows(dataset, draft, header, body, input_col, expected_col, tags_col, notes_col)
        end
    end
  end

  defp do_import_rows(dataset, draft, header, body, input_col, expected_col, tags_col, notes_col) do
    header_index =
      header
      |> Enum.with_index()
      |> Enum.into(%{}, fn {h, i} -> {h, i} end)

    input_idx = Map.get(header_index, input_col)

    cond do
      is_nil(input_idx) ->
        {:error, {:missing_column, input_col}}

      true ->
        expected_idx = Map.get(header_index, expected_col)
        tags_idx = Map.get(header_index, tags_col)
        notes_idx = Map.get(header_index, notes_col)

        result =
          body
          |> Enum.with_index(2)
          |> Enum.reduce_while({:ok, %{inserted: 0, skipped: 0}}, fn {row, line}, {:ok, acc} ->
            case build_and_insert_csv_row(
                   dataset,
                   draft,
                   row,
                   input_idx,
                   expected_idx,
                   tags_idx,
                   notes_idx
                 ) do
              {:ok, :inserted} -> {:cont, {:ok, %{acc | inserted: acc.inserted + 1}}}
              {:ok, :skipped} -> {:cont, {:ok, %{acc | skipped: acc.skipped + 1}}}
              {:error, reason} -> {:halt, {:error, {:row, line, reason}}}
            end
          end)

        case result do
          {:ok, counts} -> {:ok, Map.put(counts, :version, draft)}
          other -> other
        end
    end
  end

  defp build_and_insert_csv_row(
         dataset,
         draft,
         row,
         input_idx,
         expected_idx,
         tags_idx,
         notes_idx
       ) do
    input_raw = Enum.at(row, input_idx) || ""

    cond do
      String.trim(input_raw) == "" ->
        {:error, :empty_input}

      true ->
        expected_raw = if expected_idx, do: Enum.at(row, expected_idx), else: nil
        tags_raw = if tags_idx, do: Enum.at(row, tags_idx), else: nil
        notes_raw = if notes_idx, do: Enum.at(row, notes_idx), else: nil

        attrs = %{
          entry_key: default_entry_key(),
          input: %{"text" => input_raw},
          expected_output: maybe_wrap_expected(expected_raw),
          tags: parse_tags(tags_raw),
          notes: nilify_blank(notes_raw)
        }

        case insert_import_entry(dataset, draft, attrs) do
          {:ok, _} -> {:ok, :inserted}
          {:skip, _} -> {:ok, :skipped}
          {:error, reason} -> {:error, reason}
        end
    end
  end

  defp maybe_wrap_expected(nil), do: nil
  defp maybe_wrap_expected(""), do: nil
  defp maybe_wrap_expected(raw), do: %{"text" => raw}

  defp parse_tags(nil), do: []
  defp parse_tags(""), do: []
  defp parse_tags(raw), do: raw |> String.split("|", trim: true) |> Enum.map(&String.trim/1)

  defp nilify_blank(nil), do: nil
  defp nilify_blank(""), do: nil
  defp nilify_blank(s), do: s

  # Tolerant CSV parser: handles quoted fields with embedded commas / newlines,
  # doubled quotes (`""` → `"`), BOM stripping, and mixed CRLF. Returns a list
  # of rows, each a list of field strings.
  defp parse_csv(raw) do
    raw
    |> strip_bom()
    |> String.replace("\r\n", "\n")
    |> String.replace("\r", "\n")
    |> do_parse_csv([], [], "", false)
  end

  defp strip_bom(<<0xEF, 0xBB, 0xBF, rest::binary>>), do: rest
  defp strip_bom(s), do: s

  defp do_parse_csv("", rows, row, field, _in_quotes) do
    case {row, field} do
      {[], ""} -> Enum.reverse(rows)
      _ -> Enum.reverse([Enum.reverse([field | row]) | rows])
    end
  end

  defp do_parse_csv(<<"\"\"", rest::binary>>, rows, row, field, true) do
    do_parse_csv(rest, rows, row, field <> "\"", true)
  end

  defp do_parse_csv(<<"\"", rest::binary>>, rows, row, field, false) do
    do_parse_csv(rest, rows, row, field, true)
  end

  defp do_parse_csv(<<"\"", rest::binary>>, rows, row, field, true) do
    do_parse_csv(rest, rows, row, field, false)
  end

  defp do_parse_csv(<<",", rest::binary>>, rows, row, field, false) do
    do_parse_csv(rest, rows, [field | row], "", false)
  end

  defp do_parse_csv(<<"\n", rest::binary>>, rows, row, field, false) do
    do_parse_csv(rest, [Enum.reverse([field | row]) | rows], [], "", false)
  end

  defp do_parse_csv(<<c::utf8, rest::binary>>, rows, row, field, in_quotes) do
    do_parse_csv(rest, rows, row, field <> <<c::utf8>>, in_quotes)
  end

  defp insert_import_entry(dataset, draft, attrs) do
    case validate_entry_contract(dataset, attrs) do
      {:ok, :ok} ->
        changeset =
          DatasetEntry.create_changeset(%DatasetEntry{}, %{
            dataset_version_id: draft.id,
            organization_id: dataset.organization_id,
            entry_key: attrs.entry_key,
            input: attrs.input,
            expected_output: attrs.expected_output,
            tags: attrs.tags,
            notes: attrs.notes
          })

        case Repo.insert(changeset) do
          {:ok, entry} ->
            {:ok, entry}

          {:error, %Ecto.Changeset{errors: errors}} ->
            if Keyword.has_key?(errors, :entry_key) do
              {:skip, :duplicate_key}
            else
              {:error, {:changeset, errors}}
            end
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Import JSONL into the dataset's draft. Each non-blank line is `Jason.decode!`'d
  and must decode to an object with at least `"input"`. Returns
  `{:ok, %{version: v, inserted: N, skipped: M}}` or `{:error, {:row, n, reason}}`.
  """
  def import_jsonl(%Dataset{} = dataset, raw) when is_binary(raw) do
    with {:ok, draft} <- ensure_draft(dataset) do
      lines =
        raw
        |> String.split("\n")
        |> Enum.with_index(1)
        |> Enum.reject(fn {line, _} -> String.trim(line) == "" end)

      result =
        Enum.reduce_while(lines, {:ok, %{inserted: 0, skipped: 0}}, fn {line, lineno},
                                                                       {:ok, acc} ->
          case import_jsonl_line(dataset, draft, line) do
            {:ok, :inserted} -> {:cont, {:ok, %{acc | inserted: acc.inserted + 1}}}
            {:ok, :skipped} -> {:cont, {:ok, %{acc | skipped: acc.skipped + 1}}}
            {:error, reason} -> {:halt, {:error, {:row, lineno, reason}}}
          end
        end)

      case result do
        {:ok, counts} -> {:ok, Map.put(counts, :version, draft)}
        other -> other
      end
    end
  end

  defp import_jsonl_line(dataset, draft, line) do
    case Jason.decode(line) do
      {:ok, %{} = obj} ->
        attrs = %{
          entry_key: Map.get(obj, "entry_key") || default_entry_key(),
          input: normalize_jsonl_input(Map.get(obj, "input")),
          expected_output: normalize_jsonl_expected(Map.get(obj, "expected_output")),
          tags: Map.get(obj, "tags") || [],
          notes: Map.get(obj, "notes")
        }

        if map_size(attrs.input) == 0 do
          {:error, :missing_input}
        else
          case insert_import_entry(dataset, draft, attrs) do
            {:ok, _} -> {:ok, :inserted}
            {:skip, _} -> {:ok, :skipped}
            {:error, reason} -> {:error, reason}
          end
        end

      {:ok, _} ->
        {:error, :not_an_object}

      {:error, err} ->
        {:error, {:decode, Exception.message(err)}}
    end
  end

  defp normalize_jsonl_input(nil), do: %{}
  defp normalize_jsonl_input(s) when is_binary(s), do: %{"text" => s}
  defp normalize_jsonl_input(%{} = m), do: m
  defp normalize_jsonl_input(other), do: %{"value" => other}

  defp normalize_jsonl_expected(nil), do: nil
  defp normalize_jsonl_expected(s) when is_binary(s), do: %{"text" => s}
  defp normalize_jsonl_expected(%{} = m), do: m
  defp normalize_jsonl_expected(other), do: %{"value" => other}

  # ──────────────────────────────────────────────────────────────────────────
  # HuggingFace stub (US-149) — accept params, insert placeholder row
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Stub for HuggingFace dataset import (US-149). Does NOT hit the HF Hub yet —
  records the import intent as a single placeholder `dataset_entries` row so
  the calling pipeline can wire a real fetch later. Returns `{:ok, %{version:
  v, placeholder_entry: e}}`.
  """
  def import_from_huggingface(%Dataset{} = dataset, params) when is_map(params) do
    hf_id = Map.get(params, "dataset_id") || Map.get(params, :dataset_id)
    split = Map.get(params, "split") || Map.get(params, :split) || "train"
    subset = Map.get(params, "subset") || Map.get(params, :subset)

    cond do
      is_nil(hf_id) or hf_id == "" ->
        {:error, :missing_dataset_id}

      true ->
        with {:ok, draft} <- ensure_draft(dataset) do
          placeholder_attrs = %{
            entry_key: "hf:#{hf_id}:#{split}",
            input: %{
              "huggingface" => true,
              "dataset_id" => hf_id,
              "split" => split,
              "subset" => subset,
              "status" => "pending_fetch"
            },
            expected_output: %{"status" => "pending_fetch"},
            tags: ["source:huggingface:#{hf_id}"],
            notes: "HuggingFace import stub — real fetch deferred to Stage 9+ worker"
          }

          case insert_import_entry(dataset, draft, placeholder_attrs) do
            {:ok, entry} -> {:ok, %{version: draft, placeholder_entry: entry}}
            {:skip, reason} -> {:error, {:already_staged, reason}}
            {:error, reason} -> {:error, reason}
          end
        end
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Parquet export stub (US-150) — returns a render plan; serialization deferred
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Build a Parquet export plan for a published dataset version. Returns the
  schema + entries — callers serialize via their chosen parquet backend.
  """
  def parquet_export_plan(organization_id, dataset_id) do
    with {:ok, v} <- resolve_current_version(organization_id, dataset_id) do
      entries = list_entries(v)

      {:ok,
       %{
         version: v,
         schema: [
           {"entry_key", :string},
           {"input", :json},
           {"expected_output", :json},
           {"tags", {:list, :string}},
           {"notes", :string}
         ],
         rows:
           Enum.map(entries, fn e ->
             %{
               "entry_key" => e.entry_key,
               "input" => e.input,
               "expected_output" => e.expected_output,
               "tags" => e.tags,
               "notes" => e.notes
             }
           end)
       }}
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Run linking helper (US-125 — validation only)
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Validate a dataset-run fan-out plan: the dataset version must be pinnable in
  `organization_id`, and every persona_version_id must be pinnable in the same
  org. Caller composes the actual `runs` row.
  """
  def validate_run_fanout(organization_id, dataset_version_id, persona_version_ids) do
    cond do
      not pinnable?(organization_id, dataset_version_id) ->
        {:error, :dataset_version_not_in_org}

      not is_list(persona_version_ids) ->
        {:error, :persona_list_required}

      true ->
        bad =
          Enum.reject(persona_version_ids, fn pvid ->
            Codefresh.Personas.pinnable?(organization_id, pvid)
          end)

        case bad do
          [] -> :ok
          [_ | _] -> {:error, {:personas_not_in_org, bad}}
        end
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Flagged captures (US-106, US-107, US-108, US-109, US-147 manual)
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Create a manual flagged capture (US-106). `auto_rule_id` may be supplied by
  the rule-engine (US-147) but is optional for manual flags.
  """
  def flag_capture(attrs) do
    %FlaggedCapture{}
    |> FlaggedCapture.create_changeset(attrs)
    |> Repo.insert()
  end

  def get_capture(organization_id, id) do
    Repo.one(
      from c in FlaggedCapture,
        where: c.organization_id == ^organization_id and c.id == ^id
    )
  rescue
    Ecto.Query.CastError -> nil
  end

  @doc """
  Browse the flagged captures library (US-107). Supports filters:
    * `:reason` (exact), `:flagged_by_user_id` (exact), `:promoted` (`:any`,
      `:unpromoted`, `:to_script`, `:to_dataset`), `:tag` (membership),
      `:q` (typeahead over title/notes), `:since` / `:until` (UTC DateTime)
  """
  def list_captures(organization_id, opts \\ []) do
    q =
      from c in FlaggedCapture,
        where: c.organization_id == ^organization_id,
        order_by: [desc: c.inserted_at]

    q
    |> capture_filter_reason(Keyword.get(opts, :reason))
    |> capture_filter_user(Keyword.get(opts, :flagged_by_user_id))
    |> capture_filter_promoted(Keyword.get(opts, :promoted))
    |> capture_filter_tag(Keyword.get(opts, :tag))
    |> capture_filter_search(Keyword.get(opts, :q))
    |> capture_filter_since(Keyword.get(opts, :since))
    |> capture_filter_until(Keyword.get(opts, :until))
    |> Repo.all()
  end

  defp capture_filter_reason(q, nil), do: q
  defp capture_filter_reason(q, ""), do: q
  defp capture_filter_reason(q, r), do: from(c in q, where: c.reason == ^r)

  defp capture_filter_user(q, nil), do: q
  defp capture_filter_user(q, ""), do: q
  defp capture_filter_user(q, uid), do: from(c in q, where: c.flagged_by_user_id == ^uid)

  defp capture_filter_promoted(q, nil), do: q
  defp capture_filter_promoted(q, :any), do: q

  defp capture_filter_promoted(q, :unpromoted) do
    from c in q,
      where: is_nil(c.promoted_to_script_node_id) and is_nil(c.promoted_to_dataset_entry_id)
  end

  defp capture_filter_promoted(q, :to_script) do
    from c in q, where: not is_nil(c.promoted_to_script_node_id)
  end

  defp capture_filter_promoted(q, :to_dataset) do
    from c in q, where: not is_nil(c.promoted_to_dataset_entry_id)
  end

  defp capture_filter_tag(q, nil), do: q
  defp capture_filter_tag(q, ""), do: q
  defp capture_filter_tag(q, tag), do: from(c in q, where: ^tag in c.tags)

  defp capture_filter_search(q, nil), do: q
  defp capture_filter_search(q, ""), do: q

  defp capture_filter_search(q, s) do
    like = "%#{String.downcase(s)}%"

    from c in q,
      where:
        fragment("lower(?) LIKE ?", c.title, ^like) or
          fragment("lower(coalesce(?, '')) LIKE ?", c.notes, ^like)
  end

  defp capture_filter_since(q, nil), do: q
  defp capture_filter_since(q, %DateTime{} = t), do: from(c in q, where: c.inserted_at >= ^t)

  defp capture_filter_until(q, nil), do: q
  defp capture_filter_until(q, %DateTime{} = t), do: from(c in q, where: c.inserted_at <= ^t)

  @doc """
  Promote a flagged capture to a script node (US-108). Inserts the capture's
  `input` as the prompt body of a new user_turn node on the target script
  draft. The caller supplies a validated `script_node_id` (already created by
  Stage 3 APIs) — this pins the promotion on the capture.
  """
  def promote_to_script_node(%FlaggedCapture{} = capture, script_node_id)
      when is_binary(script_node_id) do
    capture
    |> FlaggedCapture.promote_to_script_node_changeset(script_node_id)
    |> Repo.update()
  end

  @doc """
  Promote a flagged capture to a dataset entry (US-109). Creates a new entry on
  the target dataset's open draft using `capture.input` as input and
  `capture.agent_response` as expected_output (unless `negative?: true`, which
  keeps the response as input but stamps `expected_output` with a "must-not"
  marker). Records `promoted_to_dataset_entry_id` on the capture.

  Opts:
    * `:negative?` (boolean) — flip into bug-promotion semantics (US-109)
    * `:extra_tags` (list of strings) — merged with capture tags
  """
  def promote_to_dataset_entry(%FlaggedCapture{} = capture, %Dataset{} = dataset, opts \\ []) do
    negative? = Keyword.get(opts, :negative?, false)
    extra_tags = Keyword.get(opts, :extra_tags, [])

    expected =
      if negative? do
        %{"direction" => "negative", "must_not_produce" => capture.agent_response}
      else
        capture.agent_response
      end

    Multi.new()
    |> Multi.run(:same_org, fn _repo, _ ->
      if capture.organization_id == dataset.organization_id do
        {:ok, :ok}
      else
        {:error, :cross_org_promotion}
      end
    end)
    |> Multi.run(:draft, fn _repo, _ -> ensure_draft(dataset) end)
    |> Multi.insert(:entry, fn %{draft: draft} ->
      DatasetEntry.create_changeset(%DatasetEntry{}, %{
        dataset_version_id: draft.id,
        organization_id: dataset.organization_id,
        entry_key: "capture-#{String.slice(capture.id, 0, 8)}-#{System.unique_integer([:positive])}",
        input: capture.input,
        expected_output: expected,
        tags: Enum.uniq((capture.tags || []) ++ extra_tags),
        notes: "Promoted from flagged capture: #{capture.title}"
      })
    end)
    |> Multi.update(:pin_promotion, fn %{entry: entry} ->
      FlaggedCapture.promote_to_dataset_entry_changeset(capture, entry.id)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{entry: entry, pin_promotion: updated}} ->
        {:ok, %{capture: updated, entry: entry}}

      {:error, _step, reason, _} ->
        {:error, reason}
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Helpers
  # ──────────────────────────────────────────────────────────────────────────

  defp normalize(attrs) do
    for {k, v} <- attrs, into: %{} do
      key = if is_atom(k), do: k, else: safe_atom(to_string(k))
      {key, v}
    end
  end

  defp safe_atom(str) do
    String.to_existing_atom(str)
  rescue
    ArgumentError -> String.to_atom(str)
  end
end
