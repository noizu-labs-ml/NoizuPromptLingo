import OpenAI from 'openai';
import type { AppConfig } from '../types.js';

export function createClient(config: AppConfig): OpenAI {
  return new OpenAI({
    baseURL: config.apiUrl,
    apiKey: config.apiKey,
  });
}
