"use client";

import Link from "next/link";
import { MermaidDiagram } from "@/components/MermaidDiagram";

const CHART_TOPOLOGY = `flowchart TB
    classDef lobe fill:#1e3a5f,stroke:#3b82f6,color:#e2e8f0,stroke-width:2px
    classDef shim fill:#4c1d95,stroke:#8b5cf6,color:#e2e8f0,stroke-width:2px
    classDef interstitial fill:#374151,stroke:#9ca3af,color:#e2e8f0,stroke-width:2px
    classDef memory fill:#065f46,stroke:#10b981,color:#e2e8f0,stroke-width:2px
    classDef signal fill:#92400e,stroke:#f59e0b,color:#e2e8f0,stroke-width:2px
    classDef io fill:#1e293b,stroke:#64748b,color:#94a3b8,stroke-width:1px

    GNS["GLOBAL NEURO SIGNALS\\n─────────────────\\nflags: threat | focus | urgency\\ncreativity | fatigue | curiosity"]:::signal
    INPUT["INPUT\\n(timestamp + text/media)"]:::io
    SENSORY["SENSORY BUFFER\\n(annotate / compress / abridge)"]:::lobe
    IR_PERCEPT{"INTERSTITIAL\\nPerception Router\\n┌─────────────┐\\n│ input shim: boost/suppress│\\n│ features by neuro signal │\\n│ output shim: route by type│\\n└─────────────┘"}:::interstitial
    EGO["EGO\\n(executive director)\\nplans, delegates, decides"]:::lobe
    SUBCON["SUBCONSCIOUS\\n(background ponderer)\\npattern matching, nudges"]:::lobe
    ANALYTIC["ANALYTICAL\\n(logic / structure)\\noutlines, critiques, validates"]:::lobe
    HOLISTIC["HOLISTIC\\n(tone / coherence)\\ntheme, mood, consistency"]:::lobe
    CREATIVE["CREATIVE\\n(generation / ideation)\\nprose, concepts, metaphor"]:::lobe
    PHILOSOPHICAL["PHILOSOPHICAL\\n(deep reasoning)\\nethics, meaning, edge cases"]:::lobe
    IR_COG{"INTERSTITIAL\\nCognitive Hub\\n┌─────────────┐\\n│ input shim: context-weight │\\n│ location, recency, threat │\\n│ output shim: priority rank │\\n└─────────────┘"}:::interstitial
    IR_EXEC{"INTERSTITIAL\\nExecutive Router\\n┌─────────────┐\\n│ input shim: merge results │\\n│ from specialist lobes │\\n│ output shim: format for │\\n│ ego consumption │\\n└─────────────┘"}:::interstitial
    IR_MEM{"INTERSTITIAL\\nMemory Gateway\\n┌─────────────┐\\n│ input shim: tag + index │\\n│ output shim: relevance │\\n│ filter by recency/weight │\\n└─────────────┘"}:::interstitial
    STM[("SHORT-TERM MEMORY\\n(rolling scratchpad)\\nrecent context, decaying")]:::memory
    LTM[("LONG-TERM MEMORY\\n(vector store / archive)\\nentities, facts, summaries")]:::memory
    DREAM["DREAM SYSTEM\\n(consolidation engine)\\nscan STM → extract → commit LTM\\nprune, compress, index"]:::memory
    ACTION["ACTION OUTPUT\\n(text / images / commands)"]:::io

    INPUT --> SENSORY
    SENSORY -->|"annotated digest"| IR_PERCEPT
    GNS -.->|"priority flags"| IR_PERCEPT
    GNS -.->|"priority flags"| IR_COG
    GNS -.->|"priority flags"| IR_EXEC
    GNS -.->|"priority flags"| IR_MEM
    IR_PERCEPT -->|"shaped percepts"| IR_COG
    IR_COG -->|"task: analyze"| ANALYTIC
    IR_COG -->|"task: feel"| HOLISTIC
    IR_COG -->|"task: create"| CREATIVE
    IR_COG -->|"task: reason"| PHILOSOPHICAL
    IR_COG <-->|"background scan"| SUBCON
    ANALYTIC -->|"structured result"| IR_EXEC
    HOLISTIC -->|"tonal assessment"| IR_EXEC
    CREATIVE -->|"generated content"| IR_EXEC
    PHILOSOPHICAL -->|"reasoned position"| IR_EXEC
    IR_EXEC -->|"merged + ranked"| EGO
    EGO -->|"directives"| IR_COG
    EGO -->|"action commands"| ACTION
    EGO -->|"store this"| IR_MEM
    SUBCON -->|"nudge / alert"| IR_EXEC
    SUBCON -.->|"update flags"| GNS
    IR_MEM <--> STM
    IR_MEM <--> LTM
    STM -->|"periodic dump"| DREAM
    DREAM -->|"consolidated entities"| LTM
    DREAM -->|"pruned"| STM
    IR_MEM -->|"recalled context"| IR_COG
    IR_MEM -->|"recalled context"| IR_PERCEPT
    EGO -->|"attention directive"| IR_PERCEPT`;

