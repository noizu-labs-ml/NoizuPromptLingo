defmodule NoizuPromptLinguaWeb.RemoteAccessController do
  @moduledoc """
  Remote-access tunnel registration + the frps server-plugin callback.

  Tunnel CRUD is authenticated with an **MCP JWT** (same Bearer token the
  browser-controller uses), and gated on the caller being an editor of the org.
  `frp_auth/2` is the unauthenticated-from-the-user callback the `frps` server
  invokes; it is secured by the per-claim tunnel token (and an optional shared
  secret), never by the user's session.
  """
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Domains.RemoteAccess
  alias NoizuPromptLingua.{Organizations}
  alias NoizuPromptLingua.MCP.Resolve

  @tunnel_host "remote-access.noizu.com"

  # ── User-facing CRUD (MCP JWT) ─────────────────────────────────────────────

  def create(conn, %{"name" => name, "organization" => org_ref} = params) do
    with_editor(conn, org_ref, fn user_id, org_id ->
      case RemoteAccess.claim_tunnel(user_id, org_id, name,
             proxy_type: params["proxy_type"] || "http"
           ) do
        {:ok, tunnel, raw_token} ->
          conn
          |> put_status(:created)
          |> json(%{
            name: tunnel.name,
            tunnel_token: raw_token,
            url: "https://#{tunnel.name}.#{@tunnel_host}",
            proxy_type: tunnel.proxy_type,
            expires_at: tunnel.expires_at
          })

        {:error, :name_taken} ->
          conn |> put_status(:conflict) |> json(%{error: "name '#{name}' is already claimed"})

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: inspect(changeset.errors)})
      end
    end)
  end

  def create(conn, _), do: bad_request(conn, "name and organization are required")

  def index(conn, %{"organization" => org_ref}) do
    with_editor(conn, org_ref, fn user_id, org_id ->
      tunnels =
        RemoteAccess.list_tunnels(user_id, org_id)
        |> Enum.map(fn t ->
          %{
            name: t.name,
            url: "https://#{t.name}.#{@tunnel_host}",
            proxy_type: t.proxy_type,
            status: t.status,
            connected: not is_nil(t.last_connected_at),
            expires_at: t.expires_at
          }
        end)

      json(conn, %{tunnels: tunnels})
    end)
  end

  def index(conn, _), do: bad_request(conn, "organization is required")

  def delete(conn, %{"name" => name}) do
    with_mcp_user(conn, fn user_id ->
      case RemoteAccess.revoke_tunnel(user_id, name) do
        {:ok, _} ->
          json(conn, %{name: name, status: "revoked"})

        {:error, :not_owner} ->
          forbidden(conn, "you do not own '#{name}'")

        {:error, :not_found} ->
          conn |> put_status(:not_found) |> json(%{error: "no active claim for '#{name}'"})

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: inspect(changeset.errors)})
      end
    end)
  end

  # ── frps server-plugin callback ────────────────────────────────────────────

  def frp_auth(conn, params) do
    if frp_secret_ok?(conn) do
      handle_frp_op(conn, params["op"], params["content"] || %{})
    else
      conn |> put_status(:unauthorized) |> json(%{reject: true, reject_reason: "bad frp secret"})
    end
  end

  defp handle_frp_op(conn, "Login", content) do
    decide(conn, RemoteAccess.authorize_login(meta_token(content)))
  end

  defp handle_frp_op(conn, "NewProxy", content) do
    token = get_in(content, ["user", "metas", "token"]) || meta_token(content)
    subdomain = content["subdomain"] || content["proxy_name"]
    decide(conn, RemoteAccess.authorize_proxy(token, subdomain))
  end

  defp handle_frp_op(conn, "CloseProxy", content) do
    token = get_in(content, ["user", "metas", "token"]) || meta_token(content)
    RemoteAccess.mark_disconnected(token)
    allow(conn)
  end

  # Unknown op we were not configured for — don't block.
  defp handle_frp_op(conn, _op, _content), do: allow(conn)

  defp decide(conn, :ok), do: allow(conn)

  defp decide(conn, :deny),
    do: json(conn, %{reject: true, reject_reason: "tunnel token rejected"})

  defp allow(conn), do: json(conn, %{reject: false, unchange: true})

  defp meta_token(content), do: get_in(content, ["metas", "token"])

  defp frp_secret_ok?(conn) do
    case System.get_env("REMOTE_ACCESS_FRP_SECRET") do
      nil ->
        true

      "" ->
        true

      secret ->
        presented =
          conn.query_params["secret"] ||
            Plug.Conn.get_req_header(conn, "x-frp-secret") |> List.first()

        Plug.Crypto.secure_compare(to_string(presented), secret)
    end
  end

  # ── auth helpers ───────────────────────────────────────────────────────────

  defp with_editor(conn, org_ref, fun) do
    with_mcp_user(conn, fn user_id ->
      case Resolve.organization_id(org_ref) do
        nil ->
          conn |> put_status(:not_found) |> json(%{error: "organization '#{org_ref}' not found"})

        org_id ->
          case Organizations.authorize(user_id, org_id, "editor") do
            {:ok, _} -> fun.(user_id, org_id)
            _ -> forbidden(conn, "editor role required for this organization")
          end
      end
    end)
  end

  defp with_mcp_user(conn, fun) do
    case bearer_token(conn) do
      nil ->
        conn |> put_status(:unauthorized) |> json(%{error: "missing Bearer MCP token"})

      token ->
        verifier_opts = NoizuPromptLinguaWeb.MCPConfig.auth_opts()[:verifier] |> elem(1)

        case Noizu.MCP.Auth.CompoundJWTVerifier.verify(token, %{}, verifier_opts) do
          {:ok, %{"sub" => user_id}} when is_binary(user_id) and user_id != "" ->
            fun.(user_id)

          _ ->
            conn |> put_status(:unauthorized) |> json(%{error: "invalid MCP token"})
        end
    end
  end

  defp bearer_token(conn) do
    case Plug.Conn.get_req_header(conn, "authorization") do
      ["Bearer " <> token | _] -> token
      _ -> nil
    end
  end

  defp bad_request(conn, msg), do: conn |> put_status(:bad_request) |> json(%{error: msg})
  defp forbidden(conn, msg), do: conn |> put_status(:forbidden) |> json(%{error: msg})
end
