defmodule Starter.Migration do
  defmacro __using__(_) do
    quote do
      use Ecto.Migration
      import Ecto.Query
      import Ecto.Changeset
      import Starter.Migration
    end
  end

  import Ecto.Migration
  alias Ecto.Migration.Runner

  def extended_timestamps(opts \\ [])

  def extended_timestamps(opts) when is_list(opts) do
    opts = Keyword.merge(Runner.repo_config(:migration_timestamps, []), opts)
    opts = Keyword.put_new(opts, :null, false)

    {type, opts} = Keyword.pop(opts, :type, :naive_datetime)
    {deleted_at, opts} = Keyword.pop(opts, :deleted_at, :deleted_at)
    {inserted_at, opts} = Keyword.pop(opts, :inserted_at, :inserted_at)
    {updated_at, opts} = Keyword.pop(opts, :updated_at, :updated_at)

    if deleted_at != false, do: add(deleted_at, type, Keyword.put(opts, :null, true))
    if inserted_at != false, do: add(inserted_at, type, opts)
    if updated_at != false, do: add(updated_at, type, opts)
  end

  def drop_entity_reference_triggers(table) do
    execute "DROP TRIGGER trigger_#{table}_after_delete ON #{table}"
    execute "DROP TRIGGER trigger_#{table}_before_insert ON #{table}"
  end

  def create_entity_reference_triggers(table) do
    # On Insert
    execute """
    CREATE OR REPLACE TRIGGER trigger_#{table}_before_insert
    BEFORE INSERT ON #{table}
    FOR EACH ROW
    EXECUTE FUNCTION on_create_entity();
    """

    # On Delete
    execute """
    CREATE OR REPLACE TRIGGER trigger_#{table}_after_delete
    AFTER DELETE ON #{table}
    FOR EACH ROW
    EXECUTE FUNCTION on_delete_entity();
    """
  end

  def create_enum(name, values) do
    values = Enum.map(values, &"'#{&1}'") |> Enum.join(", ")
    execute "CREATE TYPE #{name} as ENUM (#{values})"
  end

  def drop_enum(name) do
    execute "DROP TYPE #{name}"
  end
end
