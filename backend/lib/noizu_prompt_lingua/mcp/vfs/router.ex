defmodule NoizuPromptLingua.MCP.VFS.Router do
  @moduledoc """
  NPL's VFS backend — the module the server registers (Wave 0 substrate).

  Composition by delegation, per the lib precedent (`Noizu.MCP.VFS.Control`
  moduledoc): everything under `/etc/dev/**` is served by the control tree;
  every other path delegates verbatim to the real backend,
  `NoizuPromptLingua.MCP.VFS.Root` (org-scoped namespace + `_meta` plane +
  prefix-dispatch insertion points).

  The `tool_gate:` hook threads the principal's effective toolset into
  `/etc/dev/tools/<tool>` invocations, so control-tree writes obey the same
  cascade as the MCP surface (`NoizuPromptLingua.MCP.VFS.Principal.tool_gate/3`).

  ## Known caveat (design §3.6 / feature ask C1)

  The control tree's `/etc/dev/tools/` LISTING reads the server's static
  registrations (`Noizu.MCP.VFS.Control.tool_specs/1`) — it is not filtered by
  the per-principal effective toolset the way `handle_list_tools/2` is. On
  this Wave 0 server the tool inventory is empty, so the listing is empty for
  everyone; the discrepancy only becomes visible when the FS server carries
  tools (Wave 1+). The invocation gate above already enforces the narrowed
  set, so a leaked node cannot be invoked.
  """

  use Noizu.MCP.VFS.Control,
    server: NoizuPromptLingua.MCP.VFSServer,
    real: NoizuPromptLingua.MCP.VFS.Root,
    tool_gate: {NoizuPromptLingua.MCP.VFS.Principal, :tool_gate}
end
