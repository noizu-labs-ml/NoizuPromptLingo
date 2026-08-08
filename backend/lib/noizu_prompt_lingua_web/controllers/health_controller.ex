defmodule NoizuPromptLinguaWeb.HealthController do
  use NoizuPromptLinguaWeb, :controller

  def index(conn, _params) do
    json(conn, %{status: "ok"})
  end
end
