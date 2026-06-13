# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2023 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.Support.Entities.Boos do
  @moduledoc false
  use Noizu.Repo
  def_repo()
end

defmodule Noizu.Support.Entities.Boos.Boo do
  @moduledoc false
  use Noizu.Entity

  @vsn 1.0
  @sref "boo"

  # todo config controlled enablement of mnesia/amnesia/redis/etc providers.
  # todo default dummy handler
  # todo mix command to inject entities and setup ecto/mnesia
  # todo switch to bare mnesia/hide mnesia implementation details behind behavior wrapper.
  # todo @cache redis: [:prime, :ttl (miss,fuzz)]
  # todo @persistence_layer by_atom, by_repo, name mapping, rules
  # todo index name, type, settings
  # todo invalidate cache on update
  # todo fragmented key library - own repo
  @persistence dummy_store(
                 Noizu.Support.Entity.ETS.DummyRecord,
                 Noizu.Support.Entity.ETS.DummyRepo
               )
  def_entity do
    # Universal
    # Auto
    id(:integer)

    @restricted :user
    @restricted {:role, :supper_trooper}
    @restricted {:role, :field, :supper_trooper}
    @restricted [{:role, :role2}, {:role, :role3}]
    @restricted [{:parent, :user}]
    @restricted [{:path, [{Access, :key, [:a]}, {Access, :key, [:b]}], {:role, :role_x}}]
    @restricted [{:path, [{Access, :key, [:a]}, {Access, :key, [:b]}], {:role, :role_y}}]
    @pii :low
    field(:name)

    pii do
      @json false
      field(:passport_number)
      field(:address)
    end

    # type: atom, ref, module, handler
    # index true
    # index index_name: setting
    transient do
      @json admin: true
      field(:ephermal_one)
      @json false
      field(:ephermal_two)
    end

    @transient true
    field(:ephermal_three)

    # Embed
    # Format
    # Handler
    @json brief: false
    field(:title)

    @json :omit
    @json admin: true
    @json for: [:admin, :admin2], set: [as: :ignore]
    @json admin: [as: :apple]
    field(:title2)

    @json false
    @json admin: true
    field(:description)

    @json false
    @json for: [:admin, :api, :brief], set: true
    @json for: [:foo, :bar], set: [true, as: :fop]
    @json for: :special, set: [omit: false, as: :bop]
    @json for: :api, set: [omit: true, as: :bop2]
    field(:json_template_specific)

    @json false
    @json for: [:admin, :api, :brief], set: true
    @json for: [:foo, :bar], set: [true, as: :fop2]
    @json for: :api, set: [omit: false, as: :bop2]
    field(:json_template_specific2)
  end

  defmodule Repo do
    @moduledoc false
    use Noizu.Repo
    def_repo()
  end

  # todo  all entity to pl logic
  # todo  ref, entity, id, -> Noizu.Entity.ref(module, ref, options) -> injected by derive with macro callback.
end
