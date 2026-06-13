export function StyleCard() {
  return (
    <div className="style-card">
      <div className="style-card-hero">
        <div className="style-card-seal">&#9672;</div>
        <h1 className="style-card-title">
          noizu<span style={{ color: "var(--brand-red)" }}>.</span>ink
        </h1>
        <div className="style-card-subtitle">
          Swiss Grid Style Guide &middot; Form Follows Function
        </div>
        <p className="style-card-epigraph">
          &ldquo;The grid is not a cage &mdash; it is a guarantee. Every element
          is accountable. Form follows function. The system works.&rdquo;
        </p>
      </div>
      <div className="style-card-color-bar">
        <div style={{ background: "var(--brand-red)" }} />
        <div style={{ background: "var(--brand-blue)" }} />
        <div style={{ background: "var(--brand-yellow)" }} />
        <div style={{ background: "var(--black)" }} />
        <div style={{ background: "var(--white)" }} />
      </div>
      <div className="style-card-meta">
        <div className="style-card-meta-item">
          <div className="style-card-meta-label">Typefaces</div>
          <div className="style-card-meta-value">
            Space Grotesk + IBM Plex Mono
          </div>
        </div>
        <div className="style-card-meta-item">
          <div className="style-card-meta-label">Grid</div>
          <div className="style-card-meta-value">
            8px base unit &middot; 12 columns
          </div>
        </div>
        <div className="style-card-meta-item">
          <div className="style-card-meta-label">Border Radius</div>
          <div className="style-card-meta-value">0&ndash;2px &mdash; sharp edges only</div>
        </div>
        <div className="style-card-meta-item">
          <div className="style-card-meta-label">Philosophy</div>
          <div className="style-card-meta-value">
            International Typographic Style
          </div>
        </div>
      </div>
    </div>
  );
}
