# Virtual MCP Versioning System

Semantic versioning for Virtual MCP tool interfaces, version contracts, breaking change detection, and deprecation protocols.

## Semantic Versioning for Tool Interfaces

Virtual MCP uses **MAJOR.MINOR** versioning (no patch -- tool interfaces are either compatible or breaking):

| Change Type | Version Impact | Examples |
|---|---|---|
| New tool added | MINOR bump | v1.0 --> v1.1 |
| New optional parameter on existing tool | MINOR bump | v1.1 --> v1.2 |
| Tool description updated | MINOR bump | v1.2 --> v1.3 |
| Tool removed | MAJOR bump | v1.3 --> v2.0 |
| Required parameter added to existing tool | MAJOR bump | v1.0 --> v2.0 |
| Parameter type changed | MAJOR bump | v1.0 --> v2.0 |
| Response schema changed (breaking) | MAJOR bump | v1.0 --> v2.0 |
| Tool renamed | MAJOR bump | v1.0 --> v2.0 |

## Version Contract Document Format

Each version of the Virtual MCP has a frozen contract document.

```markdown
# Version Contract: Virtual DevOps MCP v1.0

## Metadata
- **Version:** 1.0
- **Effective Date:** 2026-05-01
- **Author:** Keith Brings
- **Status:** Active

## Backward Compatibility
- This is the initial release. No backward compatibility guarantees with prior versions.

## Tool Manifest

### deploy_service
- **Category:** Deployment
- **Description:** Deploy a service to the Kubernetes cluster
- **Parameters:**
  - `service_name` (string, required): Name of the service
  - `namespace` (string, required): Target Kubernetes namespace
  - `source_path` (string, required): Path to source code
  - `image_tag` (string, optional): Image tag override. Default: auto-generated
- **Response Schema:**
  ```json
  {
    "service": "string",
    "image": "string",
    "status": "deployed | failed",
    "steps": ["string"]
  }
  ```
- **Backing Tools:** docker.build, docker.push, kubectl.apply

### check_health
- **Category:** Monitoring
- **Description:** Check health status of a deployed service
- **Parameters:**
  - `service_name` (string, required): Name of the service
  - `namespace` (string, optional): Kubernetes namespace. Default: "default"
- **Response Schema:**
  ```json
  {
    "service": "string",
    "status": "healthy | degraded | unhealthy",
    "pods": [{"name": "string", "status": "string", "restarts": "number"}]
  }
  ```
- **Backing Tools:** kubectl.get_pods, kubectl.describe_pod

### view_logs
- **Category:** Monitoring
- **Description:** View logs for a deployed service
- **Parameters:**
  - `service_name` (string, required): Name of the service
  - `namespace` (string, optional): Kubernetes namespace. Default: "default"
  - `tail` (number, optional): Number of lines from the end. Default: 100
  - `container` (string, optional): Specific container name
- **Response Schema:**
  ```json
  {
    "service": "string",
    "container": "string",
    "lines": ["string"],
    "truncated": "boolean"
  }
  ```
- **Backing Tools:** kubectl.get_pods, kubectl.logs

## Backing Tool Dependencies

| Server | Tool | Version Tested | Required |
|--------|------|---------------|----------|
| kubectl-mcp | get_pods | 0.3.0 | Yes |
| kubectl-mcp | describe_pod | 0.3.0 | Yes |
| kubectl-mcp | apply | 0.3.0 | Yes |
| kubectl-mcp | logs | 0.3.0 | Yes |
| docker-mcp | build | 0.2.1 | Yes |
| docker-mcp | push | 0.2.1 | Yes |

## Deprecation Notices
- None (initial release)
```

## Breaking Change Detection

### Schema Diff Between Versions

Compare version contracts to detect breaking changes:

```
diff v1.0 v2.0

BREAKING CHANGES:
  - deploy_service: Added required parameter "cluster" (string)
  - check_health: Response field "status" enum changed
    - v1.0: "healthy | degraded | unhealthy"
    - v2.0: "healthy | warning | critical | unknown"
  - rollback: Tool removed (was in v1.0, not in v2.0)

COMPATIBLE CHANGES:
  - deploy_service: Added optional parameter "dry_run" (boolean)
  - run_workflow: New tool added

INFORMATIONAL:
  - view_logs: Description updated
```

### Automated Detection

