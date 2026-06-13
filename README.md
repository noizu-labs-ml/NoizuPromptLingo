# secret-bucket

Agent-safe local secret bucket manipulation.

`secret-bucket` compares and copies values across local secret-bearing files without printing the values. It is intended for `.envrc`, `.envrc.dc`, and `.envrc.k8.dc` workflows where agents need to repair configuration while keeping secrets out of logs.

## Build

```bash
cargo build
```

## Test

```bash
cargo test
```

## Address Formats

```text
envrc:<file>:<VAR>
dcfile:<file>:<bucket>:<yaml.path>
```

## Examples

```bash
secret-bucket list envrc:.envrc
secret-bucket list dcfile:.envrc.k8.dc:k8
secret-bucket diff envrc:.envrc dcfile:.envrc.k8.dc:k8 --format text
secret-bucket copy envrc:.envrc:OPS_REGISTRY_PASSWORD dcfile:.envrc.k8.dc:k8:helm.registry_password
```

Command output is value-free by default.

## Privilege-Separated Install

For agent use, install the binary as a narrow root helper and keep secret files
unreadable to the agent user.

```bash
cargo build --release
sudo install -m 755 -o root -g wheel target/release/secret-bucket /usr/local/sbin/secret-bucket
sudo mkdir -p /etc/secret-bucket
sudo install -m 644 -o root -g wheel docs/policy.example.yaml /etc/secret-bucket/policy.yaml
sudo visudo -f /etc/sudoers.d/secret-bucket
```

Use `docs/sudoers.example` as the sudoers template and edit
`/etc/secret-bucket/policy.yaml` for the exact files agents may touch.

Agent command shape:

```bash
sudo -n /usr/local/sbin/secret-bucket \
  --policy /etc/secret-bucket/policy.yaml \
  diff envrc:/Users/keithbrings/Github/infra/k8/.envrc \
       dcfile:/Users/keithbrings/Github/infra/k8/.envrc.k8.dc:k8
```

The policy file must be absolute and must not be group/world writable. All
configured paths are canonicalized before access checks.
