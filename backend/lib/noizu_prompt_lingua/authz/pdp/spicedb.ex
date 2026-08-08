defmodule NoizuPromptLingua.Authz.Pdp.SpiceDB do
  @moduledoc """
  SpiceDB-backed PDP (optional). Falls back to Local if endpoint missing or
  request fails closed for write-class tools.

  Uses SpiceDB PermissionsService CheckPermission over HTTP when
  `SPICEDB_HTTP_ENDPOINT` is set (e.g. `http://spicedb.data-ns:8443`).
  Without a network dependency in CI, prefer `:local` mode.
  """

  @behaviour NoizuPromptLingua.Authz.Pdp

  require Logger

  @impl true
  def check(req) do
    endpoint = endpoint()

    if is_nil(endpoint) or endpoint == "" do
      Logger.warning("mcp_pdp mode=spicedb but SPICEDB_HTTP_ENDPOINT unset; using Local")
      NoizuPromptLingua.Authz.Pdp.Local.check(req)
    else
      case check_remote(endpoint, req) do
        :ok ->
          :ok

        {:error, reason} ->
          if fail_open?(req) do
            Logger.warning("SpiceDB check failed open: #{inspect(reason)}")
            :ok
          else
            Logger.error("SpiceDB check failed closed: #{inspect(reason)}")
            {:error, :pdp_unavailable}
          end
      end
    end
  end

  defp check_remote(endpoint, req) do
    # Minimal CheckPermission via REST (SpiceDB HTTP gateway) — subject/user.
    # Full bulk checks for three axes when catalog tuples are seeded.
    with :ok <- NoizuPromptLingua.Authz.Pdp.Local.check(Map.take(req, [:client_id, :grant_id, :user_id, :resource])),
         :ok <- maybe_remote_tool_check(endpoint, req) do
      :ok
    end
  end

  defp maybe_remote_tool_check(_endpoint, %{tool: nil}), do: :ok
  defp maybe_remote_tool_check(_endpoint, req) when not is_map_key(req, :tool), do: :ok

  defp maybe_remote_tool_check(endpoint, %{user_id: user_id, tool: tool} = req)
       when is_binary(user_id) and is_binary(tool) do
    # When SpiceDB is fully seeded, replace with real CheckPermission.
    # Until then, Local axis1 handles membership; remote is best-effort health.
    token = preshared_key()
    url = String.trim_trailing(endpoint, "/") <> "/v1/permissions/check"

    body = %{
      "resource" => %{
        "object_type" => "tool",
        "object_id" => tool
      },
      "permission" => "invoke",
      "subject" => %{
        "object" => %{
          "object_type" => "user",
          "object_id" => user_id
        }
      }
    }

    headers =
      [{"content-type", "application/json"}] ++
        if token, do: [{"authorization", "Bearer #{token}"}], else: []

    case http_post(url, body, headers) do
      {:ok, %{"permissionship" => p}} when p in ["PERMISSIONSHIP_HAS_PERMISSION", "has_permission"] ->
        :ok

      {:ok, %{"permissionship" => _}} ->
        # Fall back to local role check if SpiceDB has no tuples yet
        NoizuPromptLingua.Authz.Pdp.Local.check(req)

      {:error, _} = err ->
        err
    end
  end

  defp maybe_remote_tool_check(_, _), do: :ok

  defp http_post(url, body, headers) do
    if Code.ensure_loaded?(Req) do
      case Req.post(url, json: body, headers: headers, receive_timeout: 2_000) do
        {:ok, %{status: 200, body: body}} when is_map(body) -> {:ok, body}
        {:ok, %{status: status}} -> {:error, {:http, status}}
        {:error, reason} -> {:error, reason}
      end
    else
      {:error, :req_not_loaded}
    end
  end

  defp fail_open?(%{action: action}) when is_binary(action) do
    String.contains?(action, "read") or String.contains?(action, "list") or
      String.contains?(action, "get")
  end

  defp fail_open?(_), do: false

  defp endpoint do
    Application.get_env(:noizu_prompt_lingua, :mcp_pdp, [])
    |> Keyword.get(:spicedb_http_endpoint) ||
      System.get_env("SPICEDB_HTTP_ENDPOINT")
  end

  defp preshared_key do
    Application.get_env(:noizu_prompt_lingua, :mcp_pdp, [])
    |> Keyword.get(:spicedb_preshared_key) ||
      System.get_env("SPICEDB_PRESHARED_KEY")
  end
end
