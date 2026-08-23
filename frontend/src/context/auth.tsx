"use client";

import { createContext, useContext, useEffect, useState, useCallback } from "react";
import { api, type Organization } from "@/lib/api";
import { analytics } from "@/lib/analytics";
import { authCookieClearSuffix, authCookieSetSuffix } from "@/lib/auth-redirect";

interface User {
  id: string;
  email: string;
  user_name?: string;
  handle?: string;
  role?: string;
  bio?: string;
  status?: string;
  verified?: boolean;
}

interface AuthContextType {
  user: User | null;
  loading: boolean;
  organizations: Organization[];
  login: (email: string, password: string) => Promise<void>;
  requestMagicLink: (email: string) => Promise<{ message: string; dev_link?: string }>;
  loginWithMagicLink: (token: string) => Promise<void>;
  requestOtpLogin: (email: string) => Promise<{ message: string; dev_code?: string }>;
  verifyOtpLogin: (email: string, code: string) => Promise<void>;
  ssoExchange: (code: string) => Promise<void>;
  ssoRegister: (payload: { token: string; first: string; last: string; bio: string }) => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | null>(null);

function setAuthCookie(token: string | null) {
  if (typeof document === "undefined") return;
  if (token) {
    document.cookie = `access_token=${token}${authCookieSetSuffix()}`;
  } else {
    document.cookie = `access_token=${authCookieClearSuffix()}`;
  }
}

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [organizations, setOrganizations] = useState<Organization[]>([]);

  const loadUser = useCallback(async () => {
    const token = localStorage.getItem("access_token");
    if (!token) {
      setLoading(false);
      return;
    }

    setAuthCookie(token);

    try {
      const { user } = await api.me();
      setUser(user);
      analytics.identify({ id: user.id, email: user.email });
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
    setOrganizations(res.organizations ?? []);
    analytics.identify({ id: res.user.id, email: res.user.email });
    analytics.trackEvent({ name: "login", properties: { method: "password" } });
  }

  async function requestMagicLink(email: string) {
    return api.requestMagicLink(email);
  }

  async function loginWithMagicLink(token: string) {
    const res = await api.verifyMagicLink(token);
    localStorage.setItem("access_token", res.access_token);
    localStorage.setItem("refresh_token", res.refresh_token);
    setAuthCookie(res.access_token);
    setUser(res.user);
    setOrganizations(res.organizations ?? []);
    analytics.identify({ id: res.user.id, email: res.user.email });
    analytics.trackEvent({ name: "login", properties: { method: "magic_link" } });
  }

  async function requestOtpLogin(email: string) {
    return api.requestOtpLogin(email);
  }

  async function verifyOtpLogin(email: string, code: string) {
    const res = await api.verifyOtpLogin(email, code);
    localStorage.setItem("access_token", res.access_token);
    localStorage.setItem("refresh_token", res.refresh_token);
    setAuthCookie(res.access_token);
    setUser(res.user);
    setOrganizations(res.organizations ?? []);
    analytics.identify({ id: res.user.id, email: res.user.email });
    analytics.trackEvent({ name: "login", properties: { method: "otp" } });
  }

  async function ssoExchange(code: string) {
    const res = await api.ssoExchange(code);
    localStorage.setItem("access_token", res.access_token);
    localStorage.setItem("refresh_token", res.refresh_token);
    setAuthCookie(res.access_token);
    setUser(res.user);
    setOrganizations(res.organizations ?? []);
    analytics.identify({ id: res.user.id, email: res.user.email });
    analytics.trackEvent({ name: "login", properties: { method: "sso" } });
  }

  async function ssoRegister(payload: { token: string; first: string; last: string; bio: string }) {
    const res = await api.ssoRegister(payload);
    localStorage.setItem("access_token", res.access_token);
    localStorage.setItem("refresh_token", res.refresh_token);
    setAuthCookie(res.access_token);
    setUser(res.user);
    setOrganizations(res.organizations ?? []);
    analytics.identify({ id: res.user.id, email: res.user.email });
    analytics.trackEvent({ name: "login", properties: { method: "sso_register" } });
  }

  function logout() {
    localStorage.removeItem("access_token");
    localStorage.removeItem("refresh_token");
    setAuthCookie(null);
    setUser(null);
    setOrganizations([]);
    analytics.reset();
  }

  return (
    <AuthContext.Provider value={{ user, loading, organizations, login, requestMagicLink, loginWithMagicLink, requestOtpLogin, verifyOtpLogin, ssoExchange, ssoRegister, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used within AuthProvider");
  return ctx;
}
