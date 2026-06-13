# MCP Host — Site Map

> Unified MCP hosting platform: deploy, scaffold, and secure MCP servers.

**Domains:** justmcp.it | mcpjumpst.art | safemcp.com
**Status:** draft
**Last updated:** 2026-05-12

---

## Platform Navigation Model

The three domains share a unified auth system and top-level navigation. Users sign in once and move between surfaces via a persistent platform switcher.

### Global Navigation

```
[Logo] [JustMCP.it | Jumpstart | SafeMCP]        [Registry] [Docs] [User ▾]
```

- **Platform switcher** — tab bar distinguishing the three surfaces
- **Registry** — global search, always accessible from any surface
- **Docs** — unified documentation across all surfaces
- **User menu** — org switcher, settings, API keys, sign out

### Auth Gates

| Route Pattern | Gate |
|---------------|------|
| `/` (all surfaces) | Public |
| `/docs/*` | Public |
| `/registry/*` | Public (read), Auth (publish/bookmark) |
| `/pricing` | Public |
| `/dashboard/*` | Auth required |
| `/deploy/*` | Auth required |
| `/scaffold/*` | Auth required |
| `/policies/*` | Auth required |
| `/admin/*` | Auth + org admin role |
| `/settings/*` | Auth required |

---

## Page Flow Diagram

```mermaid
graph LR
    %% Public entry
    LANDING["/ Landing"] -->|CTA| SIGNUP["/signup"]
    LANDING -->|nav| REGISTRY["/registry"]
    LANDING -->|nav| DOCS["/docs"]
    LANDING -->|nav| PRICING["/pricing"]
    SIGNUP -->|auth| DASH["/dashboard"]

    %% JustMCP.it flow
    DASH -->|deploy| DEPLOY_NEW["/deploy/new"]
    DEPLOY_NEW -->|upload| DEPLOY_CONFIG["/deploy/configure"]
    DEPLOY_CONFIG -->|auth setup| DEPLOY_AUTH["/deploy/auth"]
    DEPLOY_AUTH -->|policy| DEPLOY_POLICY["/deploy/policy"]
    DEPLOY_POLICY -->|launch| DEPLOY_LIVE["/deploy/:id"]
    DEPLOY_LIVE -->|monitor| DEPLOY_MONITOR["/deploy/:id/monitor"]
    DEPLOY_LIVE -->|logs| DEPLOY_LOGS["/deploy/:id/logs"]

    %% Jumpstart flow
    DASH -->|scaffold| SCAFFOLD_NEW["/scaffold/new"]
    SCAFFOLD_NEW -->|select| SCAFFOLD_CONFIG["/scaffold/configure"]
    SCAFFOLD_CONFIG -->|generate| SCAFFOLD_REVIEW["/scaffold/review"]
    SCAFFOLD_REVIEW -->|download| SCAFFOLD_DL["Download / Push to GitHub"]

    %% SafeMCP flow
    DASH -->|policies| POLICIES["/policies"]
    POLICIES -->|create| POLICY_EDIT["/policies/new"]
    POLICIES -->|view| POLICY_DETAIL["/policies/:id"]
    DASH -->|audit| AUDIT["/audit"]
    AUDIT -->|detail| AUDIT_DETAIL["/audit/:request_id"]
    DASH -->|simulate| SIMULATE["/simulate"]

    %% Registry
    REGISTRY -->|detail| REGISTRY_DETAIL["/registry/:server"]
    REGISTRY_DETAIL -->|deploy| DEPLOY_NEW
    REGISTRY_DETAIL -->|docs| TOOL_DOCS["/registry/:server/docs"]

    %% Settings
    DASH -->|settings| SETTINGS["/settings"]
    SETTINGS -->|api keys| API_KEYS["/settings/api-keys"]
    SETTINGS -->|org| ORG["/settings/org"]
    SETTINGS -->|integrations| INTEGRATIONS["/settings/integrations"]
```

---

## Surface 1: JustMCP.it — One-Click Deploy

### / — Landing Page

```mermaid
graph TD
    PAGE["Landing Page"]
    PAGE --> NAV["GlobalNav\nplatform switcher + auth"]
    PAGE --> HERO["Hero\n'Deploy MCP servers in 90 seconds'\n+ primary CTA"]
    PAGE --> DEMO["LiveDemo\nanimated deploy flow preview"]
    PAGE --> FEATURES["FeatureGrid\n3-column bento: Deploy / Monitor / Secure"]
    PAGE --> TRUST["TrustBar\nsecurity badges + uptime stat"]
    PAGE --> PRICING_CTA["PricingTeaser\nfree tier callout + pricing link"]
    PAGE --> FOOTER["GlobalFooter\nnav + legal + status"]
```

