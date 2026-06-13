defmodule Boe.Game do
  alias Boe.Repo
  alias Boe.Game.Character
  import Ecto.Query

  def get_character(user) do
    Repo.one(from c in Character, where: c.user_id == ^user.id)
  end

  def create_character(user, attrs) do
    %Character{user_id: user.id}
    |> Character.creation_changeset(attrs)
    |> Repo.insert()
  end
end
