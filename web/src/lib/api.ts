const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8083";

type RequestOptions = {
  method?: string;
  body?: unknown;
  auth?: boolean;
};

export type AuthTokens = {
  access_token: string;
  refresh_token: string;
};

export type User = {
  id: number;
  email: string;
};

export type Character = {
  id: number;
  name: string;
  race: string;
  character_class: string;
  level: number;
  xp: number;
  xp_next: number;
  hp: number;
  max_hp: number;
  energy: number;
  max_energy: number;
  gold: number;
  weapon: string;
  armor: string;
  location: string;
  effects: string[];
  strength: number;
  dexterity: number;
  constitution: number;
  intelligence: number;
  wisdom: number;
  charisma: number;
};

type AuthResponse = {
  user: User;
  access_token: string;
  refresh_token: string;
};

type RefreshResponse = {
  access_token: string;
};

type MeResponse = {
  user: User;
};

type CharacterResponse = {
  character: Character;
};

type ErrorResponse = {
  error?: string;
  errors?: Record<string, string[]>;
};

const TOKEN_KEY = "boe_tokens";

export function getStoredTokens(): AuthTokens | null {
  if (typeof window === "undefined") return null;
  const raw = localStorage.getItem(TOKEN_KEY);
  if (!raw) return null;
  try {
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

export function storeTokens(tokens: AuthTokens): void {
  localStorage.setItem(TOKEN_KEY, JSON.stringify(tokens));
}

export function clearTokens(): void {
  localStorage.removeItem(TOKEN_KEY);
}

async function apiFetch<T>(path: string, opts: RequestOptions = {}): Promise<T> {
  const { method = "GET", body, auth = false } = opts;

  const headers: Record<string, string> = {
    "Content-Type": "application/json",
  };

  if (auth) {
    const tokens = getStoredTokens();
    if (tokens) {
      headers["Authorization"] = `Bearer ${tokens.access_token}`;
    }
  }

  const res = await fetch(`${API_BASE}${path}`, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
  });

  if (!res.ok) {
    const err: ErrorResponse = await res.json().catch(() => ({}));
    if (err.errors) {
      const messages = Object.entries(err.errors)
        .map(([field, msgs]) => `${field} ${msgs.join(", ")}`)
        .join("; ");
      throw new Error(messages);
    }
    throw new Error(err.error || `Request failed (${res.status})`);
  }

  return res.json();
}

export async function register(params: {
  email: string;
  password: string;
}): Promise<AuthResponse> {
  const data = await apiFetch<AuthResponse>("/api/v1/auth/register", {
    method: "POST",
    body: { user: params },
  });
  storeTokens({ access_token: data.access_token, refresh_token: data.refresh_token });
  return data;
}

export async function login(email: string, password: string): Promise<AuthResponse> {
  const data = await apiFetch<AuthResponse>("/api/v1/auth/login", {
    method: "POST",
    body: { email, password },
  });
  storeTokens({ access_token: data.access_token, refresh_token: data.refresh_token });
  return data;
}

export async function refreshAccessToken(): Promise<string | null> {
  const tokens = getStoredTokens();
  if (!tokens?.refresh_token) return null;

  try {
    const data = await apiFetch<RefreshResponse>("/api/v1/auth/refresh", {
      method: "POST",
      body: { refresh_token: tokens.refresh_token },
    });
    storeTokens({ ...tokens, access_token: data.access_token });
    return data.access_token;
  } catch {
    clearTokens();
    return null;
  }
}

export async function fetchMe(): Promise<User | null> {
  try {
    const data = await apiFetch<MeResponse>("/api/v1/auth/me", { auth: true });
    return data.user;
  } catch {
    const newToken = await refreshAccessToken();
    if (!newToken) return null;
    try {
      const data = await apiFetch<MeResponse>("/api/v1/auth/me", { auth: true });
      return data.user;
    } catch {
      clearTokens();
      return null;
    }
  }
}

export async function fetchCharacter(): Promise<Character | null> {
  try {
    const data = await apiFetch<CharacterResponse>("/api/v1/character", { auth: true });
    return data.character;
  } catch {
    return null;
  }
}

export async function createCharacter(params: {
  name: string;
  race: string;
  character_class: string;
  strength: number;
  dexterity: number;
  constitution: number;
  intelligence: number;
  wisdom: number;
  charisma: number;
}): Promise<Character> {
  const data = await apiFetch<CharacterResponse>("/api/v1/character", {
    method: "POST",
    body: { character: params },
    auth: true,
  });
  return data.character;
}

export function logout(): void {
  clearTokens();
}
