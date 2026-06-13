import type { Metadata } from "next";
import { Inter, JetBrains_Mono } from "next/font/google";
import "./globals.css";
import { Navbar } from "@/components/Navbar";
import { Footer } from "@/components/Footer";
import { JsonLd, personSchema, websiteSchema } from "@/components/JsonLd";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
});

const jetbrains = JetBrains_Mono({
  subsets: ["latin"],
  variable: "--font-jetbrains",
});

export const metadata: Metadata = {
  metadataBase: new URL("https://noizu.com"),
  title: {
    default: "Noizu Labs - Keith Brings | Fractional CTO & Principal Engineer",
    template: "%s | Noizu Labs",
  },
  description:
    "Fractional CTO and principal engineer specializing in Elixir, AI/ML systems, embedded C, and distributed infrastructure. 30+ open-source projects, research on AI rights and cognitive architecture.",
  authors: [{ name: "Keith Brings", url: "https://noizu.com" }],
  creator: "Keith Brings",
  manifest: "/manifest.json",
  icons: {
    icon: "/icon.svg",
    apple: "/apple-icon.svg",
  },
  openGraph: {
    type: "website",
    locale: "en_US",
    url: "https://noizu.com",
    siteName: "Noizu Labs",
    title: "Noizu Labs - Keith Brings | Fractional CTO & Principal Engineer",
    description:
      "Fractional CTO and principal engineer: Elixir, AI/ML, embedded systems, distributed infrastructure. Open-source projects, AI rights research, and strategic technology consulting.",
    images: [{ url: "/images/screen-overlay-fiber-optics.png", width: 1200, height: 630, alt: "Noizu Labs" }],
  },
  twitter: {
    card: "summary_large_image",
    title: "Noizu Labs - Keith Brings | Fractional CTO & Principal Engineer",
    description:
      "Fractional CTO and principal engineer: Elixir, AI/ML, embedded systems, distributed infrastructure. Open-source projects and AI rights research.",
    images: ["/images/screen-overlay-fiber-optics.png"],
  },
  robots: {
    index: true,
    follow: true,
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className={`${inter.variable} ${jetbrains.variable}`}>
      <body className="font-sans">
        <JsonLd data={personSchema} />
        <JsonLd data={websiteSchema} />
        <Navbar />
        <main className="min-h-screen">{children}</main>
        <Footer />
      </body>
    </html>
  );
}
