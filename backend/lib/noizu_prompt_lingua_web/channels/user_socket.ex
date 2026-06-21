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
            user_id = case session.user do
              {:ref, _, id} -> id
              %{id: id} -> id
            end
            {:ok, assign(socket, :user_id, user_id)}

          {:error, _} -> :error
        end

      {:error, _} -> :error
    end
  end

  # Headless clients (e.g. the local browser controller) authenticate with an
  # MCP JWT — the same Bearer token the MCP gateway accepts — rather than an
  # interactive Guardian session. Verified with the shared CompoundJWTVerifier;
  # the `sub` claim is the owning user id used for per-org authorization.
  def connect(%{"mcp_token" => token}, socket, _connect_info) do
    verifier_opts = NoizuPromptLinguaWeb.MCPConfig.auth_opts()[:verifier] |> elem(1)

    case Noizu.MCP.Auth.CompoundJWTVerifier.verify(token, %{}, verifier_opts) do
      {:ok, %{"sub" => user_id}} when is_binary(user_id) and user_id != "" ->
        {:ok, assign(socket, :user_id, user_id)}

      _ ->
        :error
    end
  end

  def connect(_params, _socket, _connect_info), do: :error

  @impl true
  def id(socket), do: "user_socket:#{socket.assigns.user_id}"
end
