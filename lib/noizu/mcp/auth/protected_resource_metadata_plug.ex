if Code.ensure_loaded?(Plug.Conn) do
  defmodule Noizu.MCP.Auth.ProtectedResourceMetadataPlug do
    @moduledoc """
    Serves the RFC 9728 protected-resource metadata document MCP clients use
    to discover your authorization server:

        # Phoenix router (path is fixed by RFC 9728)
        forward "/.well-known/oauth-protected-resource",
                Noizu.MCP.Auth.ProtectedResourceMetadataPlug,
                resource: "https://api.example.com/mcp",
                authorization_servers: ["https://auth.example.com"]

    Options: `:resource` (required), `:authorization_servers` (required),
    `:scopes_supported`, `:bearer_methods_supported`, `:extra` (map merged in).
    """

    @behaviour Plug
    import Plug.Conn

    @impl Plug
    def init(opts) do
      document =
        %{
          "resource" => Keyword.fetch!(opts, :resource),
          "authorization_servers" => Keyword.fetch!(opts, :authorization_servers)
        }
        |> put_opt(opts, :scopes_supported, "scopes_supported")
        |> put_opt(opts, :bearer_methods_supported, "bearer_methods_supported")
        |> Map.merge(Keyword.get(opts, :extra, %{}))

      %{body: Jason.encode!(document)}
    end

    @impl Plug
    def call(%{method: "GET"} = conn, %{body: body}) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, body)
    end

    def call(conn, _opts), do: send_resp(conn, 405, "Method not allowed")

    defp put_opt(document, opts, key, json_key) do
      case Keyword.fetch(opts, key) do
        {:ok, value} -> Map.put(document, json_key, value)
        :error -> document
      end
    end
  end
end
