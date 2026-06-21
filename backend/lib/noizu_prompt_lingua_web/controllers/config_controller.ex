defmodule NoizuPromptLinguaWeb.ConfigController do
  use NoizuPromptLinguaWeb, :controller

  @local_mcp_archive "noizu-local-mcp.tar.gz"

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

  defp local_mcp_dir do
    Application.app_dir(:noizu_prompt_lingua, "priv/static/downloads")
  end
end
