defmodule NoizuPromptLinguaWeb.ConfigController do
  use NoizuPromptLinguaWeb, :controller

  def features(conn, _params) do
    flags = NoizuPromptLingua.FeatureFlags.all()
    conn |> put_status(:ok) |> json(%{features: flags})
  end
end
