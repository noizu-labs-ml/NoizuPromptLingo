# JustMCP Deploy Wizard

| Field | Value |
|-------|-------|
| **ID** | `justmcp-deploy-wizard` |
| **Type** | Storyboard |
| **Category** | JustMCP Deployment |
| **User Stories** | US-026, US-027, US-028, US-030, US-037, US-095 |

## Description

Multi-step deployment flow: upload tool definition -> configure auth -> set access policy -> security scan -> deploy. Shows progress and live endpoint on completion.

## Key Components

- **WizardStepper**
- **ToolDefinitionUploader**
- **FormatDetectionPreview**
- **AuthMethodSelector**
- **PolicyEditor**
- **SecurityScanReport**
- **DeployProgressIndicator**
- **EndpointDisplay**
- **ConnectionSnippets**

## Interactions

- Upload file (drag-drop or picker)
- Select auth method
- Configure policy
- Review security scan results
- Deploy with one click
- Copy endpoint URL
- Copy connection snippets

## Navigation

- Dashboard -> Deploy Wizard -> Server Detail
