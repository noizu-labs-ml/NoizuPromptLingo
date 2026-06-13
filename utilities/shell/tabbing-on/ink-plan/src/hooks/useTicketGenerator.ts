import { useState, useCallback } from 'react';
import type OpenAI from 'openai';
import { buildSystemPrompt } from '../prompts/ticket-generator.js';
import type { Ticket, TicketType } from '../types.js';

interface GeneratorState {
  ticket: Ticket | null;
  isGenerating: boolean;
  error: string | null;
}

export function useTicketGenerator(client: OpenAI, model: string) {
  const [state, setState] = useState<GeneratorState>({
    ticket: null,
    isGenerating: false,
    error: null,
  });

  const generate = useCallback(async (transcript: string, typeOverride?: TicketType) => {
    setState({ ticket: null, isGenerating: true, error: null });

    let lastError: Error | null = null;
    for (let attempt = 0; attempt < 3; attempt++) {
      try {
        const response = await client.chat.completions.create({
          model,
          response_format: { type: 'json_object' },
          messages: [
            { role: 'system', content: buildSystemPrompt(typeOverride) },
            { role: 'user', content: transcript },
          ],
        });

        const content = response.choices[0]?.message?.content;
        if (!content) throw new Error('Empty response from LLM');

        const parsed = JSON.parse(content) as Ticket;
        if (!parsed.metadata || !parsed.body) {
          throw new Error('Invalid ticket structure in response');
        }

        setState({ ticket: parsed, isGenerating: false, error: null });
        return parsed;
      } catch (err) {
        lastError = err instanceof Error ? err : new Error(String(err));
        if (attempt < 2) {
          await new Promise(r => setTimeout(r, 1000 * Math.pow(2, attempt)));
        }
      }
    }

    const msg = lastError?.message || 'Ticket generation failed';
    setState({ ticket: null, isGenerating: false, error: msg });
    return null;
  }, [client, model]);

  const updateMetadata = useCallback((updates: Partial<Ticket['metadata']>) => {
    setState(prev => {
      if (!prev.ticket) return prev;
      return {
        ...prev,
        ticket: {
          ...prev.ticket,
          metadata: { ...prev.ticket.metadata, ...updates },
        },
      };
    });
  }, []);

  return { ...state, generate, updateMetadata };
}
