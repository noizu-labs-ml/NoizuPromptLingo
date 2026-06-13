import { cyAttrs } from "@/lib/cy-attrs";

export default function ContactPage() {
  return (
    <div className="mx-auto w-full max-w-[800px] px-4 py-16 text-white" {...cyAttrs({ cy: "contact-page", cyScope: "contact" })}>
      <h1
        className="mb-2 text-3xl tracking-wide"
        style={{ fontFamily: "var(--font-heading)", color: "var(--gold)" }}
      >
        Contact Us
      </h1>
      <hr className="mb-8 border-white/20" />

      <p className="mb-6 leading-8" style={{ color: "var(--text-secondary)" }}>
        Have questions, feedback, or need support? We&rsquo;d love to hear from
        you. Reach out using any of the methods below and we&rsquo;ll get back
        to you as soon as possible.
      </p>

      <div className="space-y-6">
        <div {...cyAttrs({ cy: "contact-section", cyId: "general" })}>
          <h2
            className="mb-1 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            General Inquiries
          </h2>
          <p style={{ color: "var(--text-primary)" }}>
            Email:{" "}
            <a
              href="mailto:support@bladeofeternity.com"
              className="underline transition-colors hover:text-[var(--gold)]"
            >
              support@bladeofeternity.com
            </a>
          </p>
        </div>

        <div {...cyAttrs({ cy: "contact-section", cyId: "feedback" })}>
          <h2
            className="mb-1 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            Bug Reports &amp; Feedback
          </h2>
          <p style={{ color: "var(--text-primary)" }}>
            Found a bug or have a feature suggestion? Email us at{" "}
            <a
              href="mailto:feedback@bladeofeternity.com"
              className="underline transition-colors hover:text-[var(--gold)]"
            >
              feedback@bladeofeternity.com
            </a>{" "}
            with a description of the issue and any relevant details.
          </p>
        </div>

        <div {...cyAttrs({ cy: "contact-section", cyId: "business" })}>
          <h2
            className="mb-1 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            Business &amp; Partnerships
          </h2>
          <p style={{ color: "var(--text-primary)" }}>
            For partnership or business inquiries, contact{" "}
            <a
              href="mailto:business@bladeofeternity.com"
              className="underline transition-colors hover:text-[var(--gold)]"
            >
              business@bladeofeternity.com
            </a>
          </p>
        </div>


      </div>

      <p className="mt-12 text-sm" style={{ color: "var(--text-muted)" }}>
        We typically respond within 1&ndash;2 business days.
      </p>
    </div>
  );
}