const CHART_SHIM = `flowchart LR
    classDef shim fill:#4c1d95,stroke:#8b5cf6,color:#e2e8f0,stroke-width:2px
    classDef signal fill:#92400e,stroke:#f59e0b,color:#e2e8f0,stroke-width:2px
    classDef router fill:#374151,stroke:#9ca3af,color:#e2e8f0,stroke-width:2px
    classDef io fill:#1e293b,stroke:#64748b,color:#94a3b8,stroke-width:1px

    IN_A["From Lobe A\\n{shape: cylinder\\ncolor: green\\nmatches: snake|hose|pipe}"]:::io
    IN_B["From Memory\\n{location: woods\\ntime: dusk}"]:::io
    GNS["Neuro Signal\\nthreat: 0.7\\nfocus: low"]:::signal

    subgraph INTERSTITIAL ["Interstitial Node"]
        direction LR
        INPUT_SHIM["INPUT SHIM\\n──────────\\n+ location=woods → boost snake\\n+ focus=low → lower thresholds\\n+ suppress pipe (not in woods)\\n──────────\\nsnake: 0.3 → 0.8\\nhose: 0.4 → 0.3\\npipe: 0.3 → dropped"]:::shim
        ROUTER["ROUTE\\nLOGIC\\n──────\\ntarget by\\npayload\\ntype"]:::router
        OUTPUT_SHIM_1["OUTPUT SHIM → Threat Lobe\\n──────────\\nformat: threat assessment\\nadd urgency tag from signal\\n{entity: snake, conf: 0.8\\nurgency: HIGH}"]:::shim
        OUTPUT_SHIM_2["OUTPUT SHIM → Ego\\n──────────\\nformat: summary digest\\n{perception: probable snake\\naction_needed: true}"]:::shim
        INPUT_SHIM --> ROUTER
        ROUTER --> OUTPUT_SHIM_1
        ROUTER --> OUTPUT_SHIM_2
    end

    IN_A --> INPUT_SHIM
    IN_B --> INPUT_SHIM
    GNS -.-> INPUT_SHIM
    GNS -.-> OUTPUT_SHIM_1
    OUTPUT_SHIM_1 --> OUT_THREAT["To Threat\\nAssessment Lobe"]:::io
    OUTPUT_SHIM_2 --> OUT_EGO["To Ego"]:::io
    THREAT_RESP["From Threat Lobe\\n{threat_confirmed: true\\nseverity: HIGH\\nupdate_signal: threat → 0.9}"]:::io
    THREAT_RESP -->|"signal update"| GNS_UPDATE["NEURO SIGNAL\\nUPDATED\\nthreat: 0.7 → 0.9\\n(broadcast to all\\ninterstitial nodes)"]:::signal
    OUT_THREAT -.->|"lobe processes\\nand responds"| THREAT_RESP`;

