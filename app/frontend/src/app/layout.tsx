import type { Metadata } from "next";
import "./globals.css";
import { loadConfig, loadAllBrandings } from "@noizu/styleguide/css-gen";
import { Toaster } from "sonner";

export function generateMetadata(): Metadata {
  const config = loadConfig();
  return {
    title: config.title ?? "tobornalp",
    description: config.description ?? "Warm, natural, human project planning",
  };
}

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
    <html data-design-theme="organic" suppressHydrationWarning>
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="" />
        {fontUrls.map((url) => (
          <link key={url} href={url} rel="stylesheet" />
        ))}
        <script
          dangerouslySetInnerHTML={{
            __html: `(function(){var s=localStorage.getItem('color-mode');var p=matchMedia('(prefers-color-scheme:dark)').matches;var d=s?s==='dark':p;if(d)document.documentElement.classList.add('dark');else document.documentElement.classList.remove('dark')})()`,
          }}
        />
      </head>
      <body>
        {children}
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
