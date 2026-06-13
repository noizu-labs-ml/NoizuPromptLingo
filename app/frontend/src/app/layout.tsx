import type { Metadata } from "next";
import "./globals.css";
import { Toaster } from "sonner";

export const metadata: Metadata = {
  title: "MCP Host — Style Guide",
  description: "Design system preview for the MCP Host platform.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className="dark" suppressHydrationWarning>
      <body className="antialiased">
        {children}
        <Toaster
          position="top-right"
          theme="dark"
          expand={true}
          gap={16}
          duration={8000}
          visibleToasts={4}
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
