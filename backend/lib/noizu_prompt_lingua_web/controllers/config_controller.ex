defmodule NoizuPromptLinguaWeb.ConfigController do
  use NoizuPromptLinguaWeb, :controller

  @local_mcp_archive "noizu-local-mcp.tar.gz"
  @browser_controller_archive "noizu-browser-controller.tar.gz"
  @remote_access_client_archive "noizu-remote-access-client.tar.gz"

  def features(conn, _params) do
    flags = NoizuPromptLingua.FeatureFlags.all()
    conn |> put_status(:ok) |> json(%{features: flags})
  end

  @doc """
  Download the standalone local-filesystem MCP server as a gzipped tarball. The
  archive is produced at build time by `make local-mcp-package` into
  `priv/static/downloads/`. Returns 404 with guidance if it hasn't been packaged.
  """
  def local_mcp_download(conn, _params) do
    path = Path.join(local_mcp_dir(), @local_mcp_archive)

    if File.exists?(path) do
      send_download(conn, {:file, path}, filename: @local_mcp_archive)
    else
      conn
      |> put_status(:not_found)
      |> json(%{
        error: "local-mcp archive not packaged",
        hint: "Run `make local-mcp-package` to build #{@local_mcp_archive}."
      })
    end
  end

  @doc """
  Download the local browser controller (Node + Playwright) as a gzipped tarball.
  Produced at build time by `make browser-controller-package`.
  """
  def browser_controller_download(conn, _params) do
    path = Path.join(local_mcp_dir(), @browser_controller_archive)

    if File.exists?(path) do
      send_download(conn, {:file, path}, filename: @browser_controller_archive)
    else
      conn
      |> put_status(:not_found)
      |> json(%{
        error: "browser-controller archive not packaged",
        hint: "Run `make browser-controller-package` to build #{@browser_controller_archive}."
      })
    end
  end

  @doc "Download the remote-access tunnel client (frpc wrapper) as a gzipped tarball."
  def remote_access_client_download(conn, _params) do
    path = Path.join(local_mcp_dir(), @remote_access_client_archive)

    if File.exists?(path) do
      send_download(conn, {:file, path}, filename: @remote_access_client_archive)
    else
      conn
      |> put_status(:not_found)
      |> json(%{
        error: "remote-access-client archive not packaged",
        hint: "Run `make remote-access-client-package` to build #{@remote_access_client_archive}."
      })
    end
  end

  defp local_mcp_dir do
    Application.app_dir(:noizu_prompt_lingua, "priv/static/downloads")
  end
end
