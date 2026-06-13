import type { Metadata } from "next";
import "./globals.css";
import { loadConfig, listThemes } from "@styleguide-engine/config/loader";
import { loadAllBrandings } from "@styleguide-engine/config/branding-loader";
import { ensureGeneratedCSS } from "@styleguide-engine/lib/css-cache";
import { Toaster } from "sonner";
import { ThemeCSS } from "@styleguide-engine/components/ThemeCSS";

export function generateMetadata(): Metadata {
  const config = loadConfig();
  return {
    title: config.title,
    description: config.description,
  };
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  ensureGeneratedCSS();
  const config = loadConfig();
  const themes = listThemes();
  const themeSlugs = themes.map((t) => t.slug);
  const allBrandings = loadAllBrandings();
  const fontUrls = [...new Set(Object.values(allBrandings).map((b) => b["font-url"]).filter(Boolean))] as string[];
  const t = config.toast;
  return (
    <html lang="en" data-design-theme={config.slug} suppressHydrationWarning>
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="" />
        {fontUrls.map((url) => (
          <link key={url} href={url} rel="stylesheet" />
        ))}
        <script dangerouslySetInnerHTML={{ __html: `(function(){var s=localStorage.getItem('color-mode');var p=matchMedia('(prefers-color-scheme:dark)').matches;if(s==='dark'||(!s&&p))document.documentElement.classList.add('dark');var v=${JSON.stringify(themeSlugs)};var t=localStorage.getItem('sg-theme');if(t&&v.indexOf(t)!==-1)document.documentElement.setAttribute('data-design-theme',t);else if(t)localStorage.removeItem('sg-theme')})()` }} />
      </head>
      <body>
        <ThemeCSS themeSlugs={themeSlugs} defaultTheme={config.slug} />
        {children}
        <Toaster
          position={t.position ?? "top-right"}
          expand={t.expand ?? true}
          gap={t.gap ?? 16}
          duration={t.duration ?? 8000}
          visibleToasts={t["visible-toasts"] ?? 4}
          toastOptions={{ unstyled: true, classNames: { toast: "toast", success: "success", error: "error", warning: "warning", info: "info" } }}
        />
      </body>
    </html>
  );
}
