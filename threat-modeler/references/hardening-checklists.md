# Hardening Checklists

> Prioritized hardening checklists for developers and operators. Each item includes severity, rationale, remediation, and effort. Work top-down within each section -- Critical items are non-negotiable, Low items are defense-in-depth.

**Severity key:** C = Critical, H = High, M = Medium, L = Low
**Effort key:** Low = minutes, Medium = hours, High = days

---

## Linux Host Hardening

| # | Sev | Item | Why it matters | Remediation | Effort |
|---|-----|------|----------------|-------------|--------|
| 1 | C | Disable root SSH login | Root login gives attackers full control with a single credential. | `sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && systemctl restart sshd` | Low |
| 2 | C | Require SSH key auth, disable passwords | Password auth is brute-forceable; keys are not. | `sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config && systemctl restart sshd` | Low |
| 3 | C | Enable automatic security updates | Unpatched CVEs are the most common intrusion vector. | Ubuntu: `apt install unattended-upgrades && dpkg-reconfigure -plow unattended-upgrades` | Low |
| 4 | C | Enable and configure firewall | Open ports expand attack surface unnecessarily. | `ufw default deny incoming && ufw allow 22/tcp && ufw allow 443/tcp && ufw enable` | Low |
| 5 | H | Restrict SSH to non-default port | Reduces automated scanner noise significantly. | `sed -i 's/^#*Port .*/Port 2222/' /etc/ssh/sshd_config` (update firewall rules accordingly) | Low |
| 6 | H | Set SSH idle timeout | Abandoned sessions can be hijacked. | Add to `sshd_config`: `ClientAliveInterval 300` and `ClientAliveCountMax 2` | Low |
| 7 | H | Remove unnecessary packages and services | Every running service is a potential attack vector. | `systemctl list-unit-files --state=enabled` then disable unused services | Medium |
| 8 | H | Configure auditd logging | Without audit logs, intrusions are invisible. | `apt install auditd && systemctl enable auditd` then add rules in `/etc/audit/rules.d/` | Medium |
| 9 | H | Restrict sudo access | Overly broad sudo grants defeat privilege separation. | Review `/etc/sudoers` via `visudo`; use `%wheel` group with explicit command lists | Low |
| 10 | H | Set umask to 027 | Default 022 lets all users read new files. | Add `umask 027` to `/etc/profile` and `/etc/bash.bashrc` | Low |
| 11 | M | Harden kernel parameters via sysctl | Defaults allow IP spoofing, redirects, and SYN floods. | Add to `/etc/sysctl.d/99-hardening.conf`: `net.ipv4.conf.all.rp_filter=1`, `net.ipv4.conf.all.accept_redirects=0`, `net.ipv4.tcp_syncookies=1` then `sysctl --system` | Low |
| 12 | M | Disable core dumps | Core dumps can leak secrets from memory. | Add `* hard core 0` to `/etc/security/limits.conf` and `fs.suid_dumpable=0` to sysctl | Low |
| 13 | M | Configure log rotation | Unrotated logs fill disks causing denial of service. | Verify `/etc/logrotate.d/` configs exist for all services; set `maxsize 100M` | Low |
| 14 | M | Set file integrity monitoring | Detects unauthorized changes to critical binaries. | `apt install aide && aide --init && mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db` then cron daily | Medium |
| 15 | M | Restrict cron access | Unrestricted cron enables persistence for attackers. | Create `/etc/cron.allow` with only authorized users; delete `/etc/cron.deny` | Low |
| 16 | L | Set login banners | Legal notice supports prosecution; deters casual probing. | Write warning to `/etc/issue.net`; set `Banner /etc/issue.net` in `sshd_config` | Low |
| 17 | L | Disable USB storage | Prevents data exfiltration via removable media on servers. | `echo "install usb-storage /bin/true" > /etc/modprobe.d/disable-usb.conf` | Low |
| 18 | L | Enable process accounting | Provides forensic timeline of all executed commands. | `apt install acct && systemctl enable acct` | Low |

---

## Kubernetes Cluster Hardening

