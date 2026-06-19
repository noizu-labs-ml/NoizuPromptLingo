"use client";

import { useState, useEffect } from "react";
import { useAuth } from "@/context/auth";
import { api } from "@/lib/api";
import { toast } from "sonner";

export default function ProfilePage() {
  const { user } = useAuth();
  const [userName, setUserName] = useState("");
  const [email, setEmail] = useState("");
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (user) {
      setUserName(user.user_name || "");
      setEmail(user.email || "");
    }
  }, [user]);

  async function handleProfileUpdate(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    try {
      await api.updateProfile({ user_name: userName, email });
      toast.success("Profile updated");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Update failed");
    } finally {
      setSaving(false);
    }
  }

  async function handlePasswordChange(e: React.FormEvent) {
    e.preventDefault();
    if (!currentPassword || !newPassword) return;
    setSaving(true);
    try {
      await api.updateProfile({ current_password: currentPassword, new_password: newPassword });
      setCurrentPassword("");
      setNewPassword("");
      toast.success("Password updated");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Password change failed");
    } finally {
      setSaving(false);
    }
  }

  if (!user) return null;

  return (
    <div style={{ maxWidth: 480, margin: "40px auto", padding: "0 24px" }}>
      <h1 style={{ fontSize: 24, marginBottom: 24 }}>Profile</h1>

      <form onSubmit={handleProfileUpdate} style={{ marginBottom: 32 }}>
        <h2 style={{ fontSize: 18, marginBottom: 16 }}>Account</h2>
        <label style={{ display: "block", marginBottom: 12 }}>
          <span style={{ display: "block", fontSize: 14, marginBottom: 4 }}>Username</span>
          <input type="text" value={userName} onChange={(e) => setUserName(e.target.value)} style={{ width: "100%", padding: 8, border: "1px solid #ccc", borderRadius: 4 }} />
        </label>
        <label style={{ display: "block", marginBottom: 12 }}>
          <span style={{ display: "block", fontSize: 14, marginBottom: 4 }}>Email</span>
          <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} style={{ width: "100%", padding: 8, border: "1px solid #ccc", borderRadius: 4 }} />
        </label>
        <button type="submit" disabled={saving} style={{ padding: "8px 16px", background: "#000", color: "#fff", border: "none", borderRadius: 4, cursor: "pointer" }}>
          {saving ? "Saving..." : "Save Profile"}
        </button>
      </form>

      <form onSubmit={handlePasswordChange}>
        <h2 style={{ fontSize: 18, marginBottom: 16 }}>Change Password</h2>
        <label style={{ display: "block", marginBottom: 12 }}>
          <span style={{ display: "block", fontSize: 14, marginBottom: 4 }}>Current Password</span>
          <input type="password" value={currentPassword} onChange={(e) => setCurrentPassword(e.target.value)} style={{ width: "100%", padding: 8, border: "1px solid #ccc", borderRadius: 4 }} />
        </label>
        <label style={{ display: "block", marginBottom: 12 }}>
          <span style={{ display: "block", fontSize: 14, marginBottom: 4 }}>New Password</span>
          <input type="password" value={newPassword} onChange={(e) => setNewPassword(e.target.value)} style={{ width: "100%", padding: 8, border: "1px solid #ccc", borderRadius: 4 }} />
        </label>
        <button type="submit" disabled={saving || !currentPassword || !newPassword} style={{ padding: "8px 16px", background: "#000", color: "#fff", border: "none", borderRadius: 4, cursor: "pointer" }}>
          {saving ? "Saving..." : "Change Password"}
        </button>
      </form>
    </div>
  );
}
