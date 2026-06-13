# Secret Bucket PRD

## Purpose

`secret-bucket` gives agents and automation a way to inspect, compare, copy, and update secret-bearing configuration files without emitting secret values into logs. The tool is designed for operational hygiene: it reduces accidental disclosure through stdout, stderr, shell traces, CI logs, and agent transcripts.

This is not intended to be a complete adversarial sandbox. A process with filesystem access to secret files can still read them. The primary guarantee is that supported workflows produce value-free reports by default.

## Problem

Agents often need to repair or synchronize secrets across files such as `.envrc`, `.envrc.dc`, and `.envrc.k8.dc`. Existing shell workflows encourage unsafe patterns:

- `grep`, `diff`, and `cat` print secret values.
- `sed` or shell substitutions can leak values through command logs.
- Human review wants names of mismatches, not the underlying values.
- Copying a value from one location to another should not require exposing that value to the agent transcript.

## Goals

- Model each secret location as an opaque bucket item.
- Compare buckets while printing only key names and statuses.
- Copy or replace values between bucket items without printing values.
- Update `.envrc` and `dc_yaml` files while preserving surrounding content.
- Provide testable guarantees that known secret values do not appear in command output.
- Support privilege-separated operation where secret files are unreadable to
  agents and only a narrow executable can manipulate approved paths.

## Non-Goals

- Strong isolation from a malicious local process.
- Network access to Infisical or Kubernetes in the first implementation.
- Full semantic preservation of arbitrary YAML formatting inside `dc_yaml` blocks.
- Secret rotation policy or entropy auditing.

## Supported Bucket Addresses

Initial local providers:

```text
envrc:<file>:<VAR>
dcfile:<file>:<bucket>:<yaml.path>
```

Examples:

```text
envrc:.envrc:OPS_REGISTRY_PASSWORD
dcfile:.envrc.k8.dc:k8:helm.registry_password
dcfile:.envrc.k8.dc:k8:infisical.client_secret
```

## Commands

```bash
secret-bucket list <bucket-prefix>
secret-bucket diff <left-prefix> <right-prefix> [--format text|json]
secret-bucket copy <source-address> <destination-address> [--dry-run]
secret-bucket set <destination-address> --value-file <file> [--dry-run]
```

All commands accept:

```bash
--policy <root-owned-policy.yaml>
```

When a policy is supplied, every source, destination, and value file must be
allowed by that policy after filesystem canonicalization.

`diff` compares keys by name. For keys present on both sides, it compares values in memory but prints only:

- `same`
- `changed`
- `missing_left`
- `missing_right`

## Logging Contract

By default:

- Never print secret values.
- Never print value prefixes.
- Never print hashes or digests of values.
- Never include secret values in error messages.
- Print only addresses, key names, and status words.

The implementation must include regression tests using sentinel values that fail if those values appear in stdout or stderr.

## Privilege-Separated Mode

For stronger local controls, install the binary as a root-owned executable and
expose it through a narrow `NOPASSWD` sudoers rule:

```text
agent user -> sudo -n /usr/local/sbin/secret-bucket --policy /etc/secret-bucket/policy.yaml ...
```

Secret files are owned by root and unreadable by the agent user. The sudo
binary performs approved reads and writes but never emits secret values.

Policy file:

```yaml
allow:
  read:
    - /Users/keithbrings/Github/infra/k8/.envrc
    - /Users/keithbrings/Github/infra/k8/.envrc.dc
    - /Users/keithbrings/Github/infra/k8/.envrc.k8.dc
  write:
    - /Users/keithbrings/Github/infra/k8/.envrc
    - /Users/keithbrings/Github/infra/k8/.envrc.dc
    - /Users/keithbrings/Github/infra/k8/.envrc.k8.dc
  value_file:
    - /Users/keithbrings/Github/infra/k8/secrets/inbox
```

Policy requirements:

- Policy path must be absolute.
- Policy file must not be group/world writable.
- Allowed paths are canonicalized before use.
- Symlink escapes outside allowed paths are rejected.
- Commands cannot override policy from environment variables.
- Writes must be atomic and preserve existing file permissions where possible.

## Acceptance Criteria

- A Rust CLI builds with `cargo test`.
- `list` reports key names from `.envrc` and `.envrc*.dc` files.
- `diff` reports only mismatch names/statuses and no values.
- `copy --dry-run` reports the planned source and destination without the value.
- `copy` updates the destination value.
- `--policy` denies unlisted read, write, and value-file paths.
- `--policy` allows listed paths after canonicalization.
- Tests prove sentinel secret values are absent from command output.
