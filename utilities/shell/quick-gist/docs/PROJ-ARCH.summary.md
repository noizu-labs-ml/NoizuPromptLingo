# Project Architecture — Summary

Single-file bash CLI wrapping `gh gist` with fzf-based interactive file selection.

**Dependencies:** `gh` (required), `fzf` (optional, interactive modes), `pbcopy` (optional, clipboard).

**Modes:** List (`-l`), Edit (`-e`), Append (`-a`), Pipe (`-p`), Create (default).

**Visibility:** Secret by default; overridden by flags or `QUICK_GIST_VISIBILITY` env var.

**Design:** Single portable script, no install dependencies beyond `gh`, graceful degradation without `fzf`.