**Key data:** None (static marketing content)
**Conversion goal:** Sign up or start deploy flow

### /deploy/new — Upload Tool Definition

```mermaid
graph TD
    PAGE["Deploy: Upload"]
    PAGE --> NAV["GlobalNav"]
    PAGE --> STEPPER["DeployStepper\n4 steps: Upload → Configure → Auth → Policy"]
    PAGE --> UPLOAD["UploadZone\ndrop zone for JSON/OpenAPI/MCP schema\n+ paste raw JSON + URL import"]
    PAGE --> PREVIEW["SchemaPreview\nparsed tool list with parameter types"]
    PAGE --> VALIDATION["ValidationPanel\nschema errors, warnings, suggestions"]
    PAGE --> ACTIONS["ActionBar\nNext / Save Draft"]
```

**Key data:** Uploaded schema file, parsed tool definitions
**Validation:** Schema parsing, tool name uniqueness check

### /deploy/configure — Server Configuration

```mermaid
graph TD
    PAGE["Deploy: Configure"]
    PAGE --> NAV["GlobalNav"]
    PAGE --> STEPPER["DeployStepper\nstep 2 active"]
    PAGE --> NAME["ServerNameInput\nsubdomain selection: {name}.justmcp.it"]
    PAGE --> TRANSPORT["TransportSelect\nSSE / WebSocket / stdio-over-HTTP"]
    PAGE --> RUNTIME["RuntimeConfig\nmemory, CPU, timeout, network policy"]
    PAGE --> ENV["EnvVars\nkey-value editor for environment variables"]
    PAGE --> ACTIONS["ActionBar\nBack / Next"]
```

**Key data:** Server config, runtime limits, transport selection

### /deploy/auth — Auth Configuration

```mermaid
graph TD
    PAGE["Deploy: Auth"]
    PAGE --> NAV["GlobalNav"]
    PAGE --> STEPPER["DeployStepper\nstep 3 active"]
    PAGE --> METHOD["AuthMethodSelect\nAPI Key / OAuth 2.1 / mTLS / None"]
    PAGE --> OAUTH["OAuthConfig\nclient ID, scopes, redirect URIs\n(conditional on OAuth selection)"]
    PAGE --> DELEGATED["DelegatedAuthConfig\ndownstream service connections\nOAuth delegate setup"]
    PAGE --> ACTIONS["ActionBar\nBack / Next"]
```

**Key data:** Auth method, OAuth config, delegated auth setup

### /deploy/policy — Access Policy

```mermaid
graph TD
    PAGE["Deploy: Policy"]
    PAGE --> NAV["GlobalNav"]
    PAGE --> STEPPER["DeployStepper\nstep 4 active"]
    PAGE --> EDITOR["PolicyEditor\nYAML/visual editor for access rules\nallow/deny lists, rate limits, constraints"]
    PAGE --> PREVIEW["PolicyPreview\nsimulated request → allow/deny decision"]
    PAGE --> ACTIONS["ActionBar\nBack / Deploy"]
```

**Key data:** Policy document, simulation results

### /deploy/:id — Server Dashboard

```mermaid
graph TD
    PAGE["Server Dashboard"]
    PAGE --> NAV["GlobalNav"]
    PAGE --> HEADER["ServerHeader\nname, status badge, endpoint URL, quick actions"]
    PAGE --> STATS["StatCards\n4-card bento: Requests/24h, Latency p99, Error Rate, Policy Denials"]
    PAGE --> CHART["RequestChart\ntime-series: requests, errors, latency"]
    PAGE --> TOOLS["ToolList\ntool inventory with per-tool metrics"]
    PAGE --> RECENT["RecentRequests\nlast 50 invocations with status + caller"]
    PAGE --> SIDEBAR["QuickActions\nRedeploy, Edit Config, View Logs, Pause"]
```

**Key data:** Server metrics, request log, tool inventory

### /deploy/:id/monitor — Monitoring

```mermaid
graph TD
    PAGE["Monitoring"]
    PAGE --> NAV["GlobalNav"]
    PAGE --> TABS["MonitorTabs\nOverview / Latency / Errors / Policy"]
    PAGE --> CHARTS["ChartGrid\ntime-series panels per metric"]
    PAGE --> ALERTS["AlertConfig\nthreshold alerts: latency, error rate, downtime"]
    PAGE --> HEALTH["HealthHistory\nuptime timeline with incident markers"]
```