| # | Sev | Item | Why it matters | Remediation | Effort |
|---|-----|------|----------------|-------------|--------|
| 1 | C | Enable RBAC and disable anonymous auth | Anonymous access lets anyone query the API server. | API server flags: `--authorization-mode=RBAC,Node` and `--anonymous-auth=false` | Low |
| 2 | C | Encrypt etcd at rest | etcd stores all secrets in plaintext by default. | Create `EncryptionConfiguration` YAML with `aescbc` or `secretbox` provider; set `--encryption-provider-config` on API server | Medium |
| 3 | C | Enable etcd TLS (peer and client) | Unencrypted etcd traffic exposes all cluster state. | Set `--etcd-certfile`, `--etcd-keyfile`, `--etcd-cafile` on API server; `--peer-cert-file`, `--peer-key-file` on etcd | Medium |
| 4 | C | Enforce Pod Security Standards (Restricted) | Without PSS, pods run as root with full host access. | Label namespaces: `kubectl label ns <ns> pod-security.kubernetes.io/enforce=restricted` | Low |
| 5 | C | Apply default-deny NetworkPolicies | Without policies, all pods can reach all other pods. | Apply per namespace: `kind: NetworkPolicy` with `spec.podSelector: {}` and empty ingress/egress | Medium |
| 6 | C | Disable automounting service account tokens | Compromised pods get free API server credentials. | Set `automountServiceAccountToken: false` on ServiceAccount and pod spec | Low |
| 7 | H | Enable API server audit logging | Without audit logs, API abuse is undetectable. | Set `--audit-log-path`, `--audit-log-maxage=30`, `--audit-log-maxsize=100`, `--audit-policy-file` | Medium |
| 8 | H | Enable admission controllers | Missing admission controllers allow dangerous workloads. | API server flag: `--enable-admission-plugins=NodeRestriction,PodSecurity,ServiceAccount,ResourceQuota,LimitRanger` | Low |
| 9 | H | Restrict kubelet API access | Unauthenticated kubelet API allows command execution on nodes. | Kubelet flags: `--anonymous-auth=false`, `--authorization-mode=Webhook`, `--client-ca-file=<ca>` | Medium |
| 10 | H | Use dedicated service accounts per workload | Shared service accounts violate least privilege. | Create per-deployment ServiceAccount; bind minimal Role via RoleBinding | Medium |
| 11 | H | Set ResourceQuota and LimitRange per namespace | Unbounded resource usage enables DoS via resource exhaustion. | Apply `ResourceQuota` (cpu, memory, pod count) and `LimitRange` (default request/limit) per namespace | Medium |
| 12 | H | Rotate certificates and tokens regularly | Long-lived credentials increase blast radius of compromise. | Use `kubeadm certs renew all` for control plane; set `--service-account-max-token-expiration=24h` | Medium |
| 13 | H | Restrict API server access to trusted networks | Internet-exposed API server is a prime target. | Firewall API server port (6443) to management IPs; or use `--advertise-address` on private interface | Low |
| 14 | H | Enable NodeRestriction admission | Without it, compromised nodes can modify any object. | API server flag: `--enable-admission-plugins=NodeRestriction` (verify present) | Low |
| 15 | M | Disable `hostNetwork`, `hostPID`, `hostIPC` in workloads | Host namespace sharing breaks container isolation. | Enforced by PSS Restricted profile; audit with `kubectl get pods -A -o json \| jq '.items[] \| select(.spec.hostNetwork==true)'` | Low |
| 16 | M | Use read-only root filesystems | Writable root lets attackers persist malware inside containers. | `securityContext.readOnlyRootFilesystem: true` with `emptyDir` for temp writes | Medium |
| 17 | M | Pin image digests, not tags | Tags are mutable; a compromised registry can swap images silently. | Use `image: registry/app@sha256:abc123...` instead of `image: registry/app:v1` | Medium |
| 18 | M | Restrict Ingress to required ports/paths | Overly broad ingress rules expose internal services. | Use path-specific rules in Ingress resources; deny all unmatched paths | Low |
| 19 | M | Scan manifests with policy tools | Manual review misses misconfigurations at scale. | `kube-bench run --targets node,master` or `trivy k8s --report summary cluster` | Medium |
| 20 | M | Isolate system workloads from user workloads | Co-tenancy lets user workloads attack system components. | Use dedicated node pools with taints: `kubectl taint nodes <node> node-role=system:NoSchedule` | High |
| 21 | L | Enable Kubernetes event forwarding | Events expire after 1 hour by default; losing forensic data. | Deploy event exporter (e.g., `kubernetes-event-exporter`) to ship events to logging backend | Medium |
| 22 | L | Label all resources consistently | Unlabeled resources are unmanageable in multi-team clusters. | Enforce labels via admission webhook or OPA/Gatekeeper ConstraintTemplate | Medium |
| 23 | L | Set `seccompProfile: RuntimeDefault` on all pods | Restricts syscalls to the container runtime's default allowlist. | Add to pod `securityContext`: `seccompProfile: { type: RuntimeDefault }` | Low |

