"use client";

import { createContext, useContext, useEffect, useState, useCallback } from "react";
import { api } from "@/lib/api";

interface User {
  id: string;
  email: string;
  user_name?: string;
  handle?: string;
  status?: string;
  verified?: boolean;
}

interface AuthContextType {
  user: User | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  register: (email: string, password: string) => Promise<void>;
  ssoExchange: (code: string) => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | null>(null);

function setAuthCookie(token: string | null) {
  if (typeof document === "undefined") return;
  if (token) {
    document.cookie = `access_token=${token}; path=/; max-age=${60 * 60}; SameSite=Lax`;
  } else {
    document.cookie = "access_token=; path=/; max-age=0; SameSite=Lax";
  }
}

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  const loadUser = useCallback(async () => {
    const token = localStorage.getItem("access_token");
    if (!token) {
      setLoading(false);
      return;
    }

    try {
      const { user } = await api.me();
      setUser(user);
    } catch {
      localStorage.removeItem("access_token");
      localStorage.removeItem("refresh_token");
      setAuthCookie(null);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadUser();
  }, [loadUser]);

  async function login(email: string, password: string) {
    const res = await api.login(email, password);
    localStorage.setItem("access_token", res.access_token);
    localStorage.setItem("refresh_token", res.refresh_token);
    setAuthCookie(res.access_token);
    setUser(res.user);
  }

  async function register(email: string, password: string) {
    const res = await api.register(email, password);
    localStorage.setItem("access_token", res.access_token);
    localStorage.setItem("refresh_token", res.refresh_token);
    setAuthCookie(res.access_token);
    setUser(res.user);
  }

  async function ssoExchange(code: string) {
    const res = await api.ssoExchange(code);
    localStorage.setItem("access_token", res.access_token);
    localStorage.setItem("refresh_token", res.refresh_token);
    setAuthCookie(res.access_token);
    setUser(res.user);
  }

  function logout() {
    localStorage.removeItem("access_token");
    localStorage.removeItem("refresh_token");
    setAuthCookie(null);
    setUser(null);
  }

  return (
    <AuthContext.Provider value={{ user, loading, login, register, ssoExchange, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used within AuthProvider");
  return ctx;
}
