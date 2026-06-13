"use client";

import { useState } from "react";
import { Select } from "@/components/ui/select";
import { SearchInput } from "@/components/ui/search-input";
import { ENTRY_TYPES, ENTRY_TYPE_LABELS, type EntryType } from "@/lib/constants";

// These would be derived from the actual universe data in production
const ERAS = [
  "First Age",
  "Second Age",
  "Third Age",
  "Fourth Age",
  "Age of Silence",
];

const REGIONS = [
  "Northern Reach",
  "Thornwall",
  "Coastal Federation",
  "The Ashward Highlands",
  "Ironmere Valley",
  "The Sunken Isles",
];

export interface EntryFiltersState {
  type: EntryType | "all";
  era: string;
  region: string;
  search: string;
}

interface EntryFiltersProps {
  onChange?: (filters: EntryFiltersState) => void;
}

export function EntryFilters({ onChange }: EntryFiltersProps) {
  const [filters, setFilters] = useState<EntryFiltersState>({
    type: "all",
    era: "",
    region: "",
    search: "",
  });

  function update(patch: Partial<EntryFiltersState>) {
    const next = { ...filters, ...patch };
    setFilters(next);
    onChange?.(next);
  }

  return (
    <div className="flex flex-col sm:flex-row gap-3">
      {/* Type dropdown */}
      <Select
        value={filters.type}
        onChange={(e) =>
          update({ type: e.target.value as EntryType | "all" })
        }
        className="sm:w-40 text-[14px] py-2"
        aria-label="Filter by type"
      >
        <option value="all">All Types</option>
        {ENTRY_TYPES.map((t) => (
          <option key={t} value={t}>
            {ENTRY_TYPE_LABELS[t]}
          </option>
        ))}
      </Select>

      {/* Era dropdown */}
      <Select
        value={filters.era}
        onChange={(e) => update({ era: e.target.value })}
        className="sm:w-44 text-[14px] py-2"
        aria-label="Filter by era"
      >
        <option value="">All Eras</option>
        {ERAS.map((era) => (
          <option key={era} value={era}>
            {era}
          </option>
        ))}
      </Select>

      {/* Region dropdown */}
      <Select
        value={filters.region}
        onChange={(e) => update({ region: e.target.value })}
        className="sm:w-52 text-[14px] py-2"
        aria-label="Filter by region"
      >
        <option value="">All Regions</option>
        {REGIONS.map((region) => (
          <option key={region} value={region}>
            {region}
          </option>
        ))}
      </Select>

      {/* Search */}
      <div className="flex-1 min-w-0">
        <SearchInput
          value={filters.search}
          onChange={(e) => update({ search: e.target.value })}
          placeholder="Search entries…"
          aria-label="Search entries"
        />
      </div>
    </div>
  );
}
