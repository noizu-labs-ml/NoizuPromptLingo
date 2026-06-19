defmodule NoizuPromptLinguaWeb.OrgChannel do
  use Phoenix.Channel

  @impl true
  def join("org:" <> org_id, _params, socket) do
    user_id = socket.assigns.user_id

    case NoizuPromptLingua.Organizations.authorize(user_id, org_id, "viewer") do
      {:ok, _membership} ->
        {:ok, assign(socket, :org_id, org_id)}

      {:error, _} ->
        {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_in("ping", _payload, socket) do
    {:reply, {:ok, %{message: "pong"}}, socket}
  end
end
