defmodule Noizu.PM.Projects.Project do
  use Noizu.Entities

  @vsn 1.0
  @repo Noizu.PM.Projects
  @sref "project"
  @persistence ecto_store(Noizu.PM.Schema.Projects.Project, Noizu.PM.Repo)
  @derive Noizu.Entity.Store.Ecto.EntityProtocol

  def_entity do
    id(:uuid)

    @config auto: false
    @store name: :organization_id
    field :organization, nil, Noizu.PM.Organizations.OrganizationReference

    field :name, nil, :string
    field :slug, nil, :string
    field :description, nil, :string
    field :settings, %{}, :map
    field :status, "active", :string
    field :archived_at, nil, :utc_datetime_usec

    # TRP superset.
    field :default_methodology, nil, :string

    # Items use raw schemas (no entity wrapper), so the default-queue link is a
    # plain uuid (the column default_queue_id) rather than an entity reference.
    @config auto: false
    @store name: :default_queue_id
    field :default_queue, nil, :uuid

    field :time_stamp, nil, Noizu.Entity.TimeStamp
  end

  jason_encoder()
end
