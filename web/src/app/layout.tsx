import type { Metadata } from "next";
import { Plus_Jakarta_Sans, JetBrains_Mono } from "next/font/google";
import "./globals.css";

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

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark">
      <body
        className={`${jakartaSans.variable} ${jetbrainsMono.variable} antialiased`}
      >
        {children}
      </body>
    </html>
  );
}
