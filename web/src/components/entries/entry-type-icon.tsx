import {
  User,
  MapPin,
  Swords,
  Landmark,
  Gem,
  Lightbulb,
  ScrollText,
  type LucideProps,
} from "lucide-react";
import { cn } from "@/lib/cn";
import type { EntryType } from "@/lib/constants";

interface EntryTypeIconProps {
  type: EntryType;
  size?: number;
  className?: string;
}

const iconMap: Record<EntryType, React.ComponentType<LucideProps>> = {
  character: User,
  location: MapPin,
  event: Swords,
  faction: Landmark,
  object: Gem,
  concept: Lightbulb,
  rule: ScrollText,
};

// Subtle type-specific colors drawn from the design token vocabulary.
// character → accent (saddle brown), location → success (forest green),
// event → flag-warn (goldenrod), faction → link (scholarly blue),
// object → ink-secondary (warm gray), concept → link-visited (#5B4A8A),
// rule → ink (near-black)
const colorMap: Record<EntryType, string> = {
  character: "text-accent",
  location: "text-success",
  event: "text-flag-warn",
  faction: "text-link",
  object: "text-ink-secondary",
  concept: "text-[#5B4A8A]",
  rule: "text-ink",
};

export function EntryTypeIcon({ type, size = 18, className }: EntryTypeIconProps) {
  const Icon = iconMap[type];
  return (
    <Icon
      size={size}
      strokeWidth={1.5}
      className={cn(colorMap[type], className)}
    />
  );
}