---

## Web Server / Reverse Proxy Hardening (NGINX)

| # | Sev | Item | Why it matters | Remediation | Effort |
|---|-----|------|----------------|-------------|--------|
| 1 | C | Enforce TLS 1.2+ and strong ciphers | TLS 1.0/1.1 have known vulnerabilities; weak ciphers are breakable. | `ssl_protocols TLSv1.2 TLSv1.3;` and `ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:...;` and `ssl_prefer_server_ciphers on;` | Low |
| 2 | C | Add Strict-Transport-Security header | Without HSTS, users can be downgraded to HTTP via MITM. | `add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;` | Low |
| 3 | H | Hide server version | Version disclosure helps attackers find matching exploits. | `server_tokens off;` in `http` block | Low |
| 4 | H | Set security headers (CSP, X-Frame, X-Content-Type) | Missing headers enable XSS, clickjacking, and MIME sniffing. | `add_header X-Frame-Options "SAMEORIGIN" always;` `add_header X-Content-Type-Options "nosniff" always;` `add_header Content-Security-Policy "default-src 'self'" always;` | Low |
| 5 | H | Configure rate limiting | Unthrottled endpoints enable brute force and DoS. | `limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;` then `limit_req zone=api burst=20 nodelay;` in location block | Low |
| 6 | H | Limit request body size | Large payloads cause memory exhaustion and buffer overflows. | `client_max_body_size 10m;` (adjust per endpoint) | Low |
| 7 | H | Prevent buffer overflow attacks | Oversized buffers can be exploited for code execution. | `client_body_buffer_size 1k;` `client_header_buffer_size 1k;` `large_client_header_buffers 4 8k;` | Low |
| 8 | M | Disable unnecessary HTTP methods | PUT/DELETE/TRACE on static servers enable file manipulation. | `if ($request_method !~ ^(GET\|HEAD\|POST)$) { return 405; }` | Low |
| 9 | M | Enable access and error logging | Without logs, attacks are invisible. | `access_log /var/log/nginx/access.log combined;` `error_log /var/log/nginx/error.log warn;` | Low |
| 10 | M | Configure timeouts | Slow-loris attacks hold connections open indefinitely. | `client_body_timeout 12;` `client_header_timeout 12;` `keepalive_timeout 15;` `send_timeout 10;` | Low |
| 11 | M | Restrict access to sensitive paths | Admin panels and status pages are prime targets. | `location /admin { allow 10.0.0.0/8; deny all; }` or use auth_basic | Low |
| 12 | M | Set Referrer-Policy and Permissions-Policy | Leaks referrer data and grants unnecessary browser APIs. | `add_header Referrer-Policy "strict-origin-when-cross-origin" always;` `add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;` | Low |
| 13 | L | Disable directory listing | Exposes file structure to attackers. | `autoindex off;` (default, but verify) | Low |
| 14 | L | Serve security.txt | Gives security researchers a way to report issues. | Create `/.well-known/security.txt` with contact, policy, and preferred-languages fields | Low |

---

## Database Hardening (PostgreSQL)

