defmodule NoizuPromptLingua.Domains.Browser.BrowserTest do
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.Domains.Browser
  alias NoizuPromptLingua.Domains.Browser.Relay
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization

  setup do
    org_id = insert_org()
    org_slug = Repo.get!(Organization, org_id).slug
    {:ok, org_id: org_id, org_slug: org_slug}
  end

  defp uniq(suffix), do: "#{suffix}-#{System.unique_integer([:positive])}"

  # A fake controller: registers for the org and answers every command with
  # `payload` via Relay.reply/2.
  defp fake_controller(org_id, payload) do
    parent = self()

    pid =
      spawn(fn ->
        loop = fn loop ->
          receive do
            {:browser_command, cmd} ->
              Relay.reply(cmd.request_id, payload)
              loop.(loop)

            {:stop, ^parent} ->
              :ok
          end
        end

        loop.(loop)
      end)

    :ok = Relay.register(org_id, pid)
    pid
  end

  defp stop_controller(pid), do: send(pid, {:stop, self()})

  # ── connected? / run ───────────────────────────────────────────────

  test "connected? reflects controller registration", %{org_id: org_id} do
    refute Browser.connected?(org_id)

    pid = fake_controller(org_id, {:ok, %{"status" => "ok"}})
    assert Browser.connected?(org_id)

    stop_controller(pid)
    # Relay monitors the controller; give the DOWN message a moment.
    eventually_false(fn -> Browser.connected?(org_id) end)
  end

  test "run/3 resolves the org and dispatches to the controller", %{
    org_id: org_id,
    org_slug: org_slug
  } do
    pid = fake_controller(org_id, {:ok, %{"url" => "https://example.com"}})

    assert {:ok, %{"url" => "https://example.com"}} =
             Browser.run(org_slug, "navigate", %{url: "https://example.com"})

    stop_controller(pid)
  end

  test "run/3 error paths: unknown org, no controller, controller error, timeout", %{
    org_id: org_id,
    org_slug: org_slug
  } do
    assert {:error, "Organization 'ghost-org' not found"} = Browser.run("ghost-org", "navigate")

    assert {:error, "no local browser controller connected for this organization"} =
             Browser.run(org_slug, "navigate")

    # Controller that answers with a binary error
    pid = fake_controller(org_id, {:error, "navigation blocked"})
    assert {:error, "navigation blocked"} = Browser.run(org_slug, "navigate")
    stop_controller(pid)

    # Controller that answers with a non-binary error
    pid2 = fake_controller(org_id, {:error, :crashed})
    assert {:error, "browser controller error: :crashed"} = Browser.run(org_slug, "navigate")
    stop_controller(pid2)

    # Controller that never answers
    deaf = spawn(fn -> Process.sleep(5_000) end)
    :ok = Relay.register(org_id, deaf)

    assert {:error, "browser controller timed out after 20ms"} =
             Browser.run(org_slug, "navigate", %{}, 20)

    Process.exit(deaf, :kill)

    assert org_id != nil
  end

  # ── capture / record ───────────────────────────────────────────────

  test "capture_screenshot degrades when object storage is not configured", %{org_slug: org_slug} do
    assert {:error, "object storage is not configured"} = Browser.capture_screenshot(org_slug)
  end

  test "record_start flows through the relay; record_stop needs storage", %{
    org_id: org_id,
    org_slug: org_slug
  } do
    assert {:error, "no local browser controller connected for this organization"} =
             Browser.record_start(org_slug)

    pid = fake_controller(org_id, {:ok, %{"recording" => true}})
    assert {:ok, %{"recording" => true}} = Browser.record_start(org_slug)
    stop_controller(pid)

    assert {:error, "object storage is not configured"} = Browser.record_stop(org_slug)
  end

  # ── MCP tool wrappers ──────────────────────────────────────────────

  test "browser tool wrappers dispatch through the domain", %{org_id: org_id, org_slug: org_slug} do
    alias NoizuPromptLingua.Domains.Browser.Tools.{Navigate, Overview, Screenshot}

    assert {:error, "Organization 'ghost-org' not found"} =
             Navigate.call(%{"organization" => "ghost-org", "url" => "https://example.com"}, %{})

    pid = fake_controller(org_id, {:ok, %{"navigated" => true}})

    assert {:ok, %{"navigated" => true}} =
             Navigate.call(%{"organization" => org_slug, "url" => "https://example.com"}, %{})

    stop_controller(pid)

    assert {:error, "object storage is not configured"} =
             Screenshot.call(%{"organization" => org_slug}, %{})

    assert {:ok, %{tools: _tools}} = Overview.call(%{"organization" => org_slug}, %{})
  end

  # ── helpers ────────────────────────────────────────────────────────

  defp eventually_false(fun, tries \\ 20)

  defp eventually_false(_fun, 0), do: :ok

  defp eventually_false(fun, tries) do
    if fun.() do
      Process.sleep(50)
      eventually_false(fun, tries - 1)
    else
      :ok
    end
  end

  defp insert_org do
    slug = uniq("browser-org")

    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        [slug, "Browser Test Org"]
      )

    Ecto.UUID.load!(raw)
  end
end
