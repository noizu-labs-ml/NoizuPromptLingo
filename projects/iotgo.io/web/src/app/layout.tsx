import type { Metadata } from "next";
import { Space_Mono, Space_Grotesk } from "next/font/google";
import "./globals.css";

const spaceMono = Space_Mono({
  variable: "--font-space-mono",
  subsets: ["latin"],
  weight: ["400", "700"],
});

const spaceGrotesk = Space_Grotesk({
  variable: "--font-space-grotesk",
  subsets: ["latin"],
  weight: ["400", "700"],
});

export const metadata: Metadata = {
  title: "IoTGo — Autonomous AI Agents for IoT Fleet Management",
  description:
    "Deploy AI agents that monitor telemetry, detect anomalies, and execute remediation playbooks. The detect-act loop, closed.",
  icons: {
    icon: "/favicon.svg",
  },
  openGraph: {
    title: "IoTGo — Autonomous AI Agents for IoT Fleet Management",
    description:
      "Deploy AI agents that monitor telemetry, detect anomalies, and execute remediation playbooks.",
    siteName: "iotgo.io",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "IoTGo — Autonomous AI Agents for IoT Fleet Management",
    description:
      "Deploy AI agents that monitor telemetry, detect anomalies, and execute remediation playbooks.",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${spaceMono.variable} ${spaceGrotesk.variable} antialiased`}
      >
        {children}
      </body>
    </html>
  );
}
