export default function Home() {
  return (
    <div className="min-h-screen font-body">
      {/* ═══ NAV ═══ */}
      <nav className="fixed top-0 left-0 right-0 z-50 backdrop-blur-md border-b border-[var(--sumi-mist)]" style={{ background: 'rgba(245, 240, 232, 0.92)' }}>
        <div className="max-w-[960px] mx-auto px-10 h-12 flex items-center justify-between">
          <a href="/" className="font-display text-lg font-medium italic text-[var(--sumi)] no-underline border-none">
            noizu.ink
          </a>
          <div className="flex items-center gap-6 font-mono text-[10px] uppercase tracking-[0.1em] text-[var(--sumi-wash)]">
            <a href="#pipeline" className="hover:text-[var(--sumi-mid)] transition-colors border-none">Pipeline</a>
            <a href="#features" className="hover:text-[var(--sumi-mid)] transition-colors border-none">Features</a>
            <a href="#pricing" className="hover:text-[var(--sumi-mid)] transition-colors border-none">Pricing</a>
            <a href="#" className="text-[var(--sumi)] font-medium border-none">Sign In</a>
          </div>
        </div>
      </nav>

      {/* ═══ HERO ═══ */}
      <section className="max-w-[960px] mx-auto px-10 pt-44 pb-36 text-center">
        {/* Seal */}
        <div
          className="inline-flex items-center justify-center w-16 h-16 border-2 border-[var(--vermillion)] rounded-sm text-[var(--vermillion)] font-jp text-3xl font-bold mb-10"
          style={{ transform: 'rotate(-3deg)', animation: 'seal-stamp 0.8s ease-out' }}
        >
          墨
        </div>

        <h1 className="font-display text-[clamp(42px,6vw,72px)] font-light italic leading-[1.05] tracking-wide text-[var(--sumi)] mb-6">
          Put your pen down.
        </h1>

        <p className="font-display text-xl font-light text-[var(--sumi-mid)] max-w-lg mx-auto leading-relaxed mb-4">
          First stroke to finished product. A guided pipeline that takes your rough idea through planning, design, and agent-driven development.
        </p>

        <p className="font-display text-base italic text-[var(--sumi-light)] max-w-md mx-auto leading-relaxed mb-12">
          &ldquo;In the ink, the whole world. In the space between strokes, everything else.&rdquo;
        </p>

        <div className="flex gap-3 justify-center">
          <a
            href="#"
            className="font-mono text-[11px] font-medium uppercase tracking-[0.12em] px-7 py-3 bg-[var(--sumi)] text-[var(--washi)] rounded-sm border-none transition-all hover:bg-[var(--sumi-strong)] hover:shadow-[var(--shadow-ink)]"
          >
            Start your project
          </a>
          <a
            href="#pipeline"
            className="font-mono text-[11px] font-medium uppercase tracking-[0.12em] px-7 py-3 text-[var(--sumi)] border border-[var(--sumi-ghost)] rounded-sm transition-all hover:border-[var(--sumi-mid)] hover:bg-[var(--washi-cool)]"
          >
            See the pipeline
          </a>
        </div>
      </section>

      <div className="brush-divider max-w-[960px] mx-auto" />

      {/* ═══ PIPELINE ═══ */}
      <section id="pipeline" className="max-w-[960px] mx-auto px-10 py-36">
        <div className="mb-16">
          <p className="font-mono text-[10px] text-[var(--sumi-wash)] uppercase tracking-[0.2em] mb-1">The Path</p>
          <h2 className="font-display text-4xl font-normal italic text-[var(--sumi)]">Four phases, twelve steps</h2>
          <p className="font-jp text-sm font-light text-[var(--sumi-wash)] mt-1">四段階 — from nothing to everything</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {[
            {
              phase: 'Sketch',
              jp: '素描',
              desc: 'Pitch → Personas → Stories → PRD. Structure the idea before touching code.',
              steps: ['Pitch your idea', 'Define who uses it', 'Write user stories', 'Assemble the PRD'],
              accent: 'var(--sumi-ghost)',
            },
            {
              phase: 'Draft',
              jp: '草案',
              desc: 'Style guide → Wireframes → Mockups. See what you\'re building before building it.',
              steps: ['Generate style guide', 'Sketch wireframes', 'Render visual mockups'],
              accent: 'var(--sumi-light)',
            },
            {
              phase: 'Ink',
              jp: '墨入',
              desc: 'Scaffold → Develop → Demo. AI agents write code against your approved spec.',
              steps: ['Generate project scaffold', 'Agents implement stories', 'Live demo preview'],
              accent: 'var(--sumi)',
            },
            {
              phase: 'Publish',
              jp: '出版',
              desc: 'Review → Deploy. Code review, security scan, one-click to production.',
              steps: ['Automated review', 'Deploy to production'],
              accent: 'var(--vermillion)',
            },
          ].map((p) => (
            <div
              key={p.phase}
              className="bg-[var(--washi-cool)] border border-[var(--sumi-mist)] rounded-sm p-10 transition-all duration-500 hover:shadow-[var(--shadow-md)] hover:-translate-y-0.5"
              style={{ borderLeft: `3px solid ${p.accent}` }}
            >
              <div className="flex items-baseline gap-3 mb-4">
                <h3 className="font-display text-xl font-medium italic text-[var(--sumi)]">{p.phase}</h3>
                <span className="font-jp text-sm font-light text-[var(--sumi-wash)]">{p.jp}</span>
              </div>
              <p className="font-body text-base text-[var(--sumi-mid)] leading-relaxed mb-5">{p.desc}</p>
              <ol className="font-mono text-[10px] text-[var(--sumi-light)] uppercase tracking-[0.1em] flex flex-col gap-2">
                {p.steps.map((s, i) => (
                  <li key={i} className="flex items-center gap-2">
                    <span className="w-4 h-4 border border-[var(--sumi-mist)] rounded-sm flex items-center justify-center text-[8px] text-[var(--sumi-ghost)] shrink-0">{i + 1}</span>
                    {s}
                  </li>
                ))}
              </ol>
            </div>
          ))}
        </div>

        <p className="font-display text-base italic text-[var(--sumi-light)] text-center mt-10">
          Stop at any phase boundary. Export what you have. Return when you&rsquo;re ready.
        </p>
      </section>

      <div className="brush-divider-thin max-w-[960px] mx-auto" />

      {/* ═══ FEATURES ═══ */}
      <section id="features" className="max-w-[960px] mx-auto px-10 py-36">
        <div className="mb-16">
          <p className="font-mono text-[10px] text-[var(--sumi-wash)] uppercase tracking-[0.2em] mb-1">Why This Way</p>
          <h2 className="font-display text-4xl font-normal italic text-[var(--sumi)]">The brush does not hurry</h2>
          <p className="font-jp text-sm font-light text-[var(--sumi-wash)] mt-1">意図的 — intentional, not fast</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {[
            {
              title: 'Structured, not free-form',
              body: 'Each step has a dedicated prompt, structured input, structured output. No carrying 50k tokens of chat history. Small, bounded, cacheable.',
            },
            {
              title: 'Resumable at any point',
              body: 'Leave after step 4, return next week. Your project waits at exactly the step you left it. The scroll doesn\'t unroll itself.',
            },
            {
              title: 'You steer, agents build',
              body: 'Approve each story\'s implementation before it merges. Pause to edit manually. Rollback any change. The brush moves, but you hold it.',
            },
            {
              title: 'Spec before code',
              body: 'Sketch and Draft phases ensure you understand what you\'re building before agents touch a line of code. Planning is not overhead — it\'s the foundation.',
            },
            {
              title: 'Export at every boundary',
              body: 'After Sketch: PRD + stories. After Draft: style guide + mockups. After Ink: working repo. After Publish: live URL. Each phase has value on its own.',
            },
            {
              title: 'Deliberate, not decorative',
              body: 'No gamification. No onboarding tours. No "AI is thinking" spinners. The pipeline IS the experience. Motion communicates, silence is intentional.',
            },
          ].map((f) => (
            <div
              key={f.title}
              className="bg-[var(--washi-cool)] border border-[var(--sumi-mist)] rounded-sm p-8 transition-all duration-500 hover:shadow-[var(--shadow-md)] hover:-translate-y-0.5"
            >
              <h3 className="font-display text-lg font-medium italic text-[var(--sumi)] mb-2 leading-snug">{f.title}</h3>
              <p className="font-body text-[15px] text-[var(--sumi-mid)] leading-relaxed">{f.body}</p>
            </div>
          ))}
        </div>
      </section>

      <div className="brush-divider max-w-[960px] mx-auto" />

      {/* ═══ SCREENS ═══ */}
      <section className="max-w-[960px] mx-auto px-10 py-36">
        <div className="mb-16">
          <p className="font-mono text-[10px] text-[var(--sumi-wash)] uppercase tracking-[0.2em] mb-1">In Practice</p>
          <h2 className="font-display text-4xl font-normal italic text-[var(--sumi)]">What you will see</h2>
          <p className="font-jp text-sm font-light text-[var(--sumi-wash)] mt-1">画面 — the visible surface</p>
        </div>

        {/* Screen 1: Wizard Step */}
        <div className="mb-20">
          <p className="font-mono text-[9px] text-[var(--sumi-wash)] uppercase tracking-[0.15em] mb-2">Sketch &amp; Draft Phases</p>
          <div className="border border-[var(--sumi-mist)] rounded-sm overflow-hidden shadow-[var(--shadow-md)]">
            {/* Browser chrome */}
            <div className="bg-[var(--washi-warm)] px-4 py-2.5 flex items-center gap-2 border-b border-[var(--sumi-mist)]">
              <div className="flex gap-1.5">
                <div className="w-2.5 h-2.5 rounded-full bg-[var(--vermillion)]" />
                <div className="w-2.5 h-2.5 rounded-full bg-[var(--kin)]" />
                <div className="w-2.5 h-2.5 rounded-full bg-[var(--matcha)]" />
              </div>
              <div className="font-mono text-[10px] text-[var(--sumi-wash)] bg-[var(--washi-cool)] px-3 py-0.5 ml-2 flex-1 max-w-[260px]">noizu.ink/project/ink-042/sketch</div>
            </div>
            {/* Screen content */}
            <div className="bg-[var(--washi)]">
              {/* Phase tabs */}
              <div className="flex border-b border-[var(--sumi-mist)]">
                {['Sketch', 'Draft', 'Ink', 'Publish'].map((tab, i) => (
                  <div key={tab} className={`flex-1 text-center py-3 font-display text-sm italic transition-colors ${
                    i === 0 ? 'text-[var(--sumi)] bg-[var(--washi)] font-medium border-b-2 border-[var(--sumi)]' :
                    i < 2 ? 'text-[var(--sumi-wash)] bg-[var(--washi-cool)]' :
                    'text-[var(--sumi-ghost)] bg-[var(--washi-cool)]'
                  } ${i > 0 ? 'border-l border-[var(--sumi-mist)]' : ''}`}>
                    {i < 1 && <span className="text-[var(--matcha)] mr-1">&#10003;</span>}
                    {tab}
                  </div>
                ))}
              </div>
              {/* Step progress */}
              <div className="px-8 pt-4">
                <div className="flex gap-1.5 mb-1">
                  {Array.from({ length: 4 }).map((_, i) => (
                    <div key={i} className={`flex-1 h-0.5 rounded-sm ${i < 2 ? 'bg-[var(--sumi)]' : i === 2 ? 'bg-gradient-to-r from-[var(--sumi)] to-[var(--sumi-mist)]' : 'bg-[var(--sumi-mist)]'}`} />
                  ))}
                </div>
                <div className="font-mono text-[9px] text-[var(--sumi-wash)] uppercase tracking-[0.1em] mb-4">Step 3 of 4 &middot; User Stories &middot; Phase: Sketch</div>
              </div>
              {/* Main content area with sidebar */}
              <div className="grid grid-cols-[1fr_280px] min-h-[320px]">
                <div className="px-8 pb-8">
                  <h3 className="font-display text-2xl font-normal italic text-[var(--sumi)] mb-4">User Stories</h3>
                  <p className="font-body text-[15px] text-[var(--sumi-mid)] leading-relaxed mb-6 max-w-md">Review the stories generated from your personas. Edit, reorder, or add new ones.</p>
                  {/* Story cards */}
                  {[
                    { id: 'INK-001', title: 'User can sign up with email', persona: 'Marcus', status: 'done' },
                    { id: 'INK-002', title: 'User can create a new project', persona: 'Marcus', status: 'done' },
                    { id: 'INK-003', title: 'User can describe their idea in free text', persona: 'Jules', status: 'editing' },
                    { id: 'INK-004', title: 'User can review AI-generated personas', persona: 'Rina', status: 'pending' },
                  ].map((story) => (
                    <div key={story.id} className={`flex items-start gap-3 py-3 border-b border-[var(--sumi-mist)] ${story.status === 'editing' ? 'bg-[var(--washi-warm)] -mx-3 px-3 rounded-sm' : ''}`}>
                      <div className={`w-4 h-4 rounded-sm border flex items-center justify-center text-[8px] shrink-0 mt-0.5 ${
                        story.status === 'done' ? 'bg-[var(--success-dim)] border-[var(--success)] text-[var(--success)]' :
                        story.status === 'editing' ? 'border-[var(--sumi)] text-[var(--sumi)]' :
                        'border-[var(--sumi-ghost)] text-[var(--sumi-ghost)]'
                      }`}>{story.status === 'done' ? '✓' : story.status === 'editing' ? '●' : '–'}</div>
                      <div>
                        <div className="font-mono text-[9px] text-[var(--sumi-wash)] uppercase tracking-[0.1em]">{story.id} &middot; {story.persona}</div>
                        <div className="font-body text-[14px] text-[var(--sumi-mid)] leading-snug">{story.title}</div>
                      </div>
                    </div>
                  ))}
                </div>
                {/* AI suggestions sidebar */}
                <div className="border-l border-[var(--sumi-mist)] bg-[var(--washi-cool)] p-5">
                  <div className="font-mono text-[9px] text-[var(--sumi-wash)] uppercase tracking-[0.2em] mb-4 pb-2 border-b border-[var(--sumi-mist)]">AI Suggestions</div>
                  <div className="bg-[var(--washi)] border border-[var(--sumi-mist)] rounded-sm p-4 mb-3">
                    <p className="font-body text-[13px] text-[var(--sumi-mid)] leading-relaxed italic mb-3">&ldquo;Consider adding a story for OAuth with Google — Marcus would expect this for quick signup.&rdquo;</p>
                    <div className="flex gap-2">
                      <button className="font-mono text-[9px] uppercase tracking-[0.1em] px-3 py-1 bg-[var(--sumi)] text-[var(--washi)] rounded-sm">Accept</button>
                      <button className="font-mono text-[9px] uppercase tracking-[0.1em] px-3 py-1 border border-[var(--sumi-ghost)] text-[var(--sumi-light)] rounded-sm">Edit</button>
                      <button className="font-mono text-[9px] uppercase tracking-[0.1em] px-3 py-1 text-[var(--sumi-wash)]">Skip</button>
                    </div>
                  </div>
                  <div className="bg-[var(--washi)] border border-[var(--sumi-mist)] rounded-sm p-4">
                    <p className="font-body text-[13px] text-[var(--sumi-mid)] leading-relaxed italic">&ldquo;Rina&rsquo;s team needs export — add a story for markdown/PDF export of the PRD.&rdquo;</p>
                  </div>
                </div>
              </div>
              {/* Bottom nav */}
              <div className="flex justify-between items-center px-8 py-4 border-t border-[var(--sumi-mist)] bg-[var(--washi-cool)]">
                <button className="font-mono text-[10px] uppercase tracking-[0.1em] text-[var(--sumi-light)]">&larr; Back</button>
                <div className="flex gap-2">
                  <button className="font-mono text-[10px] uppercase tracking-[0.1em] px-4 py-2 text-[var(--sumi-light)] border border-dashed border-[var(--sumi-ghost)] rounded-sm">Save &amp; Exit</button>
                  <button className="font-mono text-[10px] uppercase tracking-[0.1em] px-4 py-2 bg-[var(--sumi)] text-[var(--washi)] rounded-sm">Next Step &rarr;</button>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Screen 2: Agent Dashboard */}
        <div className="mb-20">
          <p className="font-mono text-[9px] text-[var(--sumi-wash)] uppercase tracking-[0.15em] mb-2">Ink Phase — 墨入</p>
          <div className="border border-[var(--sumi-mist)] rounded-sm overflow-hidden shadow-[var(--shadow-md)]">
            <div className="bg-[var(--washi-warm)] px-4 py-2.5 flex items-center gap-2 border-b border-[var(--sumi-mist)]">
              <div className="flex gap-1.5">
                <div className="w-2.5 h-2.5 rounded-full bg-[var(--vermillion)]" />
                <div className="w-2.5 h-2.5 rounded-full bg-[var(--kin)]" />
                <div className="w-2.5 h-2.5 rounded-full bg-[var(--matcha)]" />
              </div>
              <div className="font-mono text-[10px] text-[var(--sumi-wash)] bg-[var(--washi-cool)] px-3 py-0.5 ml-2 flex-1 max-w-[260px]">noizu.ink/project/ink-042/ink</div>
            </div>
            {/* Dark dashboard */}
            <div className="bg-[var(--sumi-deep)]">
              {/* Phase tabs - dark */}
              <div className="flex border-b border-[var(--sumi-strong)]">
                {['Sketch', 'Draft', 'Ink', 'Publish'].map((tab, i) => (
                  <div key={tab} className={`flex-1 text-center py-2.5 font-display text-[13px] italic border-r border-[var(--sumi-strong)] last:border-r-0 ${
                    i < 2 ? 'text-[var(--matcha)] bg-[var(--sumi)]' :
                    i === 2 ? 'text-[var(--washi)] bg-[var(--sumi-strong)] font-medium' :
                    'text-[var(--sumi-light)] bg-[var(--sumi)]'
                  }`}>
                    {i < 2 && <span className="mr-1">&#10003;</span>}
                    {tab}
                  </div>
                ))}
              </div>
              {/* Three-panel dashboard */}
              <div className="grid grid-cols-[200px_1fr_200px] min-h-[340px]" style={{ gap: '1px', background: 'var(--sumi-strong)' }}>
                {/* Backlog */}
                <div className="bg-[var(--sumi-deep)] p-4">
                  <div className="font-mono text-[8px] uppercase tracking-[0.2em] text-[var(--sumi-light)] mb-3 pb-2 border-b border-[var(--sumi-strong)]">Stories</div>
                  {[
                    { id: 'INK-040', title: 'Project scaffold', done: true },
                    { id: 'INK-041', title: 'API route setup', done: true },
                    { id: 'INK-042', title: 'User auth flow', active: true },
                    { id: 'INK-043', title: 'Dashboard layout', queued: true },
                    { id: 'INK-044', title: 'Wizard engine', queued: true },
                  ].map((s) => (
                    <div key={s.id} className={`flex items-start gap-2 py-1.5 px-2 rounded-sm text-[11px] ${s.active ? 'bg-[rgba(245,240,232,0.05)] border-l-2 border-[var(--washi)]' : ''}`}>
                      <div className={`w-1.5 h-1.5 rounded-full mt-1.5 shrink-0 ${s.done ? 'bg-[var(--matcha)]' : s.active ? 'bg-[var(--sumi-wash)]' : 'bg-[var(--sumi-light)]'}`} style={s.active ? { animation: 'breath 2s ease-in-out infinite' } : {}} />
                      <div>
                        <div className="font-mono text-[8px] text-[var(--sumi-light)]">{s.id}</div>
                        <div className={`text-[11px] leading-snug ${s.active ? 'text-[var(--washi)]' : 'text-[var(--sumi-wash)]'}`}>{s.title}</div>
                      </div>
                    </div>
                  ))}
                </div>
                {/* Live output */}
                <div className="bg-[var(--sumi)] p-4">
                  <div className="font-mono text-[8px] uppercase tracking-[0.2em] text-[var(--sumi-light)] mb-3 pb-2 border-b border-[var(--sumi-strong)] flex justify-between">
                    <span>Live Output</span>
                    <span className="text-[var(--sumi-wash)]" style={{ animation: 'breath 2s ease-in-out infinite' }}>&#9679;</span>
                  </div>
                  <div className="font-mono text-[10px] leading-[1.9] text-[var(--sumi-wash)]">
                    <div><span className="text-[var(--sumi-light)]">[14:23:01]</span> <span className="text-[var(--washi)]">coder</span> Starting INK-042</div>
                    <div><span className="text-[var(--sumi-light)]">[14:23:04]</span> <span className="text-[var(--washi)]">write</span> src/lib/auth/providers.ts</div>
                    <div><span className="text-[var(--sumi-light)]">[14:23:06]</span> <span className="text-[var(--washi)]">write</span> src/lib/auth/session.ts</div>
                    <div><span className="text-[var(--sumi-light)]">[14:23:22]</span> <span className="text-[var(--washi)]">test</span> Running auth suite...</div>
                    <div><span className="text-[var(--sumi-light)]">[14:23:28]</span> <span className="text-[var(--matcha)]">PASS</span> providers (3/3)</div>
                    <div><span className="text-[var(--sumi-light)]">[14:23:30]</span> <span className="text-[var(--vermillion-soft)]">FAIL</span> middleware (2/4)</div>
                    <div><span className="text-[var(--sumi-light)]">[14:23:33]</span> <span className="text-[var(--washi)]">write</span> src/middleware.ts (v2)</div>
                    <div><span className="text-[var(--sumi-light)]">[14:23:39]</span> <span className="text-[var(--matcha)]">12/12 passing</span></div>
                  </div>
                  <div className="flex gap-2 mt-4 pt-3 border-t border-[var(--sumi-strong)]">
                    <button className="font-mono text-[9px] uppercase tracking-[0.1em] px-3 py-1.5 bg-[var(--washi)] text-[var(--sumi)] rounded-sm">Approve</button>
                    <button className="font-mono text-[9px] uppercase tracking-[0.1em] px-3 py-1.5 border border-[var(--sumi-light)] text-[var(--sumi-wash)] rounded-sm">Changes</button>
                    <button className="font-mono text-[9px] uppercase tracking-[0.1em] px-3 py-1.5 text-[var(--sumi-light)]">Pause</button>
                  </div>
                </div>
                {/* Criteria */}
                <div className="bg-[var(--sumi-deep)] p-4">
                  <div className="font-mono text-[8px] uppercase tracking-[0.2em] text-[var(--sumi-light)] mb-3 pb-2 border-b border-[var(--sumi-strong)]">Criteria</div>
                  <div className="font-display text-[13px] italic text-[var(--washi)] mb-3">User Auth Flow</div>
                  {['OAuth2 Google', 'OAuth2 GitHub', 'JWT sessions', 'Route protection'].map((c) => (
                    <div key={c} className="flex items-center gap-2 py-1 text-[11px] text-[var(--sumi-wash)] border-b border-[var(--sumi-strong)]">
                      <div className="w-3 h-3 rounded-sm bg-[rgba(74,122,82,0.15)] border border-[var(--success)] text-[var(--success)] flex items-center justify-center text-[7px] shrink-0">&#10003;</div>
                      {c}
                    </div>
                  ))}
                  {['Token refresh', 'Sign-out'].map((c) => (
                    <div key={c} className="flex items-center gap-2 py-1 text-[11px] text-[var(--sumi-light)] border-b border-[var(--sumi-strong)]">
                      <div className="w-3 h-3 rounded-sm border border-[var(--sumi-light)] text-[var(--sumi-light)] flex items-center justify-center text-[7px] shrink-0">&ndash;</div>
                      {c}
                    </div>
                  ))}
                  <div className="mt-4 pt-3 border-t border-[var(--sumi-strong)]">
                    <div className="font-mono text-[8px] uppercase tracking-[0.2em] text-[var(--sumi-light)] mb-2">Stats</div>
                    <div className="font-mono text-[10px] text-[var(--sumi-wash)] flex flex-col gap-1">
                      <div className="flex justify-between"><span className="text-[var(--sumi-light)]">Files</span><span>5</span></div>
                      <div className="flex justify-between"><span className="text-[var(--sumi-light)]">Added</span><span className="text-[var(--matcha)]">+142</span></div>
                      <div className="flex justify-between"><span className="text-[var(--sumi-light)]">Tests</span><span className="text-[var(--matcha)]">12/12</span></div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Screen 3: Demo Preview */}
        <div>
          <p className="font-mono text-[9px] text-[var(--sumi-wash)] uppercase tracking-[0.15em] mb-2">Demo Preview</p>
          <div className="border border-[var(--sumi-mist)] rounded-sm overflow-hidden shadow-[var(--shadow-md)]">
            <div className="bg-[var(--washi-warm)] px-4 py-2.5 flex items-center gap-2 border-b border-[var(--sumi-mist)]">
              <div className="flex gap-1.5">
                <div className="w-2.5 h-2.5 rounded-full bg-[var(--vermillion)]" />
                <div className="w-2.5 h-2.5 rounded-full bg-[var(--kin)]" />
                <div className="w-2.5 h-2.5 rounded-full bg-[var(--matcha)]" />
              </div>
              <div className="font-mono text-[10px] text-[var(--sumi-wash)] bg-[var(--washi-cool)] px-3 py-0.5 ml-2 flex-1 max-w-[260px]">ink-042.noizu.ink</div>
              <div className="ml-auto flex gap-3 font-mono text-[9px] text-[var(--sumi-wash)] uppercase tracking-[0.1em]">
                <span className="opacity-60">Desktop</span>
                <span>Tablet</span>
                <span>Mobile</span>
              </div>
            </div>
            {/* Simulated app preview */}
            <div className="bg-white min-h-[360px] relative">
              {/* Simulated app nav */}
              <div className="bg-[var(--sumi)] text-white px-6 py-3 flex items-center justify-between">
                <span className="text-sm font-semibold">MyApp</span>
                <div className="flex gap-4 text-xs text-gray-400">
                  <span>Dashboard</span>
                  <span className="text-white">Projects</span>
                  <span>Settings</span>
                </div>
              </div>
              {/* Simulated app content */}
              <div className="p-6">
                <h2 className="text-xl font-semibold text-gray-900 mb-4" style={{ fontFamily: 'system-ui' }}>Projects</h2>
                <div className="grid grid-cols-3 gap-4">
                  {['User Auth', 'Dashboard', 'API Layer'].map((name) => (
                    <div key={name} className="border border-gray-200 rounded-lg p-4 bg-gray-50">
                      <div className="text-sm font-medium text-gray-900 mb-1" style={{ fontFamily: 'system-ui' }}>{name}</div>
                      <div className="text-xs text-gray-500" style={{ fontFamily: 'system-ui' }}>3 stories completed</div>
                      <div className="mt-3 flex gap-1">
                        {Array.from({ length: 5 }).map((_, i) => (
                          <div key={i} className={`flex-1 h-1 rounded-full ${i < 3 ? 'bg-green-500' : 'bg-gray-200'}`} />
                        ))}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
              {/* Floating toolbar */}
              <div className="absolute bottom-4 left-1/2 -translate-x-1/2 bg-[var(--sumi)] text-[var(--washi)] px-4 py-2 rounded-sm flex items-center gap-4 font-mono text-[9px] uppercase tracking-[0.1em] shadow-[var(--shadow-ink)]">
                <span className="text-[var(--matcha)]">&#9679; Live</span>
                <span className="text-[var(--sumi-wash)]">7 / 10 stories</span>
                <button className="text-[var(--washi)] border border-[var(--sumi-light)] px-2 py-0.5 rounded-sm">Open in tab &rarr;</button>
              </div>
            </div>
          </div>
        </div>
      </section>

      <div className="brush-divider-thin max-w-[960px] mx-auto" />

      {/* ═══ PERSONAS ═══ */}
      <section className="max-w-[960px] mx-auto px-10 py-36">
        <div className="mb-16">
          <p className="font-mono text-[10px] text-[var(--sumi-wash)] uppercase tracking-[0.2em] mb-1">For Whom</p>
          <h2 className="font-display text-4xl font-normal italic text-[var(--sumi)]">The ones who build</h2>
          <p className="font-jp text-sm font-light text-[var(--sumi-wash)] mt-1">使い手 — the users</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {[
            {
              name: 'The Weekend Builder',
              desc: 'Developer with a day job and 30 ideas in Apple Notes. Needs a deployed demo by Monday.',
              metric: 'Running prototype in one weekend',
            },
            {
              name: 'The Indie Hacker',
              desc: 'Building for revenue. Can spec it, can design it, but 40 hours of scaffolding kills momentum.',
              metric: 'First paying customer within the week',
            },
            {
              name: 'The Small Team Lead',
              desc: '2-5 person team, no dedicated PM or designer. Everyone has a different mental model.',
              metric: 'Shared codebase to iterate on, not a doc to argue about',
            },
          ].map((p) => (
            <div
              key={p.name}
              className="border-l-[3px] border-[var(--vermillion)] bg-[var(--washi-cool)] border-r border-t border-b border-r-[var(--sumi-mist)] border-t-[var(--sumi-mist)] border-b-[var(--sumi-mist)] rounded-sm p-8"
            >
              <h3 className="font-display text-lg font-medium italic text-[var(--sumi)] mb-3">{p.name}</h3>
              <p className="font-body text-[15px] text-[var(--sumi-mid)] leading-relaxed mb-4">{p.desc}</p>
              <p className="font-mono text-[9px] text-[var(--matcha)] uppercase tracking-[0.15em]">
                &#10003; {p.metric}
              </p>
            </div>
          ))}
        </div>
      </section>

      <div className="brush-divider-thin max-w-[960px] mx-auto" />

      {/* ═══ PRICING ═══ */}
      <section id="pricing" className="max-w-[960px] mx-auto px-10 py-36">
        <div className="mb-16 text-center">
          <p className="font-mono text-[10px] text-[var(--sumi-wash)] uppercase tracking-[0.2em] mb-1">Offering</p>
          <h2 className="font-display text-4xl font-normal italic text-[var(--sumi)]">Choose your path</h2>
          <p className="font-jp text-sm font-light text-[var(--sumi-wash)] mt-1">道 — the way</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          {[
            { name: 'Free', price: '$0', phases: 'Sketch', desc: '3 projects, markdown export', cta: 'Begin free' },
            { name: 'Pro', price: '$19/mo', phases: 'Sketch + Draft', desc: 'Unlimited projects, style guides, mockups', cta: 'Start Pro' },
            { name: 'Builder', price: '$49/mo', phases: '+ Ink', desc: 'Agent development, demo preview, GitHub export', cta: 'Start Building', featured: true },
            { name: 'Launch', price: '$99/mo', phases: 'All phases', desc: 'One-click deploy, CI/CD, monitoring', cta: 'Launch' },
          ].map((t) => (
            <div
              key={t.name}
              className={`rounded-sm p-6 transition-all duration-500 hover:shadow-[var(--shadow-md)] hover:-translate-y-0.5 ${
                t.featured
                  ? 'bg-[var(--sumi)] text-[var(--washi)] border border-[var(--sumi)]'
                  : 'bg-[var(--washi-cool)] border border-[var(--sumi-mist)]'
              }`}
            >
              <h3 className={`font-display text-lg font-medium italic mb-1 ${t.featured ? 'text-[var(--washi)]' : 'text-[var(--sumi)]'}`}>{t.name}</h3>
              <div className={`font-mono text-2xl font-medium mb-1 ${t.featured ? 'text-[var(--washi)]' : 'text-[var(--sumi)]'}`}>{t.price}</div>
              <div className={`font-mono text-[9px] uppercase tracking-[0.15em] mb-4 ${t.featured ? 'text-[var(--sumi-wash)]' : 'text-[var(--sumi-wash)]'}`}>{t.phases}</div>
              <p className={`font-body text-sm leading-relaxed mb-6 ${t.featured ? 'text-[var(--sumi-ghost)]' : 'text-[var(--sumi-mid)]'}`}>{t.desc}</p>
              <button className={`w-full font-mono text-[10px] font-medium uppercase tracking-[0.12em] py-2.5 rounded-sm transition-all ${
                t.featured
                  ? 'bg-[var(--washi)] text-[var(--sumi)] hover:bg-white'
                  : 'bg-[var(--sumi)] text-[var(--washi)] hover:bg-[var(--sumi-strong)]'
              }`}>
                {t.cta}
              </button>
            </div>
          ))}
        </div>
      </section>

      <div className="brush-divider max-w-[960px] mx-auto" />

      {/* ═══ FINAL CTA ═══ */}
      <section className="max-w-[960px] mx-auto px-10 py-36 text-center">
        <div
          className="inline-flex items-center justify-center w-12 h-12 border-2 border-[var(--vermillion)] rounded-sm text-[var(--vermillion)] font-jp text-xl font-bold mb-8"
          style={{ transform: 'rotate(-2deg)' }}
        >
          墨
        </div>
        <h2 className="font-display text-[clamp(32px,5vw,52px)] font-light italic text-[var(--sumi)] leading-tight mb-6">
          The blank page never<br />fills itself.
        </h2>
        <p className="font-display text-lg text-[var(--sumi-mid)] max-w-md mx-auto mb-10 leading-relaxed">
          Everyone has the first five minutes of enthusiasm. Let the machines handle the fifty hours of follow-through.
        </p>
        <a
          href="#"
          className="inline-block font-mono text-[11px] font-medium uppercase tracking-[0.12em] px-8 py-3.5 bg-[var(--vermillion)] text-[var(--washi)] rounded-sm border-none transition-all hover:bg-[var(--vermillion-soft)] hover:shadow-[0_2px_8px_rgba(194,59,34,0.2)]"
        >
          Start your first project — free
        </a>
      </section>

      {/* ═══ FOOTER ═══ */}
      <div className="brush-divider-thin max-w-[960px] mx-auto" />
      <footer className="max-w-[960px] mx-auto px-10 py-16 text-center">
        <div className="font-display text-xl font-light italic text-[var(--sumi-light)] mb-1">noizu.ink</div>
        <div className="font-mono text-[9px] text-[var(--sumi-wash)] uppercase tracking-[0.2em]">
          First stroke to finished product &middot; 2026
        </div>
      </footer>
    </div>
  );
}
