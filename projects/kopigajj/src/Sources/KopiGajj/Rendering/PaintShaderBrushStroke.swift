/// Brush stroke kernel — deposits paint with media-specific behavior.
extension PaintShaderSource {

    // MARK: - Kernel 2: Brush Stroke

    static let brushStroke = header + """

    kernel void brushStroke(
        texture2d<half, access::read_write>  wetAbsorbTex  [[ texture(0) ]],
        texture2d<half, access::read_write>  propsTex      [[ texture(1) ]],
        texture2d<float, access::read_write> heightTex     [[ texture(2) ]],
        texture2d<half, access::read>        canvasPropsTex[[ texture(3) ]],
        texture2d<half, access::read>        solidAbsorbTex[[ texture(4) ]],
        constant BrushPoint *points                        [[ buffer(0) ]],
        constant int &pointCount                           [[ buffer(1) ]],
        constant int &brushMode                            [[ buffer(2) ]],
        uint2 gid                                          [[ thread_position_in_grid ]]
    ) {
        int w = wetAbsorbTex.get_width();
        int h = wetAbsorbTex.get_height();
        if (int(gid.x) >= w || int(gid.y) >= h) return;

        float2 pos = float2(gid);
        half4 existingWet = wetAbsorbTex.read(gid);
        half4 existingProps = propsTex.read(gid);
        half4 canvasProps = canvasPropsTex.read(gid);
        float existingHeight = heightTex.read(gid).r;

        float wetness     = float(existingProps.r);
        float hardness    = float(existingProps.g);
        float absorbency  = float(canvasProps.r);
        float roughness   = float(canvasProps.g);

        // Accumulate brush deposits in absorption space
        float totalWeight = 0.0;
        float4 depositAbsorb = float4(0);
        float depositHeight = 0.0;
        float depositWetness = 0.0;  // weighted average of brush wetness values

        for (int i = 0; i < pointCount; i++) {
            BrushPoint bp = points[i];
            float2 bpPos = float2(bp.posX, bp.posY);
            int tipType = int(bp.tipType);

            // GPU-side linear interpolation between consecutive brush points.
            // For each segment (i, i+1), evaluate substeps along the path to
            // ensure sub-pixel continuity — no gaps between stamps.
            int substeps = 1;
            float2 startPos = bpPos;
            float startPressure = bp.pressure;
            float startRadius = bp.radius;
            float2 segDir = float2(bp.dirX, bp.dirY);
            float2 endPos = bpPos;
            float endPressure = bp.pressure;
            float endRadius = bp.radius;

            if (i < pointCount - 1) {
                BrushPoint next = points[i + 1];
                endPos = float2(next.posX, next.posY);
                endPressure = next.pressure;
                endRadius = next.radius;
                float dist = distance(startPos, endPos);
                float spacing = max(bp.radius * 0.3, 2.0);
                substeps = max(int(dist / spacing), 1);
                float2 seg = endPos - startPos;
                float segLen = length(seg);
                if (segLen > 0.001) segDir = seg / segLen;
            }

            float substepWeight = 1.0 / float(substeps);

            // Exclusive upper bound: endpoint of segment i == startpoint of i+1;
            // inclusive (<=) double-deposits at every junction → visible dots.
            for (int s = 0; s < substeps; s++) {
                float t = float(s) / float(substeps);
                float2 interpPos = mix(startPos, endPos, t);
                float interpPressure = mix(startPressure, endPressure, t);
                float interpRadius = mix(startRadius, endRadius, t);

                float2 delta = pos - interpPos;
                float profile = tipProfile(delta, interpRadius, tipType, bp.angle);
                if (profile < 0.001) continue;

                float w = profile * interpPressure * substepWeight;
                float4 bpAbsorb = float4(bp.absR, bp.absG, bp.absB, bp.concentration);
                depositAbsorb += bpAbsorb * w;

                // --- Bristle ridges + impasto height ---
                float2 strokeDir = segDir;
                float dirLen = length(strokeDir);
                if (dirLen < 0.01) strokeDir = float2(1, 0);
                else strokeDir /= dirLen;

                // Perpendicular to stroke direction
                float2 perpDir = float2(-strokeDir.y, strokeDir.x);
                float perpDist = dot(delta, perpDir);
                float normPerp = perpDist / max(interpRadius, 1.0);

                // Bristle grooves: sinusoidal ridges perpendicular to travel
                float bristleCount = 16.0;
                // Position-based phase variation to break aliased repetitive patterns
                float phaseShift = noise2d(interpPos * 0.05) * 3.14159;
                float bristle = sin(normPerp * bristleCount * 3.14159 + phaseShift);
                bristle = bristle * 0.5 + 0.5; // 0-1
                // Weight bristle intensity by edge proximity — ridges form at brush edges
                float edgeWeight = smoothstep(0.3, 0.9, abs(normPerp));
                bristle *= edgeWeight;

                // Edge buildup: paint pushed to edges by brush pressure
                float edgeFactor = smoothstep(0.5, 0.85, abs(normPerp));

                // Height = base deposit + bristle texture + edge pileup
                // Media-specific texture intensity:
                //   oil     — heavy impasto ridges from thick viscous paint
                //   acrylic — moderate ridges, slightly sharper than oil
                //   pastel  — granular noise (chalk catching canvas peaks)
                //   watercolor — almost flat (thin wash)
                float baseHeight = w * 0.025;
                // Reduce center height deposit — edges get more via edgeFactor
                float centerReduce = 1.0 - edgeWeight * 0.4;
                float mediaTexture;
                if (brushMode == MEDIA_OIL) {
                    // Thick impasto: grooves along stroke direction + organic noise
                    float alongDist = dot(delta, strokeDir);
                    float normAlong = alongDist / max(interpRadius, 1.0);
                    float groove = sin(normPerp * bristleCount * 3.14159 + phaseShift) * 0.5 + 0.5;
                    groove *= edgeWeight; // ridges at edges
                    float impastoNoise = noise2d(pos * 0.08 + interpPos * 0.01);
                    float depthVar = sin(normAlong * 1.5 + impastoNoise * 4.0) * 0.3 + 0.7;
                    mediaTexture = baseHeight * groove * depthVar * 0.9 + baseHeight * impastoNoise * 0.3;
                } else if (brushMode == MEDIA_ACRYLIC) {
                    // Stroke-parallel grooves: bristle channels along travel direction
                    float alongDist = dot(delta, strokeDir);
                    float normAlong = alongDist / max(interpRadius, 1.0);

                    // --- Natural acrylic bristle texture ---
                    // Warp the perpendicular coordinate with noise so grooves aren't perfectly spaced
                    float perpNoise = noise2d(float2(normPerp * 3.0, normAlong * 0.5) + interpPos * 0.02);
                    float warpedPerp = normPerp + perpNoise * 0.12;

                    // Multi-frequency grooves: primary bristle pattern + secondary sub-bristle detail
                    float groove1 = sin(warpedPerp * bristleCount * 3.14159 + phaseShift) * 0.5 + 0.5;
                    float groove2 = sin(warpedPerp * bristleCount * 2.37 * 3.14159 + 1.7 + phaseShift) * 0.5 + 0.5;
                    float groove = groove1 * 0.7 + groove2 * 0.3;
                    groove *= edgeWeight; // ridges concentrated at edges

                    // Per-bristle width variation: modulate sharpness across the stroke
                    float widthVar = noise2d(float2(normPerp * bristleCount * 0.5, interpPos.x * 0.03 + interpPos.y * 0.03));
                    groove = pow(groove, 0.8 + widthVar * 0.5);

                    // Micro-breaks: bristle skipping along stroke length
                    float breakNoise = noise2d(float2(normAlong * 4.0 + normPerp * bristleCount * 0.3, interpPos.y * 0.05));
                    float breakMask = smoothstep(0.15, 0.35, breakNoise);
                    groove = mix(0.55, groove, breakMask);

                    // Vary groove depth along stroke length for organic look
                    float depthVar = sin(normAlong * 2.0 + perpNoise * 4.0) * 0.3 + 0.7;
                    // Acrylic height multiplier: 1.5 (increased from 1.2 for more impasto)
                    mediaTexture = baseHeight * groove * depthVar * 1.5;

                    // Edge pigment darkening for acrylic: multiply absorption at stroke edges
                    if (edgeFactor > 0.5) {
                        float edgeDarkenMult = 1.0 + (edgeFactor - 0.5) * 0.4; // up to ~1.2 at extreme edge
                        bpAbsorb.rgb *= edgeDarkenMult;
                    }
                } else if (brushMode == MEDIA_PASTEL) {
                    // Chalky grain: high-frequency noise simulates pigment catching canvas texture
                    float grain = noise2d(pos * 0.25 + interpPos * float2(3.7, 2.3));
                    float grainMask = smoothstep(0.3, 0.7, grain);
                    mediaTexture = baseHeight * grainMask * 0.5;
                } else if (brushMode == MEDIA_HIGHLIGHTER) {
                    // Highlighter: zero height — ink soaks into surface
                    mediaTexture = 0.0;
                } else {
                    // Watercolor: minimal height texture
                    mediaTexture = baseHeight * bristle * 0.1;
                }
                float edgeHeight = edgeFactor * w * 0.022; // increased edge height
                depositHeight += (baseHeight * centerReduce + mediaTexture + edgeHeight) * substepWeight;

                totalWeight += w;
                depositWetness += bp.wetness * w;
            } // end substep loop
        } // end point loop

        // Normalize height deposit to prevent spikes from overlapping points
        if (totalWeight > 0.001) {
            depositHeight /= totalWeight;
            depositWetness /= totalWeight;
        }

        // ── Time tick path: zero-pressure strokes advance material state ──
        if (totalWeight < 0.001) {
            int mediaType = brushMode;
            float ht = existingHeight;

            // Height evolution per media
            if (mediaType == MEDIA_OIL && ht > 0.001) {
                float expansion = (1.0 - hardness) * 0.0005;
                heightTex.write(ht + expansion, gid);
            }
            if (mediaType == MEDIA_ACRYLIC && ht > 0.001) {
                float shrink = wetness * 0.002;
                heightTex.write(max(ht - shrink, ht * 0.85), gid);
            }
            if (mediaType == MEDIA_PASTEL && ht > 0.001) {
                float settling = 0.0002 * (1.0 - hardness);
                heightTex.write(max(ht - settling, ht * 0.95), gid);
            }

            // Material aging: viscosity + hardness evolve
            float newVisc = float(existingProps.b);
            float newHard = hardness;
            if (mediaType == MEDIA_OIL) {
                newVisc = min(newVisc + 0.001, 0.99);
                newHard = min(hardness + 0.003, 1.0);
            }
            if (mediaType == MEDIA_ACRYLIC) {
                newVisc = min(newVisc + 0.003, 0.99);
                newHard = min(hardness + 0.01, 1.0);
            }

            // Absorption aging: oil yellows = increased blue absorption
            half4 agedAbsorb = existingWet;
            if (mediaType == MEDIA_OIL && hardness > 0.5) {
                float ys = 0.0003 * hardness;
                // More blue absorbed → yellower appearance
                agedAbsorb.b = agedAbsorb.b + half(ys);
            }

            wetAbsorbTex.write(max(agedAbsorb, half4(0)), gid);
            propsTex.write(half4(existingProps.r, half(newHard), half(newVisc), existingProps.a), gid);
            return;
        }

        depositAbsorb /= totalWeight;
        float influence = clamp(totalWeight, 0.0, 1.0);

        // --- Transparent mode: concentration < 0 signals no-pigment brush ---
        // Watercolor transparent: deposit wetness only → existing colors diffuse
        // Oil/Acrylic/Pastel transparent: deposit grain/height only → texture over existing color
        bool isTransparent = (depositAbsorb.a < -0.5);
        if (isTransparent) {
            float heightDiminish = 1.0 / (1.0 + existingHeight * 0.8);

            if (brushMode == MEDIA_WATERCOLOR) {
                // Pure water: increase wetness to reactivate dried pigment for flow/diffusion
                float waterDeposit = clamp(influence * depositWetness, 0.0, 1.0);
                float newWet = clamp(wetness + waterDeposit, 0.0, 1.0);
                // Soften hardness so dried paint becomes workable again
                float soften = clamp(influence * depositWetness * 0.8, 0.0, 0.6);
                float newHard = clamp(hardness * (1.0 - soften), 0.0, 1.0);
                // No absorption change — water carries no pigment
                wetAbsorbTex.write(existingWet, gid);
                heightTex.write(existingHeight, gid);
                propsTex.write(half4(half(newWet), half(newHard), existingProps.b, existingProps.a), gid);
            } else {
                // Oil/Acrylic/Pastel: deposit height texture (grain) without color
                float grainHeight = depositHeight * influence * heightDiminish;
                // Reduce grain deposit for transparent mode (subtle texture, not heavy impasto)
                if (brushMode == MEDIA_OIL)     grainHeight *= 0.6;
                if (brushMode == MEDIA_ACRYLIC)  grainHeight *= 0.5;
                if (brushMode == MEDIA_PASTEL)   grainHeight *= 0.4;
                float newHeight = existingHeight + grainHeight;
                // Slight wetness increase (medium, not water)
                float newWet = clamp(wetness + influence * 0.1, 0.0, 0.5);
                // No absorption change — color below shows through
                wetAbsorbTex.write(existingWet, gid);
                heightTex.write(newHeight, gid);
                propsTex.write(half4(half(newWet), existingProps.g, existingProps.b, existingProps.a), gid);
            }
            return;
        }

        // --- Smudge: pressure-based push of wet paint in brush direction ---
        int existingMedia = int(existingProps.a);
        if (wetness > 0.1 && hardness < 0.7 && totalWeight > 0.1 &&
            (existingMedia == MEDIA_OIL || existingMedia == MEDIA_ACRYLIC || existingMedia == MEDIA_PASTEL)) {

            float2 smudgeDir = float2(0);
            float smudgePressure = 0.0;
            for (int p = 0; p < pointCount; p++) {
                float2 bpos = float2(points[p].posX, points[p].posY);
                float dist = length(pos - bpos);
                if (dist < points[p].radius * 1.2) {
                    smudgeDir += float2(points[p].dirX, points[p].dirY) * points[p].pressure;
                    smudgePressure = max(smudgePressure, points[p].pressure);
                }
            }
            float smudgeLen = length(smudgeDir);
            if (smudgeLen > 0.01 && smudgePressure > 0.1) {
                smudgeDir /= smudgeLen;

                float smudgeStrength = smudgePressure * wetness * (1.0 - hardness) * 0.6;
                if (existingMedia == MEDIA_ACRYLIC) smudgeStrength *= 0.5;
                if (existingMedia == MEDIA_PASTEL)  smudgeStrength *= 0.2;

                float2 upstreamPos = pos - smudgeDir * clamp(smudgeStrength * 4.0, 1.0, 6.0);
                int2 up = clamp(int2(upstreamPos), int2(0), int2(w - 1, h - 1));
                half4 upstreamAbsorb = wetAbsorbTex.read(uint2(up));

                if (float(upstreamAbsorb.a) > 0.05) {
                    // Pull upstream absorption values into current position
                    float pullAmt = clamp(smudgeStrength, 0.0, 0.5);
                    existingWet = half4(mix(float4(existingWet), float4(upstreamAbsorb), pullAmt));
                }
            }
        }

        // --- Media-specific deposition in absorption space ---

        float4 existAbsorb = float4(existingWet);
        float existConc = existAbsorb.a;
        float4 solidExisting = float4(solidAbsorbTex.read(gid));
        float solidConc = solidExisting.a;

        float4 newAbsorb;
        float newWet, newHard, newHeight;

        // Height diminishing factor
        float heightDiminish = 1.0 / (1.0 + existingHeight * 0.8);

        // --- Cross-media rejection ---
        // Watercolor cannot adhere to sealed opaque surfaces.  Real watercolor
        // beads up on dried acrylic/oil because those media form a non-absorbent
        // film.  Rejection is driven by solid concentration (surface is physically
        // sealed) and hardness (film has cured), not just height.
        float crossMediaReject = 0.0;
        if (brushMode == MEDIA_WATERCOLOR) {
            if (existingMedia == MEDIA_ACRYLIC || existingMedia == MEDIA_OIL) {
                // Sealed surface: reject based on how much dried paint is there
                float surfaceSeal = clamp(solidConc * 4.0, 0.0, 1.0);
                float hardnessSeal = smoothstep(0.1, 0.5, hardness);
                crossMediaReject = max(surfaceSeal, hardnessSeal);
                // Fully cured: complete rejection
                if (hardness > 0.6 && solidConc > 0.05) crossMediaReject = 1.0;
            }
            else if (existingMedia == MEDIA_PASTEL && solidConc > 0.05) {
                // Chalky surface: absorbs some water but rejects most pigment
                crossMediaReject = clamp(solidConc * 2.5, 0.0, 0.95);
            }
            // Height-based rejection: water runs off any elevated paint surface
            float heightReject = smoothstep(0.01, 0.1, existingHeight);
            crossMediaReject = max(crossMediaReject, heightReject * 0.85);
        }
        float effectiveInfluence = influence * (1.0 - crossMediaReject);

        if (brushMode == MEDIA_OIL) {
            // Oil: opaque coverage — new paint REPLACES old based on coverage
            // Light paint over dark = light result (not additive blending)
            float coverFactor = clamp(effectiveInfluence * 0.85, 0.0, 0.95);

            if (wetness > 0.2 && existConc > 0.1 && hardness < 0.5
                && existingMedia != MEDIA_WATERCOLOR && existingMedia != MEDIA_HIGHLIGHTER) {
                // Wet oil over wet paint media (oil/acrylic/pastel): physical mixing
                float existWeight = existConc * (1.0 - coverFactor);
                float newWeight = depositAbsorb.a * coverFactor;
                float totalW = existWeight + newWeight;
                if (totalW > 0.001) {
                    newAbsorb.rgb = ((existAbsorb.rgb * existWeight + depositAbsorb.rgb * newWeight) / totalW).rgb;
                } else {
                    newAbsorb.rgb = depositAbsorb.rgb;
                }
            } else {
                // Dry surface or fresh canvas: replace absorption proportional to coverage
                newAbsorb.rgb = mix(existAbsorb.rgb, depositAbsorb.rgb, coverFactor).rgb;
            }
            // Concentration: coverage-based "over" compositing
            float oilSrcConc = depositAbsorb.a * effectiveInfluence;
            newAbsorb.a = clamp(oilSrcConc + existConc * (1.0 - oilSrcConc), 0.0, 1.0);
            newHeight = existingHeight + depositHeight * effectiveInfluence * 1.0 * heightDiminish;
            newWet = clamp(wetness + effectiveInfluence * 0.5, 0.0, 1.0);
            newHard = clamp(hardness * (1.0 - effectiveInfluence * 0.3), 0.0, 1.0);

        } else if (brushMode == MEDIA_WATERCOLOR) {
            // Watercolor: pure additive absorption — NEVER decreases (never lightens)
            // depositWetness (0=dry brush, 1=saturated) controls water deposit and pigment behavior

            if (crossMediaReject > 0.5) {
                newAbsorb = existAbsorb;
                newAbsorb.a = existConc;
                newHeight = existingHeight;
                newWet = clamp(wetness + effectiveInfluence * depositWetness * 0.4, 0.0, 1.0);
                newHard = hardness;
            } else {
                // Dry brush (low wetness): stronger pigment deposit, less water spread
                // Wet brush (high wetness): diluted pigment, more water for flow/bleeding
                float wetFactor = clamp(depositWetness, 0.05, 1.0);

                // Pigment deposit inversely related to wetness — dry brush = concentrated
                float pigmentMult = mix(0.6, 0.25, wetFactor);  // dry=0.6 strong, wet=0.25 dilute
                float depositStr = clamp(effectiveInfluence * (pigmentMult + absorbency * 0.5), 0.0, 0.7);

                // Asymptotic absorption: each stroke moves absorption toward the pigment's
                // saturation limit with diminishing returns.  This prevents light pigments
                // (pink, yellow) from going to black — they plateau at a saturated version
                // of their hue.  The multiplier (3.5) sets how dark max-saturation
                // watercolor can get relative to a single thin wash.
                float3 maxAbsorb = depositAbsorb.rgb * 3.5;
                float3 gap = max(maxAbsorb - existAbsorb.rgb, float3(0));
                newAbsorb.rgb = (existAbsorb.rgb + gap * depositStr).rgb;
                // Concentration: dry brush deposits more concentrated pigment
                float concRate = mix(0.6, 0.3, wetFactor);
                newAbsorb.a = clamp(existConc + depositAbsorb.a * effectiveInfluence * concRate, 0.0, 0.9);
                newHeight = existingHeight + depositHeight * effectiveInfluence * 0.05 * heightDiminish;
                // Water deposit: primary effect of wetness — drives flow step behavior
                newWet = clamp(wetness + effectiveInfluence * wetFactor, 0.0, 1.0);
                // Softening: wet brush keeps surface workable longer
                float softenRate = mix(0.3, 0.7, wetFactor);
                newHard = clamp(hardness * (1.0 - effectiveInfluence * softenRate), 0.0, 1.0);
            }

        } else if (brushMode == MEDIA_ACRYLIC) {
            // Acrylic: opaque coverage — replaces existing paint (like oil but faster)
            float coverFactor = clamp(effectiveInfluence * 0.9, 0.0, 0.95);
            if (wetness > 0.15 && existConc > 0.1 && hardness < 0.3
                && existingMedia != MEDIA_WATERCOLOR && existingMedia != MEDIA_HIGHLIGHTER) {
                // Wet acrylic over wet paint media (oil/acrylic/pastel): physical mix
                float existWeight = existConc * (1.0 - coverFactor);
                float newWeight = depositAbsorb.a * coverFactor;
                float totalW = existWeight + newWeight;
                if (totalW > 0.001) {
                    newAbsorb.rgb = ((existAbsorb.rgb * existWeight + depositAbsorb.rgb * newWeight) / totalW).rgb;
                } else {
                    newAbsorb.rgb = depositAbsorb.rgb;
                }
            } else {
                // Dry surface: replace absorption (acrylic is opaque)
                newAbsorb.rgb = mix(existAbsorb.rgb, depositAbsorb.rgb, coverFactor).rgb;
            }
            float acrylicSrcConc = depositAbsorb.a * effectiveInfluence * 0.9;
            newAbsorb.a = clamp(acrylicSrcConc + existConc * (1.0 - acrylicSrcConc), 0.0, 1.0);

            // --- Acrylic height interaction with underlying paint ---
            // Wet paint underneath: brush pressure flattens/compresses existing wet layer.
            // The softer (less hard) and wetter the surface, the more the brush sinks in.
            // Dry paint underneath: solid surface, new paint builds additively on top.
            float flattenFactor = 0.0;
            if (wetness > 0.15 && hardness < 0.5) {
                // Wet acrylic: brush compresses existing wet layer
                // Flatten proportional to pressure (influence), wetness, and softness
                flattenFactor = effectiveInfluence * wetness * (1.0 - hardness) * 0.5;
            }
            // Compress existing height (simulate brush pushing into wet paint)
            float compressedHeight = existingHeight * (1.0 - flattenFactor);
            // Dry acrylic (high hardness) gets full additive buildup;
            // wet acrylic gets reduced deposit (brush is sinking, not stacking)
            float dryBonus = smoothstep(0.3, 0.8, hardness);
            float depositScale = mix(0.6, 1.4, dryBonus);
            newHeight = compressedHeight + depositHeight * effectiveInfluence * depositScale * heightDiminish;

            newWet = clamp(wetness + effectiveInfluence * 0.3, 0.0, 0.8);
            newHard = clamp(hardness * (1.0 - effectiveInfluence * 0.15), 0.0, 1.0);

        } else if (brushMode == MEDIA_PASTEL) {
            // Pastel: ADDITIVE absorption on surface peaks — chalky layering
            // Pastel deposits pigment ON TOP of existing paint, never erases
            float peakFactor = smoothstep(0.0, roughness * 0.5 + 0.01, existingHeight);
            float skip = step(0.25, noise2d(pos * 0.3 + 777));
            float pastelDeposit = effectiveInfluence * peakFactor * skip;

            // Additive: increase absorption (darken), never replace
            float depositStr = clamp(pastelDeposit * 0.6, 0.0, 0.5);
            newAbsorb.rgb = (existAbsorb.rgb + depositAbsorb.rgb * depositStr).rgb;
            newAbsorb.a = clamp(existConc + pastelDeposit * 0.6, 0.0, 1.0);
            newHeight = existingHeight + depositHeight * pastelDeposit * 0.6 * heightDiminish;
            newWet = clamp(wetness + pastelDeposit * 0.05, 0.0, 0.15);
            newHard = hardness;

        } else if (brushMode == MEDIA_HIGHLIGHTER) {
            // Highlighter: semi-transparent tinted overlay that stays vivid when layered.
            // Uses MAX blending (not additive) so absorption never exceeds the single-layer
            // value — layering saturates but never darkens toward black.
            float depositStr = clamp(effectiveInfluence * 0.5, 0.0, 0.8);
            newAbsorb.rgb = max(existAbsorb.rgb, (depositAbsorb.rgb * depositStr)).rgb;
            // Concentration: caps at 0.7 for translucency
            newAbsorb.a = clamp(max(existConc, depositAbsorb.a * effectiveInfluence * 0.6), 0.0, 0.7);
            newHeight = existingHeight;  // no height buildup — ink, not paint
            newWet = clamp(wetness + effectiveInfluence * 0.3, 0.0, 0.5);
            newHard = clamp(hardness + effectiveInfluence * 0.2, 0.0, 1.0);  // dries fast

        } else {
            // Fallback: simple additive (should not reach here with known media)
            newAbsorb = existAbsorb;
            newAbsorb.a = existConc;
            newHeight = existingHeight;
            newWet = wetness;
            newHard = hardness;
        }

        wetAbsorbTex.write(half4(max(newAbsorb, float4(0))), gid);
        heightTex.write(newHeight, gid);
        // Preserve existing media type when depositing over different media
        // (only change media type if depositing onto bare canvas)
        float writtenMedia = (existConc < 0.01) ? float(brushMode) : float(existingProps.a);
        // Override: opaque media (acrylic, pastel, oil) always stamps their type when coverage is strong
        if ((brushMode == MEDIA_ACRYLIC || brushMode == MEDIA_OIL || brushMode == MEDIA_PASTEL)
            && effectiveInfluence > 0.3) {
            writtenMedia = float(brushMode);
        }
        propsTex.write(half4(half(newWet), half(newHard), existingProps.b, half(writtenMedia)), gid);
    }
    """
}
