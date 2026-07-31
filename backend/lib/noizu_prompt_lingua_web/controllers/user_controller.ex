defmodule NoizuPromptLinguaWeb.UserController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Guardian
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User, as: UserSchema
  import Ecto.Query, only: [from: 2]

  def show(conn, _params) do
    user = get_current_user(conn)

    conn
    |> put_status(:ok)
    |> json(%{user: serialize_user(user)})
  end

  def update(conn, %{"user" => user_params}) do
    user = get_current_user(conn)

    with {:ok, updated_user} <- apply_updates(user, user_params) do
      conn
      |> put_status(:ok)
      |> json(%{user: serialize_user(updated_user)})
    else
      {:error, changeset} when is_struct(changeset, Ecto.Changeset) ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})

      {:error, reason} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
    end
  end

  def update(conn, _params) do
    conn |> put_status(:bad_request) |> json(%{error: "user params required"})
  end

  # Resolve the signed-in user as an Ecto schema record (read straight from
  # the DB columns) so bio/role/etc. always reflect persisted state. The
  # versioned entity loader does not map every column, which previously made
  # bio appear "not persisted" after a save.
  defp get_current_user(conn) do
    Repo.get(UserSchema, current_user_id(conn))
  end

  defp current_user_id(conn) do
    case Guardian.Plug.current_resource(conn).user do
      {:ref, _, id} -> id
      %NoizuPromptLingua.Users.User{} = user -> user.id
    end
  end

  # Roles a user may assign to themselves on their own profile. Privileged
  # roles (moderator, admin, owner, service) must be granted by an admin and
  # are rejected here to prevent self-escalation via PATCH /users/me.
  @self_assignable_roles ~w(user other)a

  defp apply_updates(user, params) do
    with {:ok, updates} <- build_updates(params) do
      if map_size(updates) > 0 do
        from(u in UserSchema, where: u.id == ^user.id)
        |> Repo.update_all(set: Enum.to_list(updates))
      end

      {:ok, Repo.get(UserSchema, user.id)}
    end
  end

  defp build_updates(params) do
    updates = %{}

    updates =
      if params["user_name"], do: Map.put(updates, :user_name, params["user_name"]), else: updates

    updates = if params["email"], do: Map.put(updates, :email, params["email"]), else: updates

    updates =
      if is_binary(params["bio"]), do: Map.put(updates, :bio, params["bio"]), else: updates

    case params["role"] do
      nil ->
        {:ok, updates}

      role when is_binary(role) ->
        case parse_self_role(role) do
          {:ok, role_atom} -> {:ok, Map.put(updates, :role, role_atom)}
          :error -> {:error, "role cannot be set to '#{role}' from your profile"}
        end

      _ ->
        {:ok, updates}
    end
  end

  defp parse_self_role(role) do
    atom = String.to_existing_atom(role)
    if atom in @self_assignable_roles, do: {:ok, atom}, else: :error
  rescue
    ArgumentError -> :error
  end

  defp serialize_user(user) do
    %{
      id: user.id,
      email: user.email,
      user_name: user.user_name,
      handle: user.handle,
      role: user.role,
      bio: user.bio,
      status: user.status,
      verified: user.verified
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
