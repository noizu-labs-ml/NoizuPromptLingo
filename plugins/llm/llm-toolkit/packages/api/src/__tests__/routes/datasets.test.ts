import { describe, test, expect } from "vitest";
import { Hono } from "hono";
import { datasetRoutes } from "../../routes/datasets.ts";

const app = new Hono();
app.route("/api/datasets", datasetRoutes);

describe("dataset routes", () => {
  describe("GET /api/datasets", () => {
    test("returns 200 with empty data array", async () => {
      const res = await app.request("/api/datasets");
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body).toEqual({ data: [] });
    });
  });

  describe("POST /api/datasets", () => {
    test("returns 501 not implemented", async () => {
      const res = await app.request("/api/datasets", { method: "POST" });
      expect(res.status).toBe(501);
    });
  });

  describe("GET /api/datasets/:name", () => {
    test("returns 501 not implemented", async () => {
      const res = await app.request("/api/datasets/my-dataset");
      expect(res.status).toBe(501);
    });
  });

  describe("GET /api/datasets/:name/entries", () => {
    test("returns 200 with empty data", async () => {
      const res = await app.request("/api/datasets/my-dataset/entries");
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body).toEqual({ data: [] });
    });
  });

  describe("GET /api/datasets/:name/export", () => {
    test("returns 501 not implemented", async () => {
      const res = await app.request(
        "/api/datasets/my-dataset/export?format=openai",
      );
      expect(res.status).toBe(501);
    });
  });

  describe("DELETE /api/datasets/:name/entries/:id", () => {
    test("returns 501 not implemented", async () => {
      const res = await app.request("/api/datasets/my-dataset/entries/123", {
        method: "DELETE",
      });
      expect(res.status).toBe(501);
    });
  });
});