| # | Sev | Item | Why it matters | Remediation | Effort |
|---|-----|------|----------------|-------------|--------|
| 1 | C | Enforce SSL/TLS for all connections | Unencrypted connections expose credentials and data in transit. | `postgresql.conf`: `ssl = on`, `ssl_cert_file`, `ssl_key_file`; `pg_hba.conf`: use `hostssl` instead of `host` | Medium |
| 2 | C | Use scram-sha-256 authentication | MD5 auth is vulnerable to replay attacks. | `postgresql.conf`: `password_encryption = 'scram-sha-256'`; `pg_hba.conf`: change `md5` to `scram-sha-256`; reset passwords | Medium |
| 3 | C | Restrict pg_hba.conf to specific IPs | `0.0.0.0/0` allows connections from anywhere. | Replace `host all all 0.0.0.0/0` with specific CIDR ranges for app servers | Low |
| 4 | C | Revoke PUBLIC schema privileges | By default any user can create objects in the public schema. | `REVOKE ALL ON SCHEMA public FROM PUBLIC;` then grant explicitly per role | Low |
| 5 | H | Create application-specific roles with minimal privileges | Shared superuser accounts violate least privilege. | `CREATE ROLE app_user LOGIN PASSWORD '...' NOSUPERUSER NOCREATEDB NOCREATEROLE;` then `GRANT SELECT, INSERT, UPDATE ON ... TO app_user;` | Medium |
| 6 | H | Enable query logging for DDL and slow queries | Without logs, data exfiltration and schema changes go unnoticed. | `log_statement = 'ddl'`, `log_min_duration_statement = 1000` (log queries over 1s) | Low |
| 7 | H | Set connection limits | Unbounded connections enable connection-flood DoS. | `postgresql.conf`: `max_connections = 100`; per-role: `ALTER ROLE app_user CONNECTION LIMIT 20;` | Low |
| 8 | H | Encrypt backups | Unencrypted backups are a data breach waiting to happen. | `pg_dump \| gpg --symmetric --cipher-algo AES256 -o backup.sql.gpg` or use pgBackRest with `repo1-cipher-type=aes-256-cbc` | Medium |
| 9 | M | Disable trust authentication | `trust` auth lets anyone connect without a password. | Remove all `trust` entries from `pg_hba.conf`; use `scram-sha-256` or `cert` everywhere | Low |
| 10 | M | Set statement timeout | Runaway queries can lock tables and exhaust resources. | `postgresql.conf`: `statement_timeout = '30s'` (adjust per workload) | Low |
| 11 | M | Restrict superuser count | Multiple superusers multiply the blast radius. | Audit: `SELECT rolname FROM pg_roles WHERE rolsuper;` -- keep to 1-2 accounts | Low |
| 12 | M | Enable row-level security where applicable | Without RLS, application bugs expose cross-tenant data. | `ALTER TABLE t ENABLE ROW LEVEL SECURITY;` then `CREATE POLICY ...` | High |
| 13 | L | Set log_connections and log_disconnections | Connection tracking supports forensic investigation. | `postgresql.conf`: `log_connections = on`, `log_disconnections = on` | Low |
| 14 | L | Use pgAudit for fine-grained audit logging | Built-in logging misses SELECT statements and role changes. | `shared_preload_libraries = 'pgaudit'` then `pgaudit.log = 'read, write, ddl, role'` | Medium |

---

## CI/CD Pipeline Hardening

| # | Sev | Item | Why it matters | Remediation | Effort |
|---|-----|------|----------------|-------------|--------|
| 1 | C | Never store secrets in repository or pipeline config | Leaked secrets in git history persist forever. | Use platform secret stores (GitHub Secrets, Vault); scan with `trufflehog git file://. --since-commit HEAD~50` | Low |
| 2 | C | Pin action/plugin versions by SHA, not tag | Tags are mutable; a compromised action can exfiltrate secrets. | `uses: actions/checkout@a5ac7e51b41094c92402da3b24376905380afc29` instead of `@v4` | Medium |
| 3 | C | Enable branch protection on main | Without protection, anyone can push directly and bypass review. | GitHub: Settings > Branches > Add rule: require PR, require reviews (1+), require status checks | Low |
| 4 | H | Run dependency vulnerability scanning | Known CVEs in dependencies are the easiest attack vector. | Add `npm audit`, `pip audit`, or `trivy fs .` as a required CI step | Low |
| 5 | H | Scan container images before pushing | Deploying images with known CVEs puts production at risk. | `trivy image --severity CRITICAL,HIGH --exit-code 1 myimage:latest` in CI | Low |
| 6 | H | Require signed commits | Unsigned commits allow impersonation via forged author fields. | `git config commit.gpgsign true`; enforce via branch protection: "Require signed commits" | Medium |
| 7 | H | Use short-lived credentials, not long-lived tokens | Long-lived tokens have unlimited blast radius if leaked. | Use OIDC federation (GitHub Actions to AWS/GCP); set token expiry to minutes | Medium |
| 8 | H | Restrict workflow permissions to read-only default | Writable default token lets compromised workflows modify the repo. | `.github/workflows/*.yml`: `permissions: { contents: read }` at top level; grant write only where needed | Low |
| 9 | M | Require deployment approvals for production | Automated production deploys without review risk pushing broken or malicious code. | GitHub Environments: add "production" environment with required reviewers | Low |
| 10 | M | Isolate CI runners from production networks | Shared networks let CI-stage attacks pivot to production. | Use dedicated runner VPCs/subnets; no direct database or API access from CI | High |
| 11 | M | Generate and verify SBOMs | Without an SBOM, you cannot track what ships in your artifacts. | `syft packages myimage:latest -o spdx-json > sbom.json` in CI; store alongside artifacts | Medium |
| 12 | M | Sign container images | Unsigned images can be tampered with in the registry. | `cosign sign --key cosign.key myregistry/myimage@sha256:...` | Medium |
| 13 | L | Enforce pipeline-as-code (no UI-only config) | UI-configured pipelines lack audit trail and version control. | Store all CI config in repo; disable UI pipeline editing where possible | Low |
| 14 | L | Set job timeouts | Hung jobs consume resources and may indicate compromise. | `timeout-minutes: 30` in GitHub Actions; equivalent in other platforms | Low |

