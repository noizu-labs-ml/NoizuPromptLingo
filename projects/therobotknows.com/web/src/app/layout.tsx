import type { Metadata } from "next";
import { Lora, Source_Serif_4, Inter, JetBrains_Mono } from "next/font/google";
import "./globals.css";

const lora = Lora({
  variable: "--font-lora",
  subsets: ["latin"],
  weight: ["400", "600", "700"],
  style: ["normal", "italic"],
});

const sourceSerif = Source_Serif_4({
  variable: "--font-source-serif",
  subsets: ["latin"],
  weight: ["400", "600", "700"],
  style: ["normal", "italic"],
});

const inter = Inter({
  variable: "--font-inter",
  subsets: ["latin"],
  weight: ["400", "500", "600"],
});

const jetbrainsMono = JetBrains_Mono({
  variable: "--font-jetbrains",
  subsets: ["latin"],
  weight: ["400", "500"],
});

export const metadata: Metadata = {
  title: "Knowledge Base — AI-Powered Structured Writing",
  description:
    "A living wiki that writes itself. Build consistent, cross-referenced knowledge bases for fiction, non-fiction, and technical documentation.",
  openGraph: {
    title: "Knowledge Base — AI-Powered Structured Writing",
    description:
      "Build consistent, cross-referenced knowledge bases for fiction, non-fiction, and technical documentation.",
    siteName: "kb.therobotlives.com",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <head>
        <link rel="icon" href="/favicon.svg" type="image/svg+xml" />
      </head>
      <body
        className={`${lora.variable} ${sourceSerif.variable} ${inter.variable} ${jetbrainsMono.variable} antialiased`}
      >
        {children}
      </body>
    </html>
  );
}
