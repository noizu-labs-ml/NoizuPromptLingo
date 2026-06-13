import type { AppConfig } from "@claude-assist/shared";

type Pipeline = (text: string, options: { pooling: string; normalize: boolean }) => Promise<{ data: Float32Array }>;

export class EmbeddingService {
  private pipeline: Pipeline | null = null;
  private modelName: string;
  private _ready = false;

  constructor(config?: AppConfig["embedding"]) {
    this.modelName = config?.model ?? "Xenova/all-MiniLM-L6-v2";
  }

  get ready(): boolean {
    return this._ready;
  }

  get dimensions(): number {
    return 384;
  }

  async initialize(): Promise<void> {
    try {
      const { pipeline } = await import("@huggingface/transformers");
      this.pipeline = (await pipeline("feature-extraction", this.modelName, {
        dtype: "fp32",
      })) as unknown as Pipeline;
      this._ready = true;
      console.log(`Embedding model loaded: ${this.modelName}`);
    } catch (err) {
      console.warn(
        `Failed to load embedding model: ${err instanceof Error ? err.message : err}. Semantic search will be unavailable.`,
      );
      this._ready = false;
    }
  }

  async embed(text: string): Promise<Float32Array> {
    if (!this.pipeline) throw new Error("EmbeddingService not initialized");
    const result = await this.pipeline(text, { pooling: "mean", normalize: true });
    return new Float32Array(result.data);
  }

  async embedBatch(texts: string[]): Promise<Float32Array[]> {
    const results: Float32Array[] = [];
    for (const text of texts) {
      results.push(await this.embed(text));
    }
    return results;
  }
}
