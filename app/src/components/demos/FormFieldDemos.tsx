"use client";

import { useState } from "react";
import {
  Field,
  Fieldset,
  Label,
  Legend,
  Input,
  Select,
  Textarea,
  Description,
} from "@headlessui/react";

// ─── TextInputDemo ───

export function TextInputDemo() {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("not-an-email");
  const [username, setUsername] = useState("jsmith_42");

  const emailErr = email && !email.includes("@");

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-2)", maxWidth: 360 }}>
      <Field>
        <Label className="field-label">Full name</Label>
        <Input
          className="field-input"
          value={name}
          onChange={(e) => setName(e.target.value)}
          placeholder="e.g. Jane Smith"
        />
        <Description className="field-hint">Appears on your public profile</Description>
      </Field>

      <Field>
        <Label className="field-label">Email address</Label>
        <Input
          className={`field-input${emailErr ? " field-error" : ""}`}
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
        />
        {emailErr ? (
          <Description className="field-hint field-error">✕ Enter a valid email address</Description>
        ) : (
          <Description className="field-hint">We&apos;ll never share your email</Description>
        )}
      </Field>

      <Field>
        <Label className="field-label">Username</Label>
        <Input
          className="field-input field-success"
          value={username}
          onChange={(e) => setUsername(e.target.value)}
        />
        <Description className="field-hint field-success">✓ Available</Description>
      </Field>
    </div>
  );
}

// ─── SelectDemo ───

export function SelectDemo() {
  const [country, setCountry] = useState("us");
  const [plan, setPlan] = useState("");

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-2)", maxWidth: 360 }}>
      <Field>
        <Label className="field-label">Country</Label>
        <Select
          className="field-select"
          value={country}
          onChange={(e) => setCountry(e.target.value)}
        >
          <option value="">Select a country…</option>
          <option value="us">United States</option>
          <option value="ca">Canada</option>
          <option value="gb">United Kingdom</option>
          <option value="au">Australia</option>
        </Select>
      </Field>

      <Field>
        <Label className="field-label">Subscription plan</Label>
        <Select
          className={`field-select${!plan ? " field-error" : ""}`}
          value={plan}
          onChange={(e) => setPlan(e.target.value)}
        >
          <option value="">Choose a plan…</option>
          <option value="free">Free</option>
          <option value="pro">Pro — $12/mo</option>
          <option value="team">Team — $40/mo</option>
        </Select>
        {!plan && (
          <Description className="field-hint field-error">✕ Selection required</Description>
        )}
      </Field>
    </div>
  );
}

// ─── TextareaDemo ───

const MAX = 160;

export function TextareaDemo() {
  const [bio, setBio] = useState(
    "Space Grotesk brings geometric precision without sacrificing warmth. Paired with IBM Plex Mono for code."
  );
  const [notes, setNotes] = useState("");

  const remaining = MAX - bio.length;
  const countCls = remaining < 0 ? "field-error" : remaining < 20 ? "field-warning" : "";

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-2)", maxWidth: 400 }}>
      <Field>
        <Label className="field-label">Bio</Label>
        <Textarea
          className={`field-textarea${remaining < 0 ? " field-error" : ""}`}
          value={bio}
          onChange={(e) => setBio(e.target.value)}
          rows={3}
        />
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <Description className="field-hint">Displayed on your public profile</Description>
          <span className={`field-char-count${countCls ? ` ${countCls}` : ""}`}>
            {bio.length}/{MAX}
          </span>
        </div>
      </Field>

      <Field>
        <Label className="field-label">Notes</Label>
        <Textarea
          className="field-textarea"
          value={notes}
          onChange={(e) => setNotes(e.target.value)}
          placeholder="Optional notes…"
          rows={2}
        />
        <Description className="field-hint">Visible only to you</Description>
      </Field>
    </div>
  );
}

// ─── FormLayoutDemo ───

export function FormLayoutDemo() {
  const [form, setForm] = useState({ first: "", last: "", email: "", role: "designer" });
  const set = (k: keyof typeof form) => (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) =>
    setForm((f) => ({ ...f, [k]: e.target.value }));

  return (
    <Fieldset style={{ display: "flex", flexDirection: "column", gap: "var(--space-2)", maxWidth: 440 }}>
      <Legend className="field-section-heading">Account details</Legend>

      <div className="field-row">
        <Field>
          <Label className="field-label">First name</Label>
          <Input className="field-input" value={form.first} onChange={set("first")} placeholder="Jane" />
        </Field>
        <Field>
          <Label className="field-label">Last name</Label>
          <Input className="field-input" value={form.last} onChange={set("last")} placeholder="Smith" />
        </Field>
      </div>

      <Field>
        <Label className="field-label">Email</Label>
        <Input className="field-input" type="email" value={form.email} onChange={set("email")} placeholder="jane@example.com" />
      </Field>

      <div className="field-section-heading" style={{ marginTop: "var(--space-1)" }}>Preferences</div>

      <Field>
        <Label className="field-label">Role</Label>
        <Select className="field-select" value={form.role} onChange={(e) => setForm((f) => ({ ...f, role: e.target.value }))}>
          <option value="designer">Designer</option>
          <option value="engineer">Engineer</option>
          <option value="pm">Product Manager</option>
        </Select>
      </Field>

      <div className="form-actions">
        <button className="btn secondary" type="button">Cancel</button>
        <button className="btn primary" type="submit">Save changes</button>
      </div>
    </Fieldset>
  );
}

// ─── ValidationDemo ───

export function ValidationDemo() {
  const [fields, setFields] = useState({
    email: "not-an-email",
    password: "short",
    username: "jsmith",
    displayName: "Jane Smith",
  });
  const set = (k: keyof typeof fields) => (e: React.ChangeEvent<HTMLInputElement>) =>
    setFields((f) => ({ ...f, [k]: e.target.value }));

  const emailErr   = fields.email && !fields.email.includes("@");
  const passErr    = fields.password.length > 0 && fields.password.length < 8;
  const userWarn   = fields.username === "jsmith";
  const nameOk     = fields.displayName.length > 2;

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-1)", maxWidth: 400 }}>
      <div className="alert error" style={{ marginBottom: "var(--space-half)" }}>
        <div className="alert-title">Errors need attention</div>
        <div className="alert-body">Fix the highlighted fields before submitting.</div>
      </div>

      <Field>
        <Label className="field-label">Email address</Label>
        <Input
          className={`field-input${emailErr ? " field-error" : ""}`}
          type="email"
          value={fields.email}
          onChange={set("email")}
        />
        {emailErr && <Description className="field-hint field-error">✕ Enter a valid email address</Description>}
      </Field>

      <Field>
        <Label className="field-label">Password</Label>
        <Input
          className={`field-input${passErr ? " field-error" : ""}`}
          type="password"
          value={fields.password}
          onChange={set("password")}
        />
        {passErr && <Description className="field-hint field-error">✕ Must be at least 8 characters</Description>}
      </Field>

      <Field>
        <Label className="field-label">Username</Label>
        <Input
          className={`field-input${userWarn ? " field-warning" : ""}`}
          value={fields.username}
          onChange={set("username")}
        />
        {userWarn && <Description className="field-hint field-warning">⚠ Username is taken — try jsmith_2</Description>}
      </Field>

      <Field>
        <Label className="field-label">Display name</Label>
        <Input
          className={`field-input${nameOk ? " field-success" : ""}`}
          value={fields.displayName}
          onChange={set("displayName")}
        />
        {nameOk && <Description className="field-hint field-success">✓ Looks good</Description>}
      </Field>
    </div>
  );
}
