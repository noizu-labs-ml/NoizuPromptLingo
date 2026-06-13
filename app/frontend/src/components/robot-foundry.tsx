/**
 * Metropolis Foundry — 7 robot body types × 10 poses each.
 * Converted from the static HTML reference into React SVG components.
 * All stroke, no fill. Uses currentColor + theme vars.
 */

const poseNames = ["Stand", "Wave", "Think", "Build", "Run", "Celeb", "Point", "Sit", "Up", "Power"];

/* ═══ 01. Industrial — Standard box robot ═══ */
const industrial = [
  "M25 10h20v16H25z M25 10l4-4h12l-4 4 M45 10l4-4v16l-4 4 M25 26h20v16H25z M25 26l4 4h12l-4-4 M25 42l4 4h12l-4-4 M25 32h-4l-2 2v4l2 2h4 M45 32h4l2 2v4l-2 2h-4 M29 46v6h4v-6 M41 46v6h4v-6",
  "M25 10h20v16H25z M25 10l4-4h12l-4 4 M45 10l4-4v16l-4 4 M25 26h20v16H25z M25 26l4 4h12l-4-4 M25 42l4 4h12l-4-4 M25 32h-4l-2 2v4l2 2h4 M45 30h4l2-2v-4l2-2h2 M29 46v6h4v-6 M41 46v6h4v-6",
  "M25 26h20v16H25z M25 26l4 4h12l-4-4 M25 42l4 4h12l-4-4 M25 32h-4l-4-4v-4l2-2h2l4 8 M45 32h4l2 2v4l-2 2h-4 M29 46v6h4v-6 M41 46v6h4v-6",
  "M25 10h20v16H25z M25 10l4-4h12l-4 4 M45 10l4-4v16l-4 4 M25 26h20v16H25z M25 26l4 4h12l-4-4 M25 42l4 4h12l-4-4 M25 32h-4l-2 2v4l2 2h4 M45 30h6l2-1v-2l-2-1h-2 M53 26l2-3 M53 26l-2-3 M29 46v6h4v-6 M41 46v6h4v-6",
  "M25 10h20v16H25z M25 10l4-4h12l-4 4 M45 10l4-4v16l-4 4 M25 26h20v16H25z M25 26l4 4h12l-4-4 M25 42l4 4h12l-4-4 M25 32h-4l-2 2v4l2 2h4 M45 32h4l2 2v4l-2 2h-4 M29 46l-4 6h4l4-6 M41 46l4 6h4l-4-6",
  "M25 10h20v16H25z M25 10l4-4h12l-4 4 M45 10l4-4v16l-4 4 M25 26h20v16H25z M25 26l4 4h12l-4-4 M25 42l4 4h12l-4-4 M25 28h-4l-2-2v-4l-2-2h-2 M45 28h4l2-2v-4l2-2h2 M29 46v6h4v-6 M41 46v6h4v-6",
  "M25 10h20v16H25z M25 10l4-4h12l-4 4 M45 10l4-4v16l-4 4 M25 26h20v16H25z M25 26l4 4h12l-4-4 M25 42l4 4h12l-4-4 M25 32h-4l-2 2v4l2 2h4 M45 34h10 M55 32v4 M53 33l4 1-4 1 M29 46v6h4v-6 M41 46v6h4v-6",
  "M25 10h20v16H25z M25 10l4-4h12l-4 4 M45 10l4-4v16l-4 4 M25 26h20v16H25z M25 26l4 4h12l-4-4 M25 42l4 4h12l-4-4 M25 32h-4l-2 2v4l2 2h4 M45 32h4l2 2v4l-2 2h-4 M29 46l-2 3h4l2-3 M41 46l2 3h4l-2-3 M25 49h20",
  "M25 26h20v16H25z M25 26l4 4h12l-4-4 M25 42l4 4h12l-4-4 M25 32h-4l-2 2v4l2 2h4 M45 32h4l2 2v4l-2 2h-4 M29 46v6h4v-6 M41 46v6h4v-6",
  "M25 10h20v16H25z M25 10l4-4h12l-4 4 M45 10l4-4v16l-4 4 M25 26h20v16H25z M25 26l4 4h12l-4-4 M25 42l4 4h12l-4-4 M25 28l-4 4v4l6-2 M45 28l4 4v4l-6-2 M33 46l-4 6h4l4-6 M43 46l4 6h-4l-4-6",
];

