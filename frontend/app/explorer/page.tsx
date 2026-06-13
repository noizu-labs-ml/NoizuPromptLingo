"use client";

import { useState, useCallback, Suspense } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import useSWR from "swr";
import clsx from "clsx";
import {
  FolderIcon,
  FolderOpenIcon,
  DocumentIcon,
  ChevronRightIcon,
} from "@heroicons/react/24/outline";

import { api } from "@/lib/api/client";
import type { FileTreeNode } from "@/lib/api/types";

import { CodeBlock } from "@/components/primitives/CodeBlock";
import { EmptyState } from "@/components/primitives/EmptyState";
import { PageHeader } from "@/components/primitives/PageHeader";

// ── Tree node component ───────────────────────────────────────────────────

interface TreeNodeProps {
  node: FileTreeNode;
  selectedPath: string | null;
  onSelect: (path: string) => void;
  depth?: number;
}

function TreeNode({ node, selectedPath, onSelect, depth = 0 }: TreeNodeProps) {
  const [open, setOpen] = useState(depth < 2);

  if (node.kind === "file" || node.kind === "binary") {
    const isSelected = selectedPath === node.path;
    return (
      <button
        type="button"
        onClick={() => onSelect(node.path)}
        className={clsx(
          "focus-ring flex items-center gap-1.5 w-full text-left rounded px-1.5 py-0.5 text-sm transition-colors",
          isSelected
            ? "bg-accent/10 text-accent font-medium"
            : "text-muted hover:bg-surface-1 hover:text-foreground"
        )}
        style={{ paddingLeft: `${(depth + 1) * 12 + 6}px` }}
      >
        <DocumentIcon className="h-3.5 w-3.5 shrink-0" />
        <span className="truncate">{node.name}</span>
        {node.kind === "binary" && (
          <span className="ml-auto text-[9px] font-semibold uppercase text-subtle">bin</span>
        )}
      </button>
    );
  }

  // Directory
  return (
    <div>
      <button
        type="button"
        onClick={() => setOpen((o) => !o)}
        className={clsx(
          "focus-ring flex items-center gap-1.5 w-full text-left rounded px-1.5 py-0.5 text-sm transition-colors",
          "text-foreground hover:bg-surface-1"
        )}
        style={{ paddingLeft: `${depth * 12 + 6}px` }}
      >
        <ChevronRightIcon
          className={clsx(
            "h-3 w-3 shrink-0 transition-transform",
            open && "rotate-90"
          )}
        />
        {open ? (
          <FolderOpenIcon className="h-3.5 w-3.5 shrink-0 text-accent" />
        ) : (
          <FolderIcon className="h-3.5 w-3.5 shrink-0 text-muted" />
        )}
        <span className="truncate font-medium">{node.name}</span>
      </button>
      {open && node.children && node.children.length > 0 && (
        <div>
          {node.children.map((child) => (
            <TreeNode
              key={child.path || child.name}
              node={child}
              selectedPath={selectedPath}
              onSelect={onSelect}
              depth={depth + 1}
            />
          ))}
        </div>
      )}
    </div>
  );
}

// ── File preview header (DetailHeader-like slot) ─────────────────────────

function FilePreviewHeader({ path }: { path: string }) {
  const segments = path.split("/").filter(Boolean);
  const filename = segments[segments.length - 1] ?? path;
  const dirSegments = segments.slice(0, -1);

  return (
    <div className="flex flex-col gap-1 px-1 pb-2 border-b border-border">
      {dirSegments.length > 0 && (
        <div className="flex items-center gap-1 text-label uppercase text-subtle flex-wrap">
          {dirSegments.map((seg, i) => (
            <span key={i} className="inline-flex items-center gap-1">
              <span className="font-mono normal-case tracking-normal">{seg}</span>
              <ChevronRightIcon className="h-3 w-3 text-subtle" aria-hidden="true" />
            </span>
          ))}
        </div>
      )}
      <div className="flex items-center gap-2">
        <DocumentIcon className="h-4 w-4 text-muted shrink-0" aria-hidden="true" />
        <h2 className="text-sm font-semibold font-mono text-foreground truncate">
          {filename}
        </h2>
      </div>
    </div>
  );
}

