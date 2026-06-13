"use client";

import { useEffect, useState } from "react";
import { useParams } from "next/navigation";

import { api } from "@/lib/api/client";
import { Card } from "@/components/primitives/Card";
import { DetailHeader } from "@/components/composites/DetailHeader";
import { Badge } from "@/components/primitives/Badge";

type DocSlug = "schema" | "arch" | "layout" | "status";

const SLUG_TITLES: Record<DocSlug, string> = {
  schema: "Database Schema Documentation",
  arch: "Architecture Documentation",
  layout: "Project Layout Documentation",
  status: "Project Status",
};

function isValidSlug(s: string): s is DocSlug {
  return s === "schema" || s === "arch" || s === "layout" || s === "status";
}

export function DocViewerClient() {
  const params = useParams();
  const slug = Array.isArray(params.slug) ? params.slug[0] : (params.slug ?? "");

  const [content, setContent] = useState<string | null>(null);
  const [path, setPath] = useState<string>("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!isValidSlug(slug)) {
      setError(`Unknown doc: ${slug}`);
      setLoading(false);
      return;
    }
    setLoading(true);
    setError(null);
    api.docs
      .get(slug)
      .then((doc) => {
        setContent(doc.content);
        setPath(doc.path);
      })
      .catch((err) => setError(err instanceof Error ? err.message : "Failed to load doc"))
      .finally(() => setLoading(false));
  }, [slug]);

  const title = isValidSlug(slug) ? SLUG_TITLES[slug] : slug;

  return (
    <div className="space-y-6">
      <DetailHeader
        breadcrumbs={[
          { label: "Docs" },
          { label: title },
        ]}
        title={title}
        description={path ? `Source: ${path}` : undefined}
        actions={
          <Badge variant="info" size="sm">
            markdown
          </Badge>
        }
      />

      {error ? (
        <div role="alert" className="rounded-md bg-danger/10 px-4 py-3 text-sm text-danger">
          {error}
        </div>
      ) : loading ? (
        <div className="py-16 text-center text-sm text-muted">Loading documentation…</div>
      ) : content !== null ? (
        <Card>
          <pre className="whitespace-pre-wrap font-sans text-sm leading-relaxed text-foreground">
            {content}
          </pre>
        </Card>
      ) : null}
    </div>
  );
}