/* ═══ 02. Deco Lady — Trapezoid dress ═══ */
const decoLady = [
  "M28 8h14l2 4H26z M28 8q2-4 7-4q5 0 7 4 M23 28h24l-12 20z M28 36h14 M23 36q-4 4-4 8 M47 36q4 4 4 8 M33 46v4 M41 46v4",
  "M28 8h14l2 4H26z M28 8q2-4 7-4q5 0 7 4 M23 28h24l-12 20z M28 36h14 M23 36q-4 4-4 8 M47 30q8-2 10-8 M33 46v4 M41 46v4",
  "M23 28h24l-12 20z M28 36h14 M23 40q-6-2-6 2 M47 36q4 4 4 8 M33 46v4 M41 46v4",
  "M28 8h14l2 4H26z M28 8q2-4 7-4q5 0 7 4 M23 28h24l-12 20z M28 36h14 M23 36q-4 4-4 8 M47 34h8l2 1 M33 46v4 M41 46v4",
  "M28 8h14l2 4H26z M28 8q2-4 7-4q5 0 7 4 M23 28h24l-12 20z M28 36h14 M23 36q-6 4-8 8 M47 36q6 4 8 8 M33 46l-4 6 M41 46l4 6",
  "M28 8h14l2 4H26z M28 8q2-4 7-4q5 0 7 4 M23 28h24l-12 20z M28 36h14 M23 30q-6-4-4-10 M47 30q6-4 4-10 M33 46v4 M41 46v4",
  "M28 8h14l2 4H26z M28 8q2-4 7-4q5 0 7 4 M23 28h24l-12 20z M28 36h14 M23 36q-4 4-4 8 M47 36h10 M55 34v4 M33 46v4 M41 46v4",
  "M28 8h14l2 4H26z M28 8q2-4 7-4q5 0 7 4 M23 28h24l-12 20z M28 36h14 M23 36q-4 4-4 8 M47 36q4 4 4 8",
  "M23 28h24l-12 20z M28 36h14 M23 36q-4 4-4 8 M47 36q4 4 4 8 M33 46v4 M41 46v4",
  "M28 8h14l2 4H26z M28 8q2-4 7-4q5 0 7 4 M23 28h24l-12 20z M28 36h14 M23 32l-4 4v4l4 2 M47 32l4 4v4l-4 2",
];

/* ═══ 03. Egghead — Big head, tiny body ═══ */
const egghead = [
  "M15-2h40a4 4 0 0 1 4 4v14a4 4 0 0 1-4 4h-40a4 4 0 0 1-4-4v-14 M20 6h6v6h-6z M44 6h6v6h-6z M25 28h20v10h-20z M25 32h-4l-2 2 M45 32h4l2 2 M32 38v4 M38 38v4",
  "M15-2h40a4 4 0 0 1 4 4v14a4 4 0 0 1-4 4h-40a4 4 0 0 1-4-4v-14 M20 6h6v6h-6z M44 6h6v6h-6z M25 28h20v10h-20z M25 32h-4l-2 2 M45 30q6-2 8-8 M32 38v4 M38 38v4",
  "M25 28h20v10h-20z M25 32q-4 0-6 4 M45 32h4l2 2 M32 38v4 M38 38v4",
  "M15-2h40a4 4 0 0 1 4 4v14a4 4 0 0 1-4 4h-40a4 4 0 0 1-4-4v-14 M20 6h6v6h-6z M44 6h6v6h-6z M25 28h20v10h-20z M25 32h-4l-2 2 M45 30h6l2-1 M32 38v4 M38 38v4",
  "M15-2h40a4 4 0 0 1 4 4v14a4 4 0 0 1-4 4h-40a4 4 0 0 1-4-4v-14 M20 6h6v6h-6z M44 6h6v6h-6z M25 28h20v10h-20z M25 32h-4l-2 2 M45 32h4l2 2 M32 38l-4 6 M38 38l4 6",
  "M15-2h40a4 4 0 0 1 4 4v14a4 4 0 0 1-4 4h-40a4 4 0 0 1-4-4v-14 M20 6h6v6h-6z M44 6h6v6h-6z M25 28h20v10h-20z M25 30h-4l-2-2 M45 30h4l2-2 M32 38v4 M38 38v4",
  "M15-2h40a4 4 0 0 1 4 4v14a4 4 0 0 1-4 4h-40a4 4 0 0 1-4-4v-14 M20 6h6v6h-6z M44 6h6v6h-6z M25 28h20v10h-20z M25 32h-4l-2 2 M45 34h10 M55 32v4 M32 38v4 M38 38v4",
  "M15-2h40a4 4 0 0 1 4 4v14a4 4 0 0 1-4 4h-40a4 4 0 0 1-4-4v-14 M20 6h6v6h-6z M44 6h6v6h-6z M25 28h20v10h-20z M25 32h-4l-2 2 M45 32h4l2 2 M30 40h10",
  "M25 28h20v10h-20z M25 32h-4l-2 2 M45 32h4l2 2 M32 38v4 M38 38v4",
  "M15-2h40a4 4 0 0 1 4 4v14a4 4 0 0 1-4 4h-40a4 4 0 0 1-4-4v-14 M20 6h6v6h-6z M44 6h6v6h-6z M25 28h20v10h-20z M25 30l-4 4v4l4-2 M45 30l4 4v4l-4-2 M33 38v6 M37 38v6",
];

