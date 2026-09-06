defmodule NoizuPromptLingua.MCP.VFSServer do
  @moduledoc """
  NPL's VFS server (Wave 0 substrate): a dedicated, tool-less MCP server whose
  only registration is the composed `NoizuPromptLingua.MCP.VFS.Router` backend.

  Mount topology (MCP-VFS-GROUP-MOUNTS.md §1.2): one VFS endpoint, one
  composed backend — the lib's one-backend-per-`vfs/*` rule makes the Router
  the single surface the `vfs/*` operation family addresses, which keeps
  caching, mounting (`mcp-mount --url wss://<host>/vfs`) and the
  `mcp_fs_search` fan-out coherent. The transport (`Noizu.MCP.Transport.VFSWS`)
  is mounted at `/vfs` on the web router with the same `DualTokenVerifier`
  pipeline the MCP surface uses; every operation then runs under the
  connection principal's identity (see `NoizuPromptLingua.MCP.VFS.Principal`).

  ## Kill switch

  `vfs_readonly: true` is read (compile-time) from
  `config :noizu_prompt_lingua, :vfs, readonly: true` — with it set, the
  composed `Control` layer refuses EVERY write (control tree included) with
  `:erofs`. Wave 0's real backend implements no mutators anyway, so the switch
  bites on the `/etc/dev` control plane (tool invocation, config toggles).
  """

  use NoizuPromptLingua.MCP.Server,
    name: "tobor_fs",
    version: "0.1.0",
    instructions:
      "Virtual filesystem plane — org-scoped tree with a per-principal discovery " <>
        "plane at /tobor/{org}/_meta and the /etc/dev control tree. Mounted over " <>
        "the VFSWS transport at /vfs.",
    vfs_readonly: Application.compile_env(:noizu_prompt_lingua, [:vfs, :readonly], false)

  vfs(NoizuPromptLingua.MCP.VFS.Router)
end
