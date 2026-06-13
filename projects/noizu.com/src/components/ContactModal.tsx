"use client";

import { useState, useEffect, useCallback, useRef } from "react";

interface ContactModalProps {
  open: boolean;
  onClose: () => void;
}

export function ContactModal({ open, onClose }: ContactModalProps) {
  const [status, setStatus] = useState<"idle" | "sending" | "sent" | "error">("idle");
  const [errorMsg, setErrorMsg] = useState("");
  const formRef = useRef<HTMLFormElement>(null);

  useEffect(() => {
    if (!open) return;
    const handler = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    window.addEventListener("keydown", handler);
    return () => window.removeEventListener("keydown", handler);
  }, [open, onClose]);

  useEffect(() => {
    document.body.style.overflow = open ? "hidden" : "";
    return () => { document.body.style.overflow = ""; };
  }, [open]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setStatus("sending");
    setErrorMsg("");

    const form = formRef.current;
    if (!form) return;

    const formData = new FormData(form);
    const email = formData.get("email") as string;
    const name = formData.get("name") as string;
    const inquiry = formData.get("inquiry") as string;

    try {
      const res = await fetch("https://listmonk.noizu.com/api/public/subscription", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          email,
          name,
          list_uuids: ["b64a0218-37cd-40a0-a110-85aaf6cdad87"],
          attribs: {
            inquiry,
            source: "noizu-website-contact",
            submitted_at: new Date().toISOString(),
          },
        }),
      });

      if (!res.ok) {
        const data = await res.json().catch(() => null);
        throw new Error(data?.message || `Request failed (${res.status})`);
      }

      setStatus("sent");
    } catch (err) {
      setErrorMsg(err instanceof Error ? err.message : "Something went wrong.");
      setStatus("error");
    }
  };

  const handleClose = useCallback(() => {
    if (status === "sending") return;
    onClose();
    setTimeout(() => {
      setStatus("idle");
      setErrorMsg("");
      formRef.current?.reset();
    }, 200);
  }, [status, onClose]);

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4" onClick={handleClose}>
      <div className="absolute inset-0 bg-black/70 backdrop-blur-sm" />
      <div
        className="relative glass glow rounded-2xl w-full max-w-lg"
        onClick={(e) => e.stopPropagation()}
      >
        <button
          onClick={handleClose}
          className="absolute top-4 right-4 text-zinc-400 hover:text-white transition-colors"
        >
          <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" strokeWidth={2} stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>

        <div className="p-8 sm:p-10">
          {status === "sent" ? (
            <div className="text-center py-8">
              <div className="w-12 h-12 rounded-full bg-gold-400/20 flex items-center justify-center mx-auto mb-4">
                <svg className="w-6 h-6 text-gold-400" fill="none" viewBox="0 0 24 24" strokeWidth={2} stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M4.5 12.75l6 6 9-13.5" />
                </svg>
              </div>
              <h3 className="text-xl font-semibold text-white mb-2">Message sent</h3>
              <p className="text-sm text-zinc-400">I&apos;ll get back to you soon.</p>
            </div>
          ) : (
            <>
              <h3 className="text-xl font-semibold text-white mb-1">Get in Touch</h3>
              <p className="text-sm text-zinc-400 mb-6">Tell me about your project or challenge.</p>
              <form
                ref={formRef}
                onSubmit={handleSubmit}
                className="space-y-4"
              >
                <div>
                  <label htmlFor="contact-name" className="block text-sm text-zinc-300 mb-1.5">Name</label>
                  <input
                    id="contact-name"
                    type="text"
                    name="name"
                    required
                    className="w-full px-4 py-2.5 bg-white/5 border border-white/10 rounded-xl text-white text-sm placeholder:text-zinc-500 focus:outline-none focus:border-gold-400/50 focus:ring-1 focus:ring-gold-400/25 transition-colors"
                    placeholder="Your name"
                  />
                </div>
                <div>
                  <label htmlFor="contact-email" className="block text-sm text-zinc-300 mb-1.5">Email</label>
                  <input
                    id="contact-email"
                    type="email"
                    name="email"
                    required
                    className="w-full px-4 py-2.5 bg-white/5 border border-white/10 rounded-xl text-white text-sm placeholder:text-zinc-500 focus:outline-none focus:border-gold-400/50 focus:ring-1 focus:ring-gold-400/25 transition-colors"
                    placeholder="you@example.com"
                  />
                </div>
                <div>
                  <label htmlFor="contact-inquiry" className="block text-sm text-zinc-300 mb-1.5">Inquiry</label>
                  <textarea
                    id="contact-inquiry"
                    name="inquiry"
                    rows={4}
                    className="w-full px-4 py-2.5 bg-white/5 border border-white/10 rounded-xl text-white text-sm placeholder:text-zinc-500 focus:outline-none focus:border-gold-400/50 focus:ring-1 focus:ring-gold-400/25 transition-colors resize-none"
                    placeholder="Tell me about your project..."
                  />
                </div>
                {status === "error" && (
                  <p className="text-sm text-red-400">{errorMsg || "Something went wrong. Please try again."}</p>
                )}
                <button
                  type="submit"
                  disabled={status === "sending"}
                  className="w-full py-3 bg-gold-400 hover:bg-gold-300 disabled:opacity-50 disabled:cursor-not-allowed text-black text-sm font-medium rounded-xl transition-colors"
                >
                  {status === "sending" ? "Sending..." : "Send Message"}
                </button>
              </form>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
