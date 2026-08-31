# PROJ-FAQ Summary — run-claude

Question list only, no answers. Full Q&A: [PROJ-FAQ.md](PROJ-FAQ.md).

## Motivation
- Why would I route through a local LiteLLM proxy instead of just setting `ANTHROPIC_BASE_URL` myself?
- Why does switching providers require directory `enter`/`leave` instead of just exporting env vars in `.envrc`?
- Why two proxies (front + LiteLLM) instead of pointing straight at LiteLLM?

## Fit
- When should I skip run-claude and just use native `claude` with Anthropic auth directly?
- When would I point `ANTHROPIC_BASE_URL` straight at the LiteLLM proxy (`:4444`) instead of the front proxy (`:4443`)?
- When is `--kitchen-sink` the wrong choice?

## Comparison
- How does `set-folder` differ from `with-agent-shim` / `run-claude with`?
- How does passthrough mode differ from standard mode in terms of billing?
- How is this different from just using `direnv` alone for provider switching?

## Capability
- Can I keep my Claude subscription billing while also using other providers in the same session?
- Does it survive proxy crashes automatically?
- Can two directories on different profiles run against the proxy at the same time?
- Does `run-claude models avail` show every model I have defined, or just the ones currently in use?

## Caveats
- What happens if `direnv hook` isn't loaded before the run-claude shell hook line?
- Does the proxy log my prompts or my API keys?
- Is there a latency or resource cost to the two-proxy chain?
- Why does `make install` warn and skip instead of failing when `uv` isn't on PATH?
- Why does `set-folder` write two files (`.envrc` and `.envrc.user`) instead of one?
- Why isn't run-claude installed by `make install-utilities` like other Noizu utilities?

## Trust
- Where are my API keys stored, and how are they protected?
- What lands in TimescaleDB, and can I inspect or purge it?
