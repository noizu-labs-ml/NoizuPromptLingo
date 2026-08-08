import Link from "next/link";
import { ReactNode } from "react";

type AuthCardProps = {
  title: string;
  cyId: "login" | "signup";
  error?: string | null;
  footer?: ReactNode;
  children: ReactNode;
};

export function AuthCard({ title, cyId, error, footer, children }: AuthCardProps) {
  return (
    <div
      className="auth-card-wrap"
      data-cy="auth-card-wrap"
      style={{
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        minHeight: "calc(100vh - 80px)",
        padding: "2rem 1rem",
      }}
    >
      <div
        className="auth-card sg-card sg-card--auth"
        data-cy="auth-card"
        data-cy-id={cyId}
        style={{
          width: "100%",
          maxWidth: 420,
          padding: "2rem",
        }}
      >
        <h1
          className="sg-page-title"
          data-cy="auth-title"
          style={{ marginTop: 0, marginBottom: "1.5rem" }}
        >
          {title}
        </h1>
        {error && (
          <p className="sg-error" data-cy="auth-error" role="alert">
            {error}
          </p>
        )}
        {children}
        {footer && <div style={{ marginTop: "1rem" }}>{footer}</div>}
      </div>
    </div>
  );
}

export function AuthFooterLink({
  prompt,
  href,
  label,
  cy,
}: {
  prompt: string;
  href: string;
  label: string;
  cy: string;
}) {
  return (
    <p>
      {prompt}{" "}
      <Link href={href} data-cy={cy}>
        {label}
      </Link>
    </p>
  );
}
