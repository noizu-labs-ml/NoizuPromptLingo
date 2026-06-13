defmodule Boe.Game.Character do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_races ~w(human elf dwarf halfling orc)
  @valid_classes ~w(warrior mage rogue cleric ranger)
  @attributes ~w(strength dexterity constitution intelligence wisdom charisma)a
  @base_total 70
  @min_attr 8
  @max_attr 20

  @race_bonuses %{
    "human" => %{strength: 1, dexterity: 1, constitution: 1, intelligence: 1, wisdom: 1, charisma: 1},
    "elf" => %{dexterity: 2, intelligence: 1},
    "dwarf" => %{constitution: 2, strength: 1},
    "halfling" => %{dexterity: 2, charisma: 1},
    "orc" => %{strength: 2, constitution: 1}
  }

  @class_equipment %{
    "warrior" => %{weapon: "Iron Shortsword (+5 attack)", armor: "Chain Mail (+8 defense)"},
    "mage" => %{weapon: "Oak Staff (+2 attack, +5 spell power)", armor: "Cloth Robes (+2 defense)"},
    "rogue" => %{weapon: "Steel Dagger (+4 attack)", armor: "Leather Armor (+5 defense)"},
    "cleric" => %{weapon: "Iron Mace (+4 attack)", armor: "Scale Mail (+6 defense)"},
    "ranger" => %{weapon: "Hunting Bow (+4 attack)", armor: "Hide Armor (+4 defense)"}
  }

  schema "characters" do
    belongs_to :user, Boe.Accounts.User
    field :name, :string
    field :race, :string
    field :character_class, :string
    field :level, :integer, default: 1
    field :xp, :integer, default: 0
    field :xp_next, :integer, default: 100
    field :hp, :integer
    field :max_hp, :integer
    field :energy, :integer
    field :max_energy, :integer
    field :gold, :integer, default: 50
    field :weapon, :string
    field :armor, :string
    field :location, :string, default: "Rune — Town Square"
    field :effects, {:array, :string}, default: []
    field :strength, :integer
    field :dexterity, :integer
    field :constitution, :integer
    field :intelligence, :integer
    field :wisdom, :integer
    field :charisma, :integer

    timestamps(type: :utc_datetime)
  end

  def creation_changeset(character, attrs) do
    character
    |> cast(attrs, [:name, :race, :character_class | @attributes])
    |> validate_required([:name, :race, :character_class | @attributes])
    |> validate_length(:name, min: 2, max: 30)
    |> validate_inclusion(:race, @valid_races)
    |> validate_inclusion(:character_class, @valid_classes)
    |> validate_attribute_ranges()
    |> validate_attribute_total()
    |> unique_constraint(:name)
    |> unique_constraint(:user_id)
    |> apply_race_bonuses()
    |> apply_class_equipment()
    |> compute_derived_stats()
  end

  defp validate_attribute_ranges(changeset) do
    Enum.reduce(@attributes, changeset, fn attr, cs ->
      validate_number(cs, attr, greater_than_or_equal_to: @min_attr, less_than_or_equal_to: @max_attr)
    end)
  end

  defp validate_attribute_total(changeset) do
    if changeset.valid? do
      total = Enum.reduce(@attributes, 0, fn attr, sum ->
        sum + (get_change(changeset, attr) || get_field(changeset, attr) || 10)
      end)

      if total == @base_total do
        changeset
      else
        add_error(changeset, :strength, "attribute points must total #{@base_total}, got #{total}")
      end
    else
      changeset
    end
  end

  defp apply_race_bonuses(changeset) do
    if changeset.valid? do
      race = get_change(changeset, :race)
      bonuses = Map.get(@race_bonuses, race, %{})

      Enum.reduce(bonuses, changeset, fn {attr, bonus}, cs ->
        current = get_change(cs, attr) || get_field(cs, attr) || 10
        put_change(cs, attr, current + bonus)
      end)
    else
      changeset
    end
  end

  defp apply_class_equipment(changeset) do
    if changeset.valid? do
      char_class = get_change(changeset, :character_class)
      equipment = Map.get(@class_equipment, char_class, %{weapon: "Fists", armor: "Tattered Cloth"})

      changeset
      |> put_change(:weapon, equipment.weapon)
      |> put_change(:armor, equipment.armor)
    else
      changeset
    end
  end

  defp compute_derived_stats(changeset) do
    if changeset.valid? do
      con = get_change(changeset, :constitution) || get_field(changeset, :constitution) || 10
      wis = get_change(changeset, :wisdom) || get_field(changeset, :wisdom) || 10

      hp = 50 + con * 5
      energy = 20 + wis * 3

      changeset
      |> put_change(:hp, hp)
      |> put_change(:max_hp, hp)
      |> put_change(:energy, energy)
      |> put_change(:max_energy, energy)
    else
      changeset
    end
  end
end
