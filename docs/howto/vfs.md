# Browse NPL syntax as files (VFS)

The public Prompt Lingo host exposes a **read-only virtual filesystem** at
`wss://promptlingo.dev/vfs`. Mount it and you get markdown you can open in
Finder, VS Code, or `less` — the same grouped section output the landing
gallery and `NPLLoad` produce.

No API key. No OAuth. First WebSocket frame is still `vfs/auth` (empty token
is fine).

## What you see

```
~/npl/
└── tobor/_npl/
    ├── conventions/          # raw YAML (syntax.yaml, pumps.yaml, …)
    ├── sections/             # grouped markdown per section
    │   ├── syntax.md
    │   ├── pumps.md
    │   └── …
    └── spec.md               # full concise NPLSpec
```

Writes return read-only / not-implemented. Org trees are absent for an
anonymous mount.

## Path A — `mcp-mount` (no kernel driver)

Works on macOS, Linux, and Windows. Materializes real files over WebSocket.
This is the path to use for **promptlingo.dev**.

Build from [elixir-mcp](https://github.com/noizu-labs/noizu-mcp)
(`daemon/mcp_mount`):

```bash
cd daemon/mcp_mount
MIX_ENV=prod mix escript.build
./mcp-mount --url wss://promptlingo.dev/vfs --mount ~/npl --ro
```

`--token` is optional. `--ro` never pushes local edits.

Unmount: Ctrl-C. Files remain on disk; remount resyncs.

macOS escript note: write-back needs `mac_listener` beside the binary. A
read-only syntax mount does not need it.

Release binaries (when published): GitHub Releases on `noizu-mcp` ship
`mcp-fuse-*` for kernel mounts. `mcp-mount` remains the remote WSS client.

## Path B — `mcp-fuse` (kernel FUSE)

`mcp-fuse` talks **unix-domain sockets** to a local MCP VFS (same machine as
the server). It is not the promptlingo.dev remote path.

| Platform | Runtime | Binary (GitHub Releases) |
|---|---|---|
| macOS arm | [macFUSE](https://osxfuse.github.io/) or [fuse-t](https://www.fuse-t.app/) | `mcp-fuse-darwin-arm64` |
| Linux amd64 | FUSE 3 (`fusermount3`) | `mcp-fuse-linux-amd64` |
| Linux arm64 | FUSE 3 | `mcp-fuse-linux-arm64` |
| Windows amd64 | [WinFsp](https://winfsp.dev/) | `mcp-fuse-windows-amd64.exe` |
| Windows arm64 | WinFsp | `mcp-fuse-windows-arm64.exe` |

```bash
bin/mcp-fuse --server unix:/run/mcp/vfs.sock --mount /Volumes/mcp --ro
```

Build from source: `make fuse-build` in elixir-mcp. See `fuse/README.md`.

## MCP (not a filesystem)

If you only need the conventions inside an agent:

```bash
claude mcp add --transport http npl https://promptlingo.dev/mcp
```

Tools: `NPLLoad`, `NPLSpec`. No auth.
