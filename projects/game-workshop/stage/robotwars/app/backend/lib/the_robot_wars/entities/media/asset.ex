defmodule TheRobotWars.Media.Asset do
  use Noizu.Entities

  @vsn 1.0
  @repo TheRobotWars.Media
  @sref "media-asset"
  @persistence ecto_store(TheRobotWars.Schema.Media.Asset, TheRobotWars.Repo)
  @derive Noizu.Entity.Store.Ecto.EntityProtocol
  def_entity do
    id(:uuid)
    field :media_type, nil, {:ecto, TheRobotWars.Schema.Media.Asset.__schema__(:type, :media_type)}
    field :file_type, nil, {:ecto, TheRobotWars.Schema.Media.Asset.__schema__(:type, :file_type)}
    field :file, nil, :string
    field :short_id, nil, :string
    field :visibility, "private", :string
    field :owner_type, nil, :string
    field :owner_id, nil, :uuid
    field :flagged, nil, :boolean
    field :settings, %{}, :map
    field :time_stamp, nil, Noizu.Entity.TimeStamp
  end

  jason_encoder()
end
