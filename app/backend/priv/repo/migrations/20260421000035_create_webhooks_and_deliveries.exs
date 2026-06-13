defmodule Codefresh.Repo.Migrations.CreateWebhooksAndDeliveries do
  use Ecto.Migration

  def change do
    create table(:webhooks) do
      add :organization_id, references(:organizations, type: :uuid, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :endpoint_url, :text, null: false
      add :secret, :binary, null: false
      add :event_filters, {:array, :string}, null: false, default: []
      add :active, :boolean, null: false, default: true
      add :created_by_user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      timestamps(type: :utc_datetime)
    end

    create index(:webhooks, [:organization_id, :active])

    create table(:webhook_deliveries) do
      add :webhook_id, references(:webhooks, type: :uuid, on_delete: :delete_all), null: false
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :event_type, :string, null: false
      add :event_payload, :map, null: false, default: %{}
      add :http_status, :integer
      add :error_message, :text
      add :retry_count, :integer, null: false, default: 0
      add :next_retry_at, :utc_datetime
      add :sent_at, :utc_datetime
      add :inserted_at, :utc_datetime, null: false
    end

    create index(:webhook_deliveries, [:webhook_id, :sent_at])
    create index(:webhook_deliveries, [:next_retry_at], where: "sent_at IS NULL")
  end
end
