defmodule ExLiteLLM.Schema.Repo.Migrations.CreateRequestLogs do
  use Ecto.Migration

  def change do
    create table(:request_logs) do
      add(:method, :string)
      add(:path, :string)
      add(:model, :string)
      add(:target, :string)
      add(:status, :integer)
      add(:duration_ms, :integer)
      add(:req_bytes, :integer)
      add(:resp_bytes, :integer)
      add(:stream, :boolean, default: false)
      add(:error, :string)
      add(:inserted_at, :utc_datetime_usec)
    end

    create(index(:request_logs, [:inserted_at]))
    create(index(:request_logs, [:status]))
  end
end
