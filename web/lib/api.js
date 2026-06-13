const BACKEND_URL = process.env.BACKEND_URL || "http://localhost:4040";

export async function fetchBackend(path, opts = {}) {
  const isServer = typeof window === "undefined";
  const base = isServer ? BACKEND_URL : "";
  const url = `${base}${path}`;
  const res = await fetch(url, {
    ...opts,
    headers: { "Content-Type": "application/json", ...opts.headers },
    next: { revalidate: opts.revalidate ?? 10 },
  });
  if (!res.ok) throw new Error(`API ${res.status}: ${url}`);
  return res.json();
}

export async function fetchStats() {
  return fetchBackend("/api/dashboard/stats");
}

export async function fetchActivity(limit = 20) {
  return fetchBackend(`/api/dashboard/activity?limit=${limit}`);
}

export async function fetchProjects() {
  return fetchBackend("/api/projects");
}

export async function fetchProject(id) {
  return fetchBackend(`/api/projects/${id}`);
}

export async function fetchAssets(params = {}) {
  const qs = new URLSearchParams(params).toString();
  return fetchBackend(`/api/assets${qs ? `?${qs}` : ""}`);
}

export async function fetchAsset(id) {
  return fetchBackend(`/api/assets/${id}`);
}

export async function fetchAssetHistory(id) {
  return fetchBackend(`/api/assets/${id}/history`);
}

export async function fetchTickets(params = {}) {
  const qs = new URLSearchParams(params).toString();
  return fetchBackend(`/api/tickets${qs ? `?${qs}` : ""}`);
}

export async function fetchTicket(id) {
  return fetchBackend(`/api/tickets/${id}`);
}

export async function fetchChatRooms() {
  return fetchBackend("/api/chat/rooms");
}

export async function fetchMessages(roomId) {
  return fetchBackend(`/api/chat/rooms/${roomId}/messages`);
}

export async function fetchReviews(params = {}) {
  const qs = new URLSearchParams(params).toString();
  return fetchBackend(`/api/reviews${qs ? `?${qs}` : ""}`);
}

export async function fetchReview(id) {
  return fetchBackend(`/api/reviews/${id}`);
}
