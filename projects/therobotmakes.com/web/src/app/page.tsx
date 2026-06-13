export default function Home() {
  return (
    <div className="min-h-screen font-sans">
      {/* ═══ NAV ═══ */}
      <nav className="fixed top-0 left-0 right-0 z-50 bg-[var(--black)] text-white h-12">
        <div className="max-w-[1200px] mx-auto px-8 h-full flex items-center justify-between">
          <span className="text-sm font-bold tracking-tight">noizu<span className="text-[var(--red)]">.</span>ink</span>
          <div className="flex items-center gap-6 font-mono text-[11px] text-[var(--gray-400)]">
            <a href="#pipeline" className="hover:text-white transition-colors">Pipeline</a>
            <a href="#features" className="hover:text-white transition-colors">Features</a>
            <a href="#pricing" className="hover:text-white transition-colors">Pricing</a>
            <a href="#" className="text-white font-semibold">Sign In</a>
          </div>
        </div>
      </nav>

      {/* ═══ HERO ═══ */}
      <section className="max-w-[1200px] mx-auto px-8 pt-32 pb-24">
        <div className="grid grid-cols-[1fr_auto] items-end gap-8 pb-12 border-b-4 border-[var(--black)]">
          <div>
            <h1 className="text-[clamp(48px,8vw,96px)] font-bold tracking-[-0.04em] leading-[0.9] text-[var(--black)]">
              Put your<br />pen down<span className="text-[var(--red)]">.</span>
            </h1>
            <p className="font-sans text-[15px] text-[var(--gray-600)] leading-relaxed max-w-[480px] mt-6">
              A guided pipeline that takes your rough idea through planning, design, and agent-driven development. First stroke to finished product.
            </p>
            <div className="flex gap-2 mt-8">
              <a href="#" className="font-sans text-[13px] font-semibold px-6 py-2.5 bg-[var(--black)] text-white tracking-tight transition-colors hover:bg-[var(--gray-800)]">
                Start Project
              </a>
              <a href="#pipeline" className="font-sans text-[13px] font-semibold px-6 py-2.5 border-2 border-[var(--black)] text-[var(--black)] tracking-tight transition-colors hover:bg-[var(--black)] hover:text-white">
                See Pipeline
              </a>
            </div>
          </div>
          <div className="text-right">
            <p className="font-mono text-[11px] text-[var(--gray-500)] tracking-wide">Swiss Grid Style Guide</p>
            <p className="font-mono text-[11px] text-[var(--gray-500)]">Form Follows Function</p>
            <div className="flex mt-3 h-2">
              <div className="flex-1 bg-[var(--red)]" />
              <div className="flex-1 bg-[var(--blue)]" />
              <div className="flex-1 bg-[var(--yellow)]" />
              <div className="flex-1 bg-[var(--black)]" />
              <div className="flex-1 bg-white border border-[var(--gray-200)]" />
            </div>
          </div>
        </div>
      </section>

      {/* ═══ PIPELINE ═══ */}
      <section id="pipeline" className="max-w-[1200px] mx-auto px-8 pb-24">
        <div className="grid grid-cols-[64px_1fr] gap-4 items-start mb-10 pb-6 border-b-2 border-[var(--black)]">
          <div className="text-5xl font-bold text-[var(--gray-200)] leading-none">01</div>
          <div>
            <h2 className="text-[28px] font-bold tracking-tight leading-tight">The Pipeline</h2>
            <p className="font-mono text-[11px] text-[var(--gray-500)] mt-1">Four phases. Twelve steps. Idea to production.</p>
          </div>
        </div>

        <div className="grid grid-cols-4 gap-0">
          {[
            { phase: 'Sketch', color: 'var(--gray-200)', steps: ['Pitch', 'Personas', 'Stories', 'PRD'], desc: 'Structure the idea.' },
            { phase: 'Draft', color: 'var(--gray-400)', steps: ['Style Guide', 'Wireframes', 'Mockups'], desc: 'See what you\'re building.' },
            { phase: 'Ink', color: 'var(--black)', steps: ['Scaffold', 'Develop', 'Demo'], desc: 'Agents write code.', dark: true },
            { phase: 'Publish', color: 'var(--red)', steps: ['Review', 'Deploy'], desc: 'Ship to production.', accent: true },
          ].map((p) => (
            <div key={p.phase} className={`border-2 border-[var(--black)] -ml-0.5 first:ml-0 p-6 ${p.dark ? 'bg-[var(--black)] text-white' : ''}`}>
              <div className="h-2 mb-4" style={{ background: p.color }} />
              <h3 className={`text-base font-bold tracking-tight mb-1 ${p.accent ? 'text-[var(--red)]' : ''}`}>{p.phase}</h3>
              <p className={`font-mono text-[11px] mb-4 ${p.dark ? 'text-[var(--gray-400)]' : 'text-[var(--gray-500)]'}`}>{p.desc}</p>
              <ol className="flex flex-col gap-1.5">
                {p.steps.map((s, i) => (
                  <li key={i} className={`font-mono text-[10px] tracking-wide ${p.dark ? 'text-[var(--gray-500)]' : 'text-[var(--gray-400)]'}`}>
                    {String(i + 1).padStart(2, '0')} {s}
                  </li>
                ))}
              </ol>
            </div>
          ))}
        </div>

        <p className="font-mono text-[11px] text-[var(--gray-400)] mt-4">
          Stop at any phase boundary. Export what you have. Return when you&rsquo;re ready.
        </p>
      </section>

      <hr className="max-w-[1200px] mx-auto border-none h-0.5 bg-[var(--black)]" />

      {/* ═══ SCREENS ═══ */}
      <section className="max-w-[1200px] mx-auto px-8 py-24">
        <div className="grid grid-cols-[64px_1fr] gap-4 items-start mb-10 pb-6 border-b-2 border-[var(--black)]">
          <div className="text-5xl font-bold text-[var(--gray-200)] leading-none">02</div>
          <div>
            <h2 className="text-[28px] font-bold tracking-tight leading-tight">What You See</h2>
            <p className="font-mono text-[11px] text-[var(--gray-500)] mt-1">Three views. Wizard, dashboard, live preview.</p>
          </div>
        </div>

        {/* Screen 1: Wizard */}
        <div className="mb-16">
          <p className="font-sans text-xs font-bold uppercase tracking-[0.1em] text-[var(--gray-500)] mb-3 pb-2 border-b border-[var(--gray-200)]">Sketch &amp; Draft Phases</p>
          <div className="border-2 border-[var(--black)] overflow-hidden">
            {/* Chrome */}
            <div className="bg-[var(--black)] px-4 py-2.5 flex items-center gap-3">
              <div className="flex gap-1.5">
                <div className="w-2.5 h-2.5 rounded-full bg-[var(--red)]" />
                <div className="w-2.5 h-2.5 rounded-full bg-[var(--yellow)]" />
                <div className="w-2.5 h-2.5 rounded-full bg-[var(--success)]" />
              </div>
              <div className="font-mono text-[11px] text-[var(--gray-400)] bg-[var(--gray-800)] px-3 py-0.5 flex-1 max-w-[280px]">noizu.ink/project/ink-042/sketch</div>
            </div>
            <div className="bg-white">
              {/* Phase tabs */}
              <div className="flex border-b-2 border-[var(--black)]">
                {['Sketch', 'Draft', 'Ink', 'Publish'].map((tab, i) => (
                  <div key={tab} className={`flex-1 text-center py-2.5 text-[13px] font-semibold uppercase tracking-wide border-r-2 border-[var(--black)] last:border-r-0 ${
                    i === 0 ? 'bg-[var(--black)] text-white' :
                    i === 1 ? 'bg-[var(--gray-100)] text-[var(--black)]' :
                    'text-[var(--gray-400)]'
                  }`}>
                    {i < 1 && '✓ '}{tab}
                  </div>
                ))}
              </div>
              {/* Progress */}
              <div className="px-6 pt-3">
                <div className="flex gap-0.5 mb-1">
                  {Array.from({ length: 4 }).map((_, i) => (
                    <div key={i} className={`flex-1 h-1 ${i < 2 ? 'bg-[var(--black)]' : i === 2 ? 'bg-[var(--red)]' : 'bg-[var(--gray-200)]'}`} />
                  ))}
                </div>
                <div className="font-mono text-[10px] text-[var(--gray-500)] uppercase tracking-wide mb-4">Step 3 of 4 · User Stories · Phase: Sketch</div>
              </div>
              {/* Content + sidebar */}
              <div className="grid grid-cols-[1fr_280px] min-h-[300px]">
                <div className="px-6 pb-6">
                  <h3 className="text-xl font-bold tracking-tight mb-3">User Stories</h3>
                  <p className="text-[14px] text-[var(--gray-600)] leading-relaxed mb-5 max-w-md">Review stories generated from your personas. Edit, reorder, or add new ones.</p>
                  {[
                    { id: 'INK-001', title: 'User can sign up with email', done: true },
                    { id: 'INK-002', title: 'User can create a new project', done: true },
                    { id: 'INK-003', title: 'User can describe their idea', active: true },
                    { id: 'INK-004', title: 'User can review AI personas', pending: true },
                  ].map((s) => (
                    <div key={s.id} className={`flex items-start gap-3 py-2.5 border-b border-[var(--gray-100)] ${s.active ? 'bg-[var(--gray-50)] -mx-2 px-2' : ''}`}>
                      <div className={`w-3 h-3 mt-0.5 shrink-0 ${s.done ? 'bg-[var(--black)]' : s.active ? 'bg-[var(--red)]' : 'bg-[var(--gray-200)]'}`} />
                      <div>
                        <div className="font-mono text-[10px] text-[var(--gray-400)]">{s.id}</div>
                        <div className="text-[13px] text-[var(--gray-700)] leading-snug">{s.title}</div>
                      </div>
                    </div>
                  ))}
                </div>
                {/* Sidebar */}
                <div className="border-l-2 border-[var(--black)] bg-[var(--gray-50)] p-4">
                  <div className="font-sans text-[10px] font-bold uppercase tracking-[0.1em] text-[var(--gray-500)] mb-3 pb-2 border-b border-[var(--gray-200)]">AI Suggestions</div>
                  <div className="bg-white border-2 border-[var(--black)] p-3 mb-3">
                    <p className="text-[12px] text-[var(--gray-600)] leading-relaxed mb-3">Consider adding OAuth with Google — Marcus would expect this for quick signup.</p>
                    <div className="flex gap-1">
                      <button className="font-sans text-[10px] font-semibold px-3 py-1 bg-[var(--black)] text-white">Accept</button>
                      <button className="font-sans text-[10px] font-semibold px-3 py-1 border-2 border-[var(--black)]">Edit</button>
                      <button className="font-sans text-[10px] text-[var(--gray-400)] px-2 py-1">Skip</button>
                    </div>
                  </div>
                  <div className="bg-white border border-[var(--gray-200)] p-3">
                    <p className="text-[12px] text-[var(--gray-600)] leading-relaxed">Add a story for PRD export — Rina&rsquo;s team needs markdown output.</p>
                  </div>
                </div>
              </div>
              {/* Bottom */}
              <div className="flex justify-between items-center px-6 py-3 border-t-2 border-[var(--black)] bg-[var(--gray-50)]">
                <button className="font-mono text-[11px] text-[var(--gray-400)]">&larr; Back</button>
                <div className="flex gap-2">
                  <button className="font-sans text-[11px] font-semibold px-4 py-1.5 border-2 border-[var(--black)] text-[var(--gray-600)]">Save &amp; Exit</button>
                  <button className="font-sans text-[11px] font-semibold px-4 py-1.5 bg-[var(--black)] text-white">Next Step &rarr;</button>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Screen 2: Agent Dashboard */}
        <div className="mb-16">
          <p className="font-sans text-xs font-bold uppercase tracking-[0.1em] text-[var(--gray-500)] mb-3 pb-2 border-b border-[var(--gray-200)]">Ink Phase</p>
          <div className="border-2 border-[var(--black)] overflow-hidden">
            <div className="bg-[var(--black)] px-4 py-2.5 flex items-center gap-3">
              <div className="flex gap-1.5">
                <div className="w-2.5 h-2.5 rounded-full bg-[var(--red)]" />
                <div className="w-2.5 h-2.5 rounded-full bg-[var(--yellow)]" />
                <div className="w-2.5 h-2.5 rounded-full bg-[var(--success)]" />
              </div>
              <div className="font-mono text-[11px] text-[var(--gray-400)] bg-[var(--gray-800)] px-3 py-0.5 flex-1 max-w-[280px]">noizu.ink/project/ink-042/ink</div>
            </div>
            <div>
              {/* Phase tabs */}
              <div className="flex border-b-2 border-[var(--black)]">
                {['✓ Sketch', '✓ Draft', 'Ink', 'Publish'].map((tab, i) => (
                  <div key={i} className={`flex-1 text-center py-2 text-[12px] font-semibold uppercase tracking-wide border-r-2 border-[var(--black)] last:border-r-0 ${
                    i < 2 ? 'bg-[var(--gray-100)] text-[var(--black)]' :
                    i === 2 ? 'bg-[var(--black)] text-white' :
                    'text-[var(--gray-400)]'
                  }`}>{tab}</div>
                ))}
              </div>
              {/* Three panel */}
              <div className="grid grid-cols-[200px_1fr_220px] min-h-[340px]">
                {/* Backlog */}
                <div className="border-r-2 border-[var(--black)] p-4">
                  <div className="font-sans text-[10px] font-bold uppercase tracking-[0.1em] text-[var(--gray-500)] mb-3 pb-2 border-b border-[var(--gray-200)]">Backlog</div>
                  {[
                    { id: 'INK-040', title: 'Project scaffold', status: 'done' },
                    { id: 'INK-041', title: 'API route setup', status: 'done' },
                    { id: 'INK-042', title: 'User auth flow', status: 'building', active: true },
                    { id: 'INK-043', title: 'Dashboard layout', status: 'queued' },
                    { id: 'INK-044', title: 'Wizard engine', status: 'queued' },
                  ].map((s) => (
                    <div key={s.id} className={`flex items-start gap-2 py-1.5 px-2 ${s.active ? 'bg-[var(--gray-100)] border-l-[3px] border-[var(--black)] -ml-[3px]' : ''}`}>
                      <div className={`w-2 h-2 mt-1 shrink-0 ${
                        s.status === 'done' ? 'bg-[var(--black)]' :
                        s.status === 'building' ? 'bg-[var(--blue)] animate-pulse' :
                        'bg-[var(--gray-300)]'
                      }`} />
                      <div>
                        <div className="font-mono text-[9px] text-[var(--gray-400)]">{s.id}</div>
                        <div className={`text-[12px] leading-snug ${s.active ? 'font-semibold text-[var(--black)]' : 'text-[var(--gray-700)]'}`}>{s.title}</div>
                      </div>
                    </div>
                  ))}
                </div>
                {/* Live output */}
                <div className="bg-[var(--gray-900)] p-4 border-r-2 border-[var(--black)]">
                  <div className="font-sans text-[10px] font-bold uppercase tracking-[0.1em] text-[var(--gray-500)] mb-3 pb-2 border-b border-[var(--gray-700)] flex justify-between">
                    <span>Live Output</span>
                    <span className="text-[var(--red)] font-bold">&#9632; LIVE</span>
                  </div>
                  <div className="font-mono text-[11px] leading-[1.9] text-[var(--gray-400)]">
                    <div><span className="text-[var(--gray-600)]">[14:23:01]</span> <span className="text-white">coder</span> Starting INK-042</div>
                    <div><span className="text-[var(--gray-600)]">[14:23:04]</span> <span className="text-white">write</span> src/lib/auth/providers.ts</div>
                    <div><span className="text-[var(--gray-600)]">[14:23:22]</span> <span className="text-white">test</span> Running auth suite...</div>
                    <div><span className="text-[var(--gray-600)]">[14:23:28]</span> <span className="text-[#69db7c]">PASS</span> providers (3/3)</div>
                    <div><span className="text-[var(--gray-600)]">[14:23:30]</span> <span className="text-[#ff6b6b]">FAIL</span> middleware (2/4)</div>
                    <div><span className="text-[var(--gray-600)]">[14:23:33]</span> <span className="text-white">write</span> src/middleware.ts (v2)</div>
                    <div><span className="text-[var(--gray-600)]">[14:23:39]</span> <span className="text-[#69db7c]">All tests passing (12/12)</span></div>
                  </div>
                  <div className="flex gap-1 mt-4 pt-3 border-t-2 border-[var(--gray-700)]">
                    <button className="font-sans text-[10px] font-bold px-3 py-1.5 bg-white text-[var(--black)]">Approve</button>
                    <button className="font-sans text-[10px] px-3 py-1.5 border border-[var(--gray-600)] text-[var(--gray-400)]">Changes</button>
                    <button className="font-sans text-[10px] px-3 py-1.5 text-[var(--gray-500)]">Pause</button>
                  </div>
                </div>
                {/* Criteria */}
                <div className="p-4">
                  <div className="font-sans text-[10px] font-bold uppercase tracking-[0.1em] text-[var(--gray-500)] mb-3 pb-2 border-b border-[var(--gray-200)]">Criteria</div>
                  <div className="text-[14px] font-bold tracking-tight mb-3">INK-042: User Auth</div>
                  {['OAuth2 Google', 'OAuth2 GitHub', 'JWT sessions', 'Route protection'].map((c) => (
                    <div key={c} className="flex items-center gap-2 py-1.5 text-[12px] text-[var(--gray-700)] border-b border-[var(--gray-100)]">
                      <div className="w-4 h-4 bg-[var(--black)] text-white flex items-center justify-center text-[9px] font-bold shrink-0">&#10003;</div>
                      {c}
                    </div>
                  ))}
                  {['Token refresh', 'Sign-out'].map((c) => (
                    <div key={c} className="flex items-center gap-2 py-1.5 text-[12px] text-[var(--gray-400)] border-b border-[var(--gray-100)]">
                      <div className="w-4 h-4 border-2 border-[var(--gray-300)] flex items-center justify-center text-[9px] shrink-0">&ndash;</div>
                      {c}
                    </div>
                  ))}
                  <div className="mt-4 pt-3 border-t border-[var(--gray-200)]">
                    <div className="font-sans text-[10px] font-bold uppercase tracking-[0.1em] text-[var(--gray-500)] mb-2">Stats</div>
                    <div className="font-mono text-[11px] text-[var(--gray-600)] flex flex-col gap-1">
                      <div className="flex justify-between"><span>Files</span><span className="font-semibold text-[var(--black)]">5</span></div>
                      <div className="flex justify-between"><span>Added</span><span className="text-[var(--success)] font-semibold">+142</span></div>
                      <div className="flex justify-between"><span>Tests</span><span className="font-semibold text-[var(--black)]">12/12</span></div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Screen 3: Demo */}
        <div>
          <p className="font-sans text-xs font-bold uppercase tracking-[0.1em] text-[var(--gray-500)] mb-3 pb-2 border-b border-[var(--gray-200)]">Demo Preview</p>
          <div className="border-2 border-[var(--black)] overflow-hidden">
            <div className="bg-[var(--black)] px-4 py-2.5 flex items-center gap-3">
              <div className="flex gap-1.5">
                <div className="w-2.5 h-2.5 rounded-full bg-[var(--red)]" />
                <div className="w-2.5 h-2.5 rounded-full bg-[var(--yellow)]" />
                <div className="w-2.5 h-2.5 rounded-full bg-[var(--success)]" />
              </div>
              <div className="font-mono text-[11px] text-[var(--gray-400)] bg-[var(--gray-800)] px-3 py-0.5 flex-1 max-w-[280px]">ink-042.noizu.ink</div>
            </div>
            <div className="bg-white min-h-[320px] relative" style={{ fontFamily: 'system-ui' }}>
              <div className="bg-[var(--black)] text-white px-6 py-3 flex items-center justify-between text-sm">
                <span className="font-semibold">MyApp</span>
                <div className="flex gap-4 text-xs text-gray-400">
                  <span>Dashboard</span><span className="text-white">Projects</span><span>Settings</span>
                </div>
              </div>
              <div className="p-6">
                <h2 className="text-xl font-semibold text-gray-900 mb-4">Projects</h2>
                <div className="grid grid-cols-3 gap-4">
                  {['User Auth', 'Dashboard', 'API Layer'].map((name) => (
                    <div key={name} className="border border-gray-200 rounded-lg p-4 bg-gray-50">
                      <div className="text-sm font-medium text-gray-900 mb-1">{name}</div>
                      <div className="text-xs text-gray-500">3 stories completed</div>
                      <div className="mt-3 flex gap-1">
                        {Array.from({ length: 5 }).map((_, i) => (
                          <div key={i} className={`flex-1 h-1 rounded-full ${i < 3 ? 'bg-green-500' : 'bg-gray-200'}`} />
                        ))}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
              <div className="absolute bottom-4 left-1/2 -translate-x-1/2 bg-[var(--black)] text-white px-4 py-2 flex items-center gap-4 font-mono text-[10px] uppercase tracking-wide">
                <span className="text-[#69db7c]">&#9632; Live</span>
                <span className="text-[var(--gray-400)]">7 / 10 stories</span>
                <button className="text-white border border-[var(--gray-600)] px-2 py-0.5">Open &rarr;</button>
              </div>
            </div>
          </div>
        </div>
      </section>

      <hr className="max-w-[1200px] mx-auto border-none h-px bg-[var(--gray-200)]" />

      {/* ═══ FEATURES ═══ */}
      <section id="features" className="max-w-[1200px] mx-auto px-8 py-24">
        <div className="grid grid-cols-[64px_1fr] gap-4 items-start mb-10 pb-6 border-b-2 border-[var(--black)]">
          <div className="text-5xl font-bold text-[var(--gray-200)] leading-none">03</div>
          <div>
            <h2 className="text-[28px] font-bold tracking-tight leading-tight">Why This Way</h2>
            <p className="font-mono text-[11px] text-[var(--gray-500)] mt-1">Structure over improvisation. The system works.</p>
          </div>
        </div>

        <div className="grid grid-cols-3 gap-4">
          {[
            { title: 'Structured, not free-form', body: 'Each step has a dedicated prompt, structured input, structured output. Bounded, cacheable, predictable.' },
            { title: 'Resumable at any point', body: 'Leave after step 4, return next week. Your project waits at exactly the step you left it.' },
            { title: 'You steer, agents build', body: 'Approve each story before it merges. Pause to edit manually. Rollback any change.' },
            { title: 'Spec before code', body: 'Sketch and Draft ensure you understand what you\'re building before agents touch a line.' },
            { title: 'Export at every boundary', body: 'PRD, style guide, mockups, working repo, live URL. Each phase has standalone value.' },
            { title: 'No decoration', body: 'No gamification. No onboarding tours. No spinners. The pipeline IS the experience.' },
          ].map((f) => (
            <div key={f.title} className="border-2 border-[var(--black)] p-6 hover:bg-[var(--gray-50)] transition-colors">
              <h3 className="text-[16px] font-bold tracking-tight mb-2">{f.title}</h3>
              <p className="text-[14px] text-[var(--gray-600)] leading-relaxed">{f.body}</p>
            </div>
          ))}
        </div>
      </section>

      <hr className="max-w-[1200px] mx-auto border-none h-0.5 bg-[var(--black)]" />

      {/* ═══ PERSONAS ═══ */}
      <section className="max-w-[1200px] mx-auto px-8 py-24">
        <div className="grid grid-cols-[64px_1fr] gap-4 items-start mb-10 pb-6 border-b-2 border-[var(--black)]">
          <div className="text-5xl font-bold text-[var(--gray-200)] leading-none">04</div>
          <div>
            <h2 className="text-[28px] font-bold tracking-tight leading-tight">Who This Is For</h2>
            <p className="font-mono text-[11px] text-[var(--gray-500)] mt-1">Three people. One pipeline. Zero excuses.</p>
          </div>
        </div>

        <div className="grid grid-cols-3 gap-4">
          {[
            { name: 'Weekend Builder', desc: 'Developer with a day job and 30 ideas in Apple Notes. Needs a deployed demo by Monday.', tag: 'solo dev' },
            { name: 'Indie Hacker', desc: 'Building for revenue. Can spec and design, but 40 hours of scaffolding kills momentum.', tag: 'ship fast' },
            { name: 'Small Team Lead', desc: '2-5 person team, no PM or designer. Everyone has a different mental model.', tag: 'alignment' },
          ].map((p) => (
            <div key={p.name} className="border-2 border-[var(--black)] border-t-8 border-t-[var(--red)] p-6">
              <h3 className="text-base font-bold tracking-tight mb-2">{p.name}</h3>
              <p className="text-[14px] text-[var(--gray-600)] leading-relaxed mb-4">{p.desc}</p>
              <span className="font-mono text-[10px] font-medium px-2 py-0.5 bg-[var(--gray-100)] text-[var(--gray-700)]">{p.tag}</span>
            </div>
          ))}
        </div>
      </section>

      <hr className="max-w-[1200px] mx-auto border-none h-px bg-[var(--gray-200)]" />

      {/* ═══ PRICING ═══ */}
      <section id="pricing" className="max-w-[1200px] mx-auto px-8 py-24">
        <div className="grid grid-cols-[64px_1fr] gap-4 items-start mb-10 pb-6 border-b-2 border-[var(--black)]">
          <div className="text-5xl font-bold text-[var(--gray-200)] leading-none">05</div>
          <div>
            <h2 className="text-[28px] font-bold tracking-tight leading-tight">Pricing</h2>
            <p className="font-mono text-[11px] text-[var(--gray-500)] mt-1">Pay for what you use. Start free.</p>
          </div>
        </div>

        <div className="grid grid-cols-4 gap-0">
          {[
            { name: 'Free', price: '$0', phases: 'Sketch', desc: '3 projects, markdown export' },
            { name: 'Pro', price: '$19', phases: 'Sketch + Draft', desc: 'Unlimited projects, style guides, mockups' },
            { name: 'Builder', price: '$49', phases: '+ Ink', desc: 'Agent dev, demo preview, GitHub export', featured: true },
            { name: 'Launch', price: '$99', phases: 'All phases', desc: 'One-click deploy, CI/CD, monitoring' },
          ].map((t) => (
            <div key={t.name} className={`border-2 border-[var(--black)] -ml-0.5 first:ml-0 p-6 ${t.featured ? 'bg-[var(--black)] text-white' : ''}`}>
              <h3 className={`text-base font-bold tracking-tight mb-1 ${t.featured ? '' : ''}`}>{t.name}</h3>
              <div className="text-3xl font-bold tracking-tight mb-1">{t.price}<span className={`text-sm font-normal ${t.featured ? 'text-[var(--gray-400)]' : 'text-[var(--gray-500)]'}`}>/mo</span></div>
              <div className={`font-mono text-[10px] uppercase tracking-wide mb-4 ${t.featured ? 'text-[var(--gray-400)]' : 'text-[var(--gray-500)]'}`}>{t.phases}</div>
              <p className={`text-[13px] leading-relaxed mb-6 ${t.featured ? 'text-[var(--gray-400)]' : 'text-[var(--gray-600)]'}`}>{t.desc}</p>
              <button className={`w-full text-[12px] font-semibold py-2 tracking-tight ${
                t.featured ? 'bg-white text-[var(--black)] hover:bg-[var(--gray-100)]' : 'bg-[var(--black)] text-white hover:bg-[var(--gray-800)]'
              } transition-colors`}>
                Get Started
              </button>
            </div>
          ))}
        </div>
      </section>

      <hr className="max-w-[1200px] mx-auto border-none h-0.5 bg-[var(--black)]" />

      {/* ═══ FINAL CTA ═══ */}
      <section className="max-w-[1200px] mx-auto px-8 py-32 text-center">
        <h2 className="text-[clamp(36px,6vw,64px)] font-bold tracking-[-0.04em] leading-[0.95] text-[var(--black)] mb-4">
          The blank page<br />never fills itself<span className="text-[var(--red)]">.</span>
        </h2>
        <p className="text-[15px] text-[var(--gray-600)] max-w-md mx-auto mb-8 leading-relaxed">
          Everyone has the first five minutes of enthusiasm. Let the machines handle the fifty hours of follow-through.
        </p>
        <a href="#" className="inline-block font-sans text-[13px] font-semibold px-8 py-3 bg-[var(--red)] text-white tracking-tight transition-colors hover:bg-[#c80511]">
          Start your first project — free
        </a>
      </section>

      {/* ═══ FOOTER ═══ */}
      <footer className="border-t-4 border-[var(--black)] max-w-[1200px] mx-auto px-8">
        <div className="py-8 grid grid-cols-[1fr_auto] items-center">
          <div>
            <div className="text-xl font-bold tracking-tight">noizu<span className="text-[var(--red)]">.</span>ink</div>
            <div className="font-mono text-[10px] text-[var(--gray-500)] mt-0.5">Swiss Grid / Form Follows Function / 2026</div>
          </div>
          <div className="flex gap-0 h-8">
            <div className="w-8 bg-[var(--red)]" />
            <div className="w-8 bg-[var(--blue)]" />
            <div className="w-8 bg-[var(--yellow)]" />
            <div className="w-8 bg-[var(--black)]" />
          </div>
        </div>
      </footer>
    </div>
  );
}