const CHART_TIME = `flowchart TB
    classDef current fill:#1e3a5f,stroke:#3b82f6,color:#e2e8f0,stroke-width:2px
    classDef recent fill:#1e3a5f,stroke:#3b82f6,color:#e2e8f0,stroke-width:1px
    classDef fading fill:#1e293b,stroke:#475569,color:#94a3b8,stroke-width:1px
    classDef ghost fill:#111827,stroke:#334155,color:#64748b,stroke-width:1px
    classDef lobe fill:#374151,stroke:#9ca3af,color:#e2e8f0,stroke-width:2px
    classDef output fill:#065f46,stroke:#10b981,color:#e2e8f0,stroke-width:2px

    subgraph LOBE_CTX ["Lobe Context Window (e.g. Threat Assessment)"]
        direction TB
        T0["TICK t (NOW) — FULL RESOLUTION\\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\\nINPUT: {shape: coiled cylinder, color: green-brown,\\nlocation: forest floor, neuro: threat=0.7, focus=low}\\nPREV OUTPUT: {assessment: probable snake, conf: 0.82,\\naction: freeze, reasoning: coiled shape + woods context}"]:::current
        T1["TICK t-1 — LIGHTLY SUMMARIZED\\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\\nINPUT: coiled green object on forest floor\\nOUTPUT: probable snake (conf 0.78), recommended caution"]:::recent
        T2["TICK t-2 — COMPRESSED\\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\\nsaw green cylinder in woods → leaning snake"]:::fading
        T3["TICK t-3 — ONE-LINER\\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\\nsnake assessment began"]:::ghost
        T4["TICK t-4+ — EXPIRED\\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\\n(no longer in context window)"]:::ghost
        T0 --- T1 --- T2 --- T3 --- T4
    end

    PROCESS["LOBE PROCESSES TICK t\\n────────────────────\\nSees: 3 consecutive ticks of snake assessment\\nin its own decaying context → reinforces mode\\n────────────────────\\nIf new input contradicts (someone picks up hose):\\nt+1 context still shows snake history but\\nfresh input overrides → confidence drops\\nby t+3 snake echoes have decayed away"]:::lobe
    NEW_OUT["OUTPUT TICK t\\n{assessment: snake, conf: 0.85\\nmode: sustained-threat\\nticks_in_mode: 3}"]:::output

    LOBE_CTX --> PROCESS --> NEW_OUT
    NEW_OUT -.->|"becomes t-1\\nin next tick"| LOBE_CTX`;

const CHART_MEMORY = `flowchart TB
    classDef lobe fill:#1e3a5f,stroke:#3b82f6,color:#e2e8f0,stroke-width:2px
    classDef shim fill:#4c1d95,stroke:#8b5cf6,color:#e2e8f0,stroke-width:2px
    classDef memory fill:#065f46,stroke:#10b981,color:#e2e8f0,stroke-width:2px
    classDef dream fill:#7c2d12,stroke:#fb923c,color:#e2e8f0,stroke-width:2px
    classDef io fill:#1e293b,stroke:#64748b,color:#94a3b8,stroke-width:1px

    LOBES["Processing Lobes\\n(any lobe output)"]:::lobe
    EGO["Ego\\n(explicit store commands)"]:::lobe

    subgraph MEM_GW ["Memory Gateway (Interstitial)"]
        direction LR
        WRITE_SHIM["WRITE SHIM\\n──────────\\ntag with timestamp\\nauto-categorize\\nassign decay rate"]:::shim
        READ_SHIM["READ SHIM\\n──────────\\nfilter by recency\\nrank by relevance\\napply neuro signal\\n(threat → prioritize\\ndanger memories)"]:::shim
    end

    STM[("SHORT-TERM MEMORY\\n━━━━━━━━━━━━━━━━━\\nrolling buffer\\neach entry has:\\n• content summary\\n• timestamp\\n• decay weight\\n• source lobe\\n━━━━━━━━━━━━━━━━━\\nauto-decays over time")]:::memory

    subgraph DREAM_SYS ["Dream System"]
        direction TB
        SCAN["SCAN\\nperiodically sweep STM\\nidentify high-salience items"]:::dream
        EXTRACT["EXTRACT\\nentities, relationships\\nkey events, patterns"]:::dream
        COMPRESS["COMPRESS\\nstructured summary\\nYAML → indexed entry"]:::dream
        COMMIT["COMMIT\\nwrite to LTM\\nprune from STM"]:::dream
        SCAN --> EXTRACT --> COMPRESS --> COMMIT
    end

    LTM[("LONG-TERM MEMORY\\n━━━━━━━━━━━━━━━━━\\nvector store + index\\nentities & relationships\\ncompressed summaries\\nsearchable by query\\n━━━━━━━━━━━━━━━━━\\npersistent")]:::memory

    LOBES -->|"raw results"| WRITE_SHIM
    EGO -->|"store command"| WRITE_SHIM
    WRITE_SHIM -->|"tagged entry"| STM
    STM -->|"periodic scan"| SCAN
    COMMIT -->|"structured entities"| LTM
    COMMIT -->|"prune signal"| STM
    LTM -->|"query results"| READ_SHIM
    STM -->|"recent context"| READ_SHIM
    READ_SHIM -->|"recalled context"| LOBES`;

