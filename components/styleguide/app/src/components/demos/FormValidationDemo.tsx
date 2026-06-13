"use client";

import { useState } from "react";
import { Field, Label, Input, Description } from "@headlessui/react";

export function FormValidationDemo() {
  const [fields, setFields] = useState({
    email: "not-an-email",
    username: "jsmith",
    displayName: "Jane Smith",
    bio: "",
  });
  const set = (k: keyof typeof fields) =>
    (e: React.ChangeEvent<HTMLInputElement>) =>
      setFields((f) => ({ ...f, [k]: e.target.value }));

  const emailErr  = fields.email.length > 0 && !fields.email.includes("@");
  const userWarn  = fields.username === "jsmith";
  const nameOk    = fields.displayName.length > 2;

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-1)", maxWidth: 400 }}>
      <Field>
        <Label className="field-label">Email address</Label>
        <Input
          className={`field-input${emailErr ? " field-error" : ""}`}
          type="email"
          value={fields.email}
          onChange={set("email")}
        />
        {emailErr && (
          <Description className="field-hint field-error">✕ Enter a valid email address</Description>
        )}
      </Field>

      <Field>
        <Label className="field-label">Username</Label>
        <Input
          className={`field-input${userWarn ? " field-warning" : ""}`}
          value={fields.username}
          onChange={set("username")}
        />
        {userWarn && (
          <Description className="field-hint field-warning">⚠ Username is taken — try jsmith_2</Description>
        )}
      </Field>

      <Field>
        <Label className="field-label">Display name</Label>
        <Input
          className={`field-input${nameOk ? " field-success" : ""}`}
          value={fields.displayName}
          onChange={set("displayName")}
        />
        {nameOk && (
          <Description className="field-hint field-success">✓ Looks good</Description>
        )}
      </Field>

      <Field>
        <Label className="field-label">Bio</Label>
        <Input
          className="field-input"
          value={fields.bio}
          onChange={set("bio")}
          placeholder="Optional"
        />
        <Description className="field-hint">Max 160 characters</Description>
      </Field>
    </div>
  );
}
