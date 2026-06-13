/**
 * Tool detail page — server wrapper for static export.
 *
 * generateStaticParams pre-renders a route for every tool in the catalog.
 * The actual rendering is handled by ToolDetailClient which reads the tool
 * name from the URL at runtime via useParams (client-side dynamic).
 */

import catalogSnapshot from "@/lib/api/mock/catalog.json";
import { ToolDetailClient } from "./ToolDetailClient";

interface CatalogEntry {
  name: string;
}

interface CatalogSnapshot {
  catalog: CatalogEntry[];
}

export function generateStaticParams(): { name: string }[] {
  const { catalog } = catalogSnapshot as CatalogSnapshot;
  return catalog.map((tool) => ({ name: encodeURIComponent(tool.name) }));
}

export default function ToolDetailPage() {
  return <ToolDetailClient />;
}
