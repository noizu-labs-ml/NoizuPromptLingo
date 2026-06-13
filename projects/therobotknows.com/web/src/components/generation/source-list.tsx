import * as React from "react";
import {
  User,
  MapPin,
  Swords,
  Landmark,
  Gem,
  Lightbulb,
  ScrollText,
} from "lucide-react";
import { cn } from "@/lib/cn";
import type { EntryType } from "@/lib/constants";

interface SourceEntry {
  id: string;
  type: EntryType;
  label: string;
  included: boolean;
  note?: string;
}

interface SourceListProps {
  sources: SourceEntry[];
  onToggle?: (id: string) => void;
  onEditSources?: () => void;
}

const TYPE_ICONS: Record<EntryType, React.ComponentType<{ size?: number; strokeWidth?: number; className?: string }>> = {
  character: User,
  location:  MapPin,
  event:     Swords,
  faction:   Landmark,
  object:    Gem,
  concept:   Lightbulb,
  rule:      ScrollText,
};

const TYPE_COLORS: Record<EntryType, string> = {
  character: "text-accent",
  location:  "text-success",
  event:     "text-flag-warn",
  faction:   "text-link",
  object:    "text-ink-secondary",
  concept:   "text-[#5B4A8A]",
  rule:      "text-ink",
};

export function SourceList({ sources, onToggle, onEditSources }: SourceListProps) {
  return (
    <div>
      <div className="flex items-center justify-between mb-2">
        <p className="font-mono text-[11px] font-semibold uppercase tracking-[0.06em] text-ink-tertiary">
          AI will reference
        </p>
        {onEditSources && (
          <button
            onClick={onEditSources}
            className="font-sans text-[12px] text-link hover:text-link-hover underline underline-offset-2 transition-colors duration-200"
          >
            Edit sources
          </button>
        )}
      </div>

      <div className="border border-rule rounded-md overflow-hidden bg-surface">
        {sources.map((source, index) => {
          const Icon = TYPE_ICONS[source.type];
          return (
            <label
              key={source.id}
              className={cn(
                "flex items-start gap-3 px-3 py-2.5 cursor-pointer",
                "hover:bg-elevated transition-colors duration-150",
                index < sources.length - 1 && "border-b border-rule-subtle",
                !source.included && "opacity-50"
              )}
            >
              {/* Checkbox */}
              <input
                type="checkbox"
                checked={source.included}
                onChange={() => onToggle?.(source.id)}
                className="mt-0.5 accent-[#8B4513] cursor-pointer"
              />

              {/* Icon */}
              <Icon
                size={14}
                strokeWidth={1.5}
                className={cn("mt-0.5 shrink-0", TYPE_COLORS[source.type])}
              />

              {/* Label + note */}
              <div className="min-w-0 flex-1">
                <span className="font-serif text-[13px] text-ink leading-snug">
                  {source.label}
                </span>
                {source.note && (
                  <p className="font-mono text-[10px] text-ink-tertiary mt-0.5 leading-snug">
                    {source.note}
                  </p>
                )}
              </div>

              {/* Status pip */}
              <span
                className={cn(
                  "font-mono text-[8px] mt-1 shrink-0",
                  source.included ? "text-canon" : "text-ink-tertiary"
                )}
              >
                {source.included ? "■" : "□"}
              </span>
            </label>
          );
        })}
      </div>
    </div>
  );
}