const CHART_EVOLUTION = `flowchart LR
    classDef phase1 fill:#1e3a5f,stroke:#3b82f6,color:#e2e8f0,stroke-width:2px
    classDef phase2 fill:#4c1d95,stroke:#8b5cf6,color:#e2e8f0,stroke-width:2px
    classDef phase3 fill:#065f46,stroke:#10b981,color:#e2e8f0,stroke-width:2px

    subgraph P1 ["Phase 1: Prototype"]
        direction TB
        P1_LOBE["Lobes = LLM agents\\nwith system prompts"]:::phase1
        P1_SHIM["Shims = YAML transform\\nrules or mini LLM calls"]:::phase1
        P1_PIPE["Pipes = MCP tools\\n(read_inbox / send_message)"]:::phase1
        P1_MEM["Memory = JSON/YAML files"]:::phase1
    end

    subgraph P2 ["Phase 2: Hybrid"]
        direction TB
        P2_LOBE["Lobes = smaller fine-tuned\\nmodels per domain"]:::phase2
        P2_SHIM["Shims = learned transform\\nfunctions on embeddings"]:::phase2
        P2_PIPE["Pipes = tensor bus\\n(raw embeddings)"]:::phase2
        P2_MEM["Memory = vector DB\\nwith embedding search"]:::phase2
    end

    subgraph P3 ["Phase 3: Neural"]
        direction TB
        P3_LOBE["Lobes = compact trained\\nneural modules"]:::phase3
        P3_SHIM["Shims = LoRA adapters\\n+ additional layers"]:::phase3
        P3_PIPE["Pipes = direct tensor\\nconnections"]:::phase3
        P3_MEM["Memory = differentiable\\nmemory matrices"]:::phase3
    end

    P1 -->|"replace YAML\\nwith embeddings"| P2
    P2 -->|"replace LLMs\\nwith trained nets"| P3`;

function Legend({ items }: { items: { color: string; border: string; label: string }[] }) {
  return (
    <div className="flex flex-wrap gap-5 mt-4 p-4 bg-[#111827] border border-[#1e293b] rounded-md text-xs text-zinc-400">
      {items.map((item) => (
        <div key={item.label} className="flex items-center gap-2">
          <div
            className="w-3.5 h-3.5 rounded-sm flex-shrink-0"
            style={{ background: item.color, border: `2px solid ${item.border}` }}
          />
          {item.label}
        </div>
      ))}
    </div>
  );
}

