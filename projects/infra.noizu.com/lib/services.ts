export type ServiceStatus = "active" | "disabled" | "internal" | "pending" | "coming-soon" | "maintenance";

export interface Service {
  slug: string;
  name: string;
  domain: string;
  description: string;
  group: string;
  icon: string;
  status: ServiceStatus;
  tags: string[];
}

export interface ServiceGroup {
  name: string;
  icon: string;
  services: Service[];
}

export const GROUP_ORDER = [
  "Project Management",
  "Design & Diagrams",
  "Automation",
  "Analytics & BI",
  "Observability",
  "AI & Notebooks",
  "ML & Data",
  "Marketing & Content",
  "CRM",
  "Growth & SEO",
  "Developer Services",
  "Operations",
  "Communications",
  "Infrastructure",
  "Published Sites",
] as const;

export const GROUP_ICONS: Record<string, string> = {
  "Project Management": "\u{1F4CB}",
  "Design & Diagrams": "\u{1F3A8}",
  "Automation": "\u{26A1}",
  "Analytics & BI": "\u{1F4CA}",
  "Observability": "\u{1F4C8}",
  "AI & Notebooks": "\u{1F9E0}",
  "ML & Data": "\u{1F9EA}",
  "Marketing & Content": "\u{1F4E3}",
  "CRM": "\u{1F91D}",
  "Growth & SEO": "\u{1F680}",
  "Developer Services": "\u{1F6E0}\u{FE0F}",
  "Operations": "\u{1F4BC}",
  "Communications": "\u{1F4E7}",
  "Infrastructure": "\u{2699}\u{FE0F}",
  "Published Sites": "\u{1F310}",
};

