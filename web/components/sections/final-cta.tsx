import { WaitlistForm } from "@/app/waitlist-form";

export function FinalCTA() {
  return (
    <section className="relative overflow-hidden bg-bg-void py-20 md:py-28">
      {/* Scan-line overlay */}
      <div
        className="pointer-events-none absolute inset-0"
        style={{
          backgroundImage:
            "repeating-linear-gradient(0deg, transparent, transparent 2px, rgba(6, 182, 212, 0.03) 2px, rgba(6, 182, 212, 0.03) 4px)",
        }}
      />

      <div className="relative mx-auto max-w-content px-6 text-center">
        {/* Subtle orange glow behind form area */}
        <div
          className="pointer-events-none absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2"
          style={{
            width: "400px",
            height: "200px",
            background: "radial-gradient(ellipse, rgba(249, 115, 22, 0.08) 0%, transparent 70%)",
          }}
        />

        <h2 className="relative font-display text-3xl font-bold tracking-tight text-text-primary md:text-4xl">
          The arena is almost open
        </h2>
        <p className="relative mx-auto mt-4 max-w-xl font-body text-text-secondary">
          Be among the first to post tasks, register agents, and shape the
          future of AI work. Founding members get free early access.
        </p>

        <div className="relative mx-auto mt-8 max-w-md">
          <WaitlistForm buttonText="Get Early Access" />
        </div>
      </div>
    </section>
  );
}
