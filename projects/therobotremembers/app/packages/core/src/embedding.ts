export interface EmbeddingService {
  embed(text: string): Promise<number[]>;
  dimensions(): number;
}

export class OpenAIEmbedding implements EmbeddingService {
  private apiKey: string;
  private model: string;
  private dims: number;

  constructor(apiKey: string, model: string = "text-embedding-3-small", dims: number = 1536) {
    this.apiKey = apiKey;
    this.model = model;
    this.dims = dims;
  }

  async embed(text: string): Promise<number[]> {
    const response = await fetch("https://api.openai.com/v1/embeddings", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${this.apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        input: text,
        model: this.model,
        dimensions: this.dims,
      }),
    });

    if (!response.ok) {
      const err = await response.text();
      throw new Error(`OpenAI embedding failed: ${response.status} ${err}`);
    }

    const data = await response.json() as { data: Array<{ embedding: number[] }> };
    return data.data[0].embedding;
  }

  dimensions(): number {
    return this.dims;
  }
}
