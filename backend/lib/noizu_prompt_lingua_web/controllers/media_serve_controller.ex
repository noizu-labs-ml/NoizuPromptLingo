defmodule NoizuPromptLinguaWeb.MediaServeController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Media
  alias NoizuPromptLingua.Media.Transform
  alias NoizuPromptLingua.Authz

  def show(conn, %{"short_id" => short_id} = params) do
    case Media.get_by_short_id(short_id) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: "Media not found"})

      media ->
        case check_access(conn, media) do
          :ok ->
            serve_media(conn, media, params)

          {:error, :unauthorized} ->
            conn |> put_status(401) |> json(%{error: "Authentication required"})

          {:error, :forbidden} ->
            conn |> put_status(403) |> json(%{error: "Insufficient permissions"})
        end
    end
  end

  defp check_access(_conn, %{visibility: "public"}), do: :ok

  defp check_access(conn, %{visibility: visibility, owner_type: owner_type, owner_id: owner_id})
       when visibility in ["org", "private"] do
    case get_user_id(conn) do
      nil ->
        {:error, :unauthorized}

      user_id when visibility == "org" ->
        case Authz.authorize(user_id, owner_type, owner_id, "viewer") do
          {:ok, _} -> :ok
          _ -> {:error, :forbidden}
        end

      user_id when visibility == "private" ->
        if Authz.check_permission(user_id, owner_type, owner_id, "media:view") do
          :ok
        else
          {:error, :forbidden}
        end
    end
  end

  defp check_access(conn, _media) do
    case get_user_id(conn) do
      nil -> {:error, :unauthorized}
      _ -> :ok
    end
  end

  defp serve_media(conn, media, params) do
    transform_params = Transform.parse_params(params)

    if Transform.has_transforms?(transform_params) and media.media_type in [:image, "image"] do
      serve_transformed(conn, media, transform_params)
    else
      serve_original(conn, media)
    end
  end

  defp serve_original(conn, media) do
    if media.visibility == "public" do
      url = NoizuPromptLingua.Storage.presigned_download_url(media.file)

      conn
      |> put_resp_header("cache-control", "public, max-age=3600")
      |> redirect(external: url)
    else
      case Media.fetch_from_s3(media.file) do
        {:ok, binary} ->
          content_type = file_content_type(media)

          conn
          |> put_resp_content_type(content_type)
          |> put_resp_header("cache-control", "private, no-store")
          |> send_resp(200, binary)

        _ ->
          conn |> put_status(500) |> json(%{error: "Failed to fetch media"})
      end
    end
  end

  defp serve_transformed(conn, media, transform_params) do
    case Media.get_or_create_variant(media, transform_params) do
      {:ok, variant_key, content_type} ->
        if media.visibility == "public" do
          url = NoizuPromptLingua.Storage.presigned_download_url(variant_key)

          conn
          |> put_resp_header("cache-control", "public, max-age=31536000, immutable")
          |> redirect(external: url)
        else
          case Media.fetch_from_s3(variant_key) do
            {:ok, binary} ->
              conn
              |> put_resp_content_type(content_type)
              |> put_resp_header("cache-control", "private, no-store")
              |> send_resp(200, binary)

            _ ->
              conn |> put_status(500) |> json(%{error: "Failed to fetch variant"})
          end
        end

      {:error, reason} ->
        conn |> put_status(422) |> json(%{error: "Transform failed: #{inspect(reason)}"})
    end
  end

  defp get_user_id(conn) do
    try do
      case Plug.Conn.get_req_header(conn, "authorization") do
        ["Bearer " <> token] ->
          case NoizuPromptLingua.Guardian.decode_and_verify(token) do
            {:ok, claims} ->
              case NoizuPromptLingua.Guardian.resource_from_claims(claims) do
                {:ok, %NoizuPromptLingua.Users.Sessions.UserSession{user: {:ref, _, id}}} -> id
                {:ok, %NoizuPromptLingua.Users.Sessions.UserSession{user: %{id: id}}} -> id
                _ -> nil
              end

            _ ->
              nil
          end

        _ ->
          nil
      end
    rescue
      _ -> nil
    end
  end

  defp file_content_type(media) do
    case media.file_type do
      t when t in ["jpg", "jpeg", :jpg, :jpeg] -> "image/jpeg"
      t when t in ["png", :png] -> "image/png"
      t when t in ["gif", :gif] -> "image/gif"
      t when t in ["webp", :webp] -> "image/webp"
      t when t in ["svg", :svg] -> "image/svg+xml"
      t when t in ["mp4", :mp4] -> "video/mp4"
      t when t in ["pdf", :pdf] -> "application/pdf"
      _ -> "application/octet-stream"
    end
  end
end
