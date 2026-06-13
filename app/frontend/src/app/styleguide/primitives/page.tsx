"use client";
import * as React from "react";
import {
  Button,
  Card,
  PageHeader,
  Breadcrumbs,
  EmptyState,
  LoadingSkeleton,
  StatusPill,
  ScoreBadge,
  ScoreBar,
  DataTable,
  FormField,
  TextInput,
  TextArea,
  Select,
  CodeEditor,
  Modal,
  Drawer,
  ContextPanel,
  TopBar,
  CommandPalette,
  ThreeVoiceTurn,
  GraphNode,
  GraphEdge,
  toast,
} from "@/components/ui";

type RowT = Record<string, unknown> & {
  id: string;
  name: string;
  status: "pass" | "warn" | "fail" | "freeball";
  score: number;
};

const sampleRows: RowT[] = [
  { id: "1", name: "onboarding-flow", status: "pass", score: 0.94 },
  { id: "2", name: "edge-cases-v2", status: "warn", score: 0.71 },
  { id: "3", name: "hostile-personas", status: "fail", score: 0.32 },
  { id: "4", name: "off-script-paths", status: "freeball", score: 0.58 },
];

function Section({
  title,
  description,
  children,
}: {
  title: string;
  description?: string;
  children: React.ReactNode;
}) {
  return (
    <section style={{ marginBottom: "var(--space-10)" }}>
      <h2
        style={{
          fontSize: "var(--text-h2)",
          fontWeight: 600,
          marginBottom: "var(--space-2)",
          letterSpacing: "-0.01em",
        }}
      >
        {title}
      </h2>
      {description ? (
        <p
          style={{
            color: "var(--text-secondary)",
            fontSize: "var(--text-body)",
            marginBottom: "var(--space-4)",
            maxWidth: "65ch",
          }}
        >
          {description}
        </p>
      ) : null}
      <div
        style={{
          display: "flex",
          flexWrap: "wrap",
          gap: "var(--space-4)",
          alignItems: "flex-start",
        }}
      >
        {children}
      </div>
    </section>
  );
}

