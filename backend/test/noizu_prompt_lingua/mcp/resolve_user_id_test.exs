defmodule NoizuPromptLingua.MCP.ResolveUserIdTest do
  use ExUnit.Case, async: true

  alias NoizuPromptLingua.MCP.Resolve

  test "bare UUID sub" do
    id = Ecto.UUID.generate()
    assert Resolve.normalize_user_id(%{"sub" => id}) == id
  end

  test "user: prefix from OAuth tokens" do
    id = Ecto.UUID.generate()
    assert Resolve.normalize_user_id(%{"sub" => "user:#{id}"}) == id
  end

  test "user_id claim preferred" do
    id = Ecto.UUID.generate()
    assert Resolve.normalize_user_id(%{"user_id" => id, "sub" => "user:other"}) == id
  end

  test "svc principal ignored" do
    assert Resolve.normalize_user_id(%{"sub" => "svc:backend"}) == nil
  end

  test "current_user_id from ctx assigns" do
    id = Ecto.UUID.generate()
    ctx = %{assigns: %{auth_claims: %{"sub" => "user:#{id}"}}}
    assert Resolve.current_user_id(ctx) == id
  end
end
