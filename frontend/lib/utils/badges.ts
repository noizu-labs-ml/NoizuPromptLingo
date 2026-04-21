/**
 * Map an artifact kind string to a Badge variant.
 */
export function kindVariant(
  kind: string
): "default" | "success" | "warning" | "danger" | "info" {
  switch (kind) {
    case "markdown": return "info";
    case "json": return "warning";
    case "yaml": return "success";
    case "code": return "danger";
    default: return "default";
  }
}