/* ═══ 04. Longshanks — Stilt walker ═══ */
const longshanks = [
  "M27 6h16v12h-16z M27 6l2-4h12l-2 4 M27 18l2 2h12l-2-2 M22 30h26v12h-26z M22 30l2-4h22l-2 4 M22 42l2 2h22l-2-2 M22 36h-4q-4 4-4 8 M48 36h4q4 4 4 8 M30 44v14h2 M42 44v14h2",
  "M27 6h16v12h-16z M27 6l2-4h12l-2 4 M27 18l2 2h12l-2-2 M22 30h26v12h-26z M22 30l2-4h22l-2 4 M22 42l2 2h22l-2-2 M22 36h-4q-4 4-4 8 M48 34q8-2 10-8 M30 44v14h2 M42 44v14h2",
  "M22 30h26v12h-26z M22 30l2-4h22l-2 4 M22 42l2 2h22l-2-2 M22 38q-6-2-6 4 M48 36h4q4 4 4 8 M30 44v14h2 M42 44v14h2",
  "M27 6h16v12h-16z M27 6l2-4h12l-2 4 M27 18l2 2h12l-2-2 M22 30h26v12h-26z M22 30l2-4h22l-2 4 M22 42l2 2h22l-2-2 M22 36h-4q-4 4-4 8 M48 34h8l2-1 M30 44v14h2 M42 44v14h2",
  "M27 6h16v12h-16z M27 6l2-4h12l-2 4 M27 18l2 2h12l-2-2 M22 30h26v12h-26z M22 30l2-4h22l-2 4 M22 42l2 2h22l-2-2 M22 36h-4q-4 4-4 8 M48 36h4q4 4 4 8 M30 44l-4 14 M42 44l4 14",
  "M27 6h16v12h-16z M27 6l2-4h12l-2 4 M27 18l2 2h12l-2-2 M22 30h26v12h-26z M22 30l2-4h22l-2 4 M22 42l2 2h22l-2-2 M22 34h-4q-6-4-4-10 M48 34h4q6-4 4-10 M30 44v14h2 M42 44v14h2",
  "M27 6h16v12h-16z M27 6l2-4h12l-2 4 M27 18l2 2h12l-2-2 M22 30h26v12h-26z M22 30l2-4h22l-2 4 M22 42l2 2h22l-2-2 M22 36h-4q-4 4-4 8 M48 38h10 M58 36v4 M30 44v14h2 M42 44v14h2",
  "M27 6h16v12h-16z M27 6l2-4h12l-2 4 M27 18l2 2h12l-2-2 M22 30h26v12h-26z M22 30l2-4h22l-2 4 M22 42l2 2h22l-2-2 M22 36h-4q-4 4-4 8 M48 36h4q4 4 4 8 M30 44h14v2h-14",
  "M22 30h26v12h-26z M22 30l2-4h22l-2 4 M22 42l2 2h22l-2-2 M22 36h-4q-4 4-4 8 M48 36h4q4 4 4 8 M30 44v14h2 M42 44v14h2",
  "M27 6h16v12h-16z M27 6l2-4h12l-2 4 M27 18l2 2h12l-2-2 M22 30h26v12h-26z M22 30l2-4h22l-2 4 M22 42l2 2h22l-2-2 M22 32l-4 4v4l6-2 M48 32l4 4v4l-6-2 M30 44v14 M42 44v14",
];

