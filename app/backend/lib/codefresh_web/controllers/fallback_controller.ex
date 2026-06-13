defmodule CodefreshWeb.FallbackController do
  use CodefreshWeb, :controller

  def call(conn, {:error, :not_found}), do: send_resp(conn, 404, "")
  def call(conn, {:error, :forbidden}), do: send_resp(conn, 403, "")
  def call(conn, {:error, :unauthorized}), do: send_resp(conn, 401, "")

  def call(conn, {:error, %Ecto.Changeset{} = cs}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
  end
end
