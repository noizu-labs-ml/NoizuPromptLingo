---
id: US-061
title: "Install tool via make install"
slug: install-via-make
personas: [P-003, P-005]
epic: "Installation & Configuration"
priority: must-have
complexity: low
tags: [install, make, binary, path]
---

# US-061: Install tool via make install

## User Story

**As a** DevOps engineer setting up the toolchain
**I want to** install `generate-media-prompt` with a single `make install`
**So that** the binary is available on PATH immediately

## Acceptance Criteria

- **Given** the media-tools directory
  **When** I run `make install`
  **Then** the Rust binary is compiled and installed to `~/.local/bin/generate-media-prompt`

- **Given** `~/.local/bin` is on PATH
  **When** installation completes
  **Then** `generate-media-prompt --help` works from any directory

## Notes
Rust build produces a single binary with LTO and strip enabled for small binary size.
