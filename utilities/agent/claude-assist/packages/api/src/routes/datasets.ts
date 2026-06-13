import { Hono } from "hono";
import type { StorageService } from "../services/storage.ts";
import type { QualityLabel } from "@claude-assist/shared";
import { exportDataset } from "../services/exporter.ts";

export function createDatasetRoutes(storage: StorageService): Hono {
  const routes = new Hono();

  routes.get("/", async (c) => {
    const datasets = await storage.getDatasets();
    return c.json({ data: datasets });
  });

  routes.post("/", async (c) => {
    const body = await c.req.json() as { name: string; description?: string };
    if (!body.name) {
      return c.json({ data: null, error: "name required" }, 400);
    }
    const dataset = await storage.createDataset(body.name, body.description ?? "");
    return c.json({ data: dataset }, 201);
  });

  routes.get("/:name", async (c) => {
    const name = c.req.param("name");
    const dataset = await storage.getDataset(name);
    if (!dataset) {
      return c.json({ data: null, error: "not found" }, 404);
    }
    return c.json({ data: dataset });
  });

  routes.get("/:name/entries", async (c) => {
    const name = c.req.param("name");
    const quality = c.req.query("quality") as QualityLabel | undefined;
    const entries = await storage.getDatasetEntries(name, { quality });
    return c.json({ data: entries });
  });

  routes.post("/:name/entries", async (c) => {
    const name = c.req.param("name");
    const body = await c.req.json() as {
      conversationId: string;
      startIndex: number;
      endIndex: number;
      quality?: QualityLabel;
      systemPrompt?: string;
      messages: Array<{ role: string; content: string }>;
    };
    const entry = await storage.createDatasetEntry({
      datasetName: name,
      conversationId: body.conversationId,
      startIndex: body.startIndex,
      endIndex: body.endIndex,
      quality: body.quality ?? "silver",
      systemPrompt: body.systemPrompt,
      messages: body.messages,
    });
    return c.json({ data: entry }, 201);
  });

  routes.patch("/:name/entries/:id", async (c) => {
    const id = c.req.param("id");
    const body = await c.req.json() as { quality?: QualityLabel; systemPrompt?: string };
    await storage.updateDatasetEntry(id, body);
    return c.json({ success: true });
  });

  routes.delete("/:name/entries/:id", async (c) => {
    const id = c.req.param("id");
    await storage.deleteDatasetEntry(id);
    return c.json({ success: true });
  });

  routes.get("/:name/export", async (c) => {
    const name = c.req.param("name");
    const format = c.req.query("format") ?? "jsonl";
    const entries = await storage.getDatasetEntries(name);
    const exported = exportDataset(entries, format);
    return c.text(exported, 200, { "Content-Type": "application/x-ndjson" });
  });

  return routes;
}

// Backward-compatible export for existing tests
export const datasetRoutes = new Hono();
datasetRoutes.get("/", async (c) => c.json({ data: [] }));
datasetRoutes.post("/", async (c) => c.json({ data: null, error: "not implemented" }, 501));
datasetRoutes.get("/:name", async (c) => c.json({ data: null, error: "not implemented" }, 501));
datasetRoutes.get("/:name/entries", async (c) => c.json({ data: [] }));
datasetRoutes.patch("/:name/entries/:id", async (c) => c.json({ data: null, error: "not implemented" }, 501));
datasetRoutes.delete("/:name/entries/:id", async (c) => c.json({ success: false, error: "not implemented" }, 501));
datasetRoutes.get("/:name/export", async (c) => c.json({ data: null, error: "not implemented" }, 501));
