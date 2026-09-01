import type { Metadata, Viewport } from "next";
import "./globals.css";
import { AuthProvider } from "@/context/auth";
import { OrgProvider } from "@/context/org";
import { StarredProjectsProvider } from "@/context/starred";
import { SidebarProvider } from "@/context/sidebar";
import { Navbar } from "@/components/navbar";
import { AnalyticsProvider } from "@/components/analytics-provider";
import { CookieConsentProvider } from "@/components/cookie-consent";
import { OtelProvider } from "@/components/otel-provider";
import { loadConfig, loadAllBrandings } from "@noizu/styleguide/css-gen";
import { Toaster } from "sonner";

export function generateMetadata(): Metadata {
  // Product document title — do not use style-guide.meta.yaml `title`
  // (that field is for the styleguide page, e.g. "Style Guide — Base Theme").
  return {
    title: {
      default: "NoizuPromptLingo",
      template: "NoizuPromptLingo - %s",
    },
    description:
      "Tobor Locker — MCP-native work infrastructure for AI agents. Durable artifacts, tickets, sessions, wiki, chat, review, and memory for Claude Code, Codex, and any MCP client.",
    icons: {
      icon: [{ url: "/favicon.svg", type: "image/svg+xml" }],
      shortcut: [{ url: "/favicon.svg", type: "image/svg+xml" }],
    },
  };
}

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  const config = loadConfig();
  const allBrandings = loadAllBrandings();
  const fontUrls = [
    ...new Set(
      Object.values(allBrandings)
        .map((b) => b["font-url"])
        .filter(Boolean)
    ),
  ] as string[];
  const t = config.toast;

  return (
    <html lang="en" data-design-theme={config.slug} suppressHydrationWarning>
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="" />
        {fontUrls.map((url) => (
          <link key={url} href={url} rel="stylesheet" />
        ))}
        <script src="/__env.js" />
        <script
          dangerouslySetInnerHTML={{
            __html: `(function(){try{var saved=localStorage.getItem('color-mode');var mode=saved==='light'||saved==='dark'?saved:'dark';document.documentElement.classList.toggle('dark',mode==='dark');document.documentElement.style.colorScheme=mode}catch(_){document.documentElement.classList.add('dark')}})()`,
          }}
        />
      </head>
      <body>
        <OtelProvider>
          <AuthProvider>
            <OrgProvider>
              <StarredProjectsProvider>
              <CookieConsentProvider>
                <AnalyticsProvider>
                  <SidebarProvider>
                    <Navbar />
                    {children}
                  </SidebarProvider>
                </AnalyticsProvider>
              </CookieConsentProvider>
              </StarredProjectsProvider>
            </OrgProvider>
          </AuthProvider>
        </OtelProvider>
        <Toaster
          position={t?.position ?? "top-right"}
          expand={t?.expand ?? true}
          gap={t?.gap ?? 16}
          duration={t?.duration ?? 8000}
          visibleToasts={t?.["visible-toasts"] ?? 4}
          toastOptions={{
            unstyled: true,
            classNames: {
              toast: "toast",
              success: "success",
              error: "error",
              warning: "warning",
              info: "info",
            },
          }}
        />
      </body>
    </html>
  );
}
