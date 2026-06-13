"use client";

import Link from "next/link";
import type { Service } from "@/lib/services";
import { ServiceHeader } from "./ServiceHeader";

interface ServiceViewerProps {
  service: Service;
}

const statusMessages: Record<string, { heading: string; body: string }> = {
  "coming-soon": {
    heading: "Coming Soon",
    body: "This service is being prepared for deployment. Check back soon!",
  },
  pending: {
    heading: "Coming Soon",
    body: "This service is being prepared for deployment. Check back soon!",
  },
  maintenance: {
    heading: "Under Maintenance",
    body: "This service is temporarily unavailable while we work on improvements.",
  },
};

function PlaceholderPage({ service }: { service: Service }) {
  const msg = statusMessages[service.status] ?? statusMessages["pending"];
  const accentColor =
    service.status === "maintenance"
      ? "from-orange-500/20 to-orange-600/5"
      : "from-cyan-500/20 to-cyan-600/5";
  const badgeColor =
    service.status === "maintenance"
      ? "bg-orange-500/15 text-orange-400 border-orange-500/30"
      : "bg-cyan-500/15 text-cyan-400 border-cyan-500/30";

  return (
    <div className="flex-1 flex items-center justify-center bg-surface-0">
      <div className="text-center max-w-md px-6">
        <div
          className={`w-24 h-24 mx-auto mb-6 rounded-2xl bg-gradient-to-br ${accentColor} flex items-center justify-center`}
        >
          <span className="text-5xl">{service.icon}</span>
        </div>
        <h2 className="text-2xl font-bold text-gray-100 mb-2">
          {service.name}
        </h2>
        <span
          className={`inline-block text-xs font-medium px-3 py-1 rounded-full border mb-4 ${badgeColor}`}
        >
          {msg.heading}
        </span>
        <p className="text-muted text-sm mb-2">{service.description}</p>
        <p className="text-muted/70 text-xs mb-8">{msg.body}</p>
        <Link
          href="/"
          className="inline-flex items-center gap-2 text-sm text-accent hover:text-accent-hover transition-colors"
        >
          <svg
            className="w-4 h-4"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M15 19l-7-7 7-7"
            />
          </svg>
          Back to Dashboard
        </Link>
      </div>
    </div>
  );
}

export function ServiceViewer({ service }: ServiceViewerProps) {
  const isPlaceholder =
    service.status === "coming-soon" ||
    service.status === "pending" ||
    service.status === "maintenance";
  const url = `https://${service.domain}`;

  return (
    <div className="h-screen flex flex-col">
      <ServiceHeader current={service} />
      {isPlaceholder ? (
        <PlaceholderPage service={service} />
      ) : (
        <div className="flex-1 relative bg-surface-0">
          <iframe
            src={url}
            title={service.name}
            className="w-full h-full border-0"
            sandbox="allow-same-origin allow-scripts allow-popups allow-forms allow-modals allow-downloads"
            referrerPolicy="no-referrer"
          />
          <noscript>
            <div className="absolute inset-0 flex items-center justify-center bg-surface-0">
              <a
                href={url}
                target="_blank"
                rel="noopener noreferrer"
                className="text-accent"
              >
                Open {service.name} directly
              </a>
            </div>
          </noscript>
        </div>
      )}
    </div>
  );
}
