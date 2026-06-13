defmodule NPLWeb.AuthController do
  use NPLWeb, :controller

  def sync(conn, %{"sub" => _, "email" => _} = params) do
    case NoizuPromptLingua.Auth.find_or_create_user(params) do
      {:ok, user} ->
        json(conn, %{id: user.id, email: user.email, name: user.name})

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
end
