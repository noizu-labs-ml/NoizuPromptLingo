# Paint Medium Behaviour Reference

> Physical behaviour of four paint media — Oil, Watercolor, Acrylic, Pastel — documented for shader implementation guidance. Media type indices match `PaintShaderSource`: 0=oil, 1=watercolor, 2=acrylic, 3=pastel.

---

## Table of Contents

1. [Oil Paint](#1-oil-paint)
2. [Watercolor](#2-watercolor)
3. [Acrylic](#3-acrylic)
4. [Pastel](#4-pastel)
5. [Layering & Interaction Matrix](#5-layering--interaction-matrix)
6. [Opacity Model](#6-opacity-model)
7. [Color Mixing](#7-color-mixing)
8. [Shader Implementation Notes](#8-shader-implementation-notes)
9. [References](#9-references)

---

## 1. Oil Paint

**Binder:** Drying oil (linseed, walnut, poppy, or safflower oil)
**Pigment vehicle:** Oil acts as both binder and vehicle
**Media index:** 0

### 1.1 Physical Properties

| Property | Value / Range | Notes |
|----------|--------------|-------|
| Viscosity | High (buttery paste) | Gardner-Holt Z-2 to Z-4 for partially oxidized linseed oil. Heat-polymerized (stand) oils are thicker but flow/level more. |
| Drying time | 2-14 days (touch dry), months-years (full cure) | Varies enormously by pigment, oil type, and thickness. Earth pigments (umber, sienna) dry fastest; cadmiums are slow. Impasto can take years. |
| Opacity | Semi-opaque to fully opaque | Depends on pigment and layer thickness. Thin glazes are transparent; body paint is opaque. |
| Pigment load | 30-60% by volume | High pigment concentration compared to other media. |
| Film thickness | 50-500+ micrometers | Impasto strokes can exceed 5mm. |

**Binder chemistry:** Linseed oil is rich in linolenic acid (a polyunsaturated fatty acid), making it highly reactive with atmospheric oxygen. This reactivity creates a robust cross-linked polymer network but also causes yellowing over time due to chromophore formation.

### 1.2 Behavior When Applied

**Pressure response:**
- Light pressure: thin, translucent film that reveals canvas texture (scumbling). Brush drags across canvas peaks only.
- Medium pressure: even, opaque coverage. Brush deposits paint into both peaks and valleys of the weave.
- Heavy pressure: thick impasto ridges. Paint is pushed aside by bristles, forming ridges at stroke edges and furrows in the center.

**Edge characteristics:**
- Wet-on-dry: sharp, well-defined edges. Paint sits on top of the dried layer.
- Wet-on-wet (alla prima): soft, blended edges. Colors physically intermix at boundaries.
- Palette knife: extremely sharp, geometric edges with visible ridges.

**Texture and ridge formation:**
- Unbodied oil (raw linseed) produces "short," buttery paint — brush strokes hold their shape upon drying.
- Bodied oil (stand oil, heat-polymerized) produces "long," flowing paint — brush strokes self-level and flatten.
- Bristle brush marks create parallel furrows. The stiffer the bristle, the more pronounced the ridges.
- Impasto preserves full three-dimensional texture of the stroke, including direction, speed, and pressure variation.

**Canvas texture interaction:**
- On coarse linen: paint catches on thread peaks first, leaving gaps in valleys at low pressure ("broken color" effect).
- On smooth panel: paint spreads evenly; very fine brush marks are possible.
- Canvas weave pattern is visible through thin layers but fully obscured by impasto.

### 1.3 Drying Behavior

**Mechanism:** Autoxidative polymerization (NOT evaporation). Atmospheric O2 inserts into C-H bonds adjacent to double bonds in the fatty acid chains. The resulting hydroperoxides cross-link into a three-dimensional polymer network.

**Drying stages:**
1. **Induction period** (hours): oxygen is absorbed but no significant polymerization.
2. **Rapid curing** (days 1-7): gel point is reached; surface skins over. Cross-linking accelerates.
3. **Slow hardening** (weeks-months): bulk of the film cures from the outside in.
4. **Long-term aging** (years): continued oxidation, eventual brittleness.

**Surface changes during drying:**
- Gloss increases slightly as oil polymerizes, then decreases over years as surface becomes matte.
- **Yellowing**: linseed oil yellows noticeably, especially in low-light conditions. The yellowing is caused by chromophore formation in the polymerized oil matrix. A thin oil skin rises to the surface and yellows at a microscopic level. For shader purposes, model as a subtle warm shift (+0.02 to +0.08 in yellow channel) that increases with layer thickness and time.
- Walnut and poppy oils yellow less but form weaker films.
- Volume change is minimal (< 5%). Oil does not shrink significantly. Ridges and impasto texture are preserved almost exactly.

**Drying time by pigment (approximate touch-dry with linseed oil):**

| Pigment | Touch Dry |
|---------|-----------|
| Raw umber | 1-2 days |
| Burnt sienna | 2-3 days |
| Titanium white | 5-7 days |
| Cadmium yellow | 5-10 days |
| Ivory black | 10-14 days |
| Alizarin crimson | 10-14 days |

### 1.4 Color Mixing

- **Wet-on-wet (alla prima):** physical pigment intermixing on canvas. Colors blend smoothly due to high viscosity — they push and smear rather than flow. Subtractive color mixing.
- **Glazing:** thin transparent layer over dried opaque layer. Creates optical mixing — light passes through the glaze, reflects off the opaque layer below, and passes through the glaze again. This produces luminous color effects impossible with direct mixing. Follows Beer-Lambert absorption through the transparent layer.
- **Scumbling:** dry-brushing a thin, opaque, lighter layer over a darker dried layer. Creates broken optical mixing — underlying color shows through gaps. The brush deposits paint only on canvas peaks.

---

## 2. Watercolor

**Binder:** Gum arabic (acacia tree sap)
**Pigment vehicle:** Water
**Media index:** 1

### 2.1 Physical Properties

| Property | Value / Range | Notes |
|----------|--------------|-------|
| Viscosity | Very low (fluid wash) | Pigment is suspended in water; gum arabic adds slight body and adhesion. |
| Drying time | 1-10 minutes per wash | Depends on water content, paper weight, humidity, and airflow. |
| Opacity | Transparent to semi-transparent | The defining characteristic. Paper white provides all luminosity. |
| Pigment load | Low (5-15% by volume in wash) | Diluted significantly with water. |
| Film thickness | < 5 micrometers | Essentially a stain; no dimensional buildup. |

**Binder chemistry:** Gum arabic is a water-soluble polysaccharide. It binds pigment particles to the paper surface but remains re-wettable indefinitely — dried watercolor can always be reactivated with water.

**Additives:**
- Ox gall: reduces surface tension, improves flow.
- Glycerin/honey: humectant, slows drying, keeps paint workable.
- Extra gum arabic: increases gloss, transparency, and drying time.

### 2.2 Behavior When Applied

**Pressure response:**
- Watercolor pressure response is fundamentally different from other media. Pressure controls water deposit more than pigment deposit.
- Light touch with loaded brush: floods the surface with a large, wet wash. Pigment spreads freely.
- Heavy pressure: squeezes more water/pigment out of the brush but also pushes into paper fibers. Creates a more concentrated deposit.
- Dry brush (minimal water, moderate pressure): brush skips across paper texture peaks, leaving a broken, textured mark.

**Edge characteristics:**
- **Wet-on-wet:** extremely soft, diffuse edges. Pigment bleeds outward following capillary action through wet paper fibers. No hard boundaries.
- **Wet-on-dry:** hard, crisp edges with a characteristic **edge darkening** effect. As the wash dries, surface tension pulls pigment toward the perimeter, concentrating it along the drying edge. This is a defining visual signature of watercolor.
- **Backruns / blooms / cauliflowers:** when wetter paint is added to a partially-dried wash, the new water pushes into the drier area. It plows up settling pigment along its advancing edge, creating an irregular, serrated dark boundary with a lighter interior. This effect is caused by differential surface tension and capillary action.

**Paper interaction:**
- Watercolor is entirely dependent on the paper surface. The paper IS the painting surface — there is no separate paint film.
- **Cold-pressed (NOT) paper:** moderate texture. Pigment settles into valleys, producing granulation.
- **Hot-pressed (HP) paper:** smooth surface. Pigment sits on the surface longer, produces more even washes, sharper details.
- **Rough paper:** pronounced texture. Heavy granulation, dramatic broken-wash effects.
- Capillary action through cellulose fibers drives water migration. Water and pigment move from wetter to drier areas.

**Granulation:**
- Heavy, insoluble mineral pigments (cobalts, cerulean, raw umber, ultramarine) settle into paper valleys as water evaporates, creating a mottled, textured appearance.
- Lightweight synthetic pigments (phthalo, quinacridone) remain suspended and produce even, smooth washes. These tend to stain — they bond to the paper fibers chemically.
- Granulation increases with: more water, rougher paper, slower drying, tilted surface.

### 2.3 Drying Behavior

**Mechanism:** Evaporation of water. Gum arabic deposits as a thin, tacky film binding pigment particles to paper fibers. The paper also absorbs water through capillary action into its cellulose fiber network.

**Drying stages:**
1. **Wet/flowing** (0-2 min): water pools on surface, pigment moves freely. Wet-on-wet effects possible.
2. **Damp/setting** (2-5 min): surface sheen disappears. Pigment is settling. Adding water now causes backruns.
3. **Touch dry** (5-10 min): surface is dry to touch. Pigment is fixed in place.
4. **Bone dry** (10-30 min): fully dry throughout paper. Safe to apply next layer.

**Surface changes during drying:**
- **Lightening:** watercolor dries 20-40% lighter than when wet. This is the primary color shift. Wet paper is semi-transparent, allowing less light to reflect; dry paper is fully reflective. The pigment concentration appears lower once water evaporates because particles spread across the surface.
- No ridge or texture formation — watercolor has zero dimensional buildup.
- Granulating pigments become more visible as water evaporates and particles settle into paper valleys.
- Colors remain re-wettable. Subsequent layers can disturb previous ones if scrubbed.

### 2.4 Color Mixing

- **Wet-on-wet:** pigments physically intermix in the water layer on the paper. Colors flow together driven by capillary action and gravity. Produces soft gradients. Difficult to control precisely.
- **Layered glazing:** transparent washes laid over dry previous washes. Light passes through all layers, reflects off white paper, and returns through all layers. Pure Beer-Lambert optical mixing. This is the primary color-building technique.
- **Palette mixing:** colors mixed on a palette before application. Produces flat, even color in a single layer.
- Because watercolor is transparent, it is purely subtractive. You cannot lighten — you can only darken or shift hue. White = unpainted paper.

---

## 3. Acrylic

**Binder:** Acrylic polymer emulsion (methyl methacrylate / butyl acrylate copolymer)
**Pigment vehicle:** Water (carrier for the emulsion)
**Media index:** 2

### 3.1 Physical Properties

| Property | Value / Range | Notes |
|----------|--------------|-------|
| Viscosity | Variable (fluid to heavy body) | Fluid acrylics: water-like. Heavy body: comparable to oil paint. Gel mediums extend further. |
| Drying time | 10-30 minutes (surface), 24-72 hours (full cure) | Much faster than oil. Retarders can extend working time. |
| Opacity | Opaque to semi-opaque | Dries to a solid, continuous polymer film. Thin washes can be semi-transparent. |
| Pigment load | ~6.5% pigment + ~32% polymer + ~41% water | Water evaporates to leave ~60-70% polymer by volume in the dried film. |
| Film thickness | 10-500+ micrometers | Can achieve impasto similar to oil, but film shrinks on drying. |

**Binder chemistry:** Acrylic polymer particles are suspended in water as an emulsion. When water evaporates, the polymer spheres coalesce and fuse into a continuous, clear, flexible plastic film. Unlike oil, this is a purely physical process (no chemical cross-linking).

### 3.2 Behavior When Applied

**Pressure response:**
- Light pressure: thin, semi-transparent film. Similar to watercolor wash when heavily diluted.
- Medium pressure: even opaque coverage. Brush strokes blend easily while wet.
- Heavy pressure: ridges form, but acrylic's rapid drying means you must work quickly. Heavy body acrylic holds impasto well, but marks flatten slightly as water evaporates.

**Edge characteristics:**
- Wet-on-dry: sharp, clean edges. Acrylic adheres to almost any surface.
- Wet-on-wet: smooth blending possible but narrow working window (5-15 minutes before surface skins).
- Dried edge: acrylic produces a distinct "plastic" edge quality — crisp, slightly raised, with a subtle sheen difference between paint and bare canvas.

**Texture and ridge formation:**
- Heavy body acrylic holds brush marks well, but they shrink during drying (see below).
- Gel mediums and modeling paste allow extreme texture buildup.
- Dried acrylic has a slightly rubbery, flexible quality compared to oil's brittle rigidity.

**Canvas texture interaction:**
- Acrylic soaks into canvas fibers more than oil (especially when diluted), creating a mechanical bond.
- Thin washes: acrylic stains the canvas similarly to watercolor. Canvas texture shows through.
- Heavy body: fills weave completely. When dry-brushed, catches on peaks only (like oil scumbling).

### 3.3 Drying Behavior

**Mechanism:** Evaporation of water from the polymer emulsion. As water leaves, the acrylic polymer spheres (each ~0.1 micrometers diameter) are drawn together. They deform under capillary forces and coalesce into a continuous film. This is called the **minimum film formation temperature** (MFFT) process.

**Drying stages:**
1. **Wet/workable** (0-10 min): paint blends freely. Water evaporating from surface.
2. **Skinning** (10-20 min): surface develops a polymer skin while interior is still wet. Touching now lifts the skin.
3. **Touch dry** (20-60 min): surface is solid. Interior still curing.
4. **Full cure** (24-72 hours): complete coalescence throughout the film.

**Surface changes during drying:**
- **Darkening (value shift):** the defining color shift of acrylic. Wet acrylic emulsion is slightly milky/cloudy (white polymer particles scatter light). As water evaporates and polymer clarifies, this milkiness disappears, revealing the true (darker) pigment color. Shift is approximately 5-15% darker.
  - Most noticeable with: dark transparent pigments (alizarin, phthalo).
  - Least noticeable with: light opaque pigments (cadmium yellow, titanium white).
- **Shrinkage:** acrylic film shrinks as water evaporates. Volume loss is approximately 30-40% (the water fraction). Impasto ridges visibly flatten. For shader purposes: reduce height map by ~35% during drying.
- **Sheen change:** wet acrylic is matte/satin. Dried acrylic is satin to glossy (depending on formulation). Matte mediums reduce this.
- No yellowing (unlike oil). Acrylic polymer is chemically stable and does not discolor with age.

### 3.4 Color Mixing

- **Wet-on-wet:** physical pigment mixing, identical to oil but with a shorter working window. Subtractive color mixing.
- **Layering:** because acrylic dries to an insoluble film, subsequent layers sit cleanly on top without disturbing previous layers. This makes acrylic excellent for layered techniques.
- **Glazing:** diluted acrylic (with glazing medium) over dried opaque layers. Similar optical effect to oil glazing, but the acrylic glaze dries faster and does not yellow.
- **Dry brush / scumbling:** works like oil but with faster drying. Broken coverage reveals layers below.

---

## 4. Pastel

**Binder:** Minimal — gum tragacanth, methylcellulose, or synthetic polymer (just enough to hold the stick together)
**Pigment vehicle:** None (dry application)
**Media index:** 3

### 4.1 Physical Properties

| Property | Value / Range | Notes |
|----------|--------------|-------|
| Viscosity | N/A (dry medium) | Pastel is a solid stick, not a fluid. Applied as dry powder. |
| Drying time | Instant (no drying phase) | Dry medium — no vehicle to evaporate. |
| Opacity | Opaque (surface deposit) | Dense pigment powder sitting on paper peaks. |
| Pigment load | Very high (80-95%+) | Highest pigment concentration of any medium. Minimal binder. |
| Film thickness | 10-100+ micrometers | Loose powder layer. Can build up with multiple passes. |

**Composition:** Three components:
1. **Finely ground pigment** — the color.
2. **Dry filler** — chalk (calcium carbonate), kaolin (clay), or plite (plaster). Extends pigment, modifies texture, creates tints.
3. **Binder** — gum tragacanth or methylcellulose. Just enough to hold the stick together. Less binder = softer pastel = more vibrant color.

**Hardness spectrum:**
- **Extra-soft** (Schmincke, Sennelier): almost pure pigment. Crumbles easily. Maximum color intensity.
- **Soft** (Unison, Mount Vision): standard. Good balance of pigment load and stick integrity.
- **Hard** (NuPastel, Conté): more binder and filler. Produces finer lines. Less color saturation.
- **Pastel pencils:** pastel core in a wood casing. Fine detail work.

### 4.2 Behavior When Applied

**Pressure response:**
- Light pressure: pastel touches only the peaks of the paper texture ("tooth"). Produces a broken, textured mark with paper showing through the gaps. Very little pigment deposited.
- Medium pressure: pigment fills more of the paper valleys. More even coverage. The tooth begins to fill.
- Heavy pressure: pigment is forced deep into the paper tooth. Dense, saturated color. Paper texture is obscured. Risk of filling the tooth completely ("glazing" the surface — making it too smooth for more pastel to adhere).

**Edge characteristics:**
- Naturally soft, diffuse edges due to the powdery nature of the deposit.
- Sharp edges are possible with hard pastels or pastel pencils, but not with soft pastels.
- Edges can be further softened by blending with fingers, stumps, or chamois.
- Side strokes (laying the stick flat) produce broad, soft-edged marks.
- Tip strokes produce narrower marks with slightly crisper edges.

**Texture and surface interaction:**
- Pastel does NOT form a continuous film. It sits as loose powder on the paper surface.
- Adhesion is purely **mechanical** — pigment particles are physically trapped in the paper's tooth (texture peaks and valleys). There is no chemical or adhesive bond.
- Paper choice is critical. Sanded pastel papers (UArt, Pastelmat) have aggressive tooth that grips many layers. Smooth papers lose grip after 2-3 layers.
- Smudging varies by: pigment-to-binder ratio (more binder = less smudge), particle size and hardness, how effectively the paper tooth grips the particles.
- Pastel dust falls off if the surface is tapped or shaken. Fixative spray can be used between layers to create artificial tooth for additional passes.

### 4.3 Drying Behavior

**Mechanism:** None. Pastel is already dry. There is no drying phase, no curing, no chemical change.

**Surface stability:**
- Pastel is permanently fragile. It never "sets" or hardens.
- The pigment layer can be smudged, wiped, or blown off at any time.
- Fixative sprays (typically dilute acrylic resin) partially seal the surface, but they darken the colors slightly and reduce the characteristic matte, velvety finish.
- Without fixative, pastel paintings must be framed behind glass.

**No color shift:** pastel appears the same wet or dry (because it is always dry). The color you see when applying is the final color. This is unique among the four media.

**No dimensional change:** the powder layer does not shrink, swell, or deform. What you deposit stays exactly where and how you put it.

### 4.4 Color Mixing

- **Layering / optical mixing:** the primary technique. Multiple pastel colors are applied in overlapping strokes. Each layer partially obscures the one below. The eye blends the visible fragments of each layer into a perceived mixed color. This is closer to additive mixing (like pointillism) than subtractive mixing.
- **Physical blending:** rubbing two deposited pastel layers together with a finger or stump creates a physical pigment mix. This is subtractive mixing. Blending produces smooth gradients but often "muddies" color and fills the paper tooth.
- **Crosshatching:** overlapping directional strokes of different colors create optical mixing without physical blending. Preserves more color vibrancy.
- **No wet mixing:** unlike oil, watercolor, and acrylic, pastels cannot be mixed in a fluid state. All mixing happens on the paper surface.

---

## 5. Layering & Interaction Matrix

### 5.1 Full 4x4 Interaction Matrix

The matrix below describes what happens when the **row medium** is applied over a dried layer of the **column medium**.

| Applied Over → | Oil (dried) | Watercolor (dried) | Acrylic (dried) | Pastel (unfixed) |
|----------------|-------------|--------------------|-----------------|--------------------|
| **Oil** | Good adhesion. Wet-on-dry or fat-over-lean layering. New oil layer bonds to the oxidized surface. Standard technique. | **Works well.** Classic underpainting technique. Oil adheres to the porous watercolor/paper surface. The oil layer seals the watercolor beneath permanently. Light oil colors can cover dark watercolor. | **Works, with caveats.** "Oil over acrylic" is an accepted practice because acrylic provides a porous, tooth-bearing surface. However, the oil does not chemically bond to the plastic acrylic film — adhesion is mechanical. Long-term, thick oil layers over glossy acrylic may eventually delaminate. Matte or lightly sanded acrylic surfaces provide better grip. | **Not recommended.** Oil would obliterate and absorb the loose pastel powder. The pastel particles would contaminate the oil layer, creating a muddy, structurally weak mixture. The loose powder prevents proper adhesion. |
| **Watercolor** | **Does not work.** Water beads up on the oil film surface and slides off. Oil is hydrophobic. No adhesion possible. The watercolor wash will pool and streak unpredictably. | Good adhesion. Standard layering technique (glazing). New wash sits on top of previous dry wash. HOWEVER: water in the new wash can re-wet and disturb the previous layer (watercolor remains forever re-wettable). Light washes cannot cover dark — watercolor is purely additive/darkening. | **Partial adhesion.** Watercolor can be applied over matte acrylic surfaces, but adhesion is weaker than on paper. The acrylic film is less absorbent than paper. Watercolor tends to bead slightly on glossy acrylic. Matte or textured acrylic surfaces work better. | **Poor adhesion.** Watercolor wash slides off the waxy pastel powder. The water may disturb and smear the pastel. Not a viable combination in this order. |
| **Acrylic** | **Does not work.** Acrylic will not adhere to a cured oil film. The oil surface is non-porous and slightly oily. Acrylic will bead, crack, or flake during application and will certainly delaminate over time. This is the most important incompatibility to model. | **Works well.** Acrylic adheres to the porous watercolor/paper surface. The acrylic layer seals the watercolor beneath (making it no longer re-wettable). This is a common mixed-media technique. Opaque acrylic can fully cover dark watercolor. | Good adhesion. Acrylic layers bond well to each other. Previous layers are insoluble once dry, so new layers sit cleanly on top without disturbing them. Excellent for layered techniques. | **Moderate adhesion.** Acrylic can be applied over pastel as a fixative-like seal. The wet acrylic soaks into and around the pastel powder, partially binding it. However, the result may darken the pastel significantly and the surface texture changes from powdery to plastic. Thick pastel may resist penetration. |
| **Pastel** | **Moderate adhesion.** Pastel can grip the slightly textured surface of dried oil paint, especially if the oil surface has tooth (from brush marks or matte medium). Smooth, glossy oil surfaces provide less grip. The pastel sits on top mechanically. No chemical interaction. | **Works very well.** A classic mixed-media combination. Watercolor underpainting provides color and value, then pastel is applied over the dry surface for detail, highlights, and texture. The paper still has tooth for the pastel to grip. Pastel easily covers and modifies watercolor beneath. | **Works well.** Acrylic underpainting (especially matte or textured) provides excellent tooth for pastel. Common professional technique. The acrylic base provides a sealed, stable foundation. Pastel adheres mechanically to the acrylic surface texture. | Standard layering. New pastel sits on top of previous pastel, filling remaining tooth. Each layer reduces available tooth. After 3-5 heavy layers, the surface may become too smooth ("glazed") for more pastel to grip. Fixative between layers restores tooth. |

### 5.2 Key Compatibility Rules

For shader implementation, these rules can be simplified:

```
RULE 1: "Fat over lean" — oil can go over anything water-based, never the reverse.
RULE 2: Acrylic NEVER over oil. (Acrylic adhesion = 0 on oil surface.)
RULE 3: Watercolor NEVER over oil. (Hydrophobic rejection.)
RULE 4: Pastel over anything = mechanical grip only (needs surface tooth).
RULE 5: Anything wet over unfixed pastel = disruption/contamination.
RULE 6: Watercolor over watercolor = previous layer can be disturbed.
RULE 7: Acrylic over acrylic = clean isolation (previous layer is insoluble).
```

### 5.3 Light-Over-Dark Coverage

| Medium | Can Light Cover Dark? | Mechanism |
|--------|----------------------|-----------|
| Oil | Yes (with sufficient thickness) | Opaque pigment in thick binder physically obscures underlayer. Titanium white is extremely opaque. Thin layers: no. |
| Watercolor | **No.** | Transparent medium. Light pigment over dark = slight color shift, not coverage. Paper white cannot be recovered (except by lifting). |
| Acrylic | Yes | Opaque polymer film. One coat of titanium white can cover most dark layers. May need 2 coats for full coverage over black. |
| Pastel | Yes (surface only) | Dense opaque powder sits on top of previous layers. Light pastel over dark works well — but only on surface peaks. Dark color remains visible in paper valleys unless heavily applied. |

---

## 6. Opacity Model

### 6.1 Watercolor — Beer-Lambert Absorption

Watercolor is the only purely transparent medium of the four. Its opacity model follows the Beer-Lambert law:

```
T = e^(-α · c · d)
```

Where:
- `T` = transmittance (fraction of light passing through)
- `α` = molar absorption coefficient (pigment-specific, wavelength-dependent)
- `c` = pigment concentration
- `d` = effective path length (layer thickness)

Light travels: down through paint layer → reflects off white paper → up through paint layer again. Total absorption path = 2d.

**Shader implication:** For each watercolor layer, compute `absorption = 1 - e^(-2αcd)` per color channel. The paper provides 100% reflectance (white). Each layer reduces the reflected light. Multiple transparent layers multiply their transmittances.

Staining pigments (phthalo, quinacridone) have high α values. Granulating pigments (cobalt, ultramarine) have variable α across the surface because pigment concentration varies with paper texture.

### 6.2 Oil — Variable Opacity (Kubelka-Munk)

Oil paint ranges from transparent (glazes) to fully opaque (body paint), depending on pigment type and layer thickness. The Kubelka-Munk model is appropriate:

```
K/S = (1 - R∞)² / (2R∞)
```

Where:
- `K` = absorption coefficient
- `S` = scattering coefficient
- `R∞` = reflectance of an infinitely thick layer (hiding power)

**Shader implication:** Each oil paint layer has both absorption AND scattering. Transparent pigments (alizarin, viridian) have high K, low S — they absorb light but let it pass to the layer below. Opaque pigments (cadmium, titanium white) have high S — they scatter light back before it reaches the underlayer. Layer thickness modulates both coefficients.

### 6.3 Acrylic — Opaque Film

Acrylic dries to a continuous, solid polymer film. For most practical purposes, it can be modeled as:

- **Full body:** fully opaque. One layer completely obscures everything beneath.
- **Diluted wash:** semi-transparent, approaching watercolor behavior. Use Beer-Lambert model.
- **Glazing medium:** transparent acrylic layer, behaves similarly to oil glaze.

**Shader implication:** Opacity is a direct function of `concentration` (pigment-to-water ratio in the mix). At concentration > 0.7, treat as opaque (alpha = 1.0). Below that, interpolate toward Beer-Lambert transparency.

### 6.4 Pastel — Surface Occlusion

Pastel opacity is not absorption-based. It is geometric occlusion — opaque powder particles sitting on surface peaks physically block the view of whatever is beneath.

```
coverage = f(pressure, tooth_remaining, particle_density)
```

**Shader implication:** Model as a coverage mask rather than a continuous film. At light pressure, coverage might be 30-50% (paper/underlayer visible in valleys). At heavy pressure, coverage approaches 90-100%. The coverage pattern is modulated by the canvas/paper height map — peaks are covered first, valleys last.

---

## 7. Color Mixing

### 7.1 Mixing Models by Medium

| Medium | Primary Mixing Model | Secondary Model | Notes |
|--------|---------------------|-----------------|-------|
| Oil | Subtractive (physical pigment blend) | Optical (glazing layers, Beer-Lambert through transparent layers) | Wet-on-wet = physical. Glaze over dry = optical. Scumbling = partial coverage optical mix. |
| Watercolor | Optical (layered glazing, Beer-Lambert) | Subtractive (wet-on-wet blend) | Primary technique is layered washes. Wet-on-wet produces physical blends but is hard to control. |
| Acrylic | Subtractive (physical pigment blend) | Optical (glazing layers) | Similar to oil but faster drying. Clean layer separation because dried acrylic is insoluble. |
| Pastel | Optical (overlapping strokes, partial coverage) | Subtractive (physical blend by rubbing) | Layered strokes = optical mix. Finger/stump blending = physical. Crosshatching = controlled optical. |

### 7.2 Kubelka-Munk for Paint Mixing

For physically accurate paint mixing simulation across all media, the Kubelka-Munk two-flux model provides the most accurate framework:

- Each pigment is characterized by wavelength-dependent K (absorption) and S (scattering) coefficients.
- Mixing pigments: K_mix and S_mix are weighted averages of the component pigments' K and S values by concentration.
- Layering: use the Kubelka-Munk layering equations to compute the combined reflectance of multiple layers over a substrate.
- The reflectance R of a layer of thickness d over a substrate of reflectance R_g can be computed from K, S, d, and R_g.

For a simplified shader approach, spectral.js (by Ronald van Wijnen) demonstrates an implementation of Kubelka-Munk paint mixing using 7-wavelength spectral representation.

### 7.3 Subtractive vs. Optical Mixing

**Subtractive mixing** (physical pigment blend):
- Pigment particles are physically intermixed.
- Each pigment absorbs its characteristic wavelengths.
- The mixture absorbs the UNION of all component absorptions.
- Result is always darker than the lightest component.
- Red + blue = dark purple (not bright violet).

**Optical / glazing mixing** (layered transparent films):
- Pigment layers are physically separate.
- Light passes through each layer sequentially.
- Total absorption is the SUM of each layer's absorption.
- Can produce luminous, saturated colors impossible with physical mixing.
- Red glaze over blue = luminous violet (light passes through both).

---

## 8. Shader Implementation Notes

### 8.1 Per-Medium Parameter Ranges

These suggested parameter ranges map to the `BrushPoint` and `SimParams` structs in `PaintShaderSource`:

| Parameter | Oil | Watercolor | Acrylic | Pastel |
|-----------|-----|-----------|---------|--------|
| `viscosity` | 0.7 - 1.0 | 0.01 - 0.15 | 0.3 - 0.8 | N/A (use coverage model) |
| `concentration` | 0.4 - 0.9 | 0.02 - 0.3 | 0.2 - 0.8 | 0.8 - 1.0 |
| `dryRate` | 0.001 - 0.01 | 0.05 - 0.3 | 0.02 - 0.08 | 1.0 (instant) |
| `flowStrength` | 0.0 - 0.1 | 0.3 - 1.0 | 0.0 - 0.2 | 0.0 |
| `diffusionRate` | 0.0 - 0.05 | 0.2 - 0.8 | 0.0 - 0.1 | 0.0 |
| `edgeDarken` | 0.0 - 0.05 | 0.1 - 0.4 | 0.0 - 0.05 | 0.0 |
| height buildup | High (preserves ridges) | None | Moderate (shrinks ~35%) | Surface powder (no film) |

### 8.2 Drying Simulation Priorities

| Medium | Key Drying Effect to Simulate |
|--------|------------------------------|
| Oil | Slow uniform cure. No color shift (minor yellow over long time). Height preserved. Surface skins first. |
| Watercolor | Fast evaporation. Edge darkening (pigment migration to perimeter). Lightening (~30%). Granulation (pigment settling into height-map valleys). |
| Acrylic | Moderate evaporation. Darkening (~10%). Height shrinkage (~35%). Surface skins before interior cures. |
| Pastel | No drying. Instant deposit. Coverage mask based on surface height map. Smudge/spread simulation instead. |

### 8.3 Layer Interaction Rules for Shader

```metal
// Pseudocode for medium compatibility check
bool canAdhere(int newMedium, int existingMedium) {
    // Oil over water-based: yes
    if (newMedium == OIL && existingMedium != OIL) return true;
    // Oil over oil: yes
    if (newMedium == OIL && existingMedium == OIL) return true;
    // Watercolor over oil: no (beading)
    if (newMedium == WATERCOLOR && existingMedium == OIL) return false;
    // Acrylic over oil: no (delamination)
    if (newMedium == ACRYLIC && existingMedium == OIL) return false;
    // Acrylic over acrylic: yes (clean)
    if (newMedium == ACRYLIC && existingMedium == ACRYLIC) return true;
    // Acrylic over watercolor: yes
    if (newMedium == ACRYLIC && existingMedium == WATERCOLOR) return true;
    // Watercolor over acrylic: partial (reduced adhesion)
    if (newMedium == WATERCOLOR && existingMedium == ACRYLIC) return true; // but reduce flow adhesion
    // Watercolor over watercolor: yes (but can rewet previous)
    if (newMedium == WATERCOLOR && existingMedium == WATERCOLOR) return true;
    // Pastel over anything: mechanical grip (check surface tooth)
    if (newMedium == PASTEL) return surfaceTooth > 0.1;
    // Anything wet over unfixed pastel: contamination
    if (existingMedium == PASTEL && !pastelFixed) return false; // disrupts powder
    return true;
}
```

---

## 9. References

### Oil Paint
- [Oil paint - Wikipedia](https://en.wikipedia.org/wiki/Oil_paint)
- [Differences Between Linseed Oil and Stand Oil - Natural Pigments](https://www.naturalpigments.com/artist-materials/linseed-stand-oil)
- [Boiled Linseed Oil in Art - Natural Pigments](https://www.naturalpigments.com/artist-materials/drying-linseed-oil-guide-for-artists)
- [Linseed Oil Processing: Chemistry and Impact - Painting Best Practices](https://paintingbestpractices.com/linseed-oil-processing-understanding-its-chemistry-and-impact-on-oil-painting-techniques/)
- [Oil Paint & Oil Mediums Guide - Jackson's Art Blog](https://www.jacksonsart.com/blog/2017/06/06/oil-paint-guide/)
- [Creating Impastos in Oil Paintings - Natural Pigments](https://www.naturalpigments.com/artist-materials/oil-painting-impasto)
- [The Impasto Technique of Rembrandt - Natural Pigments](https://www.naturalpigments.com/artist-materials/rembrandt-impasto-technique)
- [Comprehensive Characterization of Drying Oil Oxidation and Polymerization - PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC11394013/)
- [On the Yellowing of Oils - Just Paint](https://justpaint.org/on-the-yellowing-of-oils/)
- [What is Dark Yellowing in Oil Paintings? - Jackson's Art Blog](https://www.jacksonsart.com/blog/2019/10/04/what-is-dark-yellowing/)
- [Understanding and Preventing Yellowing - Painting Best Practices](https://paintingbestpractices.com/yellowing-of-oil-paints/)

### Watercolor
- [How Watercolor Paints Are Made - Handprint](https://www.handprint.com/HP/WCL/pigmt1.html)
- [The Secret of Gum Arabic - Artists Network](https://www.artistsnetwork.com/art-mediums/watercolor/the-secret-of-gum-arabic/)
- [The Physics of Watercolour - Linda Saul RWS](https://lindasaul.co.uk/2022/01/02/watercolour-physics/)
- [Backruns, Blooms and Cauliflowers - Erik Lundgren](https://akvarell.se/2022/02/09/backruns-blooms-and-cauliflowers/)
- [How to Create or Avoid Watercolour Blooms - Louise De Masi](https://www.louisedemasi.com/tips/2024/5/21/how-to-create-or-avoid-watercolour-blooms)
- [Measuring Watercolor Granulation - Natural Pigments](https://www.naturalpigments.eu/artist-materials/measuring-watercolor-granulation)
- [What's Granulation in Watercolour - Emily Wassell](https://www.emilywassell.co.uk/watercolour-for-beginners/list-of-techniques/what-is-granulation-granulating-paints/)
- [The Magic of Texture: Watercolor Granulation - Prominent Painting](https://prominentpainting.com/watercolor-granulation-techniques/)
- [Spectrophotometric Analysis of Watercolor Paint Quality - Loyola eCommons](https://ecommons.luc.edu/cgi/viewcontent.cgi?article=2548&context=ures)

### Acrylic
- [Acrylic paint - Wikipedia](https://en.wikipedia.org/wiki/Acrylic_paint)
- [What Is Acrylic Paint - Liquitex](https://www.liquitex.com/blogs/acrylic-knowledge/what-is-acrylic-paint)
- [Acrylic Paints: Atomistic View of Polymer Structure - PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC8488938/)
- [Why Acrylic Paints Dry Darker - Marianne Vander Dussen](https://mariannevanderdussen.com/blogs/news/color-mixing-with-acrylic-why-acrylic-paints-dry-darker)
- [Color Shift-Shrinkage - Just Paint](https://justpaint.org/color-shift-shrinkage/)
- [Beginners Guide to Acrylic Paints - Gel Press](https://gelpress.com/blogs/art-and-inspiration/beginners-guide-to-acrylic-paints)

### Pastel
- [Pastel - Wikipedia](https://en.wikipedia.org/wiki/Pastel)
- [Why Some Pastels Smudge More Than Others - Beyond Every Art](https://www.beyondeveryart.com/why-pastels-smudge-different-amounts/)
- [Landscape Painting in Pastels: Chapter One - Pastels and Other Materials](https://landscapesinpastel.blogspot.com/2010/02/chapter-onepastels-and-other-materials.html)
- [Anatomy of a Pastel - FAMSF](https://www.famsf.org/learn-engage/read-watch-listen/anatomy-of-a-pastel-3)
- [Pastel FAQs - Sheila M. Evans Studio](https://sheilaevans.art/more/pastel-faqs)

### Mixed Media Compatibility
- [Can You Mix Oil and Acrylic Paint? - Cowling & Wilcox](https://www.cowlingandwilcox.com/blog/post/188-can-you-mix-oil-and-acrylic-paint)
- [The Truth About Mixing Acrylic and Oil Paint - Collette](https://www.collette.co.nz/blog/The-Truth-About-Mixing-Acrylic-And-Oil-Paint)
- [Acrylic or Watercolor Underpainting for Oils - Just Paint](https://justpaint.org/acrylic-or-watercolor-underpainting-for-oils/)
- [Free Mixed Media Art Supplies Compatibility Chart - Nela Dunato](https://neladunato.com/blog/mixed-media-art-supplies-compatibility-chart/)
- [Medium Compatibility - Daler-Rowney](https://daler-rowney.com/medium-compatibility-guidance-on-which-mediums-can-be-mixed-and-their-combined-effects/)
- [Soft Pastel in Mixed Media - Sue Flanagan](https://www.sueflanagan.com/blog/101544/soft-pastel-in-mixed-media)
- [Perfect Chemistry: Compatibility - Golden Artist Colors](https://goldenartistcolors.com/inspiration/compatibility)

### Color Mixing Theory
- [Kubelka-Munk Theory - Wikipedia](https://en.wikipedia.org/wiki/Kubelka%E2%80%93Munk_theory)
- [Kubelka-Munk Color Mixing in VEX - vanity_ibex](https://vanity-ibex.xyz/blog/kubelka_munk_colormixing/)
- [Generating Spectral Paint Curves With ML - Lars Wander](https://larswander.com/writing/spectral-paint-curves/)
- [spectral.js: Paint-like Color Mixing Library - GitHub](https://github.com/rvanwijnen/spectral.js)
- [PIGMENTO: Pigment-Based Image Analysis - arXiv](https://arxiv.org/pdf/1707.08323)
- [Verification of Kubelka-Munk for Artist Acrylic Paint - ResearchGate](https://www.researchgate.net/publication/264844752_Verification_of_the_Kubelka-Munk_Turbid_Media_Theory_for_Artist_Acrylic_Paint_Summer_2004)
- [Mixing Paint Pigments - RMIT Colour Theory](https://rmit.pressbooks.pub/colourtheory1/chapter/mixing-paint-pigments/)
- [How to Use Watercolor and Pastel for Mixed Media - Malcolm Dewey Fine Art](https://www.malcolmdeweyfineart.com/blog/how-to-use-watercolor-and-pastel-for-beautiful-mixed-media-paintings)
