defmodule NoizuPromptLingua.Auth.SSOCode do
  @ttl_seconds 60

  def create(session_id) do
    code = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    {:ok, _} = NoizuPromptLingua.Redis.set("sso_code:#{code}", to_string(session_id), ex: @ttl_seconds)
    {:ok, code}
  end

  def exchange(code) do
    key = NoizuPromptLingua.Redis.prefix("sso_code:#{code}")
    case NoizuPromptLingua.Redis.command(["GETDEL", key]) do
      {:ok, nil} -> {:error, :invalid_code}
      {:ok, session_id} -> {:ok, session_id}
    end
  end
end
