"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { api } from "@/lib/api";
import { useOrg, useOrgId } from "@/context/org";
import { toast } from "sonner";
import { DataTable } from "@/components/console/DataTable";
import { membersDescriptor, type OrgMember } from "@/lib/console/descriptors/members";

// Members table (epic 8920d294 / ticket 7bddfd70). The LIST renders via the console
// DataTable primitive; the RBAC-gated row actions (assign-role @ admin, remove @ lead)
// are diego's descriptor gates (members.ts) + the action UI below (ava's data-UI lane).
//
// effectiveRole: for the members of ONE org, the caller's effective role is uniform =
// myRole (from the org list) — so this view does NOT need marcus's per-row echo
// (16dc3df2); that echo is for lists where the caller's role VARIES per row (orgs).
// The descriptor's canEdit/canDelete gate visibility off ctx.effectiveRole; the server
// guard is the sole deny-closed boundary (gating here is advisory).

// RBAC role set for assignment (owner is not assignable; legacy 'editor' maps to
// 'member' on display via roles.ts). priya seq641.
const ASSIGNABLE_ROLES = ["viewer", "member", "lead", "admin"];

function RolePickerModal({
  orgId,
  member,
  onClose,
  onSaved,
}: {
  orgId: string;
  member: OrgMember;
  onClose: () => void;
  onSaved: () => void;
}) {
  const [role, setRole] = useState(member.role);
  const [saving, setSaving] = useState(false);

  async function save() {
    setSaving(true);
    try {
      await api.updateMemberRole(orgId, member.id, role);
      toast.success("Role updated");
      onSaved();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to update role");
      setSaving(false);
    }
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-card modal-card--sm" onClick={(e) => e.stopPropagation()}>
        <h2 className="modal-title">Assign role</h2>
        <p className="modal-body">
          Set the role for <strong>{member.display_name || member.user_name || member.email}</strong>.
        </p>
        <div className="sg-field">
          <label htmlFor="role-pick">Role</label>
          <select id="role-pick" value={role} onChange={(e) => setRole(e.target.value)}>
            {ASSIGNABLE_ROLES.map((r) => (
              <option key={r} value={r}>
                {r}
              </option>
            ))}
          </select>
        </div>
        <div className="modal-actions">
          <button type="button" className="sg-btn sg-btn--outline" onClick={onClose}>
            Cancel
          </button>
          <button type="button" className="sg-btn sg-btn--black" onClick={save} disabled={saving || role === member.role}>
            {saving ? "Saving…" : "Save"}
          </button>
        </div>
      </div>
    </div>
  );
}

export default function MembersPage() {
  const { orgId, slug, loading: orgLoading } = useOrgId();
  const { organizations } = useOrg();
  const router = useRouter();
  const [inviteEmail, setInviteEmail] = useState("");
  const [inviteRole, setInviteRole] = useState("viewer");
  const [inviting, setInviting] = useState(false);
  const [roleTarget, setRoleTarget] = useState<OrgMember | null>(null);
  const [reloadKey, setReloadKey] = useState(0);
  const reload = () => setReloadKey((k) => k + 1);

  // The caller's effective role in this org (advisory gate for the invite + row actions).
  const myRole = organizations.find((o) => o.id === orgId)?.role;
  const isAdmin = myRole === "admin" || myRole === "owner";

  async function handleInvite(e: React.FormEvent) {
    e.preventDefault();
    if (!inviteEmail || !orgId) return;
    setInviting(true);
    try {
      await api.addMember(orgId, inviteEmail, inviteRole);
      setInviteEmail("");
      reload();
      toast.success("Member added");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to add member");
    } finally {
      setInviting(false);
    }
  }

  async function handleRemove(member: OrgMember) {
    if (!orgId || !confirm(`Remove ${member.display_name || member.user_name || member.email}?`)) return;
    try {
      await api.removeMember(orgId, member.id);
      toast.success("Member removed");
      reload();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to remove member");
    }
  }

  return (
    <div className="content">
      <main>
        <h1 className="sg-page-title">Members</h1>
        <p className="sg-page-intro">
          People with access to this organization.
          {isAdmin ? " As an admin you can invite members and change roles." : " Only org admins can change membership."}
        </p>

        {isAdmin && (
          <form onSubmit={handleInvite} className="button-row" style={{ marginBottom: 24, alignItems: "flex-end" }}>
            <div className="sg-field" style={{ flex: 1 }}>
              <label htmlFor="invite-email">Invite by email</label>
              <input
                id="invite-email"
                type="email"
                placeholder="person@example.com"
                value={inviteEmail}
                onChange={(e) => setInviteEmail(e.target.value)}
              />
            </div>
            <div className="sg-field">
              <label htmlFor="invite-role">Role</label>
              <select id="invite-role" value={inviteRole} onChange={(e) => setInviteRole(e.target.value)}>
                {ASSIGNABLE_ROLES.map((r) => (
                  <option key={r} value={r}>
                    {r}
                  </option>
                ))}
              </select>
            </div>
            <button type="submit" className="sg-btn sg-btn--black sg-btn--sm" disabled={inviting}>
              {inviting ? "Adding…" : "Add"}
            </button>
          </form>
        )}

        {!orgId ? (
          <p className="sg-page-intro">{orgLoading ? "Loading…" : "Select an organization to view its members."}</p>
        ) : (
          <DataTable
            descriptor={membersDescriptor}
            ctx={{ orgId, orgSlug: slug, effectiveRole: myRole }}
            refreshKey={reloadKey}
            onOpenRow={(m) => router.push(`/app/${slug}/members/${m.id}`)}
            onEditRow={(m) => setRoleTarget(m)}
            onDeleteRow={handleRemove}
          />
        )}
      </main>

      {roleTarget && orgId && (
        <RolePickerModal
          orgId={orgId}
          member={roleTarget}
          onClose={() => setRoleTarget(null)}
          onSaved={() => {
            setRoleTarget(null);
            reload();
          }}
        />
      )}
    </div>
  );
}
