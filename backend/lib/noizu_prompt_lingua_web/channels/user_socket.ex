defmodule NoizuPromptLinguaWeb.UserSocket do
  use Phoenix.Socket

  channel "org:*", NoizuPromptLinguaWeb.OrgChannel
  channel "browser:*", NoizuPromptLinguaWeb.BrowserChannel

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    case NoizuPromptLingua.Guardian.decode_and_verify(token, %{"typ" => "access"}) do
      {:ok, claims} ->
        case NoizuPromptLingua.Guardian.resource_from_claims(claims) do
          {:ok, session} ->
            user_id =
              case session.user do
                {:ref, _, id} -> id
                %{id: id} -> id
              end

            {:ok, assign(socket, :user_id, user_id)}

          {:error, _} ->
            :error
        end

      {:error, _} ->
        :error
    end
  end

  # Headless clients (e.g. the local browser controller) authenticate with an
  # MCP JWT — the same Bearer token the MCP gateway accepts — rather than an
  # interactive Guardian session. DualTokenVerifier accepts RS256 (JWKS) and
  # legacy HS256; CompoundJWTVerifier is HS256-only and rejects issuer lists.
  def connect(%{"mcp_token" => token}, socket, _connect_info) do
    verifier_opts = NoizuPromptLinguaWeb.MCPConfig.auth_opts()[:verifier] |> elem(1)

    case NoizuPromptLingua.MCP.DualTokenVerifier.verify(token, %{}, verifier_opts) do
      {:ok, claims} ->
        case NoizuPromptLingua.MCP.Resolve.normalize_user_id(claims) do
          id when is_binary(id) and id != "" -> {:ok, assign(socket, :user_id, id)}
          _ -> :error
        end

      _ ->
        :error
    end
  end

  def connect(_params, _socket, _connect_info), do: :error

  @impl true
  def id(socket), do: "user_socket:#{socket.assigns.user_id}"
end
