import { Hono } from "hono";
import type { StorageService } from "../services/storage.ts";

interface ProjectRow {
  project_path: string;
  conversation_count: number;
  last_active: string;
}

function deriveProjectName(projectPath: string): string {
  const parts = projectPath.split("/").filter(Boolean);
  // Skip common long prefixes like Users/username — take last 2 meaningful segments
  if (parts.length > 2) return parts.slice(-2).join("/");
  return projectPath;
}

export function createProjectRoutes(storage: StorageService): Hono {
  const routes = new Hono();

  // GET / — list all projects with metadata + conversation counts
  routes.get("/", async (c) => {
    const db = storage.getDb();

    const projectRows = db.prepare(`
      SELECT
        project_path,
        COUNT(*) as conversation_count,
        MAX(updated_at) as last_active
      FROM conversations
      GROUP BY project_path
      ORDER BY last_active DESC
    `).all() as ProjectRow[];

    const allMeta = await storage.getAllProjectMeta();
    const metaMap = new Map(allMeta.map((m) => [m.projectPath, m]));

    const result = projectRows.map((row) => {
      const meta = metaMap.get(row.project_path);
      return {
        projectPath: row.project_path,
        title: meta?.title ?? null,
        displayName: meta?.title ?? deriveProjectName(row.project_path),
        description: meta?.description ?? null,
        tags: meta?.tags ?? [],
        conversationCount: row.conversation_count,
        lastActive: row.last_active,
      };
    });

    return c.json(result);
  });

  // GET /:path — get single project metadata (path is URL-encoded)
  routes.get("/:path", async (c) => {
    const projectPath = decodeURIComponent(c.req.param("path"));
    const meta = await storage.getProjectMeta(projectPath);

    const db = storage.getDb();
    const statsRow = db.prepare(`
      SELECT COUNT(*) as conversation_count, MAX(updated_at) as last_active
      FROM conversations
      WHERE project_path = ?
    `).get(projectPath) as { conversation_count: number; last_active: string | null };

    return c.json({
      projectPath,
      title: meta?.title ?? null,
      displayName: meta?.title ?? deriveProjectName(projectPath),
      description: meta?.description ?? null,
      tags: meta?.tags ?? [],
      conversationCount: statsRow.conversation_count,
      lastActive: statsRow.last_active,
    });
  });

  // PATCH /:path — update title, description, tags
  routes.patch("/:path", async (c) => {
    const projectPath = decodeURIComponent(c.req.param("path"));
    const body = await c.req.json<{ title?: string; description?: string; tags?: string[] }>();

    await storage.upsertProjectMeta({
      projectPath,
      ...(body.title !== undefined && { title: body.title }),
      ...(body.description !== undefined && { description: body.description }),
      ...(body.tags !== undefined && { tags: body.tags }),
    });

    const meta = await storage.getProjectMeta(projectPath);
    return c.json(meta);
  });

  return routes;
}
