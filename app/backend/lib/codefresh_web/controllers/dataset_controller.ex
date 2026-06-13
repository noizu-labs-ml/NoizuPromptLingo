defmodule CodefreshWeb.DatasetController do
  @moduledoc """
  Stage 9 datasets controller. Covers:
    * Head CRUD (US-101, US-110)
    * Version publish + current-version resolver (US-102 / US-110)
    * Manual entry authoring (US-103)
    * CSV / JSONL import (US-104)
    * HuggingFace stub (US-149)
    * Parquet export plan (US-150)
    * Dataset-run fan-out validator (US-125)
  """

  use CodefreshWeb, :controller

  alias Codefresh.{Datasets, Organizations}
  alias Codefresh.Guardian

  # ──────────────────────────────────────────────────────────────────────────
  # Head CRUD (US-101)
  # ──────────────────────────────────────────────────────────────────────────

  def index(conn, %{"organization_id" => org_id} = params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer") do
      opts =
        []
        |> maybe_put(:search, params["q"])
        |> maybe_put(:type, params["type"])
        |> maybe_put(:include_archived, truthy?(params["include_archived"]))

      rows = Datasets.list_datasets(org_id, opts)
      json(conn, %{datasets: Enum.map(rows, &render_dataset/1)})
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def create(conn, %{"organization_id" => org_id, "dataset" => params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor") do
      attrs =
        params
        |> Map.put("organization_id", org_id)
        |> Map.put("created_by_user_id", user.id)

      case Datasets.create_dataset(attrs) do
        {:ok, d} ->
          conn |> put_status(:created) |> json(%{dataset: render_dataset(d)})

        {:error, cs} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
      end
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def create(conn, _),
    do: bad_request(conn, "Expected {dataset: {name, slug?, description?, type?}}")

  def show(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         d when not is_nil(d) <- Datasets.get_dataset(org_id, id) do
      versions = Datasets.list_versions(d)

      current =
        case d.current_version_id do
          nil -> nil
          vid -> Enum.find(versions, &(&1.id == vid))
        end

      json(conn, %{
        dataset: render_dataset(d),
        current_version: render_version(current),
        versions: Enum.map(versions, &render_version_summary/1)
      })
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def update(conn, %{"organization_id" => org_id, "id" => id, "dataset" => params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         d when not is_nil(d) <- Datasets.get_dataset(org_id, id),
         {:ok, updated} <- Datasets.update_dataset(d, params) do
      json(conn, %{dataset: render_dataset(updated)})
    else
      nil ->
        send_resp(conn, 404, "")

      {:error, :forbidden} ->
        send_resp(conn, 403, "")

      {:error, :not_a_member} ->
        send_resp(conn, 404, "")

      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
    end
  end

  def archive(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         d when not is_nil(d) <- Datasets.get_dataset(org_id, id),
         {:ok, _} <- Datasets.archive_dataset(d) do
      send_resp(conn, 204, "")
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
      {:error, _} -> send_resp(conn, 422, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Publish (US-102 + US-110)
  # ──────────────────────────────────────────────────────────────────────────

  def publish(conn, %{"organization_id" => org_id, "id" => id} = params) do
    user = Guardian.Plug.current_resource(conn)
    version_params = params["version"] || %{}

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         d when not is_nil(d) <- Datasets.get_dataset(org_id, id) do
      attrs = Map.put(version_params, "published_by_user_id", user.id)

      case Datasets.publish_version(d, attrs) do
        {:ok, :published, v} ->
          conn |> put_status(:created) |> json(%{version: render_version(v), status: "published"})

        {:ok, :noop, v} ->
          conn
          |> put_status(:ok)
          |> json(%{
            version: render_version(v),
            status: "noop",
            note: "identical body already published"
          })

        {:error, :no_draft} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "nothing to publish — add entries first"})

        {:error, :rubric_not_pinnable} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "default_rubric_version_id must resolve to a rubric in this org"})

        {:error, reason} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: inspect(reason)})
      end
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def current_version(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer") do
      case Datasets.resolve_current_version(org_id, id) do
        {:ok, v} -> json(conn, %{version: render_version(v)})
        {:error, :not_found} -> send_resp(conn, 404, "")

        {:error, :not_published} ->
          conn
          |> put_status(:conflict)
          |> json(%{error: "dataset has no published version"})
      end
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Entry authoring + imports (US-103 / US-104)
  # ──────────────────────────────────────────────────────────────────────────

  def add_entry(conn, %{"organization_id" => org_id, "id" => id, "entry" => params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         d when not is_nil(d) <- Datasets.get_dataset(org_id, id) do
      case Datasets.add_entry(d, params) do
        {:ok, {version, entry}} ->
          conn
          |> put_status(:created)
          |> json(%{
            version: render_version_summary(version),
            entry: render_entry(entry)
          })

        {:error, :expected_output_required} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "expected_output is required for request_response datasets"})

        {:error, cs} when is_struct(cs, Ecto.Changeset) ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})

        {:error, reason} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: inspect(reason)})
      end
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def add_entry(conn, _), do: bad_request(conn, "Expected {entry: {input, expected_output?}}")

  def import_csv(conn, %{"organization_id" => org_id, "id" => id} = params) do
    user = Guardian.Plug.current_resource(conn)
    raw = params["csv"] || ""
    mapping = params["mapping"] || %{}

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         d when not is_nil(d) <- Datasets.get_dataset(org_id, id) do
      case Datasets.import_csv(d, raw, mapping) do
        {:ok, %{version: v, inserted: n, skipped: m}} ->
          conn
          |> put_status(:created)
          |> json(%{
            version: render_version_summary(v),
            inserted: n,
            skipped: m
          })

        {:error, {:row, line, reason}} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "row #{line} failed", reason: inspect(reason)})

        {:error, reason} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: inspect(reason)})
      end
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def import_jsonl(conn, %{"organization_id" => org_id, "id" => id} = params) do
    user = Guardian.Plug.current_resource(conn)
    raw = params["jsonl"] || ""

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         d when not is_nil(d) <- Datasets.get_dataset(org_id, id) do
      case Datasets.import_jsonl(d, raw) do
        {:ok, %{version: v, inserted: n, skipped: m}} ->
          conn
          |> put_status(:created)
          |> json(%{
            version: render_version_summary(v),
            inserted: n,
            skipped: m
          })

        {:error, {:row, line, reason}} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "line #{line} failed", reason: inspect(reason)})

        {:error, reason} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: inspect(reason)})
      end
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def import_huggingface(conn, %{"organization_id" => org_id, "id" => id} = params) do
    user = Guardian.Plug.current_resource(conn)
    hf_params = params["huggingface"] || params["params"] || %{}

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         d when not is_nil(d) <- Datasets.get_dataset(org_id, id) do
      case Datasets.import_from_huggingface(d, hf_params) do
        {:ok, %{version: v, placeholder_entry: e}} ->
          conn
          |> put_status(:accepted)
          |> json(%{
            version: render_version_summary(v),
            placeholder_entry: render_entry(e),
            note: "HuggingFace fetch is stubbed; a worker will hydrate entries later"
          })

        {:error, :missing_dataset_id} ->
          bad_request(conn, "Expected {huggingface: {dataset_id, split?, subset?}}")

        {:error, reason} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: inspect(reason)})
      end
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Parquet export plan (US-150)
  # ──────────────────────────────────────────────────────────────────────────

  def export_plan(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer") do
      case Datasets.parquet_export_plan(org_id, id) do
        {:ok, plan} ->
          json(conn, %{
            version: render_version_summary(plan.version),
            schema:
              Enum.map(plan.schema, fn {col, t} -> %{"column" => col, "type" => inspect(t)} end),
            row_count: length(plan.rows)
          })

        {:error, :not_found} ->
          send_resp(conn, 404, "")

        {:error, :not_published} ->
          conn |> put_status(:conflict) |> json(%{error: "dataset has no published version"})
      end
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Dataset-run fan-out validator (US-125)
  # ──────────────────────────────────────────────────────────────────────────

  def validate_fanout(conn, %{
        "organization_id" => org_id,
        "dataset_version_id" => dvid,
        "persona_version_ids" => pvids
      })
      when is_list(pvids) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor") do
      case Datasets.validate_run_fanout(org_id, dvid, pvids) do
        :ok ->
          json(conn, %{status: "ok", dataset_version_id: dvid, persona_count: length(pvids)})

        {:error, reason} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: inspect(reason)})
      end
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def validate_fanout(conn, _),
    do: bad_request(conn, "Expected {dataset_version_id, persona_version_ids: [...]}")

  # ──────────────────────────────────────────────────────────────────────────
  # Renderers
  # ──────────────────────────────────────────────────────────────────────────

  defp render_dataset(d) do
    %{
      id: d.id,
      slug: d.slug,
      name: d.name,
      description: d.description,
      type: d.type,
      current_version_id: d.current_version_id,
      archived_at: d.archived_at,
      inserted_at: d.inserted_at,
      updated_at: d.updated_at
    }
  end

  defp render_version(nil), do: nil

  defp render_version(v) do
    %{
      id: v.id,
      version_number: v.version_number,
      parent_version_id: v.parent_version_id,
      default_rubric_version_id: v.default_rubric_version_id,
      checksum: Base.encode16(v.checksum, case: :lower),
      published_by_user_id: v.published_by_user_id,
      published_at: v.inserted_at
    }
  end

  defp render_version_summary(v) do
    %{
      id: v.id,
      version_number: v.version_number,
      checksum: Base.encode16(v.checksum, case: :lower),
      published_at: v.inserted_at
    }
  end

  defp render_entry(e) do
    %{
      id: e.id,
      entry_key: e.entry_key,
      input: e.input,
      expected_output: e.expected_output,
      tags: e.tags,
      notes: e.notes,
      dataset_version_id: e.dataset_version_id,
      inserted_at: e.inserted_at
    }
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Helpers
  # ──────────────────────────────────────────────────────────────────────────

  defp bad_request(conn, msg), do: conn |> put_status(:bad_request) |> json(%{error: msg})

  defp maybe_put(opts, _k, nil), do: opts
  defp maybe_put(opts, _k, ""), do: opts
  defp maybe_put(opts, _k, false), do: opts
  defp maybe_put(opts, k, v), do: Keyword.put(opts, k, v)

  defp truthy?(v) when v in [true, "true", "1", 1], do: true
  defp truthy?(_), do: false
end
