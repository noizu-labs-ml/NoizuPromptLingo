# fstab-mounter — Architecture Summary

## Overview
macOS LaunchDaemon providing Linux-style `/etc/fstab` behavior for APFS volumes. Reads `/etc/osx-fstab` at boot and ensures volumes are mounted at declared paths.

## Components
- **fstab-remount** — Bash mount script (UUID → label → disk fallback chain)
- **LaunchDaemon plist** — Runs script once at boot as root, logs to `/var/log/fstab-remount.log`
- **osx-fstab.stub** — Config template installed to `/etc/osx-fstab`
- **Makefile** — install / uninstall / status / logs targets

## Config Format
One line per volume: `uuid=<UUID> label=<Label> disk=<device> <mountpoint> <fstype> <options> 0 0`. Supports `noauto` (skip), `owners` (enable ownership). Use `-` for unknown identifiers.

## Resolution Strategy
Tries UUID, then label, then disk identifier — first `diskutil info` match wins. Volumes at correct path are skipped; volumes at wrong path are force-unmounted and remounted.

## Key Decisions
- LaunchDaemon (not Agent) — needs root before user login
- 3s boot delay for external disk enumeration
- Zero third-party dependencies — macOS builtins only
