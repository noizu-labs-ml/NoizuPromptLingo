defmodule NoizuPromptLingua.Sessions.Session do
  use Noizu.Entities

  @vsn 1.0
  @repo NoizuPromptLingua.Sessions
  @sref "session"
  @persistence ecto_store(NoizuPromptLingua.Schema.Sessions.Session, NoizuPromptLingua.Repo)
  @derive Noizu.Entity.Store.Ecto.EntityProtocol

  def_entity do
    id(:uuid)

    @config auto: false
    @store name: :organization_id
    field :organization, nil, NoizuPromptLingua.Organizations.OrganizationReference

    @config auto: false
    @store name: :project_id
    field :project, nil, NoizuPromptLingua.Projects.ProjectReference

    field :title, nil, :string
    field :description, nil, :string
    field :status, "active", :string
    field :model, nil, :string
    field :runner, nil, :string
    field :archived_at, nil, :utc_datetime_usec
    field :time_stamp, nil, Noizu.Entity.TimeStamp
  end

  jason_encoder()
end
