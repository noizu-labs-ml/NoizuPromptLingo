"use client";

import { useState, useMemo } from "react";
import { getGroupedServices, searchServices, GROUP_ORDER } from "@/lib/services";
import { SearchBar } from "@/components/SearchBar";
import { GroupFilter } from "@/components/GroupFilter";
import { ServiceGrid } from "@/components/ServiceGrid";

export default function Dashboard() {
  const [query, setQuery] = useState("");
  const [activeGroup, setActiveGroup] = useState<string | null>(null);

  const filtered = useMemo(() => {
    let results = searchServices(query);
    if (activeGroup) {
      results = results.filter((s) => s.group === activeGroup);
    }
    return results;
  }, [query, activeGroup]);

  const groups = useMemo(() => {
    return GROUP_ORDER.map((groupName) => ({
      name: groupName,
      icon: "",
      services: filtered.filter((s) => s.group === groupName),
    })).filter((g) => g.services.length > 0);
  }, [filtered]);

  const allGroups = getGroupedServices();

  return (
    <div className="min-h-screen">
      <header className="border-b border-surface-3 bg-surface-1/80 backdrop-blur-sm sticky top-0 z-10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 py-4">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 rounded-lg bg-accent flex items-center justify-center text-white font-bold text-sm">
                N
              </div>
              <h1 className="text-xl font-semibold text-gray-100">
                Noizu Infrastructure
              </h1>
            </div>
            <span className="text-xs text-muted">
              {filtered.length} service{filtered.length !== 1 ? "s" : ""}
            </span>
          </div>
          <SearchBar value={query} onChange={setQuery} />
          <GroupFilter
            groups={allGroups.map((g) => g.name)}
            active={activeGroup}
            onSelect={setActiveGroup}
          />
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 py-6">
        {groups.length === 0 ? (
          <div className="text-center py-20 text-muted">
            <p className="text-lg">No services match your search.</p>
            <button
              onClick={() => {
                setQuery("");
                setActiveGroup(null);
              }}
              className="mt-3 text-accent hover:text-accent-hover text-sm"
            >
              Clear filters
            </button>
          </div>
        ) : (
          <ServiceGrid groups={groups} />
        )}
      </main>
    </div>
  );
}
