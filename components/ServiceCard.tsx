"use client";

import Link from "next/link";
import type { Service, ServiceStatus } from "@/lib/services";

interface ServiceCardProps {
  service: Service;
}

const statusLabel: Record<ServiceStatus, string> = {
  active: "Active",
  disabled: "Disabled",
  internal: "Internal",
  pending: "Pending",
  "coming-soon": "Coming Soon",
  maintenance: "Maintenance",
};

const ribbonConfig: Partial<
  Record<ServiceStatus, { text: string; bg: string; border: string }>
> = {
  "coming-soon": {
    text: "Coming Soon",
    bg: "bg-cyan-500/90",
    border: "border-cyan-400/30",
  },
  pending: {
    text: "Coming Soon",
    bg: "bg-sky-500/90",
    border: "border-sky-400/30",
  },
  maintenance: {
    text: "Maintenance",
    bg: "bg-orange-500/90",
    border: "border-orange-400/30",
  },
};

export function ServiceCard({ service }: ServiceCardProps) {
  const isInactive =
    service.status === "coming-soon" ||
    service.status === "pending" ||
    service.status === "maintenance";
  const ribbon = ribbonConfig[service.status];

  return (
    <Link
      href={`/service/${service.slug}`}
      className={`group relative block glass-card rounded-xl p-4 overflow-hidden transition-all duration-200 ${
        isInactive
          ? "opacity-60 hover:opacity-80"
          : ""
      }`}
    >
      {ribbon && (
        <div
          className={`absolute top-0 right-0 ${ribbon.bg} text-white text-[9px] font-bold uppercase tracking-wider px-6 py-0.5 translate-x-[22px] translate-y-[8px] rotate-45 shadow-sm pointer-events-none`}
        >
          {ribbon.text}
        </div>
      )}
      <div className="flex items-start justify-between mb-3">
        <span className="text-2xl" role="img" aria-label={service.name}>
          {service.icon}
        </span>
        <span
          className={`status-${service.status} text-[10px] font-medium px-2 py-0.5 rounded-full`}
        >
          {statusLabel[service.status]}
        </span>
      </div>
      <h3 className="text-sm font-semibold text-gray-100 group-hover:text-accent-hover transition-colors">
        {service.name}
      </h3>
      <p className="text-xs text-muted mt-1 line-clamp-2">
        {service.description}
      </p>
      <div className="mt-3 flex items-center gap-1.5 text-[11px] text-muted/70">
        <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"
          />
        </svg>
        {service.domain}
      </div>
    </Link>
  );
}
