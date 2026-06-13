# Security Architecture

## Current State

The landing page has no application-level authentication or authorization. Security is enforced at the infrastructure layer.

### Network Security

- **Cloudflare-only access**: NGINX ingress annotations restrict source IPs to Cloudflare ranges via `nginx.ingress.kubernetes.io/whitelist-source-range`
- **TLS termination**: Ingress terminates TLS using origin certificates synced from Infisical
- **SSL redirect**: All HTTP traffic redirected to HTTPS via ingress annotation

### TLS Certificate Management

Certificates are managed by the Infisical Operator:
- **Source**: Infisical project `k8-infra`, environment `prod`, path `/apps/tls/iotgo`
- **Secret keys**: `IOTGO_TLS_CRT` (certificate), `IOTGO_TLS_KEY` (private key)
- **Sync interval**: 300 seconds (5 minutes)
- **Credentials**: Universal auth credentials in `infisical-operator-system` namespace

### Container Security

- Minimal attack surface: `nginx:alpine` runtime image (no Node.js in production)
- No privileged capabilities required
- Resource limits enforced (200m CPU, 256Mi memory)

## Future Considerations

When the backend and agent runtime are built, the security model will need to address:
- API authentication (JWT / API keys)
- Multi-tenant fleet isolation
- Agent action authorization (playbook constraint enforcement)
- Audit logging for all agent actions
- Secrets management for fleet connection credentials (MQTT certs, cloud provider tokens)
