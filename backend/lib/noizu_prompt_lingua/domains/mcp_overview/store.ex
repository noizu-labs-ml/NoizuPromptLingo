defmodule NoizuPromptLingua.Domains.MCPOverview.Store do
  @moduledoc """
  Persistence + pgvector nearest-neighbor for `mcp_overview` (design spec §5).

  Two tables:

    * `mcp_overviews` — cached, reviewable per-task overviews. `task_embedding`
      (1536-d, cosine) drives recall; `status` gates the review loop
      (`generated` → `approved` | `rejected`).
    * `mcp_tool_vectors` — per-tool description embeddings for a scope, used by the
      generator to FOCUS a fresh overview (near tools get depth, far get a line).

  DIVERGENCE (explicit instruction 2026-07-16): vectors go to postgres/pgvector,
  NOT Weaviate (contra `Domains.Memory.VectorStore`). Distance metric: **cosine**
  (`<=>`). Recall threshold: `:mcp_overview_similarity_threshold` (cosine distance,
  default 0.25); a hit must be within it. Ordering prefers `approved` over
  `generated`, then ascending distance.
  """

  # ── schemas ───────────────────────────────────────────────────────────────
  # Defined before the query functions that reference their structs (nested
  # modules must be compiled earlier in the source than their first use).

  defmodule Overview do
    @moduledoc "Cached, reviewable per-task MCP endpoint overview (pgvector-recalled)."
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key {:id, :binary_id, autogenerate: true}
    @statuses ~w(generated approved rejected)

    schema "mcp_overviews" do
      field :scope_slug, :string
      field :task_text, :string
      field :task_embedding, Pgvector.Ecto.Vector
      field :overview_md, :string
      field :runner, :string
      field :model, :string
      field :verbosity, :integer
      field :status, :string, default: "generated"

      timestamps(type: :utc_datetime)
    end

    def statuses, do: @statuses

    def changeset(row, attrs) do
      row
      |> cast(attrs, [
        :scope_slug,
        :task_text,
        :task_embedding,
        :overview_md,
        :runner,
        :model,
        :verbosity,
        :status
      ])
      |> validate_required([:scope_slug, :task_text, :overview_md, :status])
      |> validate_inclusion(:status, @statuses)
    end
  end

  defmodule ToolVector do
    @moduledoc "Per-tool description embedding for a scope; focuses fresh overviews."
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key {:id, :binary_id, autogenerate: true}

    schema "mcp_tool_vectors" do
      field :scope_slug, :string
      field :group_id, :string
      field :tool_name, :string
      field :verbosity, :integer
      field :description_hash, :string
      field :embedding, Pgvector.Ecto.Vector

      timestamps(type: :utc_datetime)
    end

    def changeset(row, attrs) do
      row
      |> cast(attrs, [
        :scope_slug,
        :group_id,
        :tool_name,
        :verbosity,
        :description_hash,
        :embedding
      ])
      |> validate_required([:scope_slug, :group_id, :tool_name, :description_hash])
      |> unique_constraint([:scope_slug, :tool_name, :description_hash],
        name: :uq_mcp_tool_vectors_scope_tool_hash
      )
    end
  end

  import Ecto.Query
  alias NoizuPromptLingua.Repo

  @default_threshold 0.25

  # ── config ───────────────────────────────────────────────────────────────

  @doc "Cosine-distance recall threshold. A cached overview must be within this to hit."
  def similarity_threshold do
    Application.get_env(
      :noizu_prompt_lingua,
      :mcp_overview_similarity_threshold,
      @default_threshold
    )
  end

  # ── mcp_overviews ─────────────────────────────────────────────────────────

  @doc """
  Nearest cached overview for `scope_slug` within the cosine-distance threshold.
  Prefers `approved`, then `generated`; `rejected` never matches. Rows without an
  embedding are ignored (they can't be NN-matched). Returns `{:ok, %Overview{}}`
  or `:miss`.
  """
  def nearest_overview(scope_slug, task_vec, opts \\ []) do
    threshold = Keyword.get(opts, :threshold, similarity_threshold())
    qv = Pgvector.new(task_vec)

    query =
      from(o in Overview,
        where: o.scope_slug == ^scope_slug,
        where: o.status in ["approved", "generated"],
        where: not is_nil(o.task_embedding),
        where: fragment("(? <=> ?)", o.task_embedding, ^qv) <= ^threshold,
        order_by: [
          asc: fragment("CASE WHEN ? = 'approved' THEN 0 ELSE 1 END", o.status),
          asc: fragment("(? <=> ?)", o.task_embedding, ^qv)
        ],
        limit: 1
      )

    case Repo.one(query) do
      nil -> :miss
      %Overview{} = row -> {:ok, row}
    end
  end

  @doc "Insert an overview row. `attrs` may include `task_embedding` (a list of floats)."
  def insert_overview(attrs) do
    %Overview{}
    |> Overview.changeset(attrs)
    |> Repo.insert()
  end

  def get_overview(id), do: Repo.get(Overview, id)

  @doc """
  List overviews, newest first. Filters: `:scope_slug`, `:status`, `:limit` (default 100).
  """
  def list_overviews(opts \\ []) do
    Overview
    |> maybe_where(:scope_slug, opts[:scope_slug])
    |> maybe_where(:status, opts[:status])
    |> order_by([o], desc: o.inserted_at)
    |> limit(^(opts[:limit] || 100))
    |> Repo.all()
  end

  @doc "Set an overview's status (`approved` | `rejected` | `generated`)."
  def set_status(id, status) when status in ["approved", "rejected", "generated"] do
    update_overview(id, %{status: status})
  end

  @doc "Edit `overview_md`; editing implies approval (per review-flow spec §5)."
  def edit_overview(id, overview_md) do
    update_overview(id, %{overview_md: overview_md, status: "approved"})
  end

  defp update_overview(id, attrs) do
    case get_overview(id) do
      nil -> {:error, :not_found}
      row -> row |> Overview.changeset(attrs) |> Repo.update()
    end
  end

  # ── mcp_tool_vectors ──────────────────────────────────────────────────────

  @doc "The current tool-vector row for `{scope_slug, tool_name}` (nil if unindexed)."
  def get_tool_vector(scope_slug, tool_name) do
    ToolVector
    |> where([t], t.scope_slug == ^scope_slug and t.tool_name == ^tool_name)
    |> Repo.one()
  end

  @doc "All tool-vector rows for a scope."
  def list_tool_vectors(scope_slug) do
    ToolVector
    |> where([t], t.scope_slug == ^scope_slug)
    |> Repo.all()
  end

  @doc """
  Replace the current tool-vector for `{scope_slug, tool_name}` with a fresh
  `{description_hash, embedding}`. Deletes any prior rows for that tool first so a
  single current vector per tool is kept (the DB unique is
  `(scope_slug, tool_name, description_hash)`).
  """
  def put_tool_vector(attrs) do
    scope_slug = fetch(attrs, :scope_slug)
    tool_name = fetch(attrs, :tool_name)

    Repo.transaction(fn ->
      ToolVector
      |> where([t], t.scope_slug == ^scope_slug and t.tool_name == ^tool_name)
      |> Repo.delete_all()

      case %ToolVector{} |> ToolVector.changeset(attrs) |> Repo.insert() do
        {:ok, row} -> row
        {:error, cs} -> Repo.rollback(cs)
      end
    end)
  end

  @doc """
  Tool vectors for `scope_slug` ranked by ascending cosine distance to `task_vec`.
  Returns `[%{tool_name, group_id, distance}]` (nearest first), capped at `:limit`.
  """
  def nearest_tool_vectors(scope_slug, task_vec, opts \\ []) do
    limit = Keyword.get(opts, :limit, 100)
    qv = Pgvector.new(task_vec)

    from(t in ToolVector,
      where: t.scope_slug == ^scope_slug and not is_nil(t.embedding),
      order_by: [asc: fragment("(? <=> ?)", t.embedding, ^qv)],
      limit: ^limit,
      select: %{
        tool_name: t.tool_name,
        group_id: t.group_id,
        distance: fragment("(? <=> ?)", t.embedding, ^qv)
      }
    )
    |> Repo.all()
  end

  # ── helpers ───────────────────────────────────────────────────────────────

  defp maybe_where(q, _field, nil), do: q
  defp maybe_where(q, :scope_slug, v), do: where(q, [o], o.scope_slug == ^v)
  defp maybe_where(q, :status, v), do: where(q, [o], o.status == ^v)

  defp fetch(attrs, key), do: Map.get(attrs, key) || Map.get(attrs, to_string(key))
end
