export function JsonLd({ data }: { data: Record<string, unknown> }) {
  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }}
    />
  );
}

export const personSchema = {
  "@context": "https://schema.org",
  "@type": "Person",
  name: "Keith Brings",
  jobTitle: "Fractional CTO & Principal Engineer",
  url: "https://noizu.com",
  sameAs: [
    "https://github.com/noizu-labs",
    "https://github.com/noizu-labs-ml",
    "https://github.com/noizu-labs-scaffolding",
  ],
  knowsAbout: [
    "Elixir",
    "AI/ML",
    "Embedded Systems",
    "Distributed Architecture",
    "Kubernetes",
    "Infrastructure",
  ],
};

export const websiteSchema = {
  "@context": "https://schema.org",
  "@type": "WebSite",
  name: "Noizu Labs",
  url: "https://noizu.com",
  description:
    "Leadership in performance and scale. Fractional CTO, principal engineering, and strategic technology consulting.",
  author: {
    "@type": "Person",
    name: "Keith Brings",
  },
};
