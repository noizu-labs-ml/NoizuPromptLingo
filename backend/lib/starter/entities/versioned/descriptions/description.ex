defmodule Starter.Versioned.Descriptions.Description do
  use Noizu.Entities

  @vsn 1.0
  @repo Starter.Versioned.Descriptions
  @sref "versioned-description"
  @derive Noizu.Entity.Store.Ecto.EntityProtocol
  @persistence ecto_store(Starter.Schema.Versioned.Descriptions.Description, Starter.Repo)
  def_entity do
    id(:uuid)
    field :title, nil, :string
    field :body, nil, :string
    field :time_stamp, nil, Noizu.Entity.TimeStamp
  end

  jason_encoder()
end
