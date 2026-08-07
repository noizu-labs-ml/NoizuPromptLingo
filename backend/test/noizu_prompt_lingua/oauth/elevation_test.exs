defmodule NoizuPromptLingua.OAuth.ElevationTest do
  use ExUnit.Case, async: false

  alias NoizuPromptLingua.OAuth.Elevation

  setup do
    Elevation.ensure_table!()
    :ok
  end

  test "txn approve → active grant → single-use verify" do
    user_id = Ecto.UUID.generate()
    tool = "Organization.Delete"

    txn =
      Elevation.create_txn!(%{
        user_id: user_id,
        tool: tool,
        action: "org:delete",
        args_hash: "abc"
      })

    assert {:ok, _entry} = Elevation.get_txn(txn)
    assert {:ok, token, _exp} = Elevation.approve!(txn, user_id)
    assert is_binary(token)

    # Active grant works once without JWT
    assert {:ok, _} = Elevation.verify_for_tool({:user, user_id}, tool, "abc")
    # Consumed
    assert {:error, _} = Elevation.verify_for_tool({:user, user_id}, tool, "abc")
  end

  test "wrong user cannot approve" do
    user_id = Ecto.UUID.generate()
    other = Ecto.UUID.generate()

    txn =
      Elevation.create_txn!(%{
        user_id: user_id,
        tool: "X",
        action: nil,
        args_hash: nil
      })

    assert {:error, :forbidden} = Elevation.approve!(txn, other)
  end
end