export const services: Service[] = [
  // --- Project Management ---
  {
    slug: "docmost",
    name: "Docmost",
    domain: "docmost.noizu.com",
    description: "Documentation and wiki platform",
    group: "Project Management",
    icon: "\u{1F4DA}",
    status: "active",
    tags: ["docs", "wiki", "knowledge-base"],
  },
  {
    slug: "taiga",
    name: "Taiga",
    domain: "taiga.noizu.com",
    description: "Agile project management",
    group: "Project Management",
    icon: "\u{1F3C4}",
    status: "active",
    tags: ["agile", "scrum", "kanban", "pm"],
  },
  {
    slug: "nextcloud",
    name: "Nextcloud",
    domain: "nextcloud.noizu.com",
    description: "File sharing and collaboration",
    group: "Project Management",
    icon: "\u{2601}\u{FE0F}",
    status: "active",
    tags: ["files", "sync", "collaboration"],
  },
  {
    slug: "plane",
    name: "Plane",
    domain: "plane.noizu.com",
    description: "Modern project management",
    group: "Project Management",
    icon: "\u{2708}\u{FE0F}",
    status: "active",
    tags: ["issues", "projects", "tracking"],
  },

  // --- Design & Diagrams ---
  {
    slug: "penpot",
    name: "Penpot",
    domain: "penpot.noizu.com",
    description: "Open-source design and prototyping",
    group: "Design & Diagrams",
    icon: "\u{1F58C}\u{FE0F}",
    status: "active",
    tags: ["design", "prototyping", "figma-alternative"],
  },
  {
    slug: "drawio",
    name: "Draw.io",
    domain: "drawio.noizu.com",
    description: "General-purpose diagramming",
    group: "Design & Diagrams",
    icon: "\u{1F4CA}",
    status: "active",
    tags: ["diagrams", "flowcharts", "architecture"],
  },
  {
    slug: "excalidraw",
    name: "Excalidraw",
    domain: "excalidraw.noizu.com",
    description: "Collaborative whiteboarding",
    group: "Design & Diagrams",
    icon: "\u{270D}\u{FE0F}",
    status: "active",
    tags: ["whiteboard", "sketching", "collaboration"],
  },
  {
    slug: "mermaid",
    name: "Mermaid",
    domain: "mermaid.noizu.com",
    description: "Text-to-diagram editor",
    group: "Design & Diagrams",
    icon: "\u{1F9DC}\u{200D}\u{2640}\u{FE0F}",
    status: "active",
    tags: ["diagrams", "markdown", "text-to-diagram"],
  },
  {
    slug: "chartdb",
    name: "ChartDB",
    domain: "chartdb.noizu.com",
    description: "Database schema visualization",
    group: "Design & Diagrams",
    icon: "\u{1F5C4}\u{FE0F}",
    status: "active",
    tags: ["database", "schema", "erd"],
  },
  {
    slug: "mydraft",
    name: "MyDraft",
    domain: "mydraft.noizu.com",
    description: "Wireframing and architecture diagrams",
    group: "Design & Diagrams",
    icon: "\u{270F}\u{FE0F}",
    status: "active",
    tags: ["wireframes", "mockups", "ui-design"],
  },
  {
    slug: "webstudio",
    name: "Webstudio",
    domain: "webstudio.noizu.com",
    description: "Visual web builder",
    group: "Design & Diagrams",
    icon: "\u{1F3D7}\u{FE0F}",
    status: "active",
    tags: ["web", "builder", "no-code"],
  },
  {
    slug: "kroki",
    name: "Kroki",
    domain: "kroki.noizu.com",
    description: "Unified diagram rendering API",
    group: "Design & Diagrams",
    icon: "\u{1F527}",
    status: "internal",
    tags: ["api", "rendering", "diagrams"],
  },
  {
    slug: "plantuml",
    name: "PlantUML",
    domain: "plantuml.noizu.com",
    description: "UML diagram server",
    group: "Design & Diagrams",
    icon: "\u{1F331}",
    status: "active",
    tags: ["uml", "sequence", "class-diagrams"],
  },

  // --- Automation ---
  {
    slug: "n8n",
    name: "n8n",
    domain: "n8n.noizu.com",
    description: "Workflow automation platform",
    group: "Automation",
    icon: "\u{1F504}",
    status: "active",
    tags: ["automation", "workflows", "integrations", "no-code"],
  },

  // --- Observability ---
  {
    slug: "oneuptime",
    name: "OneUptime",
    domain: "oneuptime.noizu.com",
    description: "Infrastructure monitoring and status pages",
    group: "Observability",
    icon: "\u{1F7E2}",
    status: "coming-soon",
    tags: ["monitoring", "uptime", "status-page", "alerts"],
  },
  {
    slug: "signoz",
    name: "SigNoz",
    domain: "apm.noizu.com",
    description: "Application performance monitoring",
    group: "Observability",
    icon: "\u{1F4C8}",
    status: "active",
    tags: ["apm", "traces", "metrics", "logs"],
  },
  {
    slug: "phoenix",
    name: "Phoenix",
    domain: "eval.noizu.com",
    description: "LLM observability and evaluation",
    group: "Observability",
    icon: "\u{1F525}",
    status: "active",
    tags: ["llm", "evaluation", "arize"],
  },

  // --- AI & Notebooks ---
  {
    slug: "webui",
    name: "Open WebUI",
    domain: "webui.noizu.com",
    description: "Multi-provider LLM chat interface",
    group: "AI & Notebooks",
    icon: "\u{1F916}",
    status: "active",
    tags: ["llm", "chat", "ai", "litellm"],
  },
  {
    slug: "jupyterhub",
    name: "JupyterHub",
    domain: "jupyter.noizu.com",
    description: "Multi-user Jupyter notebook server",
    group: "AI & Notebooks",
    icon: "\u{1F4D3}",
    status: "active",
    tags: ["notebooks", "python", "data-science"],
  },
  {
    slug: "livebook",
    name: "Livebook",
    domain: "nb.noizu.com",
    description: "Elixir interactive notebooks",
    group: "AI & Notebooks",
    icon: "\u{1F4D6}",
    status: "active",
    tags: ["elixir", "notebooks", "livebook"],
  },

  {
    slug: "weaviate",
    name: "Weaviate",
    domain: "weaviate.noizu.com",
    description: "Vector database for AI workloads",
    group: "AI & Notebooks",
    icon: "\u{1F52E}",
    status: "active",
    tags: ["vector-db", "embeddings", "search", "ai"],
  },
  {
    slug: "vllm",
    name: "vLLM",
    domain: "vllm.vllm-ns.svc.cluster.local",
    description: "Embedding model server (e5-mistral-7b)",
    group: "AI & Notebooks",
    icon: "\u{1F4A0}",
    status: "internal",
    tags: ["llm", "embeddings", "gpu", "inference"],
  },

  // --- Analytics & BI ---
  {
    slug: "langfuse",
    name: "Langfuse",
    domain: "langfuse.noizu.com",
    description: "LLM engineering platform — traces, evals, prompt management",
    group: "Analytics & BI",
    icon: "\u{1F50D}",
    status: "active",
    tags: ["llm", "observability", "traces", "prompts"],
  },
  {
    slug: "metabase",
    name: "Metabase",
    domain: "metabase.noizu.com",
    description: "Business intelligence and analytics dashboards",
    group: "Analytics & BI",
    icon: "\u{1F4CA}",
    status: "active",
    tags: ["bi", "dashboards", "sql", "analytics"],
  },
  {
    slug: "matomo",
    name: "Matomo",
    domain: "matomo.noizu.com",
    description: "Privacy-focused web analytics",
    group: "Analytics & BI",
    icon: "\u{1F4C8}",
    status: "active",
    tags: ["analytics", "web", "privacy", "tracking"],
  },
  {
    slug: "posthog",
    name: "PostHog",
    domain: "posthog.noizu.com",
    description: "Product analytics, feature flags, and session replay",
    group: "Analytics & BI",
    icon: "\u{1F994}",
    status: "active",
    tags: ["analytics", "product", "feature-flags", "session-replay"],
  },

  // --- ML & Data ---
  {
    slug: "labelstudio",
    name: "Label Studio",
    domain: "labelstudio.noizu.com",
    description: "Multi-type data labeling and annotation",
    group: "ML & Data",
    icon: "\u{1F3F7}\u{FE0F}",
    status: "active",
    tags: ["ml", "labeling", "annotation", "datasets"],
  },
  {
    slug: "chatterbox-tts",
    name: "Chatterbox TTS",
    domain: "chatterbox-tts.noizu.com",
    description: "Text-to-speech synthesis server",
    group: "ML & Data",
    icon: "\u{1F5E3}\u{FE0F}",
    status: "active",
    tags: ["tts", "speech", "ai", "gpu"],
  },
  {
    slug: "kitten-tts",
    name: "Kitten TTS",
    domain: "kitten-tts.noizu.com",
    description: "Lightweight text-to-speech engine",
    group: "ML & Data",
    icon: "\u{1F431}",
    status: "active",
    tags: ["tts", "speech", "ai", "cpu"],
  },

  // --- Marketing & Content ---
  {
    slug: "mautic",
    name: "Mautic",
    domain: "mautic.noizu.com",
    description: "Open-source marketing automation",
    group: "Marketing & Content",
    icon: "\u{1F4E7}",
    status: "active",
    tags: ["marketing", "email", "automation", "campaigns"],
  },
  {
    slug: "ghost",
    name: "Ghost",
    domain: "ghost.noizu.com",
    description: "Professional publishing and blogging platform",
    group: "Marketing & Content",
    icon: "\u{1F47B}",
    status: "active",
    tags: ["blog", "publishing", "content", "newsletter"],
  },
  {
    slug: "listmonk",
    name: "Listmonk",
    domain: "listmonk.noizu.com",
    description: "Newsletter and mailing list manager",
    group: "Marketing & Content",
    icon: "\u{1F4EC}",
    status: "active",
    tags: ["newsletter", "mailing-list", "email", "subscribers"],
  },
  {
    slug: "postiz",
    name: "Postiz",
    domain: "postiz.noizu.com",
    description: "Social media scheduling and management",
    group: "Marketing & Content",
    icon: "\u{1F4F1}",
    status: "active",
    tags: ["social-media", "scheduling", "marketing"],
  },

  // --- CRM ---
  {
    slug: "espocrm",
    name: "EspoCRM",
    domain: "espocrm.noizu.com",
    description: "Customer relationship management",
    group: "CRM",
    icon: "\u{1F4C7}",
    status: "active",
    tags: ["crm", "sales", "contacts", "leads"],
  },
  {
    slug: "bottlecrm",
    name: "BottleCRM",
    domain: "bottlecrm.noizu.com",
    description: "Lightweight CRM for small teams",
    group: "CRM",
    icon: "\u{1FAD9}",
    status: "active",
    tags: ["crm", "sales", "lightweight"],
  },

  // --- Growth & SEO ---
  {
    slug: "growthbook",
    name: "GrowthBook",
    domain: "growthbook.noizu.com",
    description: "Feature flags and A/B testing platform",
    group: "Growth & SEO",
    icon: "\u{1F33F}",
    status: "active",
    tags: ["feature-flags", "ab-testing", "experimentation"],
  },
  {
    slug: "serpbear",
    name: "SerpBear",
    domain: "serpbear.noizu.com",
    description: "Search engine rank tracking",
    group: "Growth & SEO",
    icon: "\u{1F43B}",
    status: "active",
    tags: ["seo", "serp", "ranking", "search"],
  },
  {
    slug: "seonaut",
    name: "SEONaut",
    domain: "seonaut.noizu.com",
    description: "SEO auditing and optimization tool",
    group: "Growth & SEO",
    icon: "\u{1F6F8}",
    status: "active",
    tags: ["seo", "audit", "optimization"],
  },

  // --- Developer Services ---
  {
    slug: "code-server",
    name: "Code-server",
    domain: "code.noizu.com",
    description: "VS Code in the browser",
    group: "Developer Services",
    icon: "\u{1F4BB}",
    status: "active",
    tags: ["ide", "vscode", "editor", "remote"],
  },
  {
    slug: "livecodes",
    name: "LiveCodes",
    domain: "livecodes.noizu.com",
    description: "Online code playground and IDE",
    group: "Developer Services",
    icon: "\u{26A1}",
    status: "active",
    tags: ["playground", "ide", "sandbox", "code"],
  },
  {
    slug: "registry",
    name: "Docker Registry",
    domain: "ops.noizu.com",
    description: "Private container registry",
    group: "Developer Services",
    icon: "\u{1F433}",
    status: "active",
    tags: ["docker", "containers", "registry"],
  },
  {
    slug: "hakatime",
    name: "HakaTime",
    domain: "hakatime.noizu.com",
    description: "WakaTime-compatible time tracking",
    group: "Developer Services",
    icon: "\u{23F1}\u{FE0F}",
    status: "active",
    tags: ["time-tracking", "wakatime", "coding"],
  },
  {
    slug: "directus",
    name: "Directus",
    domain: "directus.noizu.com",
    description: "Headless CMS and data platform",
    group: "Developer Services",
    icon: "\u{1F5C2}\u{FE0F}",
    status: "coming-soon",
    tags: ["cms", "headless", "api", "data"],
  },

  // --- Operations ---
  {
    slug: "erpnext",
    name: "ERPNext",
    domain: "erpnext.noizu.com",
    description: "Enterprise resource planning",
    group: "Operations",
    icon: "\u{1F4BC}",
    status: "maintenance",
    tags: ["erp", "accounting", "inventory", "hr"],
  },

  // --- Communications ---
  {
    slug: "mailu-webmail",
    name: "Webmail",
    domain: "webmail.therobotlives.com",
    description: "Roundcube webmail for therobotlives.com",
    group: "Communications",
    icon: "\u{1F4E7}",
    status: "active",
    tags: ["email", "webmail", "roundcube", "mail"],
  },
  {
    slug: "mailu-admin",
    name: "Mail Admin",
    domain: "mail-admin.therobotlives.com",
    description: "Mailu admin interface for therobotlives.com",
    group: "Communications",
    icon: "\u{1F4EC}",
    status: "active",
    tags: ["email", "admin", "mailu", "mail-server"],
  },

  // --- Infrastructure ---
  {
    slug: "argocd",
    name: "ArgoCD",
    domain: "argocd.noizu.com",
    description: "GitOps continuous delivery for Kubernetes",
    group: "Infrastructure",
    icon: "\u{1F419}",
    status: "active",
    tags: ["gitops", "cd", "kubernetes", "deployment"],
  },
  {
    slug: "infisical",
    name: "Infisical",
    domain: "infisical.noizu.com",
    description: "Secrets management platform",
    group: "Infrastructure",
    icon: "\u{1F510}",
    status: "active",
    tags: ["secrets", "vault", "env"],
  },
  {
    slug: "headlamp",
    name: "Headlamp",
    domain: "headlamp.noizu.com",
    description: "Kubernetes dashboard",
    group: "Infrastructure",
    icon: "\u{2388}",
    status: "active",
    tags: ["kubernetes", "dashboard", "k8s"],
  },
  {
    slug: "cockpit",
    name: "Cockpit",
    domain: "cockpit.noizu.com",
    description: "Server management UI",
    group: "Infrastructure",
    icon: "\u{1F39B}\u{FE0F}",
    status: "active",
    tags: ["server", "management", "linux"],
  },
  {
    slug: "minio",
    name: "MinIO",
    domain: "minio-design.noizu.com",
    description: "Object storage console for design assets",
    group: "Infrastructure",
    icon: "\u{1FAA3}",
    status: "internal",
    tags: ["storage", "s3", "objects"],
  },
  {
    slug: "rabbitmq",
    name: "RabbitMQ",
    domain: "rabbitmq-design.noizu.com",
    description: "Message broker management",
    group: "Infrastructure",
    icon: "\u{1F430}",
    status: "disabled",
    tags: ["messaging", "queue", "amqp"],
  },

  // --- Published Sites ---
  {
    slug: "noizu",
    name: "Noizu",
    domain: "noizu.com",
    description: "Company website",
    group: "Published Sites",
    icon: "\u{1F3E2}",
    status: "active",
    tags: ["website", "company", "public"],
  },
  // NOTE: Echelon (echelon.noizu.com) is intentionally excluded from the portal — do not re-add.
];

export function getServiceBySlug(slug: string): Service | undefined {
  return services.find((s) => s.slug === slug);
}

export function getGroupedServices(): ServiceGroup[] {
  return GROUP_ORDER.map((groupName) => ({
    name: groupName,
    icon: GROUP_ICONS[groupName] || "",
    services: services.filter((s) => s.group === groupName),
  }));
}

export function searchServices(query: string): Service[] {
  const q = query.toLowerCase().trim();
  if (!q) return services;
  return services.filter(
    (s) =>
      s.name.toLowerCase().includes(q) ||
      s.description.toLowerCase().includes(q) ||
      s.group.toLowerCase().includes(q) ||
      s.tags.some((t) => t.includes(q)) ||
      s.domain.toLowerCase().includes(q)
  );
}
