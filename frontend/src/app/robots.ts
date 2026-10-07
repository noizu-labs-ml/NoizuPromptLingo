import type { MetadataRoute } from "next";

export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: "*",
      allow: "/",
      disallow: ["/app/", "/login", "/api/"],
    },
    sitemap: "https://promptlingo.dev/site.xml",
    host: "https://promptlingo.dev",
  };
}
