import pg from "pg";
import type {
  MemoryEntry,
  MemoryWriteRequest,
  EmotionalMetadata,
  ContextualMetadata,
  AssociationEdge,
  AgentState,
} from "@trr/core";
import { NEUTRAL_EMOTIONAL_STATE } from "@trr/core";

const { Pool } = pg;

export class PostgresStore {
  private pool: pg.Pool;

  constructor(connectionString: string) {
    this.pool = new Pool({
      connectionString,
      max: 20,
      idleTimeoutMillis: 30000,
    });
  }

  async createMemory(
    req: MemoryWriteRequest,
    embedding: number[],
    summary: string
  ): Promise<MemoryEntry> {
    const emotional = req.emotionalMetadata ?? NEUTRAL_EMOTIONAL_STATE;
    const contextual = req.contextualMetadata ?? {
      collaborators: [],
      taskDomain: "unknown",
      sessionId: null,
      environment: "development",
      temporal: {
        timeOfDay: "afternoon",
        dayOfWeek: new Date().toLocaleDateString("en-US", { weekday: "long" }),
        season: "summer",
        isWeekend: [0, 6].includes(new Date().getDay()),
      },
    };

    const result = await this.pool.query(
      `INSERT INTO memories (
        content, content_type, summary, source_agent,
        emotional_metadata, contextual_metadata,
        compartment, classification, owner_agent
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING *`,
      [
        req.content,
        req.contentType ?? "episodic",
        summary,
        req.sourceAgent ?? "external",
        JSON.stringify(emotional),
        JSON.stringify(contextual),
        req.compartment ?? "default",
        req.classification ?? "open",
        req.sourceAgent ?? "external",
      ]
    );

    return this.rowToMemoryEntry(result.rows[0], embedding);
  }

  async getMemory(id: string): Promise<MemoryEntry | null> {
    const result = await this.pool.query(
      "SELECT * FROM memories WHERE id = $1",
      [id]
    );
    if (result.rows.length === 0) return null;
    return this.rowToMemoryEntry(result.rows[0], []);
  }

  async updateDecayWeight(id: string, weight: number): Promise<void> {
    await this.pool.query(
      "UPDATE memories SET decay_weight = $1 WHERE id = $2",
      [weight, id]
    );
  }

  async reinforceMemory(id: string): Promise<void> {
    await this.pool.query(
      `UPDATE memories SET
        recall_count = recall_count + 1,
        reinforcement_count = reinforcement_count + 1,
        last_recalled_at = NOW(),
        decay_weight = LEAST(1.0, decay_weight + 0.1 * (1.0 - decay_weight))
      WHERE id = $1`,
      [id]
    );
  }

  async getActiveMemories(
    compartment?: string,
    limit: number = 100
  ): Promise<Array<{ id: string; decayWeight: number; contentType: string; lastRecalledAt: Date | null }>> {
    const query = compartment
      ? `SELECT id, decay_weight, content_type, last_recalled_at
         FROM memories WHERE lifecycle_state = 'active' AND compartment = $1
         ORDER BY decay_weight DESC LIMIT $2`
      : `SELECT id, decay_weight, content_type, last_recalled_at
         FROM memories WHERE lifecycle_state = 'active'
         ORDER BY decay_weight DESC LIMIT $1`;

    const params = compartment ? [compartment, limit] : [limit];
    const result = await this.pool.query(query, params);

    return result.rows.map((row: any) => ({
      id: row.id,
      decayWeight: parseFloat(row.decay_weight),
      contentType: row.content_type,
      lastRecalledAt: row.last_recalled_at,
    }));
  }

  async healthCheck(): Promise<boolean> {
    try {
      await this.pool.query("SELECT 1");
      return true;
    } catch (err) {
      console.error("[PostgresStore] healthCheck failed:", err);
      return false;
    }
  }

  async close(): Promise<void> {
    await this.pool.end();
  }

  private rowToMemoryEntry(row: any, embedding: number[]): MemoryEntry {
    return {
      id: row.id,
      version: row.version,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
      sourceAgent: row.source_agent,
      content: row.content,
      contentType: row.content_type,
      summary: row.summary,
      embedding,
      emotionalMetadata: row.emotional_metadata as EmotionalMetadata,
      contextualMetadata: row.contextual_metadata as ContextualMetadata,
      lifecycle: {
        state: row.lifecycle_state,
        decayWeight: parseFloat(row.decay_weight),
        lastRecalledAt: row.last_recalled_at,
        recallCount: row.recall_count,
        reinforcementCount: row.reinforcement_count,
        denforcementCount: row.denforcement_count,
        consolidationIds: row.consolidation_ids ?? [],
        prunedAt: row.pruned_at,
      },
      compartment: row.compartment,
      classification: row.classification,
      ownerAgent: row.owner_agent,
    };
  }
}