/* ═══ 05. Roundy — Capsule/pill shapes ═══ */
const roundy = [
  "M25 6h20a8 8 0 0 1 0 16h-20a8 8 0 0 1 0-16 M22 6v4 M48 6v4 M23 28h24a8 8 0 0 1 0 16h-24a8 8 0 0 1 0-16 M23 36q-6 4-2 8 M47 36q6 4 2 8 M28 44v6h2v-6 M40 44v6h2v-6",
  "M25 6h20a8 8 0 0 1 0 16h-20a8 8 0 0 1 0-16 M22 6v4 M48 6v4 M23 28h24a8 8 0 0 1 0 16h-24a8 8 0 0 1 0-16 M23 36q-6 4-2 8 M47 34q8-2 10-6 M28 44v6h2v-6 M40 44v6h2v-6",
  "M23 28h24a8 8 0 0 1 0 16h-24a8 8 0 0 1 0-16 M23 40q-6-4-6 2 M47 36q6 4 2 8 M28 44v6h2v-6 M40 44v6h2v-6",
  "M25 6h20a8 8 0 0 1 0 16h-20a8 8 0 0 1 0-16 M22 6v4 M48 6v4 M23 28h24a8 8 0 0 1 0 16h-24a8 8 0 0 1 0-16 M23 36q-6 4-2 8 M47 34h8l2 1 M28 44v6h2v-6 M40 44v6h2v-6",
  "M25 6h20a8 8 0 0 1 0 16h-20a8 8 0 0 1 0-16 M22 6v4 M48 6v4 M23 28h24a8 8 0 0 1 0 16h-24a8 8 0 0 1 0-16 M23 36q-6 4-2 8 M47 36q6 4 2 8 M28 44l-2 6 M40 44l2 6",
  "M25 6h20a8 8 0 0 1 0 16h-20a8 8 0 0 1 0-16 M22 6v4 M48 6v4 M23 28h24a8 8 0 0 1 0 16h-24a8 8 0 0 1 0-16 M23 34q-6-4-4-10 M47 34q6-4 4-10 M28 44v6h2v-6 M40 44v6h2v-6",
  "M25 6h20a8 8 0 0 1 0 16h-20a8 8 0 0 1 0-16 M22 6v4 M48 6v4 M23 28h24a8 8 0 0 1 0 16h-24a8 8 0 0 1 0-16 M23 36q-6 4-2 8 M47 38h10 M57 36v4 M28 44v6h2v-6 M40 44v6h2v-6",
  "M25 6h20a8 8 0 0 1 0 16h-20a8 8 0 0 1 0-16 M22 6v4 M48 6v4 M23 28h24a8 8 0 0 1 0 16h-24a8 8 0 0 1 0-16 M23 36q-6 4-2 8 M47 36q6 4 2 8 M28 44h14v2h-14",
  "M23 28h24a8 8 0 0 1 0 16h-24a8 8 0 0 1 0-16 M23 36q-6 4-2 8 M47 36q6 4 2 8 M28 44v6h2v-6 M40 44v6h2v-6",
  "M25 6h20a8 8 0 0 1 0 16h-20a8 8 0 0 1 0-16 M22 6v4 M48 6v4 M23 28h24a8 8 0 0 1 0 16h-24a8 8 0 0 1 0-16 M23 32l-4 4v4l4-2 M47 32l4 4v4l-4-2 M28 44v6h2v-6 M40 44v6h2v-6",
];