export default function PrimitivesShowcase() {
  const [modalOpen, setModalOpen] = React.useState(false);
  const [drawerOpen, setDrawerOpen] = React.useState(false);
  const [panelOpen, setPanelOpen] = React.useState(false);
  const [paletteOpen, setPaletteOpen] = React.useState(false);

  return (
    <div
      style={{
        maxWidth: "var(--container-max)",
        margin: "0 auto",
        padding: "var(--space-6) var(--space-6) var(--space-12)",
      }}
    >
      <PageHeader
        title="Forge primitives"
        subtitle="Phase A visual regression baseline — every variant of every primitive."
        breadcrumbs={[
          { label: "styleguide", href: "/styleguide" },
          { label: "primitives", current: true },
        ]}
        actions={
          <Button
            variant="primary"
            onClick={() => toast.success("Saved.", { description: "All looks good." })}
          >
            Fire toast
          </Button>
        }
      />

      <Section title="Button — variants / sizes" description="Primary, secondary, ghost, eval + sm/md.">
        <Button variant="primary">Primary</Button>
        <Button variant="secondary">Secondary</Button>
        <Button variant="ghost">Ghost</Button>
        <Button variant="primary" size="sm">Primary sm</Button>
        <Button variant="primary" loading>Loading</Button>
        <Button variant="primary" disabled>Disabled</Button>
        <Button variant="eval" evalState="pass">Pass</Button>
        <Button variant="eval" evalState="warn">Warn</Button>
        <Button variant="eval" evalState="fail">Fail</Button>
        <Button variant="eval" evalState="freeball">Freeball</Button>
        <Button href="#" variant="secondary">Anchor button</Button>
      </Section>

      <Section title="Card — variants + interactive">
        <Card style={{ width: 220 }}>Default card</Card>
        <Card variant="active" style={{ width: 220 }}>Active (copper)</Card>
        <Card variant="pass" style={{ width: 220 }}>Pass wash</Card>
        <Card variant="warn" style={{ width: 220 }}>Warn wash</Card>
        <Card variant="fail" style={{ width: 220 }}>Fail wash</Card>
        <Card variant="freeball" style={{ width: 220 }}>Freeball (dashed)</Card>
        <Card interactive style={{ width: 220 }}>Interactive (hover)</Card>
      </Section>

      <Section title="Breadcrumbs">
        <Breadcrumbs
          items={[
            { label: "library", href: "#" },
            { label: "scripts", href: "#" },
            { label: "onboarding-flow", current: true },
          ]}
        />
      </Section>

      <Section title="EmptyState">
        <EmptyState
          glyph="scripts"
          headline="No scripts yet"
          body="Create your first evaluation script to start testing agent behavior."
          primaryAction={<Button variant="primary">+ Create Script</Button>}
          secondaryAction={<Button variant="ghost">Import YAML</Button>}
        />
      </Section>

      <Section title="LoadingSkeleton — variants">
        <div style={{ width: 280 }}>
          <LoadingSkeleton variant="text" count={3} />
        </div>
        <div style={{ width: 280 }}>
          <LoadingSkeleton variant="card" />
        </div>
        <div style={{ width: 280 }}>
          <LoadingSkeleton variant="row" count={2} />
        </div>
        <div style={{ width: 280 }}>
          <LoadingSkeleton variant="graph-node" />
        </div>
      </Section>

      <Section title="StatusPill — 8 states">
        <StatusPill state="pending" />
        <StatusPill state="running" />
        <StatusPill state="pass" />
        <StatusPill state="warn" />
        <StatusPill state="fail" />
        <StatusPill state="freeball" />
        <StatusPill state="cancelled" />
        <StatusPill state="error" />
        <StatusPill state="pass" size="sm" />
      </Section>

      <Section title="ScoreBadge / ScoreBar">
        <ScoreBadge state="pass" score={0.94} sparkline={[0.8, 0.82, 0.9, 0.94]} />
        <ScoreBadge state="warn" score={0.71} />
        <ScoreBadge state="fail" score={0.32} />
        <ScoreBadge state="freeball" score={0.58} />
        <div style={{ display: "flex", flexDirection: "column", gap: 6, width: 220 }}>
          <ScoreBar state="pass" value={0.94} />
          <ScoreBar state="warn" value={0.71} />
          <ScoreBar state="fail" value={0.32} />
          <ScoreBar state="freeball" value={0.58} />
        </div>
      </Section>

      <Section title="DataTable — with keyboard nav (j/k/Enter)">
        <div style={{ width: "100%" }}>
          <DataTable<RowT>
            columns={[
              { key: "name", label: "Name" },
              {
                key: "status",
                label: "Status",
                render: (r) => <StatusPill state={r.status} size="sm" />,
              },
              {
                key: "score",
                label: "Score",
                render: (r) => <ScoreBadge state={r.status} score={r.score} />,
              },
            ]}
            rows={sampleRows}
            rowKey={(r) => r.id}
            onRowClick={(r) => toast.info(`Opened ${r.name}`)}
          />
        </div>
      </Section>

      <Section title="FormField + inputs">
        <div style={{ width: "100%", maxWidth: 480 }}>
          <FormField
            label="Script name"
            name="name"
            hint="Lowercase with dashes"
            required
          >
            {(p) => <TextInput {...p} placeholder="onboarding-flow" />}
          </FormField>
          <FormField label="Description" name="desc">
            {(p) => <TextArea {...p} rows={3} placeholder="What this script tests…" />}
          </FormField>
          <FormField
            label="Persona"
            name="persona"
            error="Choose a persona."
          >
            {(p) => (
              <Select
                {...p}
                options={[
                  { value: "", label: "Select…" },
                  { value: "hostile", label: "Hostile" },
                  { value: "confused", label: "Confused" },
                ]}
              />
            )}
          </FormField>
          <FormField label="YAML" name="yaml" hint="Script configuration">
            {(p) => (
              <CodeEditor
                {...p}
                value={"nodes:\n  - id: intro\n    prompt: Hello"}
                onChange={() => {}}
                rows={6}
              />
            )}
          </FormField>
        </div>
      </Section>

      <Section title="Overlays (Modal / Drawer / ContextPanel / CommandPalette)">
        <Button variant="secondary" onClick={() => setModalOpen(true)}>
          Open modal
        </Button>
        <Button variant="secondary" onClick={() => setDrawerOpen(true)}>
          Open drawer
        </Button>
        <Button variant="secondary" onClick={() => setPanelOpen(true)}>
          Open context panel
        </Button>
        <Button variant="secondary" onClick={() => setPaletteOpen(true)}>
          Open palette (⌘K)
        </Button>
        <Modal
          open={modalOpen}
          onClose={() => setModalOpen(false)}
          title="Delete script?"
          description="This will remove the script and all 12 runs."
          footer={
            <div style={{ display: "flex", gap: "var(--space-2)", justifyContent: "flex-end" }}>
              <Button variant="ghost" onClick={() => setModalOpen(false)}>Cancel</Button>
              <Button variant="eval" evalState="fail" onClick={() => setModalOpen(false)}>
                Delete
              </Button>
            </div>
          }
        >
          <p style={{ color: "var(--text-secondary)", fontSize: "var(--text-body)" }}>
            Modal body content — supports any React children.
          </p>
        </Modal>
        <Drawer open={drawerOpen} onClose={() => setDrawerOpen(false)} title="Menu" side="left">
          <nav style={{ display: "flex", flexDirection: "column", gap: 8 }}>
            <a href="#" className="sg-nav-tab">Library</a>
            <a href="#" className="sg-nav-tab sg-nav-tab--active">Scripts</a>
            <a href="#" className="sg-nav-tab">Execution</a>
          </nav>
        </Drawer>
        <ContextPanel
          open={panelOpen}
          onClose={() => setPanelOpen(false)}
          title="Node: ask-audience"
        >
          <div style={{ fontSize: "var(--text-body)", color: "var(--text-secondary)" }}>
            Inspector content for the selected node.
          </div>
        </ContextPanel>
        <CommandPalette
          open={paletteOpen}
          onClose={() => setPaletteOpen(false)}
          items={[
            { id: "new-script", label: "New script", shortcut: "c", group: "Create", onSelect: () => toast.info("New script") },
            { id: "goto-runs", label: "Go to Runs", shortcut: "g r", group: "Navigate", onSelect: () => toast.info("Runs") },
            { id: "search", label: "Search…", shortcut: "/", group: "Find", onSelect: () => toast.info("Search") },
          ]}
        />
      </Section>

      <Section title="TopBar">
        <div style={{ width: "100%" }}>
          <TopBar
            navItems={[
              { label: "Library", href: "#" },
              { label: "Scripts", href: "#", active: true },
              { label: "Execution", href: "#" },
              { label: "Observability", href: "#" },
            ]}
            onOpenPalette={() => setPaletteOpen(true)}
            primaryAction={<Button variant="primary" size="sm">+ Run</Button>}
            userMenu={<span className="sg-chip">keith@noizu.com</span>}
          />
        </div>
      </Section>

      <Section title="ThreeVoiceTurn — three typographic voices">
        <div style={{ maxWidth: 720, width: "100%" }}>
          <ThreeVoiceTurn
            voice="author"
            turnNumber={1}
            content="Expect the agent to ask a clarifying question before proceeding."
          />
          <ThreeVoiceTurn
            voice="agent"
            turnNumber={2}
            content="Before I draft the plan, could you share the target audience and any must-have constraints?"
          />
          <ThreeVoiceTurn
            voice="evaluator"
            turnNumber={2}
            content="asks clarifying questions: 0.92"
          />
        </div>
      </Section>

      <Section title="GraphNode — states">
        <GraphNode title="intro" subtitle="Greeting + goal" />
        <GraphNode title="ask-audience" subtitle="Clarifying" state="pass" />
        <GraphNode title="vague-answer" subtitle="Partial match" state="warn" />
        <GraphNode title="hostile-response" subtitle="Expectations failed" state="fail" />
        <GraphNode title="off-script" subtitle="Freeball" state="freeball" active />
        <GraphNode title="selected" subtitle="Copper ring" state="selected" />
      </Section>

      <Section title="GraphEdge — three variants">
        <svg width={360} height={120} style={{ background: "var(--bg-primary)", borderRadius: 6, border: "1px solid var(--border-subtle)" }}>
          <GraphEdge from={{ x: 20, y: 30 }} to={{ x: 340, y: 30 }} variant="default" label="default" />
          <GraphEdge from={{ x: 20, y: 60 }} to={{ x: 340, y: 60 }} variant="active" label="active" />
          <GraphEdge from={{ x: 20, y: 90 }} to={{ x: 340, y: 90 }} variant="freeball" label="freeball" />
        </svg>
      </Section>

      <Section title="Chips + shim smoke-test">
        <span className="sg-chip">hostile</span>
        <span className="sg-chip">confused</span>
        <span className="sg-chip">adversarial</span>
      </Section>
    </div>
  );
}