**Key data:** Time-series metrics, alert rules, health check results

### /deploy/:id/logs — Request Logs

```mermaid
graph TD
    PAGE["Request Logs"]
    PAGE --> NAV["GlobalNav"]
    PAGE --> FILTERS["LogFilters\ndate range, caller, tool, status, policy decision"]
    PAGE --> TABLE["LogTable\ntimestamp, caller, tool, args (redacted), decision, duration"]
    PAGE --> DETAIL["LogDetail\nfull audit record (slide-over panel)"]
    PAGE --> EXPORT["ExportBar\nCSV / JSON export, compliance download"]
```

**Key data:** Audit log entries, filter state

---

## Surface 2: MCP Jumpstart — Scaffolding

### / — Landing Page (mcpjumpst.art)

```mermaid
graph TD
    PAGE["Jumpstart Landing"]
    PAGE --> NAV["GlobalNav"]
    PAGE --> HERO["Hero\n'From zero to MCP server in 5 minutes'\n+ Start Building CTA"]
    PAGE --> LANGUAGES["LanguageGrid\nTS / Python / Elixir / Go / Rust icons"]
    PAGE --> TEMPLATES["TemplateShowcase\n6 use-case cards with preview"]
    PAGE --> CODE["CodePreview\nside-by-side: template selection → generated code"]
    PAGE --> FOOTER["GlobalFooter"]
```

### /scaffold/new — Select Template

```mermaid
graph TD
    PAGE["Scaffold: Select"]
    PAGE --> NAV["GlobalNav"]
    PAGE --> STEPPER["ScaffoldStepper\n3 steps: Select → Configure → Review"]
    PAGE --> LANG["LanguageFilter\nlanguage selector chips"]
    PAGE --> TEMPLATES["TemplateGrid\nuse-case cards: CRUD Wrapper, LLM Tool,\nData Pipeline, Auth Proxy, Webhook Bridge, Custom"]
    PAGE --> PREVIEW["TemplatePreview\nfile tree + description + what's included"]
```

**Key data:** Template catalog, language support matrix

### /scaffold/configure — Configure Project

```mermaid
graph TD
    PAGE["Scaffold: Configure"]
    PAGE --> NAV["GlobalNav"]
    PAGE --> STEPPER["ScaffoldStepper\nstep 2 active"]
    PAGE --> PROJECT["ProjectConfig\nname, description, version, author"]
    PAGE --> TOOLS["ToolEditor\nadd/remove/edit tool definitions\nname, description, input schema, handler stub"]
    PAGE --> TRANSPORT["TransportConfig\nstdio / SSE / WebSocket selection"]
    PAGE --> AUTH["AuthConfig\nauth middleware selection"]
    PAGE --> INFRA["InfraConfig\nDocker / K8s manifests / CI pipeline toggles"]
```

**Key data:** Project configuration, tool definitions

### /scaffold/review — Review & Download

```mermaid
graph TD
    PAGE["Scaffold: Review"]
    PAGE --> NAV["GlobalNav"]
    PAGE --> STEPPER["ScaffoldStepper\nstep 3 active"]
    PAGE --> TREE["FileTree\ngenerated project file tree, expandable"]
    PAGE --> PREVIEW["FilePreview\nsyntax-highlighted file content viewer"]
    PAGE --> DIFF["DiffView\nchanges from base template (if re-scaffolding)"]
    PAGE --> ACTIONS["DownloadBar\nDownload ZIP / Push to GitHub / Open in Codespace"]
```

**Key data:** Generated project files

---

## Surface 3: SafeMCP — Security Control Plane

### / — Landing Page (safemcp.com)

```mermaid
graph TD
    PAGE["SafeMCP Landing"]
    PAGE --> NAV["GlobalNav"]
    PAGE --> HERO["Hero\n'Security that travels with your MCP endpoints'\n+ View Policies CTA"]
    PAGE --> PILLARS["PillarGrid\n3-column: Dual-Principal Auth / Granular Policies / Audit Trail"]
    PAGE --> DIAGRAM["ArchDiagram\ninteractive policy evaluation flow visualization"]
    PAGE --> COMPLIANCE["ComplianceBadges\nSOC 2, GDPR, audit export badges"]
    PAGE --> FOOTER["GlobalFooter"]
```

### /policies — Policy Management