```yaml
# Schema diff rules
breaking_changes:
  - tool_removed
  - required_parameter_added
  - parameter_type_changed
  - parameter_removed
  - response_field_removed
  - response_field_type_changed
  - enum_value_removed

compatible_changes:
  - tool_added
  - optional_parameter_added
  - response_field_added
  - enum_value_added
  - description_changed
```

## Migration Path Generation

When a breaking change occurs, generate a migration guide:

```markdown
# Migration Guide: v1.0 --> v2.0

## Breaking Changes

### 1. deploy_service: New Required Parameter "cluster"

**What changed:** deploy_service now requires a "cluster" parameter (string)
specifying which Kubernetes cluster to deploy to.

**Why:** Multi-cluster support was added in v2.0.

**Migration:**
```
// v1.0
ToolCall("deploy_service", {service_name: "api", namespace: "prod", source_path: "."})

// v2.0
ToolCall("deploy_service", {service_name: "api", namespace: "prod", source_path: ".", cluster: "production"})
```

### 2. check_health: Status Enum Changed

**What changed:** The status field values changed from
"healthy | degraded | unhealthy" to "healthy | warning | critical | unknown".

**Mapping:**
| v1.0 | v2.0 |
|------|------|
| healthy | healthy |
| degraded | warning |
| unhealthy | critical |
| (n/a) | unknown |

### 3. rollback: Tool Removed

**What changed:** The rollback tool was removed.

**Replacement:** Use deploy_service with the `image_tag` parameter set to the
previous version's image tag. The deployment history is available via
check_health's new `history` field.
```

## Deprecation Protocol

Tools follow a strict deprecation lifecycle:

```
Active --> Deprecated (vN) --> Removed (vN+1 minimum)
```

### Rules

1. **Mark as deprecated** in version N with a clear message:
   ```yaml
   - name: rollback
     deprecated: true
     deprecated_since: "1.2"
     deprecated_message: "Use deploy_service with previous image_tag instead"
     removal_version: "2.0"
   ```

2. **Minimum one MINOR version** between deprecation and removal. If deprecated in v1.2, earliest removal is v2.0.

3. **Deprecation warnings** in tool responses:
   ```json
   {
     "_deprecated": true,
     "_deprecated_message": "This tool will be removed in v2.0. Use deploy_service with image_tag instead.",
     "result": "..."
   }
   ```

4. **Self-audit includes deprecation check:** Verify deprecated tools still work until removal.

## Version Coexistence

A Virtual MCP can serve multiple versions simultaneously:

```yaml
# Agent definition supporting v1 and v2
versions:
  v1:
    contract: version-contract-v1.md
    tools:
      - deploy_service  # v1 schema (no cluster param)
      - check_health    # v1 schema (old status enum)
      - rollback        # deprecated but still available
      - view_logs

  v2:
    contract: version-contract-v2.md
    tools:
      - deploy_service  # v2 schema (with cluster param)
      - check_health    # v2 schema (new status enum)
      - view_logs
      - run_workflow    # new in v2

# Meta-tool behavior:
# ToolSummary(version="v1") --> shows v1 tools
# ToolSummary(version="v2") --> shows v2 tools
# ToolSummary() --> shows latest version (v2)
# ToolCall("rollback", ..., version="v1") --> works (deprecated)
# ToolCall("rollback", ..., version="v2") --> error (removed)
```

### Coexistence Rules

1. The default version is always the latest
2. Clients can pin to a specific version via a `version` parameter on meta-tools
3. Deprecated tools in older versions still work but emit warnings
4. Removed tools return a clear error with migration instructions
5. Self-audit runs against all active versions

## Example: v1 --> v2 --> v3 Lifecycle

### v1.0 (Initial Release)
- Tools: deploy_service, check_health, view_logs
- Status: Active

### v1.1 (Minor Extension)
- Added: run_workflow tool
- Modified: deploy_service added optional dry_run parameter
- Status: Active

### v1.2 (Deprecation)
- Deprecated: rollback was implicitly available -- now formally deprecated
- Status: Active with deprecation notice

### v2.0 (Breaking Changes)
- Removed: rollback
- Modified: deploy_service requires cluster parameter
- Modified: check_health status enum changed
- v1 contract: still served for backward compatibility
- Status: Active (v2 is default, v1 is supported)

### v2.1 (Minor Extension)
- Added: scale_service tool
- Status: Active

### v3.0 (Retirement of v1)
- v1 contract: no longer served
- Modified: view_logs container parameter is now required (was optional)
- Status: Active (v3 is default, v2 is supported, v1 is retired)
