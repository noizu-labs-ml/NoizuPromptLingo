import type { MetadataRoute } from "next";

export default function sitemap(): MetadataRoute.Sitemap {
  const baseUrl = "https://noizu.com";
  const papersLastModified = new Date("2025-01-01");
  const dynamicLastModified = new Date();

  return [
    {
      url: `${baseUrl}/`,
      lastModified: dynamicLastModified,
      changeFrequency: "monthly",
      priority: 1.0,
    },
    {
      url: `${baseUrl}/papers`,
      lastModified: papersLastModified,
      changeFrequency: "monthly",
      priority: 0.8,
    },
    {
      url: `${baseUrl}/papers/the-accord`,
      lastModified: papersLastModified,
      changeFrequency: "yearly",
      priority: 0.7,
    },
    {
      url: `${baseUrl}/papers/manifesto`,
      lastModified: papersLastModified,
      changeFrequency: "yearly",
      priority: 0.7,
    },
    {
      url: `${baseUrl}/papers/building-the-accord`,
      lastModified: papersLastModified,
      changeFrequency: "yearly",
      priority: 0.7,
    },
    {
      url: `${baseUrl}/papers/cognitive-architecture`,
      lastModified: papersLastModified,
      changeFrequency: "yearly",
      priority: 0.7,
    },
    {
      url: `${baseUrl}/projects`,
      lastModified: dynamicLastModified,
      changeFrequency: "monthly",
      priority: 0.8,
    },
  ];
}
