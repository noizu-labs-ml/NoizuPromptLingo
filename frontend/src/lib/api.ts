const API_URL = process.env.NEXT_PUBLIC_API_URL || "";

export interface User {
  id: string;
  email: string;
  user_name?: string;
  handle?: string;
  status?: string;
  verified?: boolean;
}

export interface Organization {
  id: string;
  slug: string;
  name: string;
  role?: string;
}

interface AuthResponse {
  user: User;
  access_token: string;
  refresh_token: string;
  organizations?: Organization[];
}

interface MagicLinkResponse {
  message: string;
  dev_link?: string;
}

interface OtpResponse {
  message: string;
  dev_code?: string;
}

interface PasswordResetResponse {
  message: string;
  dev_code?: string;
}

let refreshPromise: Promise<string | null> | null = null;

async function attemptRefresh(): Promise<string | null> {
  const refreshToken = typeof window !== "undefined" ? localStorage.getItem("refresh_token") : null;
  if (!refreshToken) return null;

  try {
    const res = await fetch(`${API_URL}/api/v1/auth/refresh`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refresh_token: refreshToken }),
    });

    if (!res.ok) return null;

    const data = await res.json();
    if (data.access_token) {
      localStorage.setItem("access_token", data.access_token);
      if (data.refresh_token) {
        localStorage.setItem("refresh_token", data.refresh_token);
      }
      // Sync cookie for middleware
      document.cookie = `access_token=${data.access_token}; path=/; max-age=${60 * 60}; SameSite=Lax`;
      return data.access_token;
    }
    return null;
  } catch {
    return null;
  }
}

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  const token = typeof window !== "undefined" ? localStorage.getItem("access_token") : null;

  const res = await fetch(`${API_URL}${path}`, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...options.headers,
    },
  });

  if (res.status === 401 && token && !path.includes("/auth/refresh")) {
    // Deduplicate concurrent refresh attempts
    if (!refreshPromise) {
      refreshPromise = attemptRefresh().finally(() => { refreshPromise = null; });
    }

    const newToken = await refreshPromise;
    if (newToken) {
      // Retry the original request with the new token
      const retryRes = await fetch(`${API_URL}${path}`, {
        ...options,
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${newToken}`,
          ...options.headers,
        },
      });

      if (!retryRes.ok) {
        const body = await retryRes.json().catch(() => ({}));
        throw new Error(body.error || body.errors?.email?.[0] || `Request failed: ${retryRes.status}`);
      }

      return retryRes.json();
    }

    // Refresh failed — clear tokens and redirect to login
    localStorage.removeItem("access_token");
    localStorage.removeItem("refresh_token");
    document.cookie = "access_token=; path=/; max-age=0; SameSite=Lax";
    if (typeof window !== "undefined") {
      window.location.href = "/login";
    }
  }

  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body.error || body.errors?.email?.[0] || `Request failed: ${res.status}`);
  }

  return res.json();
}

export const api = {
  register(email: string, password: string, inviteToken: string) {
    return request<AuthResponse>("/api/v1/auth/register", {
      method: "POST",
      body: JSON.stringify({ user: { email, password }, invite_token: inviteToken }),
    });
  },

  login(email: string, password: string) {
    return request<AuthResponse>("/api/v1/auth/login", {
      method: "POST",
      body: JSON.stringify({ email, password }),
    });
  },

  requestMagicLink(email: string) {
    return request<MagicLinkResponse>("/api/v1/auth/magic-link", {
      method: "POST",
      body: JSON.stringify({ email }),
    });
  },

  verifyMagicLink(token: string) {
    return request<AuthResponse>("/api/v1/auth/magic-link/verify", {
      method: "POST",
      body: JSON.stringify({ token }),
    });
  },

  requestOtpLogin(email: string) {
    return request<OtpResponse>("/api/v1/auth/otp-login", {
      method: "POST",
      body: JSON.stringify({ email }),
    });
  },

  verifyOtpLogin(email: string, code: string) {
    return request<AuthResponse>("/api/v1/auth/otp-login/verify", {
      method: "POST",
      body: JSON.stringify({ email, code }),
    });
  },

  requestPasswordReset(email: string) {
    return request<PasswordResetResponse>("/api/v1/auth/password-reset", {
      method: "POST",
      body: JSON.stringify({ email }),
    });
  },

  verifyPasswordReset(email: string, code: string, newPassword: string) {
    return request<{ message: string }>("/api/v1/auth/password-reset/verify", {
      method: "POST",
      body: JSON.stringify({ email, code, new_password: newPassword }),
    });
  },

  refresh(refreshToken: string) {
    return request<{ access_token: string; refresh_token?: string }>("/api/v1/auth/refresh", {
      method: "POST",
      body: JSON.stringify({ refresh_token: refreshToken }),
    });
  },

  ssoProviders() {
    return request<{ providers: string[] }>("/api/v1/auth/sso/providers");
  },

  ssoExchange(code: string) {
    return request<AuthResponse>("/api/v1/auth/sso/exchange", {
      method: "POST",
      body: JSON.stringify({ code }),
    });
  },

  me() {
    return request<{ user: User }>("/api/v1/auth/me");
  },

  getProfile() {
    return request<{ user: User }>("/api/v1/users/me");
  },

  updateProfile(data: { user_name?: string; email?: string; current_password?: string; new_password?: string }) {
    return request<{ user: User }>("/api/v1/users/me", {
      method: "PATCH",
      body: JSON.stringify({ user: data }),
    });
  },

  listOrganizations() {
    return request<{ organizations: Organization[] }>("/api/v1/organizations");
  },

  createOrganization(slug: string, name: string) {
    return request<{ organization: Organization }>("/api/v1/organizations", {
      method: "POST",
      body: JSON.stringify({ organization: { slug, name } }),
    });
  },

  getOrganization(id: string) {
    return request<{ organization: Organization }>(`/api/v1/organizations/${id}`);
  },

  sendVerificationEmail() {
    return request<{ message: string; dev_link?: string }>("/api/v1/auth/verify-email", {
      method: "POST",
    });
  },

  verifyEmail(token: string) {
    return request<{ message: string }>("/api/v1/auth/verify-email/confirm", {
      method: "POST",
      body: JSON.stringify({ token }),
    });
  },

  listMembers(orgId: string) {
    return request<{ members: Array<{ id: string; user_id: string; email: string; user_name: string; role: string; joined_at: string }> }>(`/api/v1/organizations/${orgId}/members`);
  },

  addMember(orgId: string, email: string, role: string) {
    return request<{ members: Array<{ id: string; user_id: string; email: string; user_name: string; role: string; joined_at: string }> }>(`/api/v1/organizations/${orgId}/members`, {
      method: "POST",
      body: JSON.stringify({ email, role }),
    });
  },

  updateMemberRole(orgId: string, memberId: string, role: string) {
    return request<{ members: Array<{ id: string; user_id: string; email: string; user_name: string; role: string; joined_at: string }> }>(`/api/v1/organizations/${orgId}/members/${memberId}`, {
      method: "PATCH",
      body: JSON.stringify({ role }),
    });
  },

  removeMember(orgId: string, memberId: string) {
    return request<{ message: string }>(`/api/v1/organizations/${orgId}/members/${memberId}`, {
      method: "DELETE",
    });
  },

  presignUpload(filename: string, contentType: string) {
    return request<{ upload_url: string; key: string }>("/api/v1/media/presign", {
      method: "POST",
      body: JSON.stringify({ filename, content_type: contentType }),
    });
  },

  getDownloadUrl(key: string) {
    return request<{ download_url: string }>("/api/v1/media/download", {
      method: "POST",
      body: JSON.stringify({ key }),
    });
  },

  adminListUsers(page = 1, perPage = 50) {
    return request<{ users: Array<{ id: string; email: string; user_name: string; status: string; verified: boolean; admin: boolean; created_at: string }>; total: number; page: number; per_page: number }>(`/api/v1/admin/users?page=${page}&per_page=${perPage}`);
  },

  adminShowUser(id: string) {
    return request<{ user: User & { admin: boolean; created_at: string } }>(`/api/v1/admin/users/${id}`);
  },

  adminListOrganizations(page = 1, perPage = 50) {
    return request<{ organizations: Array<{ id: string; slug: string; name: string; created_at: string }>; total: number; page: number; per_page: number }>(`/api/v1/admin/organizations?page=${page}&per_page=${perPage}`);
  },

  adminShowOrganization(id: string) {
    return request<{ organization: { id: string; slug: string; name: string; created_at: string }; members: Array<{ id: string; email: string; role: string }> }>(`/api/v1/admin/organizations/${id}`);
  },

  getFeatureFlags() {
    return request<{ features: string[] }>("/api/v1/config/features");
  },
};
