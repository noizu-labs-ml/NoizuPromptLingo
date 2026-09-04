defmodule NoizuPromptLinguaWeb.RemoteAccessController do
  @moduledoc """
  Remote-access tunnel registration + the frps server-plugin callback.

  Tunnel CRUD is authenticated with an **MCP JWT** (same Bearer token the
  browser-controller uses), and gated on the caller being an editor of the org.
  `frp_auth/2` is the unauthenticated-from-the-user callback the `frps` server
  invokes; it is secured by the per-claim tunnel token and a REQUIRED shared
  secret, never by the user's session. Both gates FAIL CLOSED: an unconfigured
  secret admits no tunnels, and ops this deployment does not understand are
  rejected rather than allowed.
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
    case frp_secret_state(conn) do
      :ok ->
        handle_frp_op(conn, params["op"], params["content"] || %{})

      # Presented secret does not match the configured one — challenge.
      :mismatch ->
        conn
        |> put_status(:unauthorized)
        |> json(%{reject: true, reject_reason: "bad frp secret"})

      # Fail closed: with the shared secret unconfigured (nil/"") there is no
      # gate at all — admit nothing rather than everything.
      :unconfigured ->
        conn
        |> put_status(:forbidden)
        |> json(%{reject: true, reject_reason: "frp secret not configured"})
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

  # Fail closed: only the ops this deployment understands pass through — an
  # unrecognised op must never be admitted by default.
  defp handle_frp_op(conn, _op, _content) do
    conn
    |> put_status(:forbidden)
    |> json(%{reject: true, reject_reason: "unknown op"})
  end

  defp decide(conn, :ok), do: allow(conn)

  defp decide(conn, :deny),
    do: json(conn, %{reject: true, reject_reason: "tunnel token rejected"})

  defp allow(conn), do: json(conn, %{reject: false, unchange: true})

  defp meta_token(content), do: get_in(content, ["metas", "token"])

  # Fail closed: an unconfigured (nil/"" — i.e. misconfigured) secret admits
  # NOTHING; the secret is mandatory for every frps callback.
  defp frp_secret_state(conn) do
    case System.get_env("REMOTE_ACCESS_FRP_SECRET") do
      secret when is_binary(secret) and secret != "" ->
        presented =
          conn.query_params["secret"] ||
            Plug.Conn.get_req_header(conn, "x-frp-secret") |> List.first()

        if is_binary(presented) and Plug.Crypto.secure_compare(presented, secret),
          do: :ok,
          else: :mismatch

      _ ->
        :unconfigured
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

        case NoizuPromptLingua.MCP.DualTokenVerifier.verify(token, %{}, verifier_opts) do
          {:ok, claims} ->
            case NoizuPromptLingua.MCP.Resolve.normalize_user_id(claims) do
              id when is_binary(id) and id != "" ->
                fun.(id)

              _ ->
                conn |> put_status(:unauthorized) |> json(%{error: "invalid MCP token"})
            end

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
