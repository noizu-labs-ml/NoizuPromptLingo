import weaviate, { type WeaviateClient } from "weaviate-client";

const COLLECTION_NAME = "MemoryEntry";

export class WeaviateStore {
  private client: WeaviateClient | null = null;
  private url: string;

  constructor(url: string) {
    this.url = url;
  }

  async connect(): Promise<void> {
    this.client = await weaviate.connectToLocal({
      host: new URL(this.url).hostname,
      port: parseInt(new URL(this.url).port) || 8080,
    });
  }

  async ensureCollection(): Promise<void> {
    if (!this.client) throw new Error("Not connected");

    const exists = await this.client.collections.exists(COLLECTION_NAME);
    if (!exists) {
      await this.client.collections.create({
        name: COLLECTION_NAME,
        properties: [
          { name: "memoryId", dataType: "text" },
          { name: "content", dataType: "text" },
          { name: "summary", dataType: "text" },
          { name: "contentType", dataType: "text" },
          { name: "compartment", dataType: "text" },
        ],
        vectorizers: weaviate.configure.vectorizer.none(),
      });
    }
  }

  async upsertMemory(
    memoryId: string,
    content: string,
    summary: string,
    contentType: string,
    compartment: string,
    embedding: number[]
  ): Promise<void> {
    if (!this.client) throw new Error("Not connected");

    const collection = this.client.collections.get(COLLECTION_NAME);
    await collection.data.insert({
      properties: { memoryId, content, summary, contentType, compartment },
      vectors: embedding,
    });
  }

  async searchSimilar(
    queryEmbedding: number[],
    limit: number = 10,
    compartment?: string
  ): Promise<Array<{ memoryId: string; score: number }>> {
    if (!this.client) throw new Error("Not connected");

    const collection = this.client.collections.get(COLLECTION_NAME);
    const filters = compartment
      ? collection.filter.byProperty("compartment").equal(compartment)
      : undefined;

    const result = await collection.query.nearVector(queryEmbedding, {
      limit,
      returnMetadata: ["distance"],
      ...(filters ? { filters } : {}),
    });

    return result.objects.map((obj) => ({
      memoryId: obj.properties.memoryId as string,
      score: 1 - (obj.metadata?.distance ?? 0),
    }));
  }

  async healthCheck(): Promise<boolean> {
    try {
      if (!this.client) return false;
      await this.client.getMeta();
      return true;
    } catch {
      return false;
    }
  }

  async close(): Promise<void> {
    if (this.client) {
      this.client.close();
      this.client = null;
    }
  }
}
