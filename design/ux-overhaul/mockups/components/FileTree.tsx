import type { FileNode } from "@/lib/fixtures";

function Node({ node, basePath }: { node: FileNode; basePath: string }) {
  const path = `${basePath}/${node.id}`;
  if (node.type === "dir") {
    return (
      <li role="treeitem" aria-expanded="true">
        <details open>
          <summary>{node.name || "(unnamed)"} /</summary>
          {node.children && node.children.length > 0 ? (
            <ul className="tree" role="group">
              {node.children.map((c) => (
                <Node node={c} basePath={basePath} key={c.id} />
              ))}
            </ul>
          ) : (
            <p className="chip">empty directory</p>
          )}
        </details>
      </li>
    );
  }
  return (
    <li role="treeitem">
      <a href={path}>{node.name || "(unnamed)"}</a> {node.live && <span className="chip">live</span>}
    </li>
  );
}

export function FileTree({ nodes, basePath }: { nodes: FileNode[]; basePath: string }) {
  return (
    <ul className="tree" role="tree" aria-label="File tree">
      {nodes.map((n) => (
        <Node node={n} basePath={basePath} key={n.id} />
      ))}
    </ul>
  );
}
