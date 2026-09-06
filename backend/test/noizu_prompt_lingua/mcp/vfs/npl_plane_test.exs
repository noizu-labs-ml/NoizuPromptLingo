defmodule NoizuPromptLingua.MCP.VFS.NPLPlaneTest do
  @moduledoc """
  Wave 1 battery for the `_npl` root plane (design §2.23): conventions/*.yaml
  as read-only files + spec.md rendered through the NPLSpec path.

  Covers: tree shape, real conventions content, spec rendering, read-only
  enforcement, traversal guards, the bounded-listing cursor policy, and the
  no-gating rule (global reference serves any authenticated connection).
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Ctx
  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.VFS.Cache
  alias NoizuPromptLingua.MCP.VFS.Root
  alias NoizuPromptLingua.NPL

  @base "/tobor/_npl"

  setup do
    NoizuPromptLingua.TRP.Cache.clear()
    NoizuPromptLingua.TRP.TestStub.reset()
    on_exit(fn -> Cache.purge(Root) end)
    :ok
  end

  # The `_npl` plane serves without org gating; an anonymous-principal Ctx is
  # deliberately the primary subject here (fail-closed does not apply to docs).
  defp anon_ctx do
    %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: "npl-" <> Integer.to_string(System.unique_integer([:positive])),
      assigns: %{auth_claims: %{"sub" => "someone"}}
    }
  end

  test "the plane maps conventions/ and spec.md" do
    ctx = anon_ctx()

    assert {:ok, dir} = VFS.stat(Root, @base, ctx)
    assert dir.type == :dir

    assert {:ok, entries, nil} = VFS.list(Root, @base, nil, ctx)
    assert Enum.map(entries, & &1.name) == ["conventions", "spec.md"]

    assert {:ok, dir} = VFS.stat(Root, "#{@base}/conventions", ctx)
    assert dir.type == :dir

    assert {:ok, node} = VFS.stat(Root, "#{@base}/spec.md", ctx)
    assert node.type == :file and node.size > 0
  end

  test "conventions/ lists the real YAML source of truth, readable verbatim" do
    ctx = anon_ctx()

    {:ok, entries, nil} = VFS.list(Root, "#{@base}/conventions", nil, ctx)
    names = Enum.map(entries, & &1.name)
    assert "syntax.yaml" in names
    assert "npl.yaml" in names
    assert Enum.all?(names, &String.ends_with?(&1, ".yaml"))

    # The listing mirrors the on-disk conventions dir.
    on_disk =
      NPL.conventions_dir()
      |> File.ls!()
      |> Enum.filter(&String.ends_with?(&1, ".yaml"))
      |> Enum.sort()

    assert Enum.sort(names) == on_disk

    {:ok, yaml, _} = VFS.read(Root, "#{@base}/conventions/syntax.yaml", ctx)
    assert yaml == File.read!(Path.join(NPL.conventions_dir(), "syntax.yaml"))

    assert {:error, :enoent} = VFS.read(Root, "#{@base}/conventions/nope.yaml", ctx)
    assert {:error, :enoent} = VFS.stat(Root, "#{@base}/conventions/nope.yaml", ctx)
  end

  test "spec.md renders the full NPL spec through the NPLSpec path" do
    ctx = anon_ctx()

    assert {:ok, spec, _} = VFS.read(Root, "#{@base}/spec.md", ctx)
    assert spec =~ "NPL@"
    assert byte_size(spec) > 1000
    assert {:ok, node} = VFS.stat(Root, "#{@base}/spec.md", ctx)
    assert node.size == byte_size(spec)
  end

  test "the plane is read-only" do
    ctx = anon_ctx()

    assert {:error, :enosys} = VFS.write(Root, "#{@base}/spec.md", "x", ctx)
    assert {:error, :enosys} = VFS.write(Root, "#{@base}/conventions/syntax.yaml", "x", ctx)
    assert {:error, :enosys} = VFS.create(Root, "#{@base}/conventions/new.yaml", "x", ctx)
    assert {:error, :enosys} = VFS.remove(Root, "#{@base}/conventions/syntax.yaml", ctx)
    assert {:error, :enosys} = VFS.search(Root, @base, "syntax", ctx)
    assert {:error, :eisdir} = VFS.read(Root, @base, ctx)
    assert {:error, :eisdir} = VFS.read(Root, "#{@base}/conventions", ctx)
    assert {:error, :enotdir} = VFS.list(Root, "#{@base}/spec.md", nil, ctx)
    assert {:error, :enoent} = VFS.read(Root, "#{@base}/nope", ctx)
  end

  test "traversal and escape segments are refused" do
    ctx = anon_ctx()

    assert {:error, :enoent} = VFS.stat(Root, "#{@base}/conventions/../../etc/passwd", ctx)
    assert {:error, :enoent} = VFS.read(Root, "#{@base}/../_meta/whoami.json", ctx)
  end

  test "bounded listings follow the Wave 0 cursor policy" do
    ctx = anon_ctx()

    assert {:error, %Noizu.MCP.Error{}} = VFS.list(Root, @base, "junk", ctx)
    assert {:ok, _, nil} = VFS.list(Root, @base, "", ctx)
    assert {:ok, _, nil} = VFS.list(Root, "#{@base}/conventions", nil, ctx)
  end

  test "the plane serves without group gating (visible to bare principals)" do
    # No TRP orgs, no resolvable client: every group subtree fails closed, but
    # `_npl` is public reference material and still serves.
    ctx = anon_ctx()

    assert {:ok, _, _} = VFS.read(Root, "#{@base}/spec.md", ctx)
    assert {:ok, _, nil} = VFS.list(Root, "/tobor", nil, ctx)

    {:ok, entries, _} = VFS.list(Root, "/tobor", nil, ctx)
    assert Enum.map(entries, & &1.name) == ["_npl"]
  end
end
