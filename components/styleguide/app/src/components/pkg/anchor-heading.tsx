"use client";

import { useCallback } from "react";
import { slugify } from "@styleguide-engine/lib/section-cookie";
import { useSectionId } from "@styleguide-engine/lib/section-context";
import { toast } from "sonner";

interface Props {
  tag?: "h2" | "h3" | "div";
  className?: string;
  children: React.ReactNode;
}

export function AnchorHeading({ tag: Tag = "h3", className, children }: Props) {
  const parentId = useSectionId();
  const text = typeof children === "string" ? children : "";
  const childSlug = slugify(text);
  const id = parentId ? `${parentId}-${childSlug}` : childSlug;

  const handleClick = useCallback(() => {
    const url = `${window.location.origin}${window.location.pathname}#${id}`;
    window.history.replaceState(null, "", `#${id}`);
    navigator.clipboard.writeText(url);
    toast.info(`URL set to anchor #${id}`);
  }, [id]);

  return (
    <Tag id={id} className={`sg-anchor-heading ${className || ""}`} onClick={handleClick}>
      <span>{children}</span>
      <span className="sg-anchor-heading-icon text-primary" aria-hidden="true">#</span>
    </Tag>
  );
}
