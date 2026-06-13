import type { Metadata } from "next";
import { Plus_Jakarta_Sans, JetBrains_Mono } from "next/font/google";
import "./globals.css";
import { AuthProvider } from "@/context/auth";
import { Navbar } from "@/components/navbar";
import { Toaster } from "sonner";
import { CommandPaletteProvider } from "@/components/ui/CommandPaletteProvider";

const jakartaSans = Plus_Jakarta_Sans({
  variable: "--font-jakarta",
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
});

const jetbrainsMono = JetBrains_Mono({
  variable: "--font-jetbrains",
  subsets: ["latin"],
  weight: ["400", "500", "600"],
});

export const metadata: Metadata = {
  title: "CodeFresh — Behavioral Testing for AI Agents",
  description:
    "Script conversations. Run evaluations. Catch agent regressions before your users do. The testing framework AI engineers actually need.",
  openGraph: {
    title: "CodeFresh — Behavioral Testing for AI Agents",
    description:
      "Script conversations. Run evaluations. Catch agent regressions before your users do.",
    siteName: "codefre.sh",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "CodeFresh — Behavioral Testing for AI Agents",
    description:
      "Script conversations. Run evaluations. Catch agent regressions before your users do.",
  },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className="dark" suppressHydrationWarning>
      <body className={`${jakartaSans.variable} ${jetbrainsMono.variable} antialiased`}>
        <AuthProvider>
          <CommandPaletteProvider>
            <Navbar />
            {children}
          </CommandPaletteProvider>
        </AuthProvider>
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
