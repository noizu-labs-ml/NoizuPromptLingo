import NeuralCanvas from "@/components/NeuralCanvas";
import WaitlistForm from "@/components/WaitlistForm";
import CounterAnimation from "@/components/CounterAnimation";

export default function Home() {
  return (
    <>
      {/* NAV */}
      <nav className="nav">
        <div className="container">
          <div className="nav-logo">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200" width="28" height="28" aria-hidden="true" focusable="false">
              <polygon points="38,100 82,35 82,165" fill="#FF3366"/>
              <polygon points="162,100 118,35 118,165" fill="#00FFAA"/>
              <circle cx="100" cy="100" r="10" fill="#FFFFFF"/>
            </svg>
            AI Fighter
          </div>
          <a href="#waitlist" className="nav-cta">
            Join Waitlist
          </a>
        </div>
      </nav>

      {/* HERO */}
      <section className="hero" id="top">
        <div className="container">
          <div className="hero-content">
            <div className="hero-badge">
              <span className="hero-badge-dot" />
              Coming 2026 &mdash; iOS &amp; Android
            </div>
            <h1>
              Design the
              <br />
              <span className="accent">intelligence.</span>
              <br />
              Win the fight.
            </h1>
            <p className="hero-sub">
              The first mobile game where you architect your fighter&apos;s
              brain. Wire neural networks. Train decision graphs. Battle in
              ranked arenas. Your strategy <em>is</em> the AI.
            </p>
            <WaitlistForm />
            <p className="hero-proof">
              <CounterAnimation target={2847} /> fighters already on the
              waitlist
            </p>
          </div>
        </div>
        <div className="hero-visual">
          <NeuralCanvas />
        </div>
      </section>

      {/* PROOF BAR */}
      <div className="proof-bar">
        <div className="container">
          <p>
            <strong>Free to play</strong> &nbsp;&middot;&nbsp;
            <strong>Never pay-to-win</strong> &nbsp;&middot;&nbsp;
            <strong>The graph is sacred</strong> &nbsp;&middot;&nbsp; Skill
            wins, not wallets
          </p>
        </div>
      </div>

      {/* FEATURES */}
      <section className="features" id="features">
        <div className="container">
          <div className="section-label">Core Loop</div>
          <h2 className="section-title">Build. Train. Battle.</h2>
          <p className="section-desc">
            Three interconnected systems that create a game loop where every win
            feels earned and every loss teaches you something.
          </p>
          <div className="feature-grid">
            <div className="feature-card">
              <div className="feature-icon feature-icon--synapse">&#129504;</div>
              <h3>Fighter Studio</h3>
              <p>
                Visual graph editor for your fighter&apos;s brain. Drag
                perception nodes (distance, health, stamina) into decision nodes
                (aggression, risk tolerance) that feed action nodes (attack,
                block, dodge). No code required.
              </p>
            </div>
            <div className="feature-card">
              <div className="feature-icon feature-icon--signal">&#9881;</div>
              <h3>Training Gym</h3>
              <p>
                Spar against AI archetypes. Watch your fighter evolve over
                generations. See decision heatmaps that reveal <em>why</em> your
                AI does what it does. Then tweak the graph and run it again.
              </p>
            </div>
            <div className="feature-card">
              <div className="feature-icon feature-icon--combat">&#9876;</div>
              <h3>Ranked Arena</h3>
              <p>
                Submit your fighter to async PvP. Battles resolve server-side
                &mdash; watch the replay with a decision overlay showing every
                choice your AI made. Climb from Bronze to the Neural tier.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* HOW IT WORKS */}
      <section className="how-it-works">
        <div className="container">
          <div className="section-label">Getting Started</div>
          <h2 className="section-title">Three minutes to your first fight</h2>
          <div className="steps">
            <div className="step">
              <div
                className="step-number"
                style={{ color: "rgba(0, 255, 170, 0.15)" }}
              >
                01
              </div>
              <h3>Wire the brain</h3>
              <p>
                Start with a template or blank graph. Connect perception,
                decision, and action nodes to create your fighter&apos;s
                strategy.
              </p>
              <span className="step-connector">&#8594;</span>
            </div>
            <div className="step">
              <div
                className="step-number"
                style={{ color: "rgba(41, 121, 255, 0.15)" }}
              >
                02
              </div>
              <h3>Train &amp; evolve</h3>
              <p>
                Run generations against sparring partners. Watch win rates climb.
                See behavioral analytics that tell you exactly what to tweak.
              </p>
              <span className="step-connector">&#8594;</span>
            </div>
            <div className="step">
              <div
                className="step-number"
                style={{ color: "rgba(255, 45, 85, 0.15)" }}
              >
                03
              </div>
              <h3>Enter the arena</h3>
              <p>
                Submit to ranked matchmaking. Watch the battle replay with
                decision traces. Adjust your graph. Climb the ladder.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* GRAPH DEMO */}
      <section className="graph-demo">
        <div className="container">
          <div className="graph-demo-inner">
            <div className="graph-mock">
              <div className="graph-mock-title">
                Fighter Studio &mdash; VOLT-9
              </div>
              <div className="graph-nodes">
                <div className="graph-node-row">
                  <div className="gnode">
                    <div className="gnode-type">perception</div>
                    <div className="gnode-name">Distance</div>
                    <div className="gnode-val">&#8594; float [0..1]</div>
                  </div>
                  <div className="gnode">
                    <div className="gnode-type">perception</div>
                    <div className="gnode-name">Health %</div>
                    <div className="gnode-val">&#8594; float [0..1]</div>
                  </div>
                  <div className="gnode">
                    <div className="gnode-type">perception</div>
                    <div className="gnode-name">Stamina</div>
                    <div className="gnode-val">&#8594; float [0..1]</div>
                  </div>
                </div>
                <div className="graph-connector">
                  <span />
                  <span />
                  <span />
                </div>
                <div className="graph-node-row">
                  <div
                    className="gnode"
                    style={{
                      borderColor: "rgba(0, 255, 170, 0.3)",
                    }}
                  >
                    <div className="gnode-type" style={{ color: "var(--synapse)" }}>
                      decision
                    </div>
                    <div className="gnode-name">Aggression</div>
                    <div className="gnode-val">weight: 0.7</div>
                  </div>
                  <div className="gnode">
                    <div className="gnode-type">decision</div>
                    <div className="gnode-name">Risk Tol.</div>
                    <div className="gnode-val">weight: 0.4</div>
                  </div>
                </div>
                <div className="graph-connector">
                  <span />
                  <span />
                </div>
                <div className="graph-node-row">
                  <div className="gnode gnode--combat">
                    <div className="gnode-type">action</div>
                    <div className="gnode-name">Attack</div>
                    <div className="gnode-val">dmg: 12</div>
                  </div>
                  <div className="gnode gnode--signal">
                    <div className="gnode-type">action</div>
                    <div className="gnode-name">Block</div>
                    <div className="gnode-val">mit: 0.6</div>
                  </div>
                  <div className="gnode gnode--signal">
                    <div className="gnode-type">action</div>
                    <div className="gnode-name">Dodge</div>
                    <div className="gnode-val">spd: 0.8</div>
                  </div>
                </div>
              </div>
            </div>

            <div className="graph-text">
              <div className="section-label">The Core Mechanic</div>
              <h3>
                Your fighter&apos;s brain
                <br />
                is a graph you design
              </h3>
              <p>
                Most games give you a skill tree. We give you a{" "}
                <span className="highlight">blank neural network</span>. Wire
                perception nodes to decisions to actions. Adjust weights. Watch
                your fighter learn.
              </p>
              <p>
                No programming knowledge needed. The visual editor makes building
                AI feel like{" "}
                <span className="highlight">connecting LEGO blocks</span>, not
                writing code. But the depth is real &mdash; advanced players
                design graphs with 20+ nodes and emergent behaviors the creators
                didn&apos;t predict.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* BATTLE PREVIEW */}
      <section className="battle-section">
        <div className="container">
          <div className="section-label">Replays</div>
          <h2 className="section-title">Watch the AI think</h2>
          <p className="section-desc">
            Every battle comes with a decision overlay. See exactly{" "}
            <em>why</em> your fighter chose DODGE over BLOCK. Then go back to
            the graph and fix the strategy.
          </p>

          <div className="battle-preview">
            <div className="battle-header">
              <div className="battle-fighter">
                <div className="battle-fighter-name">VOLT-9</div>
                <span className="battle-rank battle-rank--gold">Gold II</span>
              </div>
              <div className="battle-vs">VS</div>
              <div className="battle-fighter">
                <div className="battle-fighter-name">RAZR-X</div>
                <span className="battle-rank battle-rank--diamond">
                  Diamond
                </span>
              </div>
            </div>

            <div className="battle-bars">
              <div className="battle-bar-row">
                <span
                  className="battle-bar-label"
                  style={{ color: "var(--synapse)" }}
                >
                  64%
                </span>
                <div className="battle-bar">
                  <div
                    className="battle-bar-fill battle-bar-fill--synapse"
                    style={{ width: "64%" }}
                  />
                </div>
              </div>
              <div className="battle-bar-row">
                <span
                  className="battle-bar-label"
                  style={{ color: "var(--combat)" }}
                >
                  31%
                </span>
                <div className="battle-bar">
                  <div
                    className="battle-bar-fill battle-bar-fill--combat"
                    style={{ width: "31%" }}
                  />
                </div>
              </div>
            </div>

            <div className="decision-trace">
              <div className="decision-trace-header">
                Decision Overlay &mdash; VOLT-9 @ 2:34
              </div>
              <div className="decision-trace-action">CHOSE: DODGE</div>
              <div className="decision-trace-reason">
                Health &lt; 40% &nbsp;&middot;&nbsp; Enemy winding heavy attack
                &nbsp;&middot;&nbsp; Stamina sufficient
              </div>
              <div className="decision-trace-conf">
                confidence: 0.89 &nbsp;&middot;&nbsp; alternatives: BLOCK
                (0.42), RETREAT (0.31)
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* FAQ */}
      <section className="faq" id="faq">
        <div className="container">
          <div className="section-label">Questions</div>
          <h2 className="section-title">FAQ</h2>
          <div className="faq-grid">
            <div className="faq-item">
              <h3>Do I need to know programming?</h3>
              <p>
                No. The graph editor is visual &mdash; drag nodes and connect
                them. If you can play Minecraft redstone, you can build a
                fighter. Advanced players will find depth, but beginners start
                with pre-built templates.
              </p>
            </div>
            <div className="faq-item">
              <h3>Is it pay-to-win?</h3>
              <p>
                Never. The graph is sacred. There are no purchasable nodes that
                give competitive advantage. Monetization is cosmetics, seasonal
                passes, and convenience items only. Skill wins.
              </p>
            </div>
            <div className="faq-item">
              <h3>What platforms?</h3>
              <p>
                iOS and Android at launch. The graph editor and battle replays
                are designed for mobile touch screens. A web-based companion tool
                for advanced graph editing is planned post-launch.
              </p>
            </div>
            <div className="faq-item">
              <h3>Is it real-time multiplayer?</h3>
              <p>
                Battles are async &mdash; you submit your fighter and battles
                resolve server-side. Watch replays anytime. This means no lag, no
                disconnects, and your fighter competes even while you sleep.
              </p>
            </div>
            <div className="faq-item">
              <h3>When does it launch?</h3>
              <p>
                2026. Join the waitlist to get early access to the closed beta.
                Founding members will receive the Fighter Pass free for the first
                season.
              </p>
            </div>
            <div className="faq-item">
              <h3>Can I share my builds?</h3>
              <p>
                Yes. Export your fighter&apos;s graph to share with friends or
                the community. Import builds from the Laboratory to study how top
                players wire their networks. Optional obfuscation protects secret
                strats.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* FINAL CTA */}
      <section className="final-cta" id="waitlist">
        <div className="container">
          <div className="section-label">Early Access</div>
          <h2 className="section-title">
            Ready to build
            <br />
            your first fighter?
          </h2>
          <p className="section-desc">
            Founding members get the Fighter Pass free for Season 1.
            <br />
            No spam. Unsubscribe anytime.
          </p>
          <WaitlistForm buttonText="Get Early Access" />
          <p className="hero-proof">
            <strong>Free to play</strong> &middot; No credit card required
          </p>
        </div>
      </section>

      {/* FOOTER */}
      <footer className="footer">
        <div className="container">
          <div className="footer-copy">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200" width="18" height="18" aria-hidden="true" focusable="false">
              <polygon points="38,100 82,35 82,165" fill="#FF3366"/>
              <polygon points="162,100 118,35 118,165" fill="#00FFAA"/>
              <circle cx="100" cy="100" r="10" fill="#FFFFFF"/>
            </svg>
            &copy; 2026 AI Fighter &middot; NOIZUAI-10
          </div>
          <div className="footer-links">
            <a href="#top">Back to top</a>
            <a href="#">Privacy</a>
            <a href="#">Terms</a>
          </div>
        </div>
      </footer>
    </>
  );
}
