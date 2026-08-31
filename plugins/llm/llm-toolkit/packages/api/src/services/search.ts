import type { SearchOptions, SearchResult, Conversation } from "@llm-toolkit/shared";
import type { StorageService } from "./storage.ts";
import type { EmbeddingService } from "./embeddings.ts";

export class SearchService {
  private storage: StorageService | null;
  private embeddings: EmbeddingService | null;

  constructor(storage?: StorageService, embeddings?: EmbeddingService) {
    this.storage = storage ?? null;
    this.embeddings = embeddings ?? null;
  }

  async search(options: SearchOptions): Promise<SearchResult[]> {
    if (options.mode === "semantic") {
      return this.semanticSearch(options);
    }
    return this.fullTextSearch(options);
  }

  async searchInConversation(conversationId: string, query: string, limit = 50): Promise<Array<{ messageId: number; role: string; content: string; snippet: string }>> {
    if (!this.storage) return [];

    const db = this.storage.getDb();
    const matchQuery = sanitizeFtsQuery(query);
    if (!matchQuery) return [];

    const rows = db.prepare(`
      SELECT m.id, m.role, m.content,
        snippet(messages_fts, 0, '<<<', '>>>', '...', 40) as snippet
      FROM messages_fts
      JOIN messages m ON messages_fts.rowid = m.id
      WHERE messages_fts MATCH ? AND m.conversation_id = ?
      ORDER BY m.id
      LIMIT ?
    `).all(matchQuery, conversationId, limit) as Array<{ id: number; role: string; content: string; snippet: string }>;

    return rows.map((r) => ({
      messageId: r.id,
      role: r.role,
      content: r.content,
      snippet: r.snippet,
    }));
  }

  private async fullTextSearch(options: SearchOptions): Promise<SearchResult[]> {
    if (!this.storage) return [];

    const db = this.storage.getDb();
    const limit = options.limit ?? 20;
    const offset = options.offset ?? 0;

    if (!options.query.trim()) return [];

    // Escape FTS5 special characters and build match expression
    const matchQuery = sanitizeFtsQuery(options.query);
    if (!matchQuery) return [];

    let query = `
      SELECT
        m.conversation_id,
        m.role,
        snippet(messages_fts, 0, '<<<', '>>>', '...', 40) as snippet,
        m.timestamp,
        rank
      FROM messages_fts
      JOIN messages m ON messages_fts.rowid = m.id
      WHERE messages_fts MATCH ?
    `;
    const params: unknown[] = [matchQuery];

    if (options.role) {
      query += ` AND m.role = ?`;
      params.push(options.role);
    }

    query += ` ORDER BY rank LIMIT ? OFFSET ?`;
    params.push(limit, offset);

    const rows = db.prepare(query).all(...params) as FtsRow[];

    // Collect unique conversation IDs and fetch their metadata
    const convIds = [...new Set(rows.map((r) => r.conversation_id))];
    const conversations = new Map<string, Conversation>();
    for (const convId of convIds) {
      const conv = await this.storage.getConversation(convId);
      if (conv) conversations.set(convId, conv);
    }

    // Filter by project and date if specified
    const results: SearchResult[] = [];
    for (const row of rows) {
      const conv = conversations.get(row.conversation_id);
      if (!conv) continue;

      if (options.harness && conv.harness !== options.harness) continue;
      if (options.project && conv.projectPath !== options.project) continue;
      if (options.dateFrom && conv.startedAt < options.dateFrom) continue;
      if (options.dateTo && conv.startedAt > options.dateTo) continue;

      results.push({
        conversation: conv,
        snippet: row.snippet,
        highlights: parseHighlights(row.snippet),
        relevance: -row.rank, // FTS5 rank is negative (lower = better)
      });
    }

    return results;
  }

  private async semanticSearch(options: SearchOptions): Promise<SearchResult[]> {
    if (!this.storage || !this.embeddings?.ready || !this.storage.vecAvailable) return [];

    const queryVec = await this.embeddings.embed(options.query);
    const limit = options.limit ?? 20;
    const itemResults = await this.storage.knnSearchWorkItems(queryVec, limit * 3);
    const workItemMatches: SearchResult[] = [];
    for (const item of itemResults) {
      const conv = await this.storage.getConversation(item.conversationId);
      if (!conv) continue;

      if (options.harness && conv.harness !== options.harness) continue;
      if (options.project && conv.projectPath !== options.project) continue;
      if (options.dateFrom && conv.startedAt < options.dateFrom) continue;
      if (options.dateTo && conv.startedAt > options.dateTo) continue;

      workItemMatches.push({
        conversation: conv,
        snippet: `${item.title} - ${item.description}`,
        highlights: [],
        relevance: 1 - item.distance,
      });

      if (workItemMatches.length >= limit) return workItemMatches;
    }

    if (workItemMatches.length > 0) return workItemMatches;

    const knnResults = await this.storage.knnSearch(queryVec, limit);

    const results: SearchResult[] = [];
    for (const knn of knnResults) {
      const conv = await this.storage.getConversation(knn.id);
      if (!conv) continue;

      if (options.harness && conv.harness !== options.harness) continue;
      if (options.project && conv.projectPath !== options.project) continue;
      if (options.dateFrom && conv.startedAt < options.dateFrom) continue;
      if (options.dateTo && conv.startedAt > options.dateTo) continue;

      results.push({
        conversation: conv,
        snippet: conv.title,
        highlights: [],
        relevance: 1 - knn.distance,
      });
    }

    return results;
  }
}

function sanitizeFtsQuery(input: string): string {
  // Split into words, wrap each in quotes for exact matching, join with spaces (implicit AND)
  const words = input.trim().split(/\s+/).filter(Boolean);
  if (words.length === 0) return "";
  return words.map((w) => `"${w.replace(/"/g, '""')}"`).join(" ");
}

function parseHighlights(snippet: string): Array<{ start: number; end: number }> {
  const highlights: Array<{ start: number; end: number }> = [];
  let clean = "";
  let i = 0;
  while (i < snippet.length) {
    if (snippet.startsWith("<<<", i)) {
      const start = clean.length;
      i += 3;
      const endMarker = snippet.indexOf(">>>", i);
      if (endMarker === -1) break;
      clean += snippet.slice(i, endMarker);
      highlights.push({ start, end: clean.length });
      i = endMarker + 3;
    } else {
      clean += snippet[i];
      i++;
    }
  }
  return highlights;
}

interface FtsRow {
  conversation_id: string;
  role: string;
  snippet: string;
  timestamp: string;
  rank: number;
}
