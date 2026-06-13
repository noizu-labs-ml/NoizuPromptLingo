import { Redis } from "ioredis";

export class RedisStore {
  private client: Redis;

  constructor(url: string) {
    this.client = new Redis(url);
  }

  // --- Hot Index Operations ---

  async setHotIndex(
    emotionalBucket: string,
    entries: Array<{ memoryId: string; resonanceScore: number }>
  ): Promise<void> {
    const key = `hot:${emotionalBucket}`;
    const pipeline = this.client.pipeline();
    pipeline.del(key);
    for (const entry of entries) {
      pipeline.zadd(key, entry.resonanceScore, entry.memoryId);
    }
    pipeline.expire(key, 3600);
    await pipeline.exec();
  }

  async getHotIndex(
    emotionalBucket: string,
    limit: number = 10
  ): Promise<Array<{ memoryId: string; score: number }>> {
    const key = `hot:${emotionalBucket}`;
    const results = await this.client.zrevrange(key, 0, limit - 1, "WITHSCORES");

    const entries: Array<{ memoryId: string; score: number }> = [];
    for (let i = 0; i < results.length; i += 2) {
      entries.push({
        memoryId: results[i],
        score: parseFloat(results[i + 1]),
      });
    }
    return entries;
  }

  // --- Agent State Cache ---

  async setAgentState(agentId: string, state: Record<string, string>): Promise<void> {
    await this.client.hmset(`agent_state:${agentId}`, state);
  }

  async getAgentState(agentId: string): Promise<Record<string, string> | null> {
    const state = await this.client.hgetall(`agent_state:${agentId}`);
    return Object.keys(state).length > 0 ? state : null;
  }

  // --- Rate Limiting ---

  async checkTangentialRate(sessionId: string, windowTurns: number): Promise<boolean> {
    const key = `tangential:rate:${sessionId}`;
    const count = await this.client.get(key);
    return count === null || parseInt(count) < 1;
  }

  async recordTangentialInsertion(sessionId: string, windowTurns: number): Promise<void> {
    const key = `tangential:rate:${sessionId}`;
    await this.client.setex(key, windowTurns * 10, "1");
  }

  // --- Event Bus (Pub/Sub) ---

  async publish(channel: string, message: string): Promise<void> {
    await this.client.publish(channel, message);
  }

  createSubscriber(): Redis {
    return this.client.duplicate();
  }

  // --- Health ---

  async healthCheck(): Promise<boolean> {
    try {
      const pong = await this.client.ping();
      return pong === "PONG";
    } catch {
      return false;
    }
  }

  async close(): Promise<void> {
    await this.client.quit();
  }
}
