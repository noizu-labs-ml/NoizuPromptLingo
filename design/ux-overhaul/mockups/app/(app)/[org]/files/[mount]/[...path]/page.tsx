import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";
import { PageHeader } from "@/components/PageHeader";
import { EmptyState } from "@/components/EmptyState";
import { FileTree } from "@/components/FileTree";
import { fileTreesByMount, fileContentByMount, mounts } from "@/lib/fixtures";

export default async function FileBrowserPage({
  params,
  searchParams,
}: {
  params: Promise<{ org: string; mount: string; path?: string[] }>;
  searchParams: Promise<SearchParams>;
}) {
  const { org, mount, path } = await params;
  const sp = await searchParams;
  const state = resolveState(sp);
  const selected = path && path.length > 0 ? path[path.length - 1] : "README.md";
  const mountInfo = mounts.find((m) => m.id === mount);

  if (!mountInfo) {
    return (
      <div>
        <p className="state">STATE: {state}</p>
        <PageHeader title="Files — mount not found" />
        <EmptyState
          title="Mount not found"
          description={`No mount named "${mount}" is configured for this org.`}
          primaryActionLabel="Back to mount picker"
          variant="error"
        />
      </div>
    );
  }

  const tree = fileTreesByMount[mountInfo.id] ?? [];
  const content = fileContentByMount[mountInfo.id] ?? "";

  return (
    <div>
      <p className="state">STATE: {state}</p>
      <ScreenStates state={state} emptyTitle="This mount has no files" emptyDescription="Nothing has been written to this mount yet." emptyActionLabel="Create a file">
        <PageHeader title={`Files — ${mountInfo.name.trim() ? mountInfo.name : "(unnamed mount)"}`} overflowItems={["Download", "Show history"]} />
        <div className="three-pane">
          <div>
            <h2>Tree</h2>
            <FileTree nodes={tree} basePath={`/${org}/files/${mountInfo.id}`} />
          </div>
          <div>
            <h2>{selected}</h2>
            <textarea
              defaultValue={content}
              rows={16}
              style={{ width: "100%" }}
              aria-label={`Editor for ${selected}`}
            />
            <p>
              <button type="button">Save (⌘S)</button>
            </p>
          </div>
          <div>
            <h2>Inspector</h2>
            <p className="chip">live</p>
            <dl>
              <dt>Mount</dt>
              <dd>{mountInfo.id}</dd>
              <dt>Auth state</dt>
              <dd>{mountInfo.authState}</dd>
              <dt>Path</dt>
              <dd>{path?.join("/") || "README.md"}</dd>
              <dt>Group gate</dt>
              <dd>{mountInfo.id}:read-write</dd>
            </dl>
          </div>
        </div>
      </ScreenStates>
    </div>
  );
}
