import { describe, test, expect } from "vitest";
import { SearchService } from "../../services/search.ts";

describe("SearchService", () => {
  test("search with fts mode returns empty array", async () => {
    const service = new SearchService();
    const results = await service.search({ query: "hello", mode: "fts" });
    expect(results).toEqual([]);
  });

  test("search with semantic mode returns empty array", async () => {
    const service = new SearchService();
    const results = await service.search({ query: "hello", mode: "semantic" });
    expect(results).toEqual([]);
  });
});
