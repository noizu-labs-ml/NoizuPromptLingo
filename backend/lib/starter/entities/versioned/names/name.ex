defmodule Starter.Versioned.Names.Name do
  use Noizu.Entities

  @vsn 1.0
  @repo Starter.Versioned.Names
  @sref "versioned-name"
  @persistence ecto_store(Starter.Schema.Versioned.Names.Name, Starter.Repo)
  @derive Noizu.Entity.Store.Ecto.EntityProtocol
  def_entity do
    id(:uuid)
    field :first, nil, :string
    field :middle, [], {:array, :string}
    field :last, nil, :string
    field :time_stamp, nil, Noizu.Entity.TimeStamp
  end

  jason_encoder()

  def equal?(_, _), do: false

  def __schema__(:primary_key), do: [:id]
  def __schema__(:redact_fields), do: []
  def __schema__(_), do: true

  def __changeset__() do
    Noizu.Entity.Meta.meta(__MODULE__).changeset_fields
  end
end
