"use client";

import * as React from "react";
import dynamic from "next/dynamic";
import { useParams, useRouter } from "next/navigation";
import { GraphControls } from "@/components/graph/graph-controls";
import { GraphLegend } from "@/components/graph/graph-legend";
import type { GraphNode, GraphEdge } from "@/components/graph/knowledge-graph";
import type { EntryType } from "@/lib/constants";

const KnowledgeGraph = dynamic(
  () =>
    import("@/components/graph/knowledge-graph").then((m) => m.KnowledgeGraph),
  {
    ssr: false,
    loading: () => (
      <div className="w-full h-full bg-page animate-pulse flex items-center justify-center">
        <p className="font-mono text-[11px] text-ink-tertiary">Loading graph…</p>
      </div>
    ),
  }
);

// ── Mock data ──────────────────────────────────────────────────────────────
const MOCK_NODES: GraphNode[] = [
  { id: "kael",          label: "Kael Ashward",          type: "character", status: "canon"     },
  { id: "thornwall",     label: "Thornwall",              type: "location",  status: "canon"     },
  { id: "blacksmiths",   label: "Blacksmith Guild",       type: "faction",   status: "canon"     },
  { id: "war-stones",    label: "War of Stones",          type: "event",     status: "canon"     },
  { id: "treaty-dusk",   label: "Treaty of Dusk",         type: "event",     status: "canon"     },
  { id: "iron-routes",   label: "Iron Trade Routes",      type: "concept",   status: "canon"     },
  { id: "cold-singing",  label: "Cold-Singing",           type: "concept",   status: "canon"     },
  { id: "mira",          label: "Mira Ashward",           type: "character", status: "canon"     },
  { id: "north-reach",   label: "Northern Reach",         type: "location",  status: "canon"     },
  { id: "guild-hist",    label: "Guild History",          type: "event",     status: "generated" },
  { id: "founding-myth", label: "Founding of Thornwall",  type: "event",     status: "generated" },
  { id: "climate",       label: "Northern Climate",       type: "concept",   status: "generated" },
];

const MOCK_EDGES: GraphEdge[] = [
  { source: "kael",        target: "thornwall",    relationship: "resident"      },
  { source: "kael",        target: "blacksmiths",  relationship: "last master"   },
  { source: "kael",        target: "war-stones",   relationship: "survivor"      },
  { source: "kael",        target: "iron-routes",  relationship: "dependent on"  },
  { source: "kael",        target: "cold-singing", relationship: "practitioner"  },
  { source: "kael",        target: "mira",         relationship: "father"        },
  { source: "thornwall",   target: "blacksmiths",  relationship: "hosts"         },
  { source: "thornwall",   target: "north-reach",  relationship: "located in"    },
  { source: "thornwall",   target: "founding-myth",relationship: "origin"        },
  { source: "blacksmiths", target: "guild-hist",   relationship: "documented in" },
  { source: "war-stones",  target: "treaty-dusk",  relationship: "ended by"      },
  { source: "war-stones",  target: "iron-routes",  relationship: "disrupted"     },
  { source: "north-reach", target: "climate",      relationship: "described by"  },
  { source: "iron-routes", target: "north-reach",  relationship: "traverses"     },
];

const STATS = {
  entries:     MOCK_NODES.length,
  connections: MOCK_EDGES.length,
  conflicts:   3,
};
// ──────────────────────────────────────────────────────────────────────────

export default function GraphPage() {
  const params = useParams<{ universeId: string }>();
  const router = useRouter();

  const [searchQuery, setSearchQuery] = React.useState("");
  const [typeFilter, setTypeFilter]   = React.useState<EntryType | "all">("all");

  const filteredNodes = React.useMemo(() => {
    return MOCK_NODES.filter((n) => {
      const matchesType   = typeFilter === "all" || n.type === typeFilter;
      const matchesSearch =
        searchQuery === "" ||
        n.label.toLowerCase().includes(searchQuery.toLowerCase());
      return matchesType && matchesSearch;
    });
  }, [searchQuery, typeFilter]);

  const filteredEdges = React.useMemo(() => {
    const nodeIds = new Set(filteredNodes.map((n) => n.id));
    return MOCK_EDGES.filter(
      (e) => nodeIds.has(e.source) && nodeIds.has(e.target)
    );
  }, [filteredNodes]);

  function handleNodeClick(node: GraphNode) {
    router.push(`/${params.universeId}/entries/${node.id}`);
  }

  return (
    // This page fills the <main> which is flex-1 overflow-y-auto.
    // We use h-full so the graph canvas takes the full viewport height.
    <div className="flex flex-col h-full">
      {/* Controls */}
      <GraphControls
        searchQuery={searchQuery}
        onSearchChange={setSearchQuery}
        typeFilter={typeFilter}
        onTypeFilterChange={setTypeFilter}
        onZoomIn={() =>
          window.dispatchEvent(new CustomEvent("kb:graph:zoom", { detail: { delta: 0.25 } }))
        }
        onZoomOut={() =>
          window.dispatchEvent(new CustomEvent("kb:graph:zoom", { detail: { delta: -0.25 } }))
        }
        onFitToScreen={() =>
          window.dispatchEvent(new CustomEvent("kb:graph:fit"))
        }
      />

      {/* D3 canvas — flex-1 ensures it fills remaining vertical space */}
      <div className="flex-1 min-h-0">
        <KnowledgeGraph
          nodes={filteredNodes}
          edges={filteredEdges}
          onNodeClick={handleNodeClick}
        />
      </div>

      {/* Legend + status bar */}
      <div className="shrink-0">
        <GraphLegend />
        <div className="px-4 py-2 bg-elevated border-t border-rule">
          <p className="font-mono text-[11px] text-ink-tertiary">
            {STATS.entries} entries &middot; {STATS.connections} connections &middot;{" "}
            <span className="text-flag-error">{STATS.conflicts} conflicts</span>
          </p>
        </div>
      </div>
    </div>
  );
}
