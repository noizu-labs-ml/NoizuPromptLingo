# plugins/llm subtrees

Squash-imported into NPL. Do **not** add these as git submodules. Always pass `--squash` on add and pull so upstream history is not imported.

| Prefix | Remote | Branch | Squash |
| --- | --- | --- | --- |
| `plugins/llm/doc-pointers` | `git@github.com:the-robot-lives/doc-pointers.git` | `main` | yes |
| `plugins/llm/elixir-google-mcp` | `git@github.com:noizu-labs/elixir-google-mcp.git` | `main` | yes |
| `plugins/llm/dropbox-mcp` | `git@github.com:noizu-labs/dropbox-mcp.git` | `main` | yes |
| `plugins/llm/run-claude` | `git@github.com:noizu/run-claude.git` | `main` | yes |
| `plugins/llm/llm-toolkit` | `git@github.com:the-robot-lives/llm-toolkit.git` | `main` | yes |

## Pull recipe

From the NPL product repo root:

```bash
git subtree pull --prefix=plugins/llm/<name> <remote> main --squash
```

Examples:

```bash
git subtree pull --prefix=plugins/llm/doc-pointers \
  git@github.com:the-robot-lives/doc-pointers.git main --squash

git subtree pull --prefix=plugins/llm/elixir-google-mcp \
  git@github.com:noizu-labs/elixir-google-mcp.git main --squash

git subtree pull --prefix=plugins/llm/dropbox-mcp \
  git@github.com:noizu-labs/dropbox-mcp.git main --squash

git subtree pull --prefix=plugins/llm/run-claude \
  git@github.com:noizu/run-claude.git main --squash

git subtree pull --prefix=plugins/llm/llm-toolkit \
  git@github.com:the-robot-lives/llm-toolkit.git main --squash
```

NPL overlay files (`plugin.json`, `.mcp.json`, `bin/`, `README.md`, `Makefile`, `skills/`) live **outside** the five prefixes. Re-apply any mix.exs overlay after a pull if upstream reintroduces monorepo path deps.
