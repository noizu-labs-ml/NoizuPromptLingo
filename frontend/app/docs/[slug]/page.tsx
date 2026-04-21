import { DocViewerClient } from "./DocViewerClient";

export function generateStaticParams() {
  return [
    { slug: "schema" },
    { slug: "arch" },
    { slug: "layout" },
  ];
}

export default function DocPage() {
  return <DocViewerClient />;
}
