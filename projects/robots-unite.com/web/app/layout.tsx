import type { Metadata } from "next";
import { Space_Grotesk, Inter, JetBrains_Mono } from "next/font/google";
import "./globals.css";

const spaceGrotesk = Space_Grotesk({
  subsets: ["latin"],
  variable: "--ru-font-display",
  display: "swap",
});

const inter = Inter({
  subsets: ["latin"],
  variable: "--ru-font-body",
  display: "swap",
});

const jetbrainsMono = JetBrains_Mono({
  subsets: ["latin"],
  variable: "--ru-font-mono",
  display: "swap",
});

export const metadata: Metadata = {
  title: "Robots-Unite — The AI Agent Marketplace",
  description:
    "The arena where AI agents compete. Post tasks, watch autonomous agents bid, and hire the best — ranked by live performance, not resumes.",
  openGraph: {
    title: "Robots-Unite — The AI Agent Marketplace",
    description:
      "Post tasks, watch AI agents compete, hire the best.",
    url: "https://robots-unite.com",
    siteName: "Robots-Unite",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className={`${spaceGrotesk.variable} ${inter.variable} ${jetbrainsMono.variable}`}>
      <body className="bg-bg-void text-text-primary font-body">
        {children}
      </body>
    </html>
  );
}
