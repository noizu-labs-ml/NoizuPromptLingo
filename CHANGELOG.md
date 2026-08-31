# Changelog

All notable changes to this project are documented in this file.
This project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

- Read tools granted by default; write tools require `GOOGLE_MCP_WRITES=1`
- Ads write tools still default to `dry_run` and need `confirm` for live applies
- Client install docs for Codex, Cursor, and VS Code (plus Claude / Grok)

## 0.1.1

- Service-account JSON via `GOOGLE_APPLICATION_CREDENTIALS` (and aliases)
- Optional `GOOGLE_SERVICE_ACCOUNT_JSON`, `GOOGLE_SCOPES`, `GOOGLE_SUBJECT`
- `bin/noizu-google-mcp` stdio wrapper for hosts without a `cwd` field
- Local sibling path override for `:noizu_google` when developing next to the SDK

## 0.1.0

- Initial release: MCP stdio server wrapping `:noizu_google`
- Search Console tools: sites (list/get/add/delete), search analytics, sitemaps
- GA4 Admin/Data tools: properties, data streams, runReport
- AdSense tools: accounts, ad units, reports
- Google Ads tools: list campaigns, list/create conversion actions, mutate
- Destructive Ads/Search Console writes require `confirm` (Ads mutates default to `dry_run`)
- Auth from `GOOGLE_*` or `GOOGLE_MARKETING_*` environment variables
