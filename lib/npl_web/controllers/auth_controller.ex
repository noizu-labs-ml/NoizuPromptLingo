defmodule NPLWeb.AuthController do
  use NPLWeb, :controller

  def sync(conn, %{"sub" => _, "email" => _} = params) do
    case NoizuPromptLingua.Auth.find_or_create_user(params) do
      {:ok, user} ->
        json(conn, %{
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
          bio: user.bio,
          profile_complete: user.profile_complete
        })

      {:error, changeset} ->
        conn
        |> put_status(422)
        |> json(%{error: inspect(changeset.errors)})
    end
  end

  def sync(conn, _params) do
    conn
    |> put_status(400)
    |> json(%{error: "sub and email required"})
  end

  def profile(conn, %{"sub" => sub}) do
    case NoizuPromptLingua.Auth.get_user_by_sub(sub) do
      nil ->
        conn |> put_status(404) |> json(%{error: "user not found"})

      user ->
        json(conn, %{
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
          bio: user.bio,
          profile_complete: user.profile_complete
        })
    end
  end

  def update_profile(conn, %{"sub" => sub} = params) do
    case NoizuPromptLingua.Auth.update_profile(sub, params) do
      {:ok, user} ->
        json(conn, %{
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
          bio: user.bio,
          profile_complete: user.profile_complete
        })

      {:error, :not_found} ->
        conn |> put_status(404) |> json(%{error: "user not found"})

      {:error, changeset} ->
        conn |> put_status(422) |> json(%{error: inspect(changeset.errors)})
    end
  end
end
