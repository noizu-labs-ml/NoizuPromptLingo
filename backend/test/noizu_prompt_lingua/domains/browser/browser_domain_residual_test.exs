defmodule NoizuPromptLingua.Domains.Browser.ResidualTest do
  @moduledoc """
  Arms of the browser domain the committed browser_domain_test.exs leaves
  uncovered: `connected?/1` registration tracking, unknown-organization
  folds, and the Relay translate arms for binary / non-binary / timeout
  controller failures (exercised through the REAL Relay with a spawned fake
  controller; killed on exit so the Relay's DOWN handler drops it).

  Not covered by design here or in the main suite: capture_screenshot /
  record_stop persist arms (presigned storage + media registration chain).
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.Browser
  alias NoizuPromptLingua.Domains.Browser.Relay

  setup do
    if Process.whereis(Relay) == nil, do: start_supervised!(Relay)

    org_id = Ecto.UUID.generate()
    table = :"browser_fake_#{System.unique_integer([:positive])}"
    :ets.new(table, [:named_table, :public, :set])
    :ets.insert(table, {:script, :ignore})

    fake = spawn(fn -> fake_loop(table) end)

    on_exit(fn ->
      Process.exit(fake, :kill)
      if :ets.whereis(table) != :undefined, do: :ets.delete(table)
    end)

    %{org_id: org_id, fake: fake, table: table}
  end

  defp fake_loop(table) do
    receive do
      {:browser_command, %{request_id: rid}} ->
        case :ets.lookup(table, :script) do
          [{:script, :ignore}] -> :ok
          [{:script, result}] -> Relay.reply(rid, result)
        end

        fake_loop(table)
    end
  end

  test "connected?/1 tracks relay registrations", %{org_id: org_id, fake: fake} do
    refute Browser.connected?(org_id)
    assert :ok = Relay.register(org_id, fake)
    assert Browser.connected?(org_id)
  end

  test "run/3 with an unknown organization ref folds to an error" do
    assert {:error, "Organization 'ghost-org' not found"} = Browser.run("ghost-org", "navigate")
  end

  test "run/3 passes binary controller errors through", %{org_id: org_id, fake: fake, table: table} do
    Relay.register(org_id, fake)
    :ets.insert(table, {:script, {:error, "page crashed"}})

    assert {:error, "page crashed"} = Browser.run(org_id, "screenshot", %{}, 5_000)
  end

  test "run/3 inspects non-binary controller errors", %{org_id: org_id, fake: fake, table: table} do
    Relay.register(org_id, fake)
    :ets.insert(table, {:script, {:error, {:handler_gone}}})

    assert {:error, "browser controller error: {:handler_gone}"} =
             Browser.run(org_id, "navigate", %{}, 5_000)
  end

  test "run/3 surfaces controller timeouts", %{org_id: org_id, fake: fake} do
    Relay.register(org_id, fake)

    assert {:error, "browser controller timed out after 25ms"} =
             Browser.run(org_id, "navigate", %{}, 25)
  end
end
