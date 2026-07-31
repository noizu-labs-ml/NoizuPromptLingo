defmodule NoizuPromptLingua.Domains.Browser do
  @moduledoc """
  Cloud-side helpers for the browser-control domain. Resolves the org ref and
  dispatches an action to the user's connected local controller via the
  `Relay`, translating relay errors into tool-friendly `{:error, message}`.
  """

  import Ecto.Query
  alias NoizuPromptLingua.MCP.Resolve
  alias NoizuPromptLingua.Domains.Browser.Relay
  alias NoizuPromptLingua.{Storage, Media, Repo}
  alias NoizuPromptLingua.Schema.Media.Asset

  @no_controller "no local browser controller connected for this organization"
  @screenshot_owner "browser_screenshot"
  @video_owner "browser_video"

  @doc "True when a controller is connected for the resolved org (or false)."
  def connected?(org_ref) do
    case Resolve.organization_id(org_ref) do
      nil -> false
      org_id -> Relay.connected?(org_id)
    end
  end

  @doc """
  Resolve `org_ref`, then dispatch `{action, params}` to its controller and
  return the controller's `{:ok, data}` / `{:error, message}`.
  """
  def run(org_ref, action, params \\ %{}, timeout \\ 30_000) do
    case Resolve.organization_id(org_ref) do
      nil ->
        {:error, "Organization '#{org_ref}' not found"}

      org_id ->
        command = %{action: action, params: params}

        case Relay.dispatch(org_id, command, timeout) do
          {:ok, data} -> {:ok, data}
          {:error, :no_controller} -> {:error, @no_controller}
          {:error, :timeout} -> {:error, "browser controller timed out after #{timeout}ms"}
          {:error, message} when is_binary(message) -> {:error, message}
          {:error, other} -> {:error, "browser controller error: #{inspect(other)}"}
        end
    end
  end

  @doc """
  Capture a screenshot. Mints a presigned PUT URL, asks the controller to upload
  the PNG straight to object storage, then registers a `media` asset and returns
  its serve URL. Falls back to returning base64 if the controller can't upload.
  """
  def capture_screenshot(org_ref, params \\ %{}) do
    with_org(org_ref, fn org_id ->
      key = "browser/#{org_id}/#{Ecto.UUID.generate()}.png"
      put_url = Storage.presigned_upload_url(key, "image/png")
      cmd = %{action: "screenshot", params: Map.merge(params, %{upload_url: put_url, key: key})}

      case Relay.dispatch(org_id, cmd, 30_000) do
        {:ok, %{"key" => ^key} = data} ->
          persist(org_id, key, "image", "png", @screenshot_owner, %{
            "source" => "browser.screenshot",
            "width" => data["width"],
            "height" => data["height"]
          })

        {:ok, %{"image" => b64} = data} ->
          # Controller couldn't upload — return the base64 inline instead.
          {:ok, %{image: b64, width: data["width"], height: data["height"], stored: false}}

        {:ok, data} ->
          {:ok, data}

        other ->
          translate(other)
      end
    end)
  end

  @doc "Begin recording the browser session (Playwright records video per context)."
  def record_start(org_ref) do
    with_org(org_ref, fn org_id ->
      translate(Relay.dispatch(org_id, %{action: "record_start", params: %{}}, 30_000))
    end)
  end

  @doc """
  Stop recording: mint a presigned PUT URL for the webm, have the controller
  finalize + upload the video, then register it as a `media` asset.
  """
  def record_stop(org_ref) do
    with_org(org_ref, fn org_id ->
      key = "browser/#{org_id}/#{Ecto.UUID.generate()}.webm"
      put_url = Storage.presigned_upload_url(key, "video/webm")

      cmd = %{
        action: "record_stop",
        params: %{upload_url: put_url, key: key, content_type: "video/webm"}
      }

      case Relay.dispatch(org_id, cmd, 60_000) do
        {:ok, %{"key" => ^key} = data} ->
          persist(org_id, key, "video", "webm", @video_owner, %{
            "source" => "browser.video",
            "duration_ms" => data["duration_ms"]
          })

        {:ok, data} ->
          {:ok, data}

        other ->
          translate(other)
      end
    end)
  end

  @doc "List captured browser screenshots + videos for an org, newest first."
  def list_captures(org_id, limit \\ 100) do
    Repo.all(
      from a in Asset,
        where:
          a.owner_type in [@screenshot_owner, @video_owner] and a.owner_id == ^org_id and
            is_nil(a.deleted_at),
        order_by: [desc: a.inserted_at],
        limit: ^limit
    )
    |> Enum.map(fn a ->
      %{
        id: a.id,
        short_id: a.short_id,
        url: "/media/#{a.short_id}",
        media_type: a.media_type,
        inserted_at: a.inserted_at
      }
    end)
  end

  # ── internals ─────────────────────────────────────────────────────────────

  defp with_org(org_ref, fun) do
    case Resolve.organization_id(org_ref) do
      nil -> {:error, "Organization '#{org_ref}' not found"}
      org_id -> fun.(org_id)
    end
  end

  defp persist(org_id, key, media_type, file_type, owner_type, settings) do
    case Media.register_asset(%{
           media_type: media_type,
           file_type: file_type,
           file: key,
           visibility: "org",
           owner_type: owner_type,
           owner_id: org_id,
           settings: settings
         }) do
      {:ok, asset} ->
        {:ok,
         %{
           media_id: asset.id,
           short_id: asset.short_id,
           url: "/media/#{asset.short_id}",
           stored: true
         }}

      {:error, changeset} ->
        {:error, "failed to register media: #{inspect(changeset.errors)}"}
    end
  end

  defp translate({:ok, data}), do: {:ok, data}
  defp translate({:error, :no_controller}), do: {:error, @no_controller}
  defp translate({:error, :timeout}), do: {:error, "browser controller timed out"}
  defp translate({:error, message}) when is_binary(message), do: {:error, message}
  defp translate({:error, other}), do: {:error, "browser controller error: #{inspect(other)}"}
end
