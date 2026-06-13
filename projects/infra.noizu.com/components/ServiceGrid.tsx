"use client";

import { GROUP_ICONS, type ServiceGroup } from "@/lib/services";
import { ServiceCard } from "./ServiceCard";

interface ServiceGridProps {
  groups: ServiceGroup[];
}

export function ServiceGrid({ groups }: ServiceGridProps) {
  return (
    <div className="space-y-8">
      {groups.map((group) => (
        <section key={group.name}>
          <h2 className="text-sm font-semibold text-muted uppercase tracking-wider mb-3 flex items-center gap-2">
            <span>{GROUP_ICONS[group.name]}</span>
            {group.name}
            <span className="text-xs font-normal text-muted/60">
              ({group.services.length})
            </span>
          </h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
            {group.services.map((service) => (
              <ServiceCard key={service.slug} service={service} />
            ))}
          </div>
        </section>
      ))}
    </div>
  );
}
