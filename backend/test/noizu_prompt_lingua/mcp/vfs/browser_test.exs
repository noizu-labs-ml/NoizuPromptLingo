defmodule NoizuPromptLingua.MCP.VFS.BrowserTest do
  @moduledoc """
  The §2.21 browser tree (MCP-VFS-GROUP-MOUNTS.md), over
  `Noizu.MCP.Server.Features.VFS` against the backend directly (the root.ex
  dispatch entry is a round-5 diff snippet):

    * write-to-navigate round-trip against an OFFLINE fake controller
      (`Relay.register/2` + `Relay.reply/2`): write `session/{id}/url` →
      navigate job → status done → result read → session url recorded
    * job-dir semantics: request.json create → status polling → result;
      duplicate ids, malformed requests, unknown tools
    * state.json: live GetState render; connected:false without a controller
    * screenshots/recordings: metadata only — reads are `:enosys` (B1),
      media url rides xattrs; `_capture`/`_start` control writes submit jobs
    * gating matrix: no browser grant → `:enoent` subtree; disabled group →
      reads served, control writes `:eacces`; ToolGuard (per-user ACL deny)
      refuses the specific tool's control write
    * read-only discipline: everything but the control files is `:erofs`
  """

  use NoizuPromptLingua.DataCase, async: false
  @moduletag :db

  require Noizu.EntityReference.Records
  alias Noizu.EntityReference.Records, as: R

  alias Noizu.MCP.Ctx
  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.Server.VFSPubSub
  alias Noizu.MCP.VFS.Cache
  alias NoizuPromptLingua.Domains.Browser.Relay
  alias NoizuPromptLingua.MCP.VFS.Browser, as: BrowserTree
  alias NoizuPromptLingua.MCP.VFS.Jobs
  alias NoizuPromptLingua.MCP.VFS.Jobs.Browser, as: BrowserShim
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Media.Asset
  alias NoizuPromptLingua.Schema.Users.User
  alias NoizuPromptLingua.TRP.Cache, as: TrpCache
  alias NoizuPromptLingua.TRP.TestStub

  @session "main"

  setup do
    TrpCache.clear()
    TestStub.reset()
    BrowserShim.reset()

    org_id = insert_org()
    org_slug = Repo.get!(NoizuPromptLingua.Schema.Organizations.Organization, org_id).slug
    TestStub.seed_org(org_id, org_slug, "VFS Browser Org")

    on_exit(fn ->
      Cache.purge(BrowserTree)
      BrowserShim.reset()
    end)

    %{org_id: org_id, org: org_slug}
  end

  # ── fixtures ──────────────────────────────────────────────────────────────

  defp key_ctx(config, overrides \\ []) do
    uniq = System.unique_integer([:positive])

    user =
      %User{
        id: Ecto.UUID.generate(),
        email: "vfsbrowser-#{uniq}@example.com",
        user_name: "vfsbrowser#{uniq}",
        handle: "vfsbrowser#{uniq}",
        status: :active
      }
      |> Repo.insert!()

    {:ok, key, _raw} = MCPApiKeys.generate_api_key(user.id, "vfs-browser", toolset_config: config)

    claims =
      %{"api_key_id" => key.id, "sub" => user.id}
      |> Map.merge(Map.new(overrides))

    %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: "vfsbrowser-" <> Integer.to_string(uniq),
      assigns: %{auth_claims: claims}
    }
  end

  defp browser_ctx, do: key_ctx(%{"groups" => %{"browser" => %{}}})

  defp base(org, session \\ @session), do: "/tobor/#{org}/browser/session/#{session}"

  defp job_base(org, job_id, session \\ @session),
    do: base(org, session) <> "/jobs/#{job_id}"

  # A fake controller: registers for the org and answers every command with
  # `payload` via Relay.reply/2 (the browser_domain_test pattern).
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

  defp eventually(fun, tries \\ 250)

  defp eventually(_fun, 0), do: flunk("condition never became true")

  defp eventually(fun, tries) do
    if fun.() do
      :ok
    else
      Process.sleep(20)
      eventually(fun, tries - 1)
    end
  end

  defp await_job(org, job_id) do
    eventually(fn ->
      case Jobs.get_job(org, @session, "browser", job_id) do
        %{status: s} when s in [:done, :error] -> true
        _ -> false
      end
    end)

    Jobs.get_job(org, @session, "browser", job_id)
  end

  defp insert_asset(org_id, media_type, ext, short_id, owner) do
    %Asset{
      media_type: media_type,
      file_type: ext,
      file: "browser/#{org_id}/#{short_id}.#{ext}",
      short_id: short_id,
      visibility: "org",
      owner_type: owner,
      owner_id: org_id
    }
    |> Repo.insert!()
  end

  # ── gating matrix (§1.3, browser-shaped) ──────────────────────────────────

  test "no browser grant → the entire subtree is :enoent (no existence leak)", %{org: org} do
    ctx = key_ctx(%{"groups" => %{"wiki" => %{}}})

    assert {:error, :enoent} = VFS.stat(BrowserTree, "/tobor/#{org}/browser", ctx)
    assert {:error, :enoent} = VFS.stat(BrowserTree, base(org), ctx)
    assert {:error, :enoent} = VFS.read(BrowserTree, base(org) <> "/state.json", ctx)
    assert {:error, :enoent} = VFS.write(BrowserTree, base(org) <> "/url", "https://x.test/", ctx)
  end

  test "disabled group lists but refuses control writes with :eacces", %{org: org} do
    ctx = key_ctx(%{"groups" => %{"browser" => %{"disabled" => true}}})

    assert {:ok, dir} = VFS.stat(BrowserTree, "/tobor/#{org}/browser", ctx)
    assert dir.type == :dir and dir.writable == false

    assert {:ok, node} = VFS.stat(BrowserTree, base(org) <> "/url", ctx)
    assert node.type == :control and node.writable == false

    assert {:ok, _, _} = VFS.read(BrowserTree, base(org) <> "/state.json", ctx)

    assert {:error, :eacces} = VFS.write(BrowserTree, base(org) <> "/url", "https://x.test/", ctx)

    assert {:error, :eacces} =
             VFS.create(
               BrowserTree,
               job_base(org, "click-1") <> "/request.json",
               Jason.encode!(%{"tool" => "click", "args" => %{"selector" => "#a"}}),
               ctx
             )
  end

  test "org out of the TRP key scope → :enoent subtree", %{org: org} do
    ctx = browser_ctx()
    TestStub.reset()
    TrpCache.clear()

    assert {:error, :enoent} = VFS.stat(BrowserTree, "/tobor/#{org}/browser", ctx)
  end

  # ── write-to-navigate: the purest write-to-command (offline round-trip) ───

  test "url write submits a navigate job; done result + session url", %{org_id: org_id, org: org} do
    ctrl = fake_controller(org_id, {:ok, %{"url" => "https://example.test/", "title" => "Ex"}})
    ctx = browser_ctx()

    assert {:ok, node} =
             VFS.write(BrowserTree, base(org) <> "/url", "https://example.test/\n", ctx)

    assert node.type == :control
    job_id = node.xattrs["job"]
    assert is_binary(job_id)

    job = await_job(org, job_id)
    assert job.status == :done

    {:ok, result_json, _} = VFS.read(BrowserTree, job_base(org, job_id) <> "/result", ctx)

    assert %{"ok" => true, "result" => %{"url" => "https://example.test/"}} =
             Jason.decode!(result_json)

    # The session's url read now lands on the navigated page.
    assert {:ok, "https://example.test/", _} = VFS.read(BrowserTree, base(org) <> "/url", ctx)

    # …and the session shows up in the session/ listing.
    assert {:ok, sessions, nil} = VFS.list(BrowserTree, "/tobor/#{org}/browser/session", nil, ctx)
    assert Enum.any?(sessions, &(&1.name == @session))

    stop_controller(ctrl)
  end

  test "url read before any navigation is empty; state.json reports disconnected", %{org: org} do
    ctx = browser_ctx()

    assert {:ok, "", _} = VFS.read(BrowserTree, base(org) <> "/url", ctx)

    {:ok, state_json, _} = VFS.read(BrowserTree, base(org) <> "/state.json", ctx)
    assert %{"connected" => false, "session" => @session} = Jason.decode!(state_json)
  end

  test "navigate with no controller → job error, result names the cause", %{org: org} do
    ctx = browser_ctx()

    assert {:ok, node} = VFS.write(BrowserTree, base(org) <> "/url", "https://example.test/", ctx)

    job = await_job(org, node.xattrs["job"])
    assert job.status == :error

    {:ok, result_json, _} =
      VFS.read(BrowserTree, job_base(org, node.xattrs["job"]) <> "/result", ctx)

    assert %{"ok" => false, "error" => "no local browser controller" <> _} =
             Jason.decode!(result_json)
  end

  test "state.json renders live GetState through the relay", %{org_id: org_id, org: org} do
    ctrl = fake_controller(org_id, {:ok, %{"url" => "https://live.test/", "title" => "Live"}})
    ctx = browser_ctx()

    {:ok, state_json, _} = VFS.read(BrowserTree, base(org) <> "/state.json", ctx)

    assert %{
             "connected" => true,
             "url" => "https://live.test/",
             "state" => %{"title" => "Live"}
           } = Jason.decode!(state_json)

    stop_controller(ctrl)
  end

  # ── job-dir semantics (§3.8) ──────────────────────────────────────────────

  test "request.json create → click job executes against the controller", %{
    org_id: org_id,
    org: org
  } do
    ctrl = fake_controller(org_id, {:ok, %{"clicked" => true}})
    ctx = browser_ctx()

    path = job_base(org, "click-roundtrip") <> "/request.json"

    assert {:ok, node} =
             VFS.create(
               BrowserTree,
               path,
               Jason.encode!(%{"tool" => "click", "args" => %{"selector" => "#submit"}}),
               ctx
             )

    assert node.type == :file

    job = await_job(org, "click-roundtrip")
    assert job.status == :done

    {:ok, result_json, _} =
      VFS.read(BrowserTree, job_base(org, "click-roundtrip") <> "/result", ctx)

    assert %{"ok" => true, "result" => %{"clicked" => true}} = Jason.decode!(result_json)

    # request.json echoes the enriched request.
    {:ok, req_json, _} = VFS.read(BrowserTree, path, ctx)

    assert %{
             "tool" => "click",
             "organization" => ^org,
             "session" => @session
           } = Jason.decode!(req_json)

    stop_controller(ctrl)
  end

  test "malformed request json → :eio; unknown tool → :eio; oversized → :eio", %{org: org} do
    ctx = browser_ctx()

    assert {:error, :eio} =
             VFS.create(
               BrowserTree,
               job_base(org, "bad-json") <> "/request.json",
               "{not json",
               ctx
             )

    assert {:error, :eio} =
             VFS.create(
               BrowserTree,
               job_base(org, "bad-tool") <> "/request.json",
               Jason.encode!(%{"tool" => "teleport", "args" => %{}}),
               ctx
             )

    assert {:error, :eio} =
             VFS.create(
               BrowserTree,
               job_base(org, "bad-shape") <> "/request.json",
               Jason.encode!(%{"args" => %{}}),
               ctx
             )

    assert {:error, :eio} =
             VFS.create(
               BrowserTree,
               job_base(org, "too-big") <> "/request.json",
               Jason.encode!(%{
                 "tool" => "click",
                 "args" => %{"selector" => String.duplicate("x", 70_000)}
               }),
               ctx
             )
  end

  test "duplicate job id → :eexist", %{org: org} do
    ctx = browser_ctx()
    body = Jason.encode!(%{"tool" => "click", "args" => %{"selector" => "#d"}})

    assert {:ok, _} =
             VFS.create(BrowserTree, job_base(org, "dupe-job") <> "/request.json", body, ctx)

    assert {:error, :eexist} =
             VFS.create(BrowserTree, job_base(org, "dupe-job") <> "/request.json", body, ctx)

    # Drain the runner task before the sandbox owner exits — a task still
    # borrowing the shared connection at test end poisons the next test's
    # reads (DBConnection owner-exit disconnect).
    await_job(org, "dupe-job")
  end

  test "invalid session/job id shapes are :enoent", %{org: org} do
    ctx = browser_ctx()

    assert {:error, :enoent} = VFS.stat(BrowserTree, base(org, "../etc"), ctx)
    assert {:error, :enoent} = VFS.stat(BrowserTree, base(org, "Bad Caps"), ctx)
    assert {:error, :enoent} = VFS.stat(BrowserTree, base(org) <> "/jobs/NOT-A-JOB/status", ctx)
  end

  # ── ToolGuard: the control path re-verifies the mapped tool ───────────────

  test "per-user ACL deny refuses the tool's control write with :eacces", %{org: org} do
    ctx = browser_ctx()

    {:ok, _} =
      NoizuPromptLingua.Acl.create_rule(%{
        subject_ref:
          R.ref(module: NoizuPromptLingua.Users.User, id: ctx.assigns.auth_claims["sub"]),
        resource_ref: R.ref(module: NoizuPromptLingua.Schema.McpTool, id: "Browser_Click"),
        action: "mcp.tool",
        effect: "deny"
      })

    # The denied tool's job create is refused…
    assert {:error, :eacces} =
             VFS.create(
               BrowserTree,
               job_base(org, "click-denied") <> "/request.json",
               Jason.encode!(%{"tool" => "click", "args" => %{"selector" => "#a"}}),
               ctx
             )

    # …while a sibling tool's control write still goes through (error job —
    # no controller connected — proves the gate PASSED and the runner ran).
    assert {:ok, node} = VFS.write(BrowserTree, base(org) <> "/url", "https://example.test/", ctx)
    assert %{status: :error} = await_job(org, node.xattrs["job"])
  end

  # ── screenshots / recordings: B1 metadata-only ────────────────────────────

  test "screenshots mount as metadata; byte reads are :enosys; media url rides xattrs", %{
    org_id: org_id,
    org: org
  } do
    insert_asset(org_id, :image, :png, "shotabcd1234", "browser_screenshot")
    ctx = browser_ctx()

    assert {:ok, entries, nil} = VFS.list(BrowserTree, base(org) <> "/screenshots", nil, ctx)
    assert Enum.any?(entries, &(&1.type == :control and &1.name == "_capture"))

    shot = Enum.find(entries, &String.ends_with?(&1.name, "-shotabcd.png"))
    assert shot != nil

    assert {:ok, xattrs} = VFS.xattr(BrowserTree, base(org) <> "/screenshots/" <> shot.name, ctx)
    assert xattrs["binary"] == false
    assert xattrs["url"] == "/media/shotabcd1234"

    # B1: the bytes themselves never cross the wire.
    assert {:error, :enosys} =
             VFS.read(BrowserTree, base(org) <> "/screenshots/" <> shot.name, ctx)
  end

  test "_capture control write submits a screenshot job (storage-off → error job)", %{org: org} do
    ctx = browser_ctx()

    assert {:ok, node} = VFS.write(BrowserTree, base(org) <> "/screenshots/_capture", "", ctx)
    job_id = node.xattrs["job"]

    job = await_job(org, job_id)
    assert job.status == :error

    {:ok, result_json, _} = VFS.read(BrowserTree, job_base(org, job_id) <> "/result", ctx)

    assert %{"ok" => false, "error" => "object storage is not configured"} =
             Jason.decode!(result_json)
  end

  test "record _start submits a record job through the relay", %{org_id: org_id, org: org} do
    ctrl = fake_controller(org_id, {:ok, %{"recording" => true}})
    ctx = browser_ctx()

    assert {:ok, node} = VFS.write(BrowserTree, base(org) <> "/recordings/_start", "", ctx)

    job = await_job(org, node.xattrs["job"])
    assert job.status == :done

    {:ok, result_json, _} =
      VFS.read(BrowserTree, job_base(org, node.xattrs["job"]) <> "/result", ctx)

    assert %{"ok" => true, "result" => %{"recording" => true}} = Jason.decode!(result_json)

    stop_controller(ctrl)
  end

  test "recordings mount as metadata (video assets) with _start/_stop controls", %{
    org_id: org_id,
    org: org
  } do
    insert_asset(org_id, :video, :webm, "vidabcd1234", "browser_video")
    ctx = browser_ctx()

    assert {:ok, entries, nil} = VFS.list(BrowserTree, base(org) <> "/recordings", nil, ctx)

    control_names = Enum.map(entries, & &1.name)
    assert "_start" in control_names and "_stop" in control_names
    # short8: names truncate the media short_id to its first 8 chars.
    assert Enum.any?(entries, &String.ends_with?(&1.name, "-vidabcd1.webm"))

    # No image assets leak into recordings (and vice versa).
    assert {:ok, shots, nil} = VFS.list(BrowserTree, base(org) <> "/screenshots", nil, ctx)
    refute Enum.any?(shots, &String.ends_with?(&1.name, ".webm"))
  end

  # ── read-only discipline + runner marker ──────────────────────────────────

  test "everything but the control files refuses writes with :erofs", %{org: org} do
    ctx = browser_ctx()

    assert {:error, :erofs} = VFS.write(BrowserTree, base(org) <> "/state.json", "{}", ctx)
    assert {:error, :erofs} = VFS.remove(BrowserTree, base(org) <> "/state.json", ctx)
    assert {:error, :erofs} = VFS.create(BrowserTree, base(org) <> "/sneaky.json", "x", ctx)

    # Status/result are runner-only even for a browser-granted principal.
    assert {:error, :erofs} =
             VFS.write(BrowserTree, job_base(org, "j1") <> "/status", "done", ctx)

    assert {:error, :erofs} = VFS.create(BrowserTree, job_base(org, "j1") <> "/result", "{}", ctx)
    assert {:error, :erofs} = VFS.remove(BrowserTree, job_base(org, "j1"), ctx)
  end

  test "status/result read :enoent before a job exists; job listing tracks submits", %{org: org} do
    ctx = browser_ctx()

    assert {:ok, [], nil} = VFS.list(BrowserTree, base(org) <> "/jobs", nil, ctx)
    assert {:error, :enoent} = VFS.stat(BrowserTree, job_base(org, "ghost") <> "/status", ctx)

    assert {:ok, node} = VFS.write(BrowserTree, base(org) <> "/url", "https://example.test/", ctx)
    job_id = node.xattrs["job"]

    assert {:ok, entries, nil} = VFS.list(BrowserTree, base(org) <> "/jobs", nil, ctx)
    assert Enum.map(entries, & &1.name) == [job_id]

    # Before the runner finishes: request.json + status exist, result doesn't.
    eventually(fn ->
      match?({:ok, _}, VFS.stat(BrowserTree, job_base(org, job_id) <> "/request.json", ctx))
    end)

    assert {:ok, job_node} = VFS.stat(BrowserTree, job_base(org, job_id) <> "/status", ctx)
    assert job_node.type == :file

    await_job(org, job_id)
    assert {:ok, _} = VFS.stat(BrowserTree, job_base(org, job_id) <> "/result", ctx)
  end

  # ── pubsub: transitions announce (§3.8 point of the convention) ───────────

  test "job transitions publish vfs events on the browser backend", %{org_id: org_id, org: org} do
    ctrl = fake_controller(org_id, {:ok, %{"url" => "https://pubsub.test/"}})
    ctx = browser_ctx()

    :ok = VFSPubSub.watch(BrowserTree, ["/tobor/#{org}/browser"], depth: :infinity)

    assert {:ok, node} = VFS.write(BrowserTree, base(org) <> "/url", "https://pubsub.test/", ctx)
    await_job(org, node.xattrs["job"])

    events = drain_events(50)
    paths = Enum.map(events, & &1.path)
    assert Enum.any?(paths, &String.ends_with?(&1, "/request.json"))
    assert Enum.any?(paths, &String.ends_with?(&1, "/result"))

    stop_controller(ctrl)
  end

  defp drain_events(timeout) do
    receive do
      {:vfs_event, event} -> [event | drain_events(timeout)]
    after
      timeout -> []
    end
  end

  # ── overview ──────────────────────────────────────────────────────────────

  test "overview.md renders from the group Overview tool", %{org: org} do
    ctx = browser_ctx()

    assert {:ok, md, _} = VFS.read(BrowserTree, "/tobor/#{org}/browser/overview.md", ctx)
    assert md =~ "browser"
  end

  # ── helpers ───────────────────────────────────────────────────────────────

  defp insert_org do
    # Globally-unique slug: the org slug→uuid cache (Redis, 1h TTL) survives
    # across test runs, and System.unique_integer restarts per VM — a low
    # integer collides with a stale cached uuid from an earlier run, and
    # Browser.run then relays to an org that has no controller.
    stamp = Integer.to_string(System.system_time(:millisecond))
    uniq = Integer.to_string(System.unique_integer([:positive]))
    slug = "vfs-browser-org-" <> stamp <> "-" <> uniq

    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        [slug, "VFS Browser Org"]
      )

    Ecto.UUID.load!(raw)
  end
end
