"use client";

import { GROUP_ICONS } from "@/lib/services";

interface GroupFilterProps {
  groups: string[];
  active: string | null;
  onSelect: (group: string | null) => void;
}

export function GroupFilter({ groups, active, onSelect }: GroupFilterProps) {
  return (
    <div className="flex flex-wrap gap-2 mt-3">
      <button
        onClick={() => onSelect(null)}
        className={`px-3 py-1.5 rounded-full text-xs font-medium transition-colors ${
          active === null
            ? "bg-accent text-white"
            : "bg-surface-2 text-muted hover:text-gray-300 hover:bg-surface-3"
        }`}
      >
        All
      </button>
      {groups.map((group) => (
        <button
          key={group}
          onClick={() => onSelect(active === group ? null : group)}
          className={`px-3 py-1.5 rounded-full text-xs font-medium transition-colors ${
            active === group
              ? "bg-accent text-white"
              : "bg-surface-2 text-muted hover:text-gray-300 hover:bg-surface-3"
          }`}
        >
          {GROUP_ICONS[group]} {group}
        </button>
      ))}
    </div>
  );
}
