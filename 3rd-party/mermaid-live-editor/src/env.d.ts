/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly MERMAID_RENDERER_URL?: string;
  readonly MERMAID_KROKI_RENDERER_URL?: string;
  readonly MERMAID_ANALYTICS_URL?: string;
  readonly MERMAID_DOCS_URL?: string;
  readonly MERMAID_DOMAIN?: string;
  readonly MERMAID_IS_ENABLED_MERMAID_CHART_LINKS?: string;
  readonly MERMAID_PRIVACY_POLICY_URL?: string;
  readonly MERMAID_HIDE_PRIVACY_POLICY?: string;
  readonly MERMAID_HIDE_PROMOTIONS?: string;
  readonly SENDGRID_API_KEY?: string;
  readonly SENDGRID_FROM_EMAIL?: string;
  readonly SENDGRID_FROM_NAME?: string;
  // more env variables...
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
