defmodule NoizuPromptLingua.Domains.MockMCP do
  import Ecto.Query, except: [update: 2]
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{MockMCPDefinition, MockMCPCallLog}

  # ── Definition CRUD ──────────────────────────────────────────

  def create(attrs) do
    %MockMCPDefinition{}
    |> MockMCPDefinition.changeset(attrs)
    |> Repo.insert()
  end

  def get(slug_or_id) do
    case Ecto.UUID.cast(slug_or_id) do
      {:ok, _} ->
        MockMCPDefinition
        |> where([d], d.id == ^slug_or_id or d.slug == ^slug_or_id)
        |> Repo.one()
      :error ->
        Repo.get_by(MockMCPDefinition, slug: slug_or_id)
    end
  end

  def get_active(slug) do
    MockMCPDefinition
    |> where([d], d.slug == ^slug and d.status == "active")
    |> Repo.one()
  end

  def update(slug_or_id, attrs) do
    case get(slug_or_id) do
      nil -> {:error, :not_found}
      definition ->
        definition
        |> MockMCPDefinition.changeset(attrs)
        |> Repo.update()
    end
  end

  def delete(slug_or_id) do
    case get(slug_or_id) do
      nil -> {:error, :not_found}
      definition -> Repo.delete(definition)
    end
  end

  def activate(slug_or_id) do
    update(slug_or_id, %{status: "active"})
  end

  def archive(slug_or_id) do
    update(slug_or_id, %{status: "archived"})
  end

  def list(opts \\ []) do
    MockMCPDefinition
    |> maybe_filter(:status, opts[:status])
    |> maybe_filter(:project_id, opts[:project_id])
    |> order_by([d], desc: d.updated_at)
    |> limit(^(opts[:limit] || 50))
    |> Repo.all()
  end

  # ── Tool Definitions ─────────────────────────────────────────

  def set_tools(slug_or_id, tools_json) when is_list(tools_json) do
    update(slug_or_id, %{tools_json: tools_json})
  end

  def get_tools(slug) do
    case get_active(slug) do
      nil -> []
      def_ -> def_.tools_json || []
    end
  end

  # ── Call Logging ─────────────────────────────────────────────

  def log_call(definition_id, attrs) do
    %MockMCPCallLog{}
    |> MockMCPCallLog.changeset(Map.put(attrs, :definition_id, definition_id))
    |> Repo.insert()
  end

  def list_calls(definition_id, opts \\ []) do
    MockMCPCallLog
    |> where([l], l.definition_id == ^definition_id)
    |> order_by([l], desc: l.inserted_at)
    |> limit(^(opts[:limit] || 100))
    |> Repo.all()
  end

  # ── DB Provisioning ─────────────────────────────────────────

  def provision_db(slug_or_id) do
    case get(slug_or_id) do
      nil -> {:error, :not_found}
      %{db_provisioned: true} = def_ -> {:ok, def_}
      def_ ->
        db_name = "mockmcp_#{String.replace(def_.slug, "-", "_")}"
        case create_database(db_name) do
          :ok ->
            def_
            |> MockMCPDefinition.changeset(%{db_name: db_name, db_provisioned: true})
            |> Repo.update()
          {:error, reason} -> {:error, reason}
        end
    end
  end

  defp create_database(db_name) do
    safe_name = String.replace(db_name, ~r/[^a-z0-9_]/, "")
    try do
      Ecto.Adapters.SQL.query!(Repo, "CREATE DATABASE #{safe_name}", [])
      user = "mockmcp_#{safe_name}"
      password = Base.encode64(:crypto.strong_rand_bytes(24))
      Ecto.Adapters.SQL.query!(Repo, "CREATE USER #{user} WITH PASSWORD '#{password}'", [])
      Ecto.Adapters.SQL.query!(Repo, "GRANT ALL PRIVILEGES ON DATABASE #{safe_name} TO #{user}", [])
      :ok
    rescue
      e in Postgrex.Error ->
        if e.postgres.code == :duplicate_database, do: :ok, else: {:error, inspect(e)}
      e -> {:error, inspect(e)}
    end
  end

  # ── Private ─────────────────────────────────────────────────

  defp maybe_filter(q, _field, nil), do: q
  defp maybe_filter(q, :status, v), do: where(q, [d], d.status == ^v)
  defp maybe_filter(q, :project_id, v), do: where(q, [d], d.project_id == ^v)
end
