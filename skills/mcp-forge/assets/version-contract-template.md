# Version Contract: {{SERVER_NAME}} v{{VERSION}}

## Metadata

- **Version:** {{VERSION}}
- **Effective Date:** {{DATE}}
- **Author:** {{AUTHOR}}
- **Status:** {{Active | Deprecated | Retired}}
- **Previous Version:** {{PREVIOUS_VERSION or "None (initial release)"}}

## Backward Compatibility Guarantees

{{Describe what consumers can rely on remaining stable in this version.}}

{{If initial release: "This is the initial release. No backward compatibility guarantees with prior versions."}}

{{If subsequent release: "All tools from v{{PREVIOUS}} remain callable with the same parameter schemas unless listed under Breaking Changes below."}}

## Breaking Changes from Previous Version

{{If initial release: "N/A -- initial release."}}

{{If subsequent release, list each breaking change:}}

### {{CHANGE_NUMBER}}. {{DESCRIPTION}}

- **Tool:** {{TOOL_NAME}}
- **What Changed:** {{DESCRIPTION OF THE CHANGE}}
- **Why:** {{RATIONALE}}
- **Migration:**
  ```
  // Before (v{{PREVIOUS}})
  {{OLD USAGE}}

  // After (v{{VERSION}})
  {{NEW USAGE}}
  ```

## Tool Manifest

{{FOR EACH PUBLISHED TOOL:}}

### {{TOOL_NAME}}

- **Category:** {{CATEGORY (e.g., Deployment, Monitoring, CI)}}
- **Description:** {{ONE-LINE DESCRIPTION}}
- **Parameters:**
  | Name | Type | Required | Default | Description |
  |------|------|----------|---------|-------------|
  | {{name}} | {{type}} | {{yes/no}} | {{default or N/A}} | {{description}} |
- **Response Schema:**
  ```json
  {{JSON SCHEMA OF RESPONSE}}
  ```
- **Backing Tools:** {{LIST OF backing_server.tool_name CALLS}}
- **Error Behavior:** {{HOW ERRORS ARE RETURNED}}

{{END FOR EACH}}

## Backing Tool Dependencies

| Server | Tool | Version Tested | Required | Notes |
|--------|------|---------------|----------|-------|
| {{server}} | {{tool}} | {{version}} | {{Yes/No}} | {{notes}} |

## Deprecation Notices

{{If none: "No tools are currently deprecated."}}

{{If deprecations exist:}}

| Tool | Deprecated Since | Removal Version | Replacement |
|------|-----------------|-----------------|-------------|
| {{tool}} | v{{since}} | v{{removal}} | {{replacement description}} |

## Migration Instructions

{{If initial release: "N/A -- initial release."}}

{{If subsequent release: Step-by-step migration guide for consumers upgrading from the previous version.}}

## Appendix: Frozen Schema Snapshot

{{Optional: Full JSON Schema dump of all tool input/output schemas for machine comparison between versions.}}

```json
{
  "version": "{{VERSION}}",
  "tools": {
    "{{tool_name}}": {
      "input_schema": {{INPUT_SCHEMA}},
      "output_schema": {{OUTPUT_SCHEMA}}
    }
  }
}
```
