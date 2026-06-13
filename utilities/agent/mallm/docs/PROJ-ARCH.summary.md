# Project Architecture — Summary

**mallm** is a Node.js CLI that provides structured, LLM-friendly documentation for command-line tools.

**Resolution chain**: project-local `.mallm/` → user `~/.config/mallm/` → native `--mallm` protocol → `--help` fallback parsing.

**Core components**: CLI entry (commander), resolver (4-tier file/exec lookup), formatter (markdown/JSON), help parser (regex extraction), init (stub scaffolding), schema (TypeScript types + JSON Schema).

**Data model**: `MallmConfig` — summary, usage examples, typed arguments, subcommands, environment vars, LLM context (when to use, patterns, gotchas), output semantics, skill/related cross-references.

**Stack**: TypeScript 5.8, Node ≥20 ESM, Commander 13, yaml 2.7, Chalk 5. No bundler — `tsc` only.
