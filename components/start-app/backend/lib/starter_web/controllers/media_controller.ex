defmodule StarterWeb.MediaController do
  use StarterWeb, :controller

  alias Starter.Guardian
  alias Starter.Storage

  def presign(conn, %{"filename" => filename, "content_type" => content_type}) do
    session = Guardian.Plug.current_resource(conn)
    user_id = get_user_id(session)

    key = "uploads/#{user_id}/#{UUID.uuid4()}/#{sanitize_filename(filename)}"
    upload_url = Storage.presigned_upload_url(key, content_type)

    conn
    |> put_status(:ok)
    |> json(%{upload_url: upload_url, key: key})
  end

  def presign(conn, _params) do
    conn |> put_status(:bad_request) |> json(%{error: "filename and content_type required"})
  end

  def download(conn, %{"key" => key}) do
    download_url = Storage.presigned_download_url(key)
    conn |> put_status(:ok) |> json(%{download_url: download_url})
  end

  defp get_user_id(session) do
    case session.user do
      {:ref, _, id} -> id
      %{id: id} -> id
    end
  end

  defp sanitize_filename(filename) do
    filename
    |> String.replace(~r/[^\w\.\-]/, "_")
    |> String.slice(0, 255)
  end

  def register(conn, %{"key" => key, "filename" => filename} = params) do
    media_type = Map.get(params, "media_type", "image")
    file_type = params["file_type"] || ext_from_filename(filename)
    visibility = Map.get(params, "visibility", "private")
    owner_type = params["owner_type"]
    owner_id = params["owner_id"]
    settings = Map.get(params, "settings", %{})

    case Starter.Media.register_asset(%{
           media_type: media_type,
           file_type: file_type,
           file: key,
           visibility: visibility,
           owner_type: owner_type,
           owner_id: owner_id,
           settings: settings
         }) do
      {:ok, asset} ->
        conn
        |> put_status(:created)
        |> json(%{
          id: asset.id,
          short_id: asset.short_id,
          key: asset.file,
          visibility: asset.visibility
        })

      {:error, changeset} when is_struct(changeset, Ecto.Changeset) ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  defp ext_from_filename(filename) do
    case Path.extname(filename) do
      "." <> ext -> String.downcase(ext)
      _ -> "other"
    end
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