---

## Docker / Container Hardening

| # | Sev | Item | Why it matters | Remediation | Effort |
|---|-----|------|----------------|-------------|--------|
| 1 | C | Run as non-root user | Root in container = root on host if container escapes. | Dockerfile: `RUN adduser -D appuser` then `USER appuser` | Low |
| 2 | C | Drop all capabilities, add back only what is needed | Default capabilities include dangerous permissions like `NET_RAW`. | `securityContext: { capabilities: { drop: ["ALL"], add: ["NET_BIND_SERVICE"] } }` | Low |
| 3 | C | Use specific image tags or digests, never `latest` | `latest` is mutable; builds become non-reproducible and unauditable. | `FROM node:22.15-alpine` or `FROM node@sha256:...` | Low |
| 4 | H | Use multi-stage builds | Build dependencies in production images expand attack surface. | Separate `builder` stage from `runtime` stage; copy only compiled artifacts | Medium |
| 5 | H | Use read-only root filesystem | Writable filesystems let attackers persist malware. | `securityContext: { readOnlyRootFilesystem: true }`; mount `emptyDir` for `/tmp` | Medium |
| 6 | H | Set resource limits (CPU and memory) | Unlimited containers can starve the host. | `resources: { limits: { memory: "512Mi", cpu: "500m" }, requests: { memory: "256Mi", cpu: "250m" } }` | Low |
| 7 | H | Scan images in CI before push | Deploying vulnerable base images undermines all other hardening. | `trivy image --exit-code 1 --severity CRITICAL myimage:tag` | Low |
| 8 | H | Use minimal base images | Full OS images (ubuntu, debian) include hundreds of unnecessary packages. | Use `alpine`, `distroless`, or `scratch` base images | Medium |
| 9 | M | Set `no-new-privileges` flag | Prevents setuid binaries from escalating privileges inside the container. | `securityContext: { allowPrivilegeEscalation: false }` | Low |
| 10 | M | Define health checks | Without health checks, crashed processes remain in rotation. | Dockerfile: `HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost:8080/health \|\| exit 1` | Low |
| 11 | M | Do not store secrets in images | Anyone with image pull access gets the secrets. | Use runtime secret injection (env vars, mounted secrets); never `COPY .env` or `ARG SECRET` | Low |
| 12 | M | Use `.dockerignore` | Without it, `docker build` copies secrets, git history, and node_modules into the build context. | Create `.dockerignore` with: `.git`, `.env`, `node_modules`, `*.pem`, `.docker` | Low |
| 13 | L | Set a read-only `/proc` and mask `/sys` | Exposed proc/sys leaks host kernel information. | Docker run: `--read-only --tmpfs /tmp --security-opt=no-new-privileges:true` (K8s: handled by PSS Restricted) | Low |
| 14 | L | Label images with build metadata | Unlabeled images are impossible to trace back to source. | `LABEL org.opencontainers.image.source="https://github.com/org/repo"` `LABEL org.opencontainers.image.revision="${GIT_SHA}"` | Low |

---

## Quick Reference: Priority Matrix

For teams starting from zero, address these first across all categories:

| Priority | Action | Categories |
|----------|--------|------------|
| Day 1 | Disable root/password SSH; enable firewall; enforce RBAC | Linux, K8s |
| Day 1 | Encrypt etcd and database connections | K8s, PostgreSQL |
| Day 1 | Run containers as non-root with dropped capabilities | Docker, K8s |
| Week 1 | Add network policies and PSS enforcement | K8s |
| Week 1 | Enable TLS 1.2+, HSTS, and security headers | NGINX |
| Week 1 | Pin dependencies and scan for vulnerabilities | CI/CD, Docker |
| Week 1 | Restrict database access to specific IPs and roles | PostgreSQL |
| Month 1 | Enable audit logging across all layers | Linux, K8s, PostgreSQL |
| Month 1 | Sign artifacts and enforce branch protection | CI/CD |
| Month 1 | Implement resource quotas and connection limits | K8s, PostgreSQL |
