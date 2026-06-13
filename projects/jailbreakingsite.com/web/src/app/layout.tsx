import type { Metadata } from "next";
import { Inter, JetBrains_Mono } from "next/font/google";
import "./globals.css";

const inter = Inter({
  variable: "--font-inter",
  subsets: ["latin"],
  weight: ["400", "500", "600"],
});

const jetbrainsMono = JetBrains_Mono({
  variable: "--font-jetbrains-mono",
  subsets: ["latin"],
  weight: ["400", "600", "700"],
});

export const metadata: Metadata = {
  title: "JailbreakingSite — Know Every Attack. Defend Every Endpoint.",
  description:
    "The structured attack catalog, defensive testing suite, and hands-on training labs for LLM security professionals. MITRE ATT&CK meets HackTheBox for jailbreaking.",
  openGraph: {
    title: "JailbreakingSite — Know Every Attack. Defend Every Endpoint.",
    description:
      "412 classified LLM jailbreak techniques. Defensive scanning. Hands-on training labs. The security resource LLM teams actually need.",
    siteName: "jailbreakingsite.com",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "JailbreakingSite — Know Every Attack. Defend Every Endpoint.",
    description:
      "412 classified LLM jailbreak techniques. Defensive scanning. Hands-on training labs.",
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
        className={`${inter.variable} ${jetbrainsMono.variable} antialiased`}
      >
        {children}
      </body>
    </html>
  );
}