/* ═══ 06. Heavy Burly — Wide shoulders ═══ */
const burly = [
  "M27 10h16v10h-16z M27 10l2-4h12l-2 4 M43 10l2-4h4l2 4h-8 M4 30h62v10h-62z M4 30l4 4 M64 30l-4 4 M4 34h-2v6 M64 34h2v6 M25 40v4 M45 40v4",
  "M27 10h16v10h-16z M27 10l2-4h12l-2 4 M43 10l2-4h4l2 4h-8 M4 30h62v10h-62z M4 30l4 4 M64 30l-4 4 M4 34h-2v6 M64 30q6-2 10-6 M25 40v4 M45 40v4",
  "M4 30h62v10h-62z M4 30l4 4 M64 30l-4 4 M4 38q-6-4-6 2 M64 34h2v6 M25 40v4 M45 40v4",
  "M27 10h16v10h-16z M27 10l2-4h12l-2 4 M43 10l2-4h4l2 4h-8 M4 30h62v10h-62z M4 30l4 4 M64 30l-4 4 M4 34h-2v6 M64 32h8l2-1 M25 40v4 M45 40v4",
  "M27 10h16v10h-16z M27 10l2-4h12l-2 4 M43 10l2-4h4l2 4h-8 M4 30h62v10h-62z M4 30l4 4 M64 30l-4 4 M4 34h-2v6 M64 34h2v6 M25 40l-4 4 M45 40l4 4",
  "M27 10h16v10h-16z M27 10l2-4h12l-2 4 M43 10l2-4h4l2 4h-8 M4 30h62v10h-62z M4 30l4 4 M64 30l-4 4 M4 32h-2v-6 M64 32h2v-6 M25 40v4 M45 40v4",
  "M27 10h16v10h-16z M27 10l2-4h12l-2 4 M43 10l2-4h4l2 4h-8 M4 30h62v10h-62z M4 30l4 4 M64 30l-4 4 M4 34h-2v6 M64 38h10 M74 36v4 M25 40v4 M45 40v4",
  "M27 10h16v10h-16z M27 10l2-4h12l-2 4 M43 10l2-4h4l2 4h-8 M4 30h62v10h-62z M4 30l4 4 M64 30l-4 4 M4 34h-2v6 M64 34h2v6 M25 40h20v2h-20",
  "M4 30h62v10h-62z M4 30l4 4 M64 30l-4 4 M4 34h-2v6 M64 34h2v6 M25 40v4 M45 40v4",
  "M27 10h16v10h-16z M27 10l2-4h12l-2 4 M43 10l2-4h4l2 4h-8 M4 30h62v10h-62z M4 30l4 4 M64 30l-4 4 M4 32l-4 4v4l4-2 M64 32l4 4v4l-4-2 M25 40v4 M45 40v4",
];

/* ═══ 07. Wireframe — Minimalist stick ═══ */
const wireframe = [
  "M30 10h10v8h-10z M30 10l2-4h6l-2 4 M25 28h20v10h-20z M30 32l-10 10 M40 32l10 10 M30 38v14 M40 38v14",
  "M30 10h10v8h-10z M30 10l2-4h6l-2 4 M25 28h20v10h-20z M30 32l-10 10 M40 30l8-6 M30 38v14 M40 38v14",
  "M25 28h20v10h-20z M30 32l-8 6 M40 32l10 10 M30 38v14 M40 38v14",
  "M30 10h10v8h-10z M30 10l2-4h6l-2 4 M25 28h20v10h-20z M30 32l-10 10 M40 30h12 M30 38v14 M40 38v14",
  "M30 10h10v8h-10z M30 10l2-4h6l-2 4 M25 28h20v10h-20z M30 32l-10 10 M40 32l10 10 M30 38l-4 14 M40 38l4 14",
  "M30 10h10v8h-10z M30 10l2-4h6l-2 4 M25 28h20v10h-20z M30 30l-8-6 M40 30l8-6 M30 38v14 M40 38v14",
  "M30 10h10v8h-10z M30 10l2-4h6l-2 4 M25 28h20v10h-20z M30 32l-10 10 M40 32l14 6 M30 38v14 M40 38v14",
  "M30 10h10v8h-10z M30 10l2-4h6l-2 4 M25 28h20v10h-20z M30 32l-10 10 M40 32l10 10 M30 38h10v2h-10",
  "M25 28h20v10h-20z M30 32l-10 10 M40 32l10 10 M30 38v14 M40 38v14",
  "M30 10h10v8h-10z M30 10l2-4h6l-2 4 M25 28h20v10h-20z M30 30l-8 8 M40 30l8 8 M30 38v14 M40 38v14",
];