```mermaid
graph TD
    PAGE["Policies"]
    PAGE --> NAV["GlobalNav"]
    PAGE --> HEADER["PageHeader\n'Access Policies' + Create Policy CTA"]
    PAGE --> FILTERS["PolicyFilters\nscope (global/org/server/tool), status, search"]
    PAGE --> TABLE["PolicyTable\nname, scope, rules count, last modified, status"]
    PAGE --> DETAIL["PolicyDetail\nslide-over with full policy document"]
```

**Key data:** Policy list, policy documents

### /policies/new — Policy Editor

```mermaid
graph TD
    PAGE["Policy Editor"]
    PAGE --> NAV["GlobalNav"]
    PAGE --> META["PolicyMeta\nname, description, scope selector"]
    PAGE --> EDITOR["PolicyEditor\ndual-mode: Visual rule builder / YAML editor"]
    PAGE --> RULES["RuleList\nordered rules with allow/deny/confirm actions\nper-tool, per-caller, per-user conditions"]
    PAGE --> SIMULATOR["InlineSimulator\ntest request → policy evaluation trace"]
    PAGE --> ACTIONS["ActionBar\nSave Draft / Publish / Discard"]
```

**Key data:** Policy document, simulation results

### /audit — Audit Log

```mermaid
graph TD
    PAGE["Audit Log"]
    PAGE --> NAV["GlobalNav"]
    PAGE --> SEARCH["AuditSearch\nfull-text search across audit records"]
    PAGE --> FILTERS["AuditFilters\ndate range, server, tool, caller, user, decision"]
    PAGE --> TIMELINE["AuditTimeline\ntime-series bar chart of request volume by decision"]
    PAGE --> TABLE["AuditTable\ntimestamp, server, tool, caller, user, decision, duration"]
    PAGE --> DETAIL["AuditDetail\nfull immutable record (slide-over)"]
    PAGE --> EXPORT["ExportBar\ncompliance export: CSV, JSON, PDF report"]
```

**Key data:** Audit records, aggregated analytics

### /simulate — Simulation Environment

```mermaid
graph TD
    PAGE["Simulate"]
    PAGE --> NAV["GlobalNav"]
    PAGE --> HEADER["PageHeader\n'Test before production' + New Simulation CTA"]
    PAGE --> REQUEST["RequestBuilder\ncaller identity, user identity, tool, args"]
    PAGE --> POLICIES["PolicySelector\nwhich policies to evaluate against"]
    PAGE --> RESULT["SimulationResult\nallow/deny decision, matched rules,\nevaluation trace with expand/collapse"]
    PAGE --> HISTORY["SimulationHistory\nprevious simulation runs"]
```

**Key data:** Simulation input, policy evaluation trace

---

## Shared Pages

### /registry — MCP Registry & Discovery

```mermaid
graph TD
    PAGE["Registry"]
    PAGE --> NAV["GlobalNav"]
    PAGE --> SEARCH["RegistrySearch\nfull-text search with autocomplete"]
    PAGE --> CATEGORIES["CategoryNav\nhorizontal scrollable category chips"]
    PAGE --> FILTERS["FilterPanel\nlanguage, auth method, trust score, health status"]
    PAGE --> GRID["ServerGrid\ncard grid: name, description, tool count,\nhealth badge, trust score, publisher"]
    PAGE --> PAGINATION["Pagination\ninfinite scroll with count"]
```

**Key data:** Server catalog, category taxonomy, health/trust scores

### /registry/:server — Server Detail

```mermaid
graph TD
    PAGE["Server Detail"]
    PAGE --> NAV["GlobalNav"]
    PAGE --> HEADER["ServerHeader\nname, publisher, trust score, health badge,\nDeploy / Bookmark actions"]
    PAGE --> TABS["DetailTabs\nTools / Docs / Changelog / Reviews"]
    PAGE --> TOOLS["ToolList\ntool name, description, input/output schema,\nrequired permissions, usage stats"]
    PAGE --> SIDEBAR["ServerMeta\nversion, last updated, license, compatibility,\nuptime %, latency p99"]
```

**Key data:** Server metadata, tool schemas, usage stats, reviews

### /docs — Documentation

```mermaid
graph TD
    PAGE["Docs"]
    PAGE --> NAV["GlobalNav"]
    PAGE --> SIDEBAR["DocNav\ncollapsible tree: Getting Started, Guides,\nAPI Reference, Security, Self-Hosting"]
    PAGE --> CONTENT["DocContent\nmarkdown-rendered content with code blocks"]
    PAGE --> TOC["TableOfContents\nright sidebar, scroll-spy anchors"]
    PAGE --> SEARCH["DocSearch\nfull-text search with preview snippets"]
```

