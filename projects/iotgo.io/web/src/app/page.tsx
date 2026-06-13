import { WaitlistForm } from "./waitlist-form";

export default function Home() {
  return (
    <div className="min-h-screen bg-background font-mono">
      <Nav />
      <Hero />
      <Divider />
      <Problem />
      <Divider />
      <HowItWorks />
      <Divider />
      <FleetDemo />
      <Divider />
      <Features />
      <Divider />
      <FinalCTA />
      <Footer />
    </div>
  );
}

/* ═══════════════════════════════════════════════
   DIVIDER
   ═══════════════════════════════════════════════ */
function Divider() {
  return (
    <div className="px-6 text-border-strong select-none" aria-hidden="true">
      <div className="mx-auto max-w-6xl font-mono text-xs tracking-widest opacity-40">
        ════════════════════════════════════════════════════════════════════════════════
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════
   NAV
   ═══════════════════════════════════════════════ */
function Nav() {
  return (
    <nav className="sticky top-0 z-50 border-b-2 border-border bg-background">
      <div className="mx-auto flex max-w-6xl items-center justify-between px-6 py-3">
        <a
          href="/"
          className="flex items-center gap-2 font-mono text-sm font-bold uppercase tracking-widest"
        >
          <svg
            viewBox="0 0 200 200"
            className="h-6 w-6 text-accent"
            fill="currentColor"
            aria-hidden="true"
          >
            <path
              fillRule="evenodd"
              d="M 100,28 A 72,72 0 1,1 99.999,28 Z M 100,50 A 50,50 0 1,0 99.999,50 Z"
            />
            <polygon points="82,66 82,134 152,100" />
          </svg>
          IOT<span className="text-accent">GO</span>
        </a>
        <a
          href="#waitlist"
          className="border-2 border-accent bg-transparent px-3 py-1.5 text-[11px] font-bold uppercase tracking-widest text-accent transition-all duration-100 hover:bg-accent hover:text-black"
        >
          Request Access
        </a>
      </div>
    </nav>
  );
}

/* ═══════════════════════════════════════════════
   HERO
   ═══════════════════════════════════════════════ */
function Hero() {
  return (
    <section className="px-6 py-20 lg:py-28">
      <div className="mx-auto max-w-4xl">
        {/* Status badge */}
        <div className="mb-8 inline-flex items-center gap-2 border-2 border-border px-3 py-1">
          <span className="h-2 w-2 bg-accent animate-pulse" />
          <span className="text-[11px] font-bold uppercase tracking-widest text-text-secondary">
            SYSTEM ONLINE — ACCEPTING EARLY ACCESS
          </span>
        </div>

        {/* Fleet health metric */}
        <div className="mb-6">
          <p className="text-[11px] font-bold uppercase tracking-[0.08em] text-text-tertiary">
            FLEET UPTIME
          </p>
          <p className="font-[family-name:var(--font-space-grotesk)] text-[72px] font-bold leading-none tracking-tight text-accent sm:text-[96px]">
            99.7<span className="text-[48px] text-text-tertiary sm:text-[56px]">%</span>
          </p>
        </div>

        <h1 className="text-2xl font-bold leading-tight tracking-tight sm:text-3xl lg:text-[36px]">
          Your fleet runs itself.
        </h1>

        <p className="mt-4 max-w-2xl text-sm leading-relaxed text-text-secondary">
          IoTGo deploys autonomous AI agents that monitor telemetry, detect
          anomalies, execute remediation playbooks, and optimize device
          configurations. The detect&#8594;act loop, closed. Stop getting paged
          at 3am for problems the system could fix itself.
        </p>

        {/* CTA */}
        <div id="waitlist" className="mt-10">
          <WaitlistForm buttonText="REQUEST EARLY ACCESS" />
        </div>

        <p className="mt-4 text-[11px] uppercase tracking-widest text-text-tertiary">
          Free for founding operators &middot; No credit card required
        </p>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════
   PROBLEM
   ═══════════════════════════════════════════════ */
function Problem() {
  const problems = [
    {
      label: "DETECT BUT DON'T ACT",
      code: "[ALERT]",
      color: "text-critical",
      description:
        "Every platform surfaces anomalies. None of them do anything about it. You get an alert. You investigate. You remediate manually. At 3am. Again.",
    },
    {
      label: "PILOTS THAT STALL",
      code: "[WARN]",
      color: "text-warning",
      description:
        "70% of IoT pilots stall after 18 months. The complexity of wiring telemetry to ML to alerting to human to action kills momentum. Most teams never get past the dashboard.",
    },
    {
      label: "AI IS BOLTED ON",
      code: "[INFO]",
      color: "text-cyan",
      description:
        'Current platforms sell "AI-powered anomaly detection" but ship threshold alerts with an ML veneer. The AI detects. The human acts. There is no closed loop.',
    },
  ];

  return (
    <section className="px-6 py-20">
      <div className="mx-auto max-w-5xl">
        <p className="text-[11px] font-bold uppercase tracking-[0.08em] text-text-tertiary">
          THE PROBLEM
        </p>
        <h2 className="mt-3 text-xl font-bold tracking-tight sm:text-2xl">
          IoT fleet management is broken
        </h2>

        <div className="mt-12 grid gap-6 md:grid-cols-3">
          {problems.map((p) => (
            <div
              key={p.label}
              className="border-2 border-border bg-surface p-4"
            >
              <div className="mb-3 flex items-center gap-2">
                <span className={`text-xs font-bold ${p.color}`}>
                  {p.code}
                </span>
                <span className="text-xs font-bold uppercase tracking-wider">
                  {p.label}
                </span>
              </div>
              <p className="text-[13px] leading-relaxed text-text-secondary">
                {p.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════
   HOW IT WORKS
   ═══════════════════════════════════════════════ */

const PLAYBOOK_YAML = `# temp-spike-remediation.yaml
scope: fleet:warehouse-east/temp-sensors
trigger:
  condition: anomaly:spike
  threshold: 3σ

actions:
  - throttle_device:
      duration: 30s
      reason: "temp spike exceeding 3σ"
  - if: still_anomalous
    then: restart_device
  - if: restart_failed
    then: escalate
      level: operator
      channel: pagerduty`;

const AGENT_LOG = `$ iotgo deploy --fleet warehouse-east \\
    --playbook temp-spike-remediation.yaml \\
    --autonomy level-2

Deploying agent AGENT-07 to warehouse-east...

[08:42:11] AGENT-07 > MONITORING 2,847 devices
[08:42:11] AGENT-07 > BASELINE loaded (7-day)
[08:43:22] AGENT-07 > ANOMALY dev:WH-E-T0447 temp=42.3°C (3.2σ)
[08:43:22] AGENT-07 > EXEC throttle dev:WH-E-T0447 30s
[08:43:53] AGENT-07 > CHECK  dev:WH-E-T0447 temp=38.1°C (1.4σ)
[08:43:53] AGENT-07 > RESOLVED anomaly cleared post-throttle
[08:43:53] AGENT-07 > LOG outcome=success action=throttle`;

function HowItWorks() {
  return (
    <section className="px-6 py-20">
      <div className="mx-auto max-w-5xl">
        <p className="text-[11px] font-bold uppercase tracking-[0.08em] text-text-tertiary">
          HOW IT WORKS
        </p>
        <h2 className="mt-3 text-xl font-bold tracking-tight sm:text-2xl">
          Define &#8594; Deploy &#8594; Trust
        </h2>
        <p className="mt-4 max-w-2xl text-sm leading-relaxed text-text-secondary">
          Write playbooks in YAML. Deploy agents to your fleet. Start at
          observer mode. Promote to autonomous as trust builds.
        </p>

        {/* Two-column: Playbook + Agent Log */}
        <div className="mt-12 grid gap-6 lg:grid-cols-2">
          {/* Playbook YAML */}
          <div>
            <div className="mb-2 flex items-center gap-2">
              <span className="text-xs font-bold text-accent">01</span>
              <h3 className="text-sm font-bold uppercase tracking-wider">
                Define playbooks in YAML
              </h3>
            </div>
            <pre className="overflow-x-auto border-2 border-border bg-surface p-4 text-[13px] leading-relaxed text-text-secondary">
              {PLAYBOOK_YAML}
            </pre>
          </div>

          {/* Agent Log */}
          <div>
            <div className="mb-2 flex items-center gap-2">
              <span className="text-xs font-bold text-accent">02</span>
              <h3 className="text-sm font-bold uppercase tracking-wider">
                Deploy agents to your fleet
              </h3>
            </div>
            <pre className="overflow-x-auto border-2 border-border bg-surface p-4 text-[13px] leading-relaxed text-text-secondary">
              {AGENT_LOG}
            </pre>
          </div>
        </div>

        {/* Progressive Autonomy */}
        <div className="mt-8">
          <div className="mb-2 flex items-center gap-2">
            <span className="text-xs font-bold text-accent">03</span>
            <h3 className="text-sm font-bold uppercase tracking-wider">
              Progressive autonomy — trust builds over time
            </h3>
          </div>
          <div className="overflow-x-auto border-2 border-border">
            <table className="w-full text-[13px]">
              <thead>
                <tr className="bg-accent-muted text-left">
                  <th className="border-b-2 border-border px-4 py-2 text-[11px] font-bold uppercase tracking-widest text-accent">
                    Level
                  </th>
                  <th className="border-b-2 border-border px-4 py-2 text-[11px] font-bold uppercase tracking-widest text-accent">
                    Agent Can
                  </th>
                  <th className="border-b-2 border-border px-4 py-2 text-[11px] font-bold uppercase tracking-widest text-accent">
                    Requires Approval
                  </th>
                </tr>
              </thead>
              <tbody className="text-text-secondary">
                <tr className="border-b border-border">
                  <td className="px-4 py-2 font-bold text-text-primary">
                    0 — OBSERVER
                  </td>
                  <td className="px-4 py-2">Monitor + alert</td>
                  <td className="px-4 py-2">Everything</td>
                </tr>
                <tr className="border-b border-border">
                  <td className="px-4 py-2 font-bold text-text-primary">
                    1 — ADVISOR
                  </td>
                  <td className="px-4 py-2">Monitor + recommend actions</td>
                  <td className="px-4 py-2">Operator executes</td>
                </tr>
                <tr className="border-b border-border">
                  <td className="px-4 py-2 font-bold text-text-primary">
                    2 — SUPERVISED
                  </td>
                  <td className="px-4 py-2">Execute playbooks</td>
                  <td className="px-4 py-2">Destructive actions</td>
                </tr>
                <tr className="border-b border-border">
                  <td className="px-4 py-2 font-bold text-text-primary">
                    3 — AUTONOMOUS
                  </td>
                  <td className="px-4 py-2">Execute all playbooks</td>
                  <td className="px-4 py-2">Escalation only</td>
                </tr>
                <tr>
                  <td className="px-4 py-2 font-bold text-accent">
                    4 — ADAPTIVE
                  </td>
                  <td className="px-4 py-2">Suggest playbook changes</td>
                  <td className="px-4 py-2">New playbook adoption</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════
   FLEET DEMO — The Signature Visual
   ═══════════════════════════════════════════════ */

const FLEET_DEVICES = [
  { id: "WH-E-T001", status: "healthy", temp: "23.4°C", uptime: "14d 3h" },
  { id: "WH-E-T002", status: "healthy", temp: "22.8°C", uptime: "14d 3h" },
  { id: "WH-E-T003", status: "warning", temp: "38.7°C", uptime: "14d 3h" },
  { id: "WH-E-T004", status: "healthy", temp: "23.1°C", uptime: "7d 12h" },
  { id: "WH-E-T005", status: "critical", temp: "54.2°C", uptime: "14d 3h" },
  { id: "WH-E-T006", status: "healthy", temp: "22.9°C", uptime: "14d 3h" },
  { id: "WH-E-T007", status: "updating", temp: "23.0°C", uptime: "14d 3h" },
  { id: "WH-E-T008", status: "healthy", temp: "24.1°C", uptime: "3d 8h" },
  { id: "WH-E-T009", status: "offline", temp: "—", uptime: "—" },
  { id: "WH-E-T010", status: "healthy", temp: "22.6°C", uptime: "14d 3h" },
  { id: "WH-E-T011", status: "healthy", temp: "23.3°C", uptime: "14d 3h" },
  { id: "WH-E-T012", status: "warning", temp: "36.1°C", uptime: "14d 3h" },
  { id: "WH-E-H001", status: "healthy", temp: "45.2%", uptime: "14d 3h" },
  { id: "WH-E-H002", status: "healthy", temp: "44.8%", uptime: "14d 3h" },
  { id: "WH-E-H003", status: "healthy", temp: "46.1%", uptime: "7d 12h" },
  { id: "WH-E-V001", status: "healthy", temp: "3.31V", uptime: "14d 3h" },
  { id: "WH-E-V002", status: "warning", temp: "2.84V", uptime: "14d 3h" },
  { id: "WH-E-V003", status: "healthy", temp: "3.29V", uptime: "14d 3h" },
];

const STATUS_STYLES: Record<string, { border: string; label: string; labelColor: string }> = {
  healthy: { border: "border-healthy", label: "[ONLINE]", labelColor: "text-healthy" },
  warning: { border: "border-warning", label: "[WARN]", labelColor: "text-warning" },
  critical: { border: "border-critical", label: "[CRITICAL]", labelColor: "text-critical" },
  offline: { border: "border-offline", label: "[OFFLINE]", labelColor: "text-offline" },
  updating: { border: "border-in-progress", label: "[UPDATING]", labelColor: "text-in-progress" },
};

function FleetDemo() {
  return (
    <section className="px-6 py-20">
      <div className="mx-auto max-w-5xl">
        <p className="text-[11px] font-bold uppercase tracking-[0.08em] text-text-tertiary">
          FLEET VIEW
        </p>
        <h2 className="mt-3 text-xl font-bold tracking-tight sm:text-2xl">
          Your entire fleet. One screen.
        </h2>
        <p className="mt-4 max-w-2xl text-sm leading-relaxed text-text-secondary">
          Every device, every status, every metric. Color is signal — green
          means operational, amber means attention, red means act now. No
          decoration. No wasted pixels.
        </p>

        {/* Fleet header */}
        <div className="mt-12 border-2 border-border">
          <div className="flex items-center justify-between border-b-2 border-border bg-surface px-4 py-2">
            <div className="flex items-center gap-3">
              <span className="text-xs font-bold uppercase tracking-widest">
                WAREHOUSE-EAST
              </span>
              <span className="text-[11px] text-text-tertiary">
                18 DEVICES
              </span>
            </div>
            <div className="flex items-center gap-4 text-[11px]">
              <span className="flex items-center gap-1">
                <span className="h-2 w-2 bg-healthy" /> 13
              </span>
              <span className="flex items-center gap-1">
                <span className="h-2 w-2 bg-warning" /> 3
              </span>
              <span className="flex items-center gap-1">
                <span className="h-2 w-2 bg-critical" /> 1
              </span>
              <span className="flex items-center gap-1">
                <span className="h-2 w-2 bg-offline" /> 1
              </span>
            </div>
          </div>

          {/* Device grid */}
          <div className="grid grid-cols-2 gap-0 sm:grid-cols-3 md:grid-cols-6">
            {FLEET_DEVICES.map((d) => {
              const s = STATUS_STYLES[d.status];
              return (
                <div
                  key={d.id}
                  className={`border border-border p-3 transition-[border-color] duration-100 hover:border-border-strong ${s.border} border-t-4`}
                >
                  <p className="text-[11px] font-bold text-text-primary">
                    {d.id}
                  </p>
                  <p className={`text-[10px] font-bold ${s.labelColor}`}>
                    {s.label}
                  </p>
                  <p className="mt-1 text-[11px] text-text-secondary">
                    {d.temp}
                  </p>
                  <p className="text-[10px] text-text-tertiary">{d.uptime}</p>
                </div>
              );
            })}
          </div>
        </div>

        {/* Sparkline hint */}
        <div className="mt-4 flex items-center gap-4 text-[11px] text-text-tertiary">
          <span>
            TELEMETRY TREND:{" "}
            <span className="text-text-secondary">
              ▁▁▂▂▃▃▂▂▁▁▂▃▅▆▇▇▅▃▂▁
            </span>
          </span>
          <span>
            AGENT-07:{" "}
            <span className="text-accent">▓▓▓▓▓▓▓▓▓▓▓▓░░░░</span>{" "}
            THROTTLE RESOLVED
          </span>
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════
   FEATURES
   ═══════════════════════════════════════════════ */
function Features() {
  const features = [
    {
      title: "PLAYBOOK ENGINE",
      description:
        "YAML-defined, version-controlled remediation sequences. Agents can only take actions the playbook authorizes. Auditable, constrained, learnable.",
      icon: "■",
    },
    {
      title: "ANOMALY DETECTION",
      description:
        "Unsupervised baseline learning per device type. Multivariate scoring, seasonal awareness, drift detection. Not just threshold breaches.",
      icon: "▲",
    },
    {
      title: "PROGRESSIVE AUTONOMY",
      description:
        "Start at observer. Promote to autonomous as trust builds. Level 0 through Level 4. You're always in control of the control.",
      icon: "◆",
    },
    {
      title: "CANARY ROLLOUTS",
      description:
        "Firmware updates deploy to 5% canary first. Agent monitors health for 2 hours. Healthy? Roll to 100%. Not? Automatic rollback.",
      icon: "●",
    },
    {
      title: "ANY PLATFORM",
      description:
        "Ingest from MQTT, HTTP, AWS IoT Core, Azure IoT Hub, ThingsBoard. IoTGo is an intelligence layer, not a replacement for your infrastructure.",
      icon: "⊕",
    },
    {
      title: "OUTCOME DASHBOARD",
      description:
        'Not "what happened" — "what the agent did and whether it worked." Fleet health score. Incidents prevented. MTTR reduction. Cost impact.',
      icon: "⚡",
    },
  ];

  return (
    <section className="px-6 py-20">
      <div className="mx-auto max-w-5xl">
        <p className="text-[11px] font-bold uppercase tracking-[0.08em] text-text-tertiary">
          CAPABILITIES
        </p>
        <h2 className="mt-3 text-xl font-bold tracking-tight sm:text-2xl">
          Everything your fleet needs to run itself
        </h2>

        <div className="mt-12 grid gap-0 border-2 border-border sm:grid-cols-2 lg:grid-cols-3">
          {features.map((f) => (
            <div
              key={f.title}
              className="border border-border bg-surface p-5 transition-[border-color] duration-100 hover:border-border-strong"
            >
              <span className="mb-3 inline-flex h-8 w-8 items-center justify-center border-2 border-accent text-sm text-accent">
                {f.icon}
              </span>
              <h3 className="text-[13px] font-bold uppercase tracking-wider">
                {f.title}
              </h3>
              <p className="mt-2 text-[12px] leading-relaxed text-text-secondary">
                {f.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════
   FINAL CTA
   ═══════════════════════════════════════════════ */
function FinalCTA() {
  return (
    <section className="px-6 py-20">
      <div className="mx-auto max-w-xl text-center">
        <h2 className="text-xl font-bold tracking-tight sm:text-2xl">
          Stop getting paged for problems
          <br />
          the system could fix itself.
        </h2>
        <p className="mt-4 text-sm leading-relaxed text-text-secondary">
          IoTGo is building the autonomous fleet management layer IoT engineers
          actually need. Get early access and shape the product.
        </p>

        <div className="mt-8">
          <WaitlistForm buttonText="REQUEST ACCESS" />
        </div>

        <p className="mt-4 text-[11px] uppercase tracking-widest text-text-tertiary">
          Founding operators get lifetime access to Pro tier
        </p>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════
   FOOTER
   ═══════════════════════════════════════════════ */
function Footer() {
  return (
    <footer className="border-t-2 border-border px-6 py-6">
      <div className="mx-auto flex max-w-5xl flex-col items-center justify-between gap-4 sm:flex-row">
        <span className="flex items-center gap-2 text-[11px] uppercase tracking-widest text-text-tertiary">
          <svg
            viewBox="0 0 200 200"
            className="h-4 w-4"
            fill="currentColor"
            aria-hidden="true"
          >
            <path
              fillRule="evenodd"
              d="M 100,28 A 72,72 0 1,1 99.999,28 Z M 100,50 A 50,50 0 1,0 99.999,50 Z"
            />
            <polygon points="82,66 82,134 152,100" />
          </svg>
          &copy; 2026 IOTGO.IO
        </span>
        <div className="flex gap-6">
          <a
            href="#"
            className="text-[11px] uppercase tracking-widest text-text-tertiary transition-colors duration-100 hover:text-text-secondary"
          >
            Privacy
          </a>
          <a
            href="#"
            className="text-[11px] uppercase tracking-widest text-text-tertiary transition-colors duration-100 hover:text-text-secondary"
          >
            Terms
          </a>
        </div>
      </div>
    </footer>
  );
}