// Poses that need head rotation (think = index 2, up = index 8)
const headRotateIdx = new Set([2, 8]);
const headPaths: Record<string, string> = {
  industrial: "M25 10h20v16H25z M25 10l4-4h12l-4 4 M45 10l4-4v16l-4 4",
  decoLady: "M28 8h14l2 4H26z M28 8q2-4 7-4q5 0 7 4",
  egghead: "M15-2h40a4 4 0 0 1 4 4v14a4 4 0 0 1-4 4h-40a4 4 0 0 1-4-4v-14 M20 6h6v6h-6z M44 6h6v6h-6z",
  longshanks: "M27 6h16v12h-16z M27 6l2-4h12l-2 4 M27 18l2 2h12l-2-2",
  roundy: "M25 6h20a8 8 0 0 1 0 16h-20a8 8 0 0 1 0-16 M22 6v4 M48 6v4",
  burly: "M27 10h16v10h-16z M27 10l2-4h12l-2 4 M43 10l2-4h4l2 4h-8",
  wireframe: "M30 10h10v8h-10z M30 10l2-4h6l-2 4",
};

interface BodyType {
  name: string;
  key: string;
  poses: string[];
  vb: string;
}

const bodyTypes: BodyType[] = [
  { name: "01. Industrial", key: "industrial", poses: industrial, vb: "0 0 70 70" },
  { name: "02. Deco Lady", key: "decoLady", poses: decoLady, vb: "0 0 70 70" },
  { name: "03. Egghead", key: "egghead", poses: egghead, vb: "0 -6 70 60" },
  { name: "04. Longshanks", key: "longshanks", poses: longshanks, vb: "0 0 70 70" },
  { name: "05. Roundy", key: "roundy", poses: roundy, vb: "0 0 70 70" },
  { name: "06. Heavy Burly", key: "burly", poses: burly, vb: "-4 0 78 55" },
  { name: "07. Wireframe", key: "wireframe", poses: wireframe, vb: "0 0 70 70" },
];

function PoseSVG({ d, vb, headKey, idx }: { d: string; vb: string; headKey: string; idx: number }) {
  const needsRotate = headRotateIdx.has(idx);
  const angle = idx === 2 ? -3 : 8; // think vs look-up

  return (
    <svg viewBox={vb} className="w-[60px] h-[60px]" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
      {needsRotate && headPaths[headKey] ? (
        <>
          <g transform={`rotate(${angle}, 35, ${headKey === "egghead" ? 8 : headKey === "longshanks" ? 12 : 14})`}>
            <path d={headPaths[headKey]} />
          </g>
          <path d={d} />
        </>
      ) : (
        <path d={d} />
      )}
    </svg>
  );
}

export function RobotFoundry() {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
      {bodyTypes.map((bt) => (
        <div key={bt.key} className="bg-[var(--surface-alt)] border border-[var(--border)] rounded-lg p-4">
          <h3 className="text-center font-[family-name:var(--font-mono)] text-xs uppercase tracking-widest text-[var(--text-muted)] border-b border-[var(--border)] pb-3 mb-4">
            {bt.name}
          </h3>
          <div className="flex flex-wrap justify-center gap-3">
            {bt.poses.map((d, i) => (
              <div key={i} className="flex flex-col items-center w-[68px]">
                <PoseSVG d={d} vb={bt.vb} headKey={bt.key} idx={i} />
                <span className="text-[8px] text-[var(--text-muted)] font-[family-name:var(--font-mono)] uppercase mt-1">
                  {poseNames[i]}
                </span>
              </div>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}
