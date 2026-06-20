"use client";

import { useState, useEffect } from "react";
import { useAuth } from "@/context/auth";
import { api, SELF_ASSIGNABLE_ROLES } from "@/lib/api";
import { toast } from "sonner";

const ROLE_LABELS: Record<string, string> = {
  user: "User",
  other: "Other",
};

export default function ProfilePage() {
  const { user } = useAuth();
  const [userName, setUserName] = useState("");
  const [email, setEmail] = useState("");
  const [role, setRole] = useState("user");
  const [bio, setBio] = useState("");
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (user) {
      setUserName(user.user_name || "");
      setEmail(user.email || "");
      setRole(user.role && SELF_ASSIGNABLE_ROLES.includes(user.role as never) ? user.role : "user");
      setBio(user.bio || "");
    }
  }, [user]);

  async function handleProfileUpdate(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    try {
      const payload: { user_name: string; email: string; bio: string; role?: string } = {
        user_name: userName,
        email,
        bio,
      };
      // Only submit role when it's a self-assignable value. A privileged role
      // set by an admin stays selected/disabled in the UI; we must not echo it
      // back, or the backend's self-escalation guard would 422 the whole save.
      if (SELF_ASSIGNABLE_ROLES.includes(role as never)) {
        payload.role = role;
      }
      await api.updateProfile(payload);
      toast.success("Profile updated");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Update failed");
    } finally {
      setSaving(false);
    }
  }

  if (!user) return null;

  // A self-assignable role list that still includes the user's current role,
  // even if it's a privileged one set by an admin (shown disabled so it isn't
  // silently downgraded on save).
  const roleOptions = SELF_ASSIGNABLE_ROLES.includes(role as never)
    ? [...SELF_ASSIGNABLE_ROLES]
    : [role, ...SELF_ASSIGNABLE_ROLES];

  return (
    <div className="content narrow">
      <main>
        <h1 className="sg-page-title">Profile</h1>
        <p className="sg-page-intro">Update your name, role, and bio.</p>

        <form onSubmit={handleProfileUpdate}>
          <div className="sg-field">
            <label htmlFor="profile-name">Name</label>
            <input
              id="profile-name"
              type="text"
              value={userName}
              onChange={(e) => setUserName(e.target.value)}
              placeholder="Your display name"
            />
          </div>

          <div className="sg-field">
            <label htmlFor="profile-email">Email</label>
            <input
              id="profile-email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
          </div>

          <div className="sg-field">
            <label htmlFor="profile-role">Role</label>
            <select
              id="profile-role"
              value={role}
              onChange={(e) => setRole(e.target.value)}
            >
              {roleOptions.map((r) => (
                <option
                  key={r}
                  value={r}
                  disabled={!SELF_ASSIGNABLE_ROLES.includes(r as never)}
                >
                  {ROLE_LABELS[r] ?? r.charAt(0).toUpperCase() + r.slice(1)}
                  {!SELF_ASSIGNABLE_ROLES.includes(r as never) ? " (admin-assigned)" : ""}
                </option>
              ))}
            </select>
            <span className="sg-field__hint">
              Elevated roles are assigned by an administrator.
            </span>
          </div>

          <div className="sg-field">
            <label htmlFor="profile-bio">Bio</label>
            <textarea
              id="profile-bio"
              value={bio}
              onChange={(e) => setBio(e.target.value)}
              placeholder="A short bio about yourself"
              rows={4}
            />
          </div>

          <div className="button-row">
            <button type="submit" disabled={saving} className="sg-btn sg-btn--black">
              {saving ? "Saving…" : "Save Profile"}
            </button>
            <button type="button" className="sg-btn sg-btn--outline" onClick={() => history.back()}>
              Cancel
            </button>
          </div>
        </form>
      </main>
    </div>
  );
}
