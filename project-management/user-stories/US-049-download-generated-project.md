---
id: US-049
title: "Download generated project as zip archive"
slug: "download-generated-project"
personas: [P-001, P-007]
epic: "MCP Jumpstart"
priority: "must-have"
complexity: "S"
tags: [mcp-jumpstart, scaffolding, download, export]
---

# US-049: Download Generated Project as Zip Archive

## User Story

**As a** Solo AI Hobbyist (P-007),
**I want to** download the generated MCP project as a zip archive,
**So that** I can extract it locally, open it in my IDE, and start developing immediately.

## Acceptance Criteria

- [ ] Given the user has previewed and confirmed the generated project (US-047), when they click "Download as ZIP," then the system generates a zip archive containing the complete project directory structure.
- [ ] Given the zip archive is generated, when the user extracts it, then the top-level directory is named after the project name (from US-048) and contains all generated files preserving the directory structure.
- [ ] Given the zip archive is downloaded, when the user examines the file sizes, then the archive does not include `node_modules/`, `__pycache__/`, `.git/`, or other generated/dependency directories.
- [ ] Given the zip archive is extracted, when the user opens it, then it includes a README.md with setup instructions (install dependencies, configure auth, run locally, run tests) specific to the selected language and template.
- [ ] Given the download completes, when the browser receives the file, then the filename follows the pattern `{project-name}-mcp.zip` and the content type is `application/zip`.
- [ ] Given the download fails due to a server error, when the error occurs, then the system displays a user-friendly error message with a retry option and the project is not lost (user can retry without regenerating).

## Notes

The zip download is the primary distribution mechanism for MCP Jumpstart. The README inside the zip should be specific to the generated configuration, not a generic template. Related: US-047 (preview), US-048 (customization), US-050 (Git push alternative).