### /pricing — Pricing

```mermaid
graph TD
    PAGE["Pricing"]
    PAGE --> NAV["GlobalNav"]
    PAGE --> TIERS["PricingTable\n3-4 tiers: Free / Pro / Team / Enterprise\nfeature comparison matrix"]
    PAGE --> CALCULATOR["UsageCalculator\nestimate cost by requests, servers, seats"]
    PAGE --> FAQ["PricingFAQ\naccordion FAQ"]
    PAGE --> CTA["BottomCTA\n'Start free' + 'Contact sales'"]
```

### /settings — Account Settings

```mermaid
graph TD
    PAGE["Settings"]
    PAGE --> NAV["GlobalNav"]
    PAGE --> SIDENAV["SettingsNav\nProfile / Organization / API Keys /\nIntegrations / Billing / Security"]
    PAGE --> CONTENT["SettingsContent\nform-based settings panels"]
```

### /settings/api-keys — API Key Management

```mermaid
graph TD
    PAGE["API Keys"]
    PAGE --> NAV["GlobalNav"]
    PAGE --> SIDENAV["SettingsNav"]
    PAGE --> LIST["KeyList\nname, prefix, created, last used, policy binding"]
    PAGE --> CREATE["CreateKeyDialog\nname, policy binding (YAML), expiration"]
    PAGE --> REVEAL["KeyReveal\none-time display of generated key"]
```

**Key data:** API keys, policy bindings

---

## Page Inventory

| Route | Surface | Purpose | Key Components | Auth |
|-------|---------|---------|----------------|------|
| `/` | All | Landing page (varies by domain) | Hero, FeatureGrid, TrustBar | Public |
| `/signup` | Shared | Registration | SignupForm | Public |
| `/login` | Shared | Authentication | LoginForm | Public |
| `/dashboard` | Shared | Overview hub | StatCards, RecentActivity, QuickActions | Auth |
| `/deploy/new` | JustMCP | Upload tool definition | UploadZone, SchemaPreview, ValidationPanel | Auth |
| `/deploy/configure` | JustMCP | Server configuration | ServerNameInput, TransportSelect, RuntimeConfig | Auth |
| `/deploy/auth` | JustMCP | Auth setup | AuthMethodSelect, OAuthConfig, DelegatedAuth | Auth |
| `/deploy/policy` | JustMCP | Access policy | PolicyEditor, PolicyPreview | Auth |
| `/deploy/:id` | JustMCP | Server dashboard | StatCards, RequestChart, ToolList | Auth |
| `/deploy/:id/monitor` | JustMCP | Monitoring | ChartGrid, AlertConfig, HealthHistory | Auth |
| `/deploy/:id/logs` | JustMCP | Request logs | LogFilters, LogTable, LogDetail | Auth |
| `/scaffold/new` | Jumpstart | Template selection | LanguageFilter, TemplateGrid | Auth |
| `/scaffold/configure` | Jumpstart | Project configuration | ToolEditor, TransportConfig, InfraConfig | Auth |
| `/scaffold/review` | Jumpstart | Review & download | FileTree, FilePreview, DownloadBar | Auth |
| `/policies` | SafeMCP | Policy list | PolicyFilters, PolicyTable | Auth |
| `/policies/new` | SafeMCP | Policy editor | PolicyEditor, RuleList, InlineSimulator | Auth |
| `/policies/:id` | SafeMCP | Policy detail | PolicyDetail, RuleList | Auth |
| `/audit` | SafeMCP | Audit log | AuditSearch, AuditTimeline, AuditTable | Auth |
| `/simulate` | SafeMCP | Policy simulator | RequestBuilder, SimulationResult | Auth |
| `/registry` | Shared | MCP server catalog | RegistrySearch, ServerGrid, CategoryNav | Public |
| `/registry/:server` | Shared | Server detail | ToolList, ServerMeta, DetailTabs | Public |
| `/docs` | Shared | Documentation | DocNav, DocContent, DocSearch | Public |
| `/pricing` | Shared | Pricing & plans | PricingTable, UsageCalculator | Public |
| `/settings` | Shared | Account settings | SettingsNav, form panels | Auth |
| `/settings/api-keys` | Shared | API key management | KeyList, CreateKeyDialog | Auth |
| `/settings/org` | Shared | Org management | MemberList, RoleEditor, InviteForm | Admin |
| `/settings/integrations` | Shared | Service connections | IntegrationList, OAuthConnectFlow | Auth |