export function CognitiveArchitectureContent() {
  return (
    <div className="overflow-x-hidden">
      <section className="relative pt-32 pb-8 sm:pt-44 sm:pb-12 overflow-hidden">
        <div className="absolute inset-0 -z-10">
          <div className="absolute top-0 left-1/3 w-[600px] h-[400px] bg-gold-400/6 rounded-full blur-[120px]" />
        </div>
        <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
          <Link
            href="/papers"
            className="inline-flex items-center gap-1.5 text-sm text-zinc-500 hover:text-gold-400 transition-colors mb-6"
          >
            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" d="M10.5 19.5L3 12m0 0l7.5-7.5M3 12h18" />
            </svg>
            Papers
          </Link>
          <h1 className="text-3xl sm:text-5xl font-bold tracking-tight text-white mb-2">
            Distributed Cognitive Architecture
          </h1>
          <p className="text-base text-zinc-400">
            A lobe-based processing system that exceeds context window limits through constrained I/O, interstitial shims, and decayed memory
          </p>
        </div>
      </section>

      <article className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8 pb-24 space-y-12">
        {/* Preamble */}
        <div className="glass rounded-xl p-7 border-l-4 border-amber-500">
          <h2 className="text-sm font-semibold text-zinc-400 uppercase tracking-wider mb-4">Preamble</h2>
          <div className="space-y-4 text-sm text-zinc-300 leading-relaxed">
            <p>
              This document extends the original{" "}
              <a href="https://github.com/noizu-labs-ml/artificial_intelligence" className="text-blue-400 underline" target="_blank" rel="noopener noreferrer">
                noizu-labs-ml/artificial_intelligence
              </a>{" "}
              library README (April 2018) which proposed that current-generation deep learning models omit critical aspects of biological neural architecture &mdash; dynamic firing thresholds, temporal decay, bidirectional feedback, and modular reusability. Concepts that have since been independently validated by Liquid Time-Constant Networks (Hasani et al., 2020), Transformer self-attention (Vaswani et al., 2017), and LoRA (Hu et al., 2021).
            </p>
            <p>
              Rather than waiting for the compute and tooling to build this from raw neural primitives, this architecture takes a pragmatic approach: <strong className="text-white">use LLM agents as stand-ins for biological lobes</strong>, with YAML-structured pipes as stand-ins for axonal connections. This lets us rapidly experiment with the <em>behavior and auditability</em> of a distributed cognitive system &mdash; observing how lobes interact, how shims shape perception, how memory consolidation affects long-running tasks &mdash; while keeping every message human-readable and debuggable.
            </p>
            <p>
              The key insight is that the topology is the architecture, not the internals. GPT/Claude agents can be replaced over time with smaller fine-tuned models, then with compact trained neural modules. YAML interfaces can be replaced with raw vector embeddings &mdash; and critically, a bridging network can be trained to produce the same YAML output from those vectors, allowing old and new components to coexist during migration. Each replacement is a local swap, not a system redesign.
            </p>
            <p>
              If initial outcomes from the Phase 1 prototype validate the behavioral model, the intended direction is <strong className="text-white">embodied AI</strong> &mdash; where the time arrow (per-lobe temporal decay), autonomous processing units (lobes running independent tick loops), and global neuro signals (system-wide priority modulation) become essential rather than theoretical. A robotic system that needs to react to a snake on the ground in real-time benefits directly from lobes that maintain temporal continuity, shims that reshape perception based on environmental context, and a subconscious that accumulates slow-burn signals while the executive focuses elsewhere.
            </p>
          </div>
        </div>

        {/* Executive Summary */}
        <div className="glass rounded-xl p-7">
          <h2 className="text-sm font-semibold text-zinc-400 uppercase tracking-wider mb-4">Executive Summary</h2>
          <div className="space-y-4 text-sm text-zinc-300 leading-relaxed">
            <p>
              This architecture models cognition as a distributed network of specialized processing lobes, each operating within a small, fixed-format context window. No single lobe holds the full state of the system. Instead, lobes communicate through interstitial routing nodes that apply contextual shims &mdash; active transforms that reshape data based on global neuro signals and upstream context before it reaches the next processor.
            </p>
            <p>
              By constraining each lobe&apos;s input and output to a fixed contract and retaining per-lobe recency of prior values, the system processes tasks far larger than any individual context window could contain. A novel, a codebase, or a complex analysis is never &ldquo;held&rdquo; in memory &mdash; it is progressively digested through short-term memory, consolidated by a dream system into long-term storage, and recalled on demand through targeted queries.
            </p>
            <p>
              Global neuro signals act as priority/urgency flags (not semantic content). They broadcast system-wide behavioral modifiers &mdash; analogous to neurochemicals &mdash; that each shim interprets differently. A &ldquo;threat&rdquo; signal causes the visual shim to boost snake-like pattern confidence while the analytical shim shifts to worst-case reasoning. Same flag, different behavioral responses per lobe.
            </p>
            <p>
              Each lobe encodes a temporal arrow internally through its own sliding context window. The current tick&apos;s input appears at full resolution, while previous outputs and inputs decay progressively &mdash; the prior tick is lightly summarized, two ticks back is compressed further, three ticks back is a one-liner. This decaying trail of self-history biases each lobe toward continuity: a lobe that has been outputting &ldquo;snake&rdquo; for several ticks sees that conviction reinforced by its own recent context, without any explicit flag forcing it. As those echoes compress and fade, the conviction weakens naturally &mdash; the soft analog of neural firing threshold decay. This is the mechanism that makes a lobe &ldquo;stay in a mode&rdquo; and then gradually relax out of it.
            </p>
            <p>
              The topology is fixed but evolvable. Phase 1 uses LLM agents passing YAML over MCP pipes. Phase 2 replaces YAML with raw token embeddings. Phase 3 replaces shims with LoRA adapters and lobes with compact trained modules. The wiring never changes &mdash; only what flows through it.
            </p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 mt-6">
            {[
              { title: "Lobes", desc: "Specialized processors with fixed I/O contracts. Each sees only its inbox, never the full system state." },
              { title: "Shims", desc: "Active contextual transforms between lobes. They rewrite, boost, suppress, or reshape data using neuro signals and context." },
              { title: "Interstitial Nodes", desc: "Routing middlemen that receive from one or more lobes, apply input/output shims, and forward to downstream targets." },
              { title: "Neuro Signals", desc: "Global broadcast flags (threat, focus, urgency, creativity). Not semantic — each shim interprets them independently." },
              { title: "Memory Tiers", desc: "STM (scratchpad), LTM (vector store), and a Dream system that consolidates and archives between tiers." },
              { title: "Time Arrow (Decay)", desc: "Each lobe's context window carries decaying echoes of prior ticks — full resolution fading to one-liners." },
              { title: "Evolutionary Path", desc: "YAML → embeddings → trained layers. Fixed topology, swappable internals." },
            ].map((p) => (
              <div key={p.title} className="bg-[#0f172a] border border-[#1e293b] rounded-md p-4">
                <strong className="block text-sm text-white mb-1">{p.title}</strong>
                <span className="text-xs text-zinc-400">{p.desc}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Diagram 1: System Topology */}
        <section>
          <h2 className="text-xl font-bold text-white mb-1">System Topology</h2>
          <p className="text-sm text-zinc-500 mb-5">
            Full architecture showing lobes, interstitial routing nodes with shims, memory tiers, and global neuro signals. Lobes never connect directly &mdash; all data flows through interstitial nodes that apply contextual transforms.
          </p>
          <MermaidDiagram chart={CHART_TOPOLOGY} id="topology" />
          <Legend items={[
            { color: "#1e3a5f", border: "#3b82f6", label: "Lobe (processor)" },
            { color: "#374151", border: "#9ca3af", label: "Interstitial Node (router + shims)" },
            { color: "#92400e", border: "#f59e0b", label: "Global Neuro Signals" },
            { color: "#065f46", border: "#10b981", label: "Memory System" },
            { color: "#1e293b", border: "#64748b", label: "External I/O" },
          ]} />
        </section>

        {/* Diagram 2: Shim Detail */}
        <section>
          <h2 className="text-xl font-bold text-white mb-1">Interstitial Node &amp; Shim Detail</h2>
          <p className="text-sm text-zinc-500 mb-5">
            Anatomy of an interstitial routing node. Data enters, passes through an input shim (contextual transform), hits the routing logic, then passes through an output shim before forwarding to downstream targets. Neuro signals feed into both shims.
          </p>
          <MermaidDiagram chart={CHART_SHIM} id="shim" />
        </section>

        {/* Diagram 3: Time Arrow */}
        <section>
          <h2 className="text-xl font-bold text-white mb-1">Time Arrow: Per-Lobe Decaying Context Window</h2>
          <p className="text-sm text-zinc-500 mb-5">
            Each lobe maintains a sliding context window that encodes temporal state. Current input arrives at full resolution. Previous ticks&apos; inputs and outputs decay progressively. This creates soft mode persistence: a lobe seeing its own recent &ldquo;snake&rdquo; outputs in context is biased toward continuing that assessment, but the bias fades naturally as those entries compress away.
          </p>
          <MermaidDiagram chart={CHART_TIME} id="time" />
          <Legend items={[
            { color: "#1e3a5f", border: "#3b82f6", label: "Current tick (full detail)" },
            { color: "#1e3a5f", border: "#3b82f6", label: "Recent (summarized)" },
            { color: "#1e293b", border: "#475569", label: "Fading (compressed)" },
            { color: "#111827", border: "#334155", label: "Ghost (one-liner / expired)" },
          ]} />
        </section>

        {/* Diagram 4: Memory */}
        <section>
          <h2 className="text-xl font-bold text-white mb-1">Memory Tiers &amp; Dream Consolidation</h2>
          <p className="text-sm text-zinc-500 mb-5">
            The three-tier memory system. Processing lobes write to STM through the Memory Gateway shim. The Dream System periodically scans STM, extracts entities and summaries, commits them to LTM, and prunes STM. Recall flows back through the gateway with relevance filtering.
          </p>
          <MermaidDiagram chart={CHART_MEMORY} id="memory" />
        </section>

        {/* Diagram 5: Evolution */}
        <section>
          <h2 className="text-xl font-bold text-white mb-1">Evolutionary Migration Path</h2>
          <p className="text-sm text-zinc-500 mb-5">
            The same topology across three phases. Internals change, wiring stays fixed.
          </p>
          <MermaidDiagram chart={CHART_EVOLUTION} id="evolution" />
        </section>
      </article>
    </div>
  );
}