// ── Inner content (uses useSearchParams — must be inside Suspense) ────────

function ExplorerContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const selectedPath = searchParams.get("path");

  const handleSelect = useCallback(
    (path: string) => {
      router.push(`/explorer?path=${encodeURIComponent(path)}`);
    },
    [router]
  );

  // Fetch tree (depth 4 by default for reasonable coverage)
  const { data: tree, isLoading: treeLoading } = useSWR(
    "explorer.tree",
    () => api.explorer.tree(".", 4)
  );

  // Fetch file content when path is selected
  const { data: fileContent, isLoading: fileLoading } = useSWR(
    selectedPath ? ["explorer.file", selectedPath] : null,
    () => api.explorer.file(selectedPath!)
  );

  return (
    <div className="flex gap-4 min-h-0 flex-1 lg:flex-row flex-col">
      {/* ── Left panel: tree ── */}
      <aside className="lg:w-80 shrink-0 rounded-lg border border-border bg-surface-1 overflow-y-auto max-h-[70vh] lg:max-h-[calc(100vh-220px)] lg:sticky lg:top-4 p-2">
        {treeLoading ? (
          <div className="animate-pulse space-y-1 p-2">
            {Array.from({ length: 8 }).map((_, i) => (
              <div key={i} className="h-5 rounded bg-border" style={{ width: `${50 + (i % 3) * 20}%` }} />
            ))}
          </div>
        ) : tree ? (
          <div className="space-y-0.5">
            {tree.children?.map((node) => (
              <TreeNode
                key={node.path || node.name}
                node={node}
                selectedPath={selectedPath}
                onSelect={handleSelect}
                depth={0}
              />
            ))}
          </div>
        ) : (
          <EmptyState
            icon={<FolderOpenIcon />}
            title="Could not load tree"
            description="The file tree failed to load."
          />
        )}
      </aside>

      {/* ── Right panel: file content ── */}
      <main className="flex-1 min-w-0">
        {!selectedPath ? (
          <EmptyState
            icon={<DocumentIcon />}
            title="No file selected"
            description="Pick a file from the tree on the left to view its contents."
          />
        ) : fileLoading ? (
          <div className="h-64 rounded-lg bg-surface-1 border border-border animate-pulse" />
        ) : fileContent ? (
          <div className="flex flex-col gap-2">
            <FilePreviewHeader path={fileContent.path} />
            {fileContent.kind === "binary" ? (
              <EmptyState
                icon={<DocumentIcon />}
                title="Binary file"
                description={`${fileContent.path} is a binary file and cannot be displayed as text.`}
              />
            ) : (
              <>
                {fileContent.truncated && (
                  <div className="rounded bg-warning/10 border border-warning/30 px-3 py-1.5 text-xs text-warning">
                    File truncated at 256 KB — showing first portion only.
                  </div>
                )}
                <CodeBlock
                  code={fileContent.content ?? ""}
                  language={selectedPath.split(".").pop()}
                  maxHeight="calc(100vh - 260px)"
                />
              </>
            )}
          </div>
        ) : (
          <EmptyState
            icon={<DocumentIcon />}
            title="File not found"
            description="The selected file could not be loaded."
          />
        )}
      </main>
    </div>
  );
}

// ── Page ──────────────────────────────────────────────────────────────────

export default function ExplorerPage() {
  return (
    <div className="flex flex-col gap-6 h-full">
      <PageHeader
        title="Project Explorer"
        description="Browse the repository file tree."
      />
      <Suspense
        fallback={
          <div className="h-64 rounded-lg bg-surface-1 border border-border animate-pulse" />
        }
      >
        <ExplorerContent />
      </Suspense>
    </div>
  );
}
