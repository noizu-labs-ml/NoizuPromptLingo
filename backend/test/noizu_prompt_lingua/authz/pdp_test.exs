defmodule NoizuPromptLingua.Authz.PdpTest do
  # Mutates Application env — never async.
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Authz.Pdp

  setup do
    original = Application.get_env(:noizu_prompt_lingua, :mcp_pdp)

    on_exit(fn ->
      if original do
        Application.put_env(:noizu_prompt_lingua, :mcp_pdp, original)
      else
        Application.delete_env(:noizu_prompt_lingua, :mcp_pdp)
      end
    end)

    :ok
  end

  test "mode defaults to :local and is enabled" do
    Application.delete_env(:noizu_prompt_lingua, :mcp_pdp)

    assert Pdp.mode() == :local
    assert Pdp.enabled?() == true
  end

  test "check delegates to the local backend for identity-only requests" do
    Application.delete_env(:noizu_prompt_lingua, :mcp_pdp)

    assert :ok = Pdp.check(%{user_id: Ecto.UUID.generate()})
  end

  test "check forwards backend errors" do
    assert {:error, :client_not_allowed} =
             Pdp.check(%{user_id: Ecto.UUID.generate(), client_id: "dcr_missing_xyz"})
  end

  test "mode :disabled always allows and reports disabled" do
    Application.put_env(:noizu_prompt_lingua, :mcp_pdp, mode: :disabled)

    assert Pdp.mode() == :disabled
    assert Pdp.enabled?() == false
    assert :ok = Pdp.check(%{client_id: "dcr_missing_xyz"})
    assert :ok = Pdp.check(%{user_id: 12_345})
  end

  test "mode :spicedb without an endpoint falls back to Local" do
    Application.put_env(:noizu_prompt_lingua, :mcp_pdp, mode: :spicedb)

    assert :ok = Pdp.check(%{user_id: Ecto.UUID.generate()})
    assert {:error, :no_identity} = Pdp.check(%{})
  end
end
