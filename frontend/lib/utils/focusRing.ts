/**
 * Canonical focus-ring className for every interactive primitive.
 *
 * Mirrors the `focus-ring` CSS utility defined in `app/globals.css`; this
 * string form exists so it can be composed with `clsx(...)` alongside other
 * classes without relying on CSS utility layering order.
 *
 *   import { focusRing } from "@/lib/utils/focusRing";
 *   <button className={clsx("btn", focusRing)}>Go</button>
 */
export const focusRing =
  "outline-none focus-visible:shadow-ring focus-visible:border-accent transition-shadow";
