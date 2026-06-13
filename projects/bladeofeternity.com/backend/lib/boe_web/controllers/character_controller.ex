defmodule BoeWeb.CharacterController do
  use BoeWeb, :controller

  alias Boe.Game

  def show(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    case Game.get_character(user) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "No character found"})

      character ->
        conn
        |> put_status(:ok)
        |> json(%{character: serialize(character)})
    end
  end

  def create(conn, %{"character" => character_params}) do
    user = Guardian.Plug.current_resource(conn)

    case Game.create_character(user, character_params) do
      {:ok, character} ->
        conn
        |> put_status(:created)
        |> json(%{character: serialize(character)})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  defp serialize(c) do
    %{
      id: c.id,
      name: c.name,
      race: c.race,
      character_class: c.character_class,
      level: c.level,
      xp: c.xp,
      xp_next: c.xp_next,
      hp: c.hp,
      max_hp: c.max_hp,
      energy: c.energy,
      max_energy: c.max_energy,
      gold: c.gold,
      weapon: c.weapon,
      armor: c.armor,
      location: c.location,
      effects: c.effects,
      strength: c.strength,
      dexterity: c.dexterity,
      constitution: c.constitution,
      intelligence: c.intelligence,
      wisdom: c.wisdom,
      charisma: c.charisma
    }
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
