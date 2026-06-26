/**
 * LLM provider configuration with autofill support
 * Ported from queue-populator's LlmConfig.swift
 */

export interface LlmProviderConfig {
  name: string;
  label: string;
  defaultModel: string;
  baseUrl: string;
  envKey: string;
  needsApiKey: boolean;
  needsBaseUrl: boolean;
  envFallbacks?: string[];
}

/**
 * Supported LLM providers with their default configurations
 */
export const LLM_PROVIDERS: Record<string, LlmProviderConfig> = {
  anthropic: {
    name: 'anthropic',
    label: 'Anthropic (Claude)',
    defaultModel: 'claude-sonnet-4-6',
    baseUrl: 'https://api.anthropic.com/v1',
    envKey: 'ANTHROPIC_API_KEY',
    needsApiKey: true,
    needsBaseUrl: false,
  },
  openai: {
    name: 'openai',
    label: 'OpenAI',
    defaultModel: 'gpt-4o',
    baseUrl: 'https://api.openai.com/v1',
    envKey: 'OPENAI_API_KEY',
    needsApiKey: true,
    needsBaseUrl: false,
  },
  groq: {
    name: 'groq',
    label: 'Groq',
    defaultModel: 'llama-3.3-70b',
    baseUrl: 'https://api.groq.com/openai/v1',
    envKey: 'GROQ_API_KEY',
    needsApiKey: true,
    needsBaseUrl: false,
  },
  cerebras: {
    name: 'cerebras',
    label: 'Cerebras',
    defaultModel: 'llama-3.3-70b',
    baseUrl: 'https://api.cerebras.ai/v1',
    envKey: 'CEREBRAS_API_KEY',
    needsApiKey: true,
    needsBaseUrl: false,
  },
  deepseek: {
    name: 'deepseek',
    label: 'DeepSeek',
    defaultModel: 'deepseek-chat',
    baseUrl: 'https://api.deepseek.com/v1',
    envKey: 'DEEPSEEK_API_KEY',
    needsApiKey: true,
    needsBaseUrl: false,
  },
  mistral: {
    name: 'mistral',
    label: 'Mistral',
    defaultModel: 'mistral-large',
    baseUrl: 'https://api.mistral.ai/v1',
    envKey: 'MISTRAL_API_KEY',
    needsApiKey: true,
    needsBaseUrl: false,
  },
  gemini: {
    name: 'gemini',
    label: 'Google Gemini',
    defaultModel: 'gemini-2.0-flash-exp',
    baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
    envKey: 'GOOGLE_API_KEY',
    needsApiKey: true,
    needsBaseUrl: false,
  },
  ollama: {
    name: 'ollama',
    label: 'Ollama (Local)',
    defaultModel: 'llama3',
    baseUrl: 'http://localhost:11434',
    envKey: '',
    needsApiKey: false,
    needsBaseUrl: true,
  },
  litellm: {
    name: 'litellm',
    label: 'LiteLLM Proxy',
    defaultModel: 'claude-sonnet-4-6',
    baseUrl: 'https://inference.noizu.com/v1',
    envKey: 'LITELLM_API_KEY',
    needsApiKey: true,
    needsBaseUrl: true,
    envFallbacks: ['OPENAI_API_KEY'],
  },
  custom: {
    name: 'custom',
    label: 'Custom (OpenAI-compatible)',
    defaultModel: 'model-name',
    baseUrl: 'https://api.example.com/v1',
    envKey: '',
    needsApiKey: false,
    needsBaseUrl: true,
  },
};

/**
 * Get provider configuration by name
 */
export function getProviderConfig(provider: string): LlmProviderConfig | undefined {
  return LLM_PROVIDERS[provider];
}

/**
 * Get a list of provider names
 */
export function getProviderNames(): string[] {
  return Object.keys(LLM_PROVIDERS);
}

/**
 * Check if provider needs API key
 */
export function providerNeedsApiKey(provider: string): boolean {
  return LLM_PROVIDERS[provider]?.needsApiKey ?? false;
}

/**
 * Check if provider needs custom base URL
 */
export function providerNeedsBaseUrl(provider: string): boolean {
  return LLM_PROVIDERS[provider]?.needsBaseUrl ?? false;
}

/**
 * Get default model for provider
 */
export function getDefaultModel(provider: string): string {
  return LLM_PROVIDERS[provider]?.defaultModel ?? 'model-name';
}

/**
 * Get default base URL for provider
 */
export function getDefaultBaseUrl(provider: string): string {
  return LLM_PROVIDERS[provider]?.baseUrl ?? 'https://api.example.com/v1';
}

/**
 * Get environment variable name for provider's API key
 */
export function getProviderEnvKey(provider: string): string {
  return LLM_PROVIDERS[provider]?.envKey ?? '';
}

/**
 * Get fallback environment variable names for provider
 */
export function getProviderEnvFallbacks(provider: string): string[] {
  return LLM_PROVIDERS[provider]?.envFallbacks ?? [];
}

/**
 * Provider label for display
 */
export function getProviderLabel(provider: string): string {
  return LLM_PROVIDERS[provider]?.label ?? provider;
}