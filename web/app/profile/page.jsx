"use client";

import { useState, useEffect, useCallback } from "react";
import { useSession } from "next-auth/react";
import { useRouter } from "next/navigation";

export default function ProfilePage() {
  const { data: session, update: updateSession } = useSession();
  const router = useRouter();
  const [name, setName] = useState("");
  const [role, setRole] = useState("");
  const [bio, setBio] = useState("");
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState(null);

  const isOnboarding = session?.user?.profileComplete === false;

  const fetchProfile = useCallback(async () => {
    const res = await fetch("/api/profile");
    if (res.ok) {
      const data = await res.json();
      setName(data.name || "");
      setRole(data.role || "");
      setBio(data.bio || "");
    }
    setLoading(false);
  }, []);

  useEffect(() => {
    if (session) fetchProfile();
  }, [session, fetchProfile]);

  async function handleSubmit(e) {
    e.preventDefault();
    setSaving(true);
    setMessage(null);

    const res = await fetch("/api/profile", {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name, role, bio }),
    });

    if (res.ok) {
      await updateSession();
      setMessage({ type: "success", text: "Profile saved." });
      if (isOnboarding) {
        setTimeout(() => router.push("/dashboard"), 500);
      }
    } else {
      const data = await res.json();
      setMessage({ type: "error", text: data.error || "Failed to save." });
    }
    setSaving(false);
  }

  if (loading) return <div style={{ color: "var(--text-3)", padding: 24 }}>Loading...</div>;

  return (
    <div style={{ maxWidth: 520 }}>
      <h1 style={{ fontSize: 22, fontWeight: 600, marginBottom: 8, letterSpacing: "-0.02em" }}>
        {isOnboarding ? "Welcome! Set up your profile" : "Edit Profile"}
      </h1>
      {isOnboarding && (
        <p style={{ color: "var(--text-2)", fontSize: 13, marginBottom: 24 }}>
          Tell us a bit about yourself to get started.
        </p>
      )}

      <form onSubmit={handleSubmit}>
        <label style={s.label}>
          Name <span style={{ color: "var(--red)" }}>*</span>
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            required
            placeholder="Your name"
            style={s.input}
          />
        </label>

        <label style={s.label}>
          Role
          <input
            type="text"
            value={role}
            onChange={(e) => setRole(e.target.value)}
            placeholder="e.g. Developer, Designer, Product Manager"
            style={s.input}
          />
        </label>

        <label style={s.label}>
          Bio
          <textarea
            value={bio}
            onChange={(e) => setBio(e.target.value)}
            placeholder="A short bio about yourself"
            rows={4}
            style={{ ...s.input, resize: "vertical" }}
          />
        </label>

        {message && (
          <div style={{
            padding: "8px 12px",
            marginBottom: 12,
            borderRadius: "var(--radius-sm)",
            fontSize: 13,
            background: message.type === "success" ? "var(--green-dim, #1a3a2a)" : "var(--red-dim, #3a1a1a)",
            color: message.type === "success" ? "var(--green, #4ade80)" : "var(--red, #f87171)",
            border: `1px solid ${message.type === "success" ? "var(--green, #4ade80)" : "var(--red, #f87171)"}`,
          }}>
            {message.text}
          </div>
        )}

        <button type="submit" disabled={saving || !name.trim()} style={s.btn}>
          {saving ? "Saving..." : isOnboarding ? "Complete Setup" : "Save Changes"}
        </button>
      </form>
    </div>
  );
}

const s = {
  label: {
    display: "block",
    marginBottom: 16,
    fontSize: 13,
    fontWeight: 500,
    color: "var(--text-1)",
  },
  input: {
    display: "block",
    width: "100%",
    marginTop: 6,
    background: "var(--bg-2)",
    border: "1px solid var(--border)",
    borderRadius: "var(--radius-sm)",
    padding: "8px 12px",
    fontSize: 13,
    color: "var(--text-0)",
    fontFamily: "var(--font)",
    outline: "none",
    boxSizing: "border-box",
  },
  btn: {
    padding: "10px 20px",
    borderRadius: "var(--radius-sm)",
    fontSize: 13,
    fontWeight: 500,
    cursor: "pointer",
    border: "1px solid var(--accent)",
    background: "var(--accent)",
    color: "white",
    fontFamily: "var(--font)",
  },
};
