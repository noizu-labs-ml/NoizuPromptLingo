# MCP Jumpstart Generator

| Field | Value |
|-------|-------|
| **ID** | `mcp-jumpstart-generator` |
| **Type** | Storyboard |
| **Category** | MCP Jumpstart |
| **User Stories** | US-039, US-040, US-041, US-042, US-043, US-044, US-045, US-046, US-047, US-048, US-049, US-050 |

## Description

Multi-step project scaffolding wizard: select language -> select template -> customize options -> preview file tree -> download or push to Git.

## Key Components

- **LanguageSelector**
- **TemplateCatalog**
- **TemplateDetailPanel**
- **CustomizationForm**
- **TransportSelector**
- **FeatureToggles**
- **FileTreePreview**
- **CodePreviewPanel**
- **DownloadButton**
- **GitPushDialog**

## Interactions

- Select language
- Browse/select template
- Customize project name, tools, transport, auth, features
- Preview file tree and code
- Download ZIP
- Push to GitHub/GitLab
- Reset to defaults

## Navigation

- Dashboard / Onboarding -> Jumpstart Generator
