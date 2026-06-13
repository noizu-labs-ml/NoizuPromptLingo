/// Flow and dry simulation kernels — pigment transport and wet-to-solid transfer.
extension PaintShaderSource {

    // MARK: - Kernel 3: Flow Step

    static let flowStep = header + """

    kernel void flowStep(
        texture2d<half, access::read>        wetAbsorbIn   [[ texture(0) ]],
        texture2d<half, access::read>        propsIn       [[ texture(1) ]],
        texture2d<float, access::read_write> heightTex     [[ texture(2) ]],
        texture2d<half, access::read>        canvasPropsTex[[ texture(3) ]],
        texture2d<half, access::write>       wetAbsorbOut  [[ texture(4) ]],
        texture2d<half, access::write>       propsOut      [[ texture(5) ]],
        constant SimParams &params                         [[ buffer(0) ]],
        uint2 gid                                          [[ thread_position_in_grid ]]
    ) {
        int w = wetAbsorbIn.get_width();
        int h = wetAbsorbIn.get_height();
        if (int(gid.x) >= w || int(gid.y) >= h) return;

        half4 absorb = wetAbsorbIn.read(gid);
        half4 props = propsIn.read(gid);
        half4 canvasProps = canvasPropsTex.read(gid);
        float height = heightTex.read(gid).r;

        float wetness   = float(props.r);
        float viscosity = float(props.b);
        float porosity  = float(canvasProps.b);
        float roughness = float(canvasProps.g);
        int mediaType = int(props.a);

        // --- Watercolor wicking: dry canvas pulls pigment from wet watercolor neighbors ---
        // Runs BEFORE early-exit so dry texels can absorb pigment, creating
        // the "ink in water" spread with organic tendrils via noise-driven anisotropy.
        if (wetness < 0.05 && mediaType != MEDIA_WATERCOLOR) {
            half4 nPrL = propsIn.read(uint2(clamp(int(gid.x) - 1, 0, w - 1), gid.y));
            half4 nPrR = propsIn.read(uint2(clamp(int(gid.x) + 1, 0, w - 1), gid.y));
            half4 nPrU = propsIn.read(uint2(gid.x, clamp(int(gid.y) - 1, 0, h - 1)));
            half4 nPrD = propsIn.read(uint2(gid.x, clamp(int(gid.y) + 1, 0, h - 1)));

            bool hasWetWC = (float(nPrL.r) > 0.2 && int(nPrL.a) == MEDIA_WATERCOLOR)
                         || (float(nPrR.r) > 0.2 && int(nPrR.a) == MEDIA_WATERCOLOR)
                         || (float(nPrU.r) > 0.2 && int(nPrU.a) == MEDIA_WATERCOLOR)
                         || (float(nPrD.r) > 0.2 && int(nPrD.a) == MEDIA_WATERCOLOR);

            if (hasWetWC) {
                float2 fpos = float2(gid);
                // Multi-scale noise: large flow direction + fine tendril structure
                float wickNoise = noise2d(fpos * 0.06 + float2(17.3, 31.7));
                float tendril = noise2d(fpos * 0.25 + float2(73.1, 11.9));
                float wickChance = wickNoise * 0.5 + tendril * 0.5;
                float wickStr = porosity * float(canvasProps.r) * params.dt * 0.8;

                if (wickChance > 0.28 && wickStr > 0.01) {
                    // Per-direction noise for anisotropic spread (paper fiber simulation)
                    float dwL = noise2d(fpos * 0.15 + float2(3.3, 0));
                    float dwR = noise2d(fpos * 0.15 + float2(0, 7.7));
                    float dwU = noise2d(fpos * 0.15 + float2(13.1, 0));
                    float dwD = noise2d(fpos * 0.15 + float2(0, 19.3));

                    half4 nAbL = wetAbsorbIn.read(uint2(clamp(int(gid.x) - 1, 0, w - 1), gid.y));
                    half4 nAbR = wetAbsorbIn.read(uint2(clamp(int(gid.x) + 1, 0, w - 1), gid.y));
                    half4 nAbU = wetAbsorbIn.read(uint2(gid.x, clamp(int(gid.y) - 1, 0, h - 1)));
                    half4 nAbD = wetAbsorbIn.read(uint2(gid.x, clamp(int(gid.y) + 1, 0, h - 1)));

                    half4 pulled = half4(0); float pullTot = 0.0;
                    if (float(nPrL.r) > 0.2 && int(nPrL.a) == MEDIA_WATERCOLOR) {
                        float pw = float(nPrL.r) * dwL * wickStr; pulled += nAbL * half(pw); pullTot += pw; }
                    if (float(nPrR.r) > 0.2 && int(nPrR.a) == MEDIA_WATERCOLOR) {
                        float pw = float(nPrR.r) * dwR * wickStr; pulled += nAbR * half(pw); pullTot += pw; }
                    if (float(nPrU.r) > 0.2 && int(nPrU.a) == MEDIA_WATERCOLOR) {
                        float pw = float(nPrU.r) * dwU * wickStr; pulled += nAbU * half(pw); pullTot += pw; }
                    if (float(nPrD.r) > 0.2 && int(nPrD.a) == MEDIA_WATERCOLOR) {
                        float pw = float(nPrD.r) * dwD * wickStr; pulled += nAbD * half(pw); pullTot += pw; }

                    if (pullTot > 0.001) {
                        half4 wickAbs = pulled / half(pullTot);
                        float wickFrac = clamp(pullTot * (wickChance - 0.28) * 2.0, 0.0, 0.15);
                        half4 newAb = mix(absorb, wickAbs, half(wickFrac));
                        newAb.a = max(absorb.a, half(wickFrac * 0.3));
                        wetAbsorbOut.write(max(newAb, half4(0)), gid);
                        float nw = clamp(wickFrac * 0.5, 0.0, 0.3);
                        propsOut.write(half4(half(nw), props.g, props.b, half(MEDIA_WATERCOLOR)), gid);
                        return;
                    }
                }
            }
            // No wicking — normal early exit for dry texel
            wetAbsorbOut.write(absorb, gid);
            propsOut.write(props, gid);
            return;
        }

        // Only wet, low-viscosity paint flows (pastel/highlighter never flow)
        if (wetness < 0.05 || viscosity > 0.7 || mediaType == MEDIA_PASTEL || mediaType == MEDIA_HIGHLIGHTER) {
            wetAbsorbOut.write(absorb, gid);
            propsOut.write(props, gid);
            return;
        }

        // Acrylic is not water-soluble — once setting, it doesn't flow
        float hardness = float(props.g);
        if (mediaType == MEDIA_ACRYLIC && hardness > 0.1) {
            wetAbsorbOut.write(absorb, gid);
            propsOut.write(props, gid);
            return;
        }

        // Watercolor flows much more aggressively than oil/acrylic
        float mediaFlowMult = 1.0;
        float mediaDiffMult = 1.0;
        if (mediaType == MEDIA_WATERCOLOR) {
            mediaFlowMult = 3.0;   // water spreads fast
            mediaDiffMult = 4.0;   // pigment diffuses broadly → soft edges
        } else if (mediaType == MEDIA_OIL) {
            mediaFlowMult = 0.3;   // oil barely flows
            mediaDiffMult = 0.2;   // minimal diffusion
        }

        // Height gradient from neighbors
        float hL = heightTex.read(uint2(clamp(int(gid.x) - 1, 0, w - 1), gid.y)).r;
        float hR = heightTex.read(uint2(clamp(int(gid.x) + 1, 0, w - 1), gid.y)).r;
        float hU = heightTex.read(uint2(gid.x, clamp(int(gid.y) - 1, 0, h - 1))).r;
        float hD = heightTex.read(uint2(gid.x, clamp(int(gid.y) + 1, 0, h - 1))).r;

        float gradMag = length(float2(hR - hL, hD - hU)) * 0.5;
        float flowAmount = params.flowStrength * wetness * (1.0 - viscosity) * params.dt * mediaFlowMult;
        // Roughness resists flow; porosity enhances it
        flowAmount *= (1.0 - roughness * 0.5) * (0.5 + porosity * 0.5);
        flowAmount *= smoothstep(0.0, 0.01, gradMag);

        // Neighbor absorption + wetness for diffusion (pigment mass transported)
        half4 nAbsorbL = wetAbsorbIn.read(uint2(clamp(int(gid.x) - 1, 0, w - 1), gid.y));
        half4 nAbsorbR = wetAbsorbIn.read(uint2(clamp(int(gid.x) + 1, 0, w - 1), gid.y));
        half4 nAbsorbU = wetAbsorbIn.read(uint2(gid.x, clamp(int(gid.y) - 1, 0, h - 1)));
        half4 nAbsorbD = wetAbsorbIn.read(uint2(gid.x, clamp(int(gid.y) + 1, 0, h - 1)));

        float wL = float(propsIn.read(uint2(clamp(int(gid.x) - 1, 0, w - 1), gid.y)).r);
        float wR = float(propsIn.read(uint2(clamp(int(gid.x) + 1, 0, w - 1), gid.y)).r);
        float wU = float(propsIn.read(uint2(gid.x, clamp(int(gid.y) - 1, 0, h - 1))).r);
        float wD = float(propsIn.read(uint2(gid.x, clamp(int(gid.y) + 1, 0, h - 1))).r);

        // Diffusion: absorption values average (pigment mass transported)
        float diffRate = params.diffusionRate * wetness * porosity * params.dt * mediaDiffMult;

        half4 absorbSum = half4(0);
        float wetSum = 0.0;
        int wetCount = 0;

        // Watercolor: noise-modulated direction weights for anisotropic diffusion.
        // Paper fibers create preferred flow channels — pigment spreads unevenly
        // in different directions, producing organic tendrils instead of uniform spread.
        float anisoL = 1.0, anisoR = 1.0, anisoU = 1.0, anisoD = 1.0;
        if (mediaType == MEDIA_WATERCOLOR) {
            float2 fpos = float2(gid);
            anisoL = 0.3 + 0.7 * noise2d(fpos * 0.08 + float2(5.1, 0));
            anisoR = 0.3 + 0.7 * noise2d(fpos * 0.08 + float2(0, 9.3));
            anisoU = 0.3 + 0.7 * noise2d(fpos * 0.08 + float2(11.7, 0));
            anisoD = 0.3 + 0.7 * noise2d(fpos * 0.08 + float2(0, 15.1));
        }

        if (wL > 0.05) { float aw = wL * anisoL; absorbSum += nAbsorbL * half(aw); wetSum += aw; wetCount++; }
        if (wR > 0.05) { float aw = wR * anisoR; absorbSum += nAbsorbR * half(aw); wetSum += aw; wetCount++; }
        if (wU > 0.05) { float aw = wU * anisoU; absorbSum += nAbsorbU * half(aw); wetSum += aw; wetCount++; }
        if (wD > 0.05) { float aw = wD * anisoD; absorbSum += nAbsorbD * half(aw); wetSum += aw; wetCount++; }

        half4 newAbsorb = absorb;
        if (wetSum > 0.01 && wetCount > 0) {
            half4 avgNeighbor = absorbSum / half(wetSum);
            float maxDiff = (mediaType == MEDIA_WATERCOLOR) ? 0.45 : 0.25;
            // Diffuse absorption values (rgb) between neighbors
            newAbsorb.rgb = mix(absorb.rgb, avgNeighbor.rgb, half(clamp(diffRate, 0.0, maxDiff)));
            // Diffuse concentration (.a) separately
            newAbsorb.a = mix(absorb.a, avgNeighbor.a, half(clamp(diffRate, 0.0, maxDiff)));
        }

        // Watercolor thinning: reduce concentration, NOT absorption
        if (mediaType == MEDIA_WATERCOLOR) {
            float concLoss = clamp(flowAmount * 0.08, 0.0, 0.03);
            newAbsorb.a = max(newAbsorb.a - half(concLoss), half(0));
        }
        // Oil, acrylic, pastel: concentration conserved during flow
        newAbsorb = max(newAbsorb, half4(0));

        // Wetness spreads to neighbors (water migration)
        float avgNeighborWet = (wetCount > 0) ? wetSum / float(wetCount) : 0.0;
        float newWetness = mix(wetness, avgNeighborWet, clamp(diffRate * 0.4, 0.0, 0.1));

        // --- Height smoothing for wet overlapping regions ---
        // When wetness is high, surface tension smooths height toward neighbor average.
        // This creates the "raised edges, smooth center" effect as overlapping
        // strokes flatten the interior while edges retain their ridges.
        float wetSmoothThreshold = 0.3;
        if (wetness > wetSmoothThreshold && mediaType != MEDIA_PASTEL) {
            float centerH = heightTex.read(gid).r;
            float avgH = (hL + hR + hU + hD) * 0.25;
            // Smoothing factor scales with wetness above threshold
            float smoothFactor = (wetness - wetSmoothThreshold) * params.dt * 0.15;
            if (mediaType == MEDIA_OIL) smoothFactor *= 0.3; // oil resists smoothing
            float smoothedH = mix(centerH, avgH, clamp(smoothFactor, 0.0, 0.12));
            heightTex.write(float4(smoothedH, 0, 0, 0), gid);
        }

        wetAbsorbOut.write(newAbsorb, gid);
        propsOut.write(half4(half(newWetness), props.g, props.b, props.a), gid);
    }
    """

    // MARK: - Kernel 4: Dry Step

    static let dryStep = header + """

    kernel void dryStep(
        texture2d<half, access::read>        wetAbsorbIn   [[ texture(0) ]],
        texture2d<half, access::read>        propsIn       [[ texture(1) ]],
        texture2d<half, access::read_write>  solidAbsorbTex[[ texture(2) ]],
        texture2d<half, access::write>       wetAbsorbOut  [[ texture(3) ]],
        texture2d<half, access::write>       propsOut      [[ texture(4) ]],
        texture2d<float, access::read_write> heightTex     [[ texture(5) ]],
        constant SimParams &params                         [[ buffer(0) ]],
        uint2 gid                                          [[ thread_position_in_grid ]]
    ) {
        int w = wetAbsorbIn.get_width();
        int h = wetAbsorbIn.get_height();
        if (int(gid.x) >= w || int(gid.y) >= h) return;

        half4 wetAbsorb = wetAbsorbIn.read(gid);
        half4 props = propsIn.read(gid);
        half4 solidAbsorb = solidAbsorbTex.read(gid);

        float wetness  = float(props.r);
        float hardness = float(props.g);
        int mediaType  = int(props.a);

        // Media-specific dry rates
        float mediaDryMult = 1.0;
        if (mediaType == MEDIA_ACRYLIC)    mediaDryMult = 8.0;   // acrylic dries very fast
        if (mediaType == MEDIA_PASTEL)     mediaDryMult = 10.0;
        if (mediaType == MEDIA_OIL)        mediaDryMult = 0.5;
        if (mediaType == MEDIA_HIGHLIGHTER) mediaDryMult = 12.0;  // ink dries almost instantly

        float dryAmount = params.dryRate * params.dt * mediaDryMult * 3.0;
        float newWet = max(wetness - dryAmount, 0.0);
        float newHard = min(hardness + dryAmount * 0.5, 1.0);

        // Transfer dried pigment: wet → solid (concentration-weighted absorption blend)
        // CONSERVATION: solid gains exactly what wet loses in concentration
        // Don't gate transfer by wetness — pigment should settle to solid even
        // after water evaporates.  The wetAbsorb.a > 0.01 guard prevents
        // running when there's nothing left to transfer.
        float transferAmount = clamp(dryAmount * 2.0, 0.0, 1.0);
        if (transferAmount > 0.001 && float(wetAbsorb.a) > 0.01) {
            float wetConc = float(wetAbsorb.a);
            float solidConc = float(solidAbsorb.a);

            // Concentration to move from wet → solid
            // Acrylic: transfer 90% per step so solid reaches full concentration
            // before wetness drops to zero (prevents visible lightening during drying)
            float concToMove = (mediaType == MEDIA_ACRYLIC)
                ? min(wetConc, max(wetConc * transferAmount, wetConc * 0.9))
                : wetConc * transferAmount;
            concToMove = min(concToMove, wetConc);  // never move more than available

            float newSolidConc;
            half3 newSolidAbsRGB;

            if (mediaType == MEDIA_OIL || mediaType == MEDIA_ACRYLIC || mediaType == MEDIA_PASTEL) {
                // ADDITIVE transfer: solid gains exactly what wet loses
                newSolidConc = min(solidConc + concToMove, 1.0);
                if (newSolidConc > 0.001) {
                    // For opaque media: wet paint REPLACES solid absorption proportional to coverage
                    // This lets white oil paint fully cover dark solid beneath
                    float wetDominance = concToMove / newSolidConc;  // how much of new solid came from wet
                    if (mediaType == MEDIA_ACRYLIC) {
                        // Acrylic: full replacement — dries to its applied color
                        newSolidAbsRGB = half3(mix(float3(solidAbsorb.rgb), float3(wetAbsorb.rgb), clamp(wetDominance, 0.0, 1.0)));
                    } else {
                        // Oil/pastel: weighted replacement — more aggressive than averaging
                        float replaceFactor = clamp(wetDominance * 1.5, 0.0, 0.95);
                        newSolidAbsRGB = half3(mix(float3(solidAbsorb.rgb), float3(wetAbsorb.rgb), replaceFactor));
                    }
                } else {
                    newSolidAbsRGB = solidAbsorb.rgb;
                }
                // Wet loses exactly what solid gained
                wetAbsorb.a = half(max(wetConc - concToMove, 0.0));
            } else if (mediaType == MEDIA_HIGHLIGHTER) {
                // Highlighter: MAX transfer — solid takes the maximum of wet/solid absorption
                // so drying never darkens beyond the single-layer intensity
                newSolidConc = clamp(max(solidConc, concToMove), 0.0, 0.7);
                newSolidAbsRGB = half3(max(float3(solidAbsorb.rgb), float3(wetAbsorb.rgb)));
                wetAbsorb.a = half(max(wetConc - concToMove, 0.0));
            } else {
                // Watercolor: concentration thins as water evaporates
                newSolidConc = clamp(solidConc + concToMove * 0.8, 0.0, 1.0);
                if (newSolidConc > 0.001) {
                    newSolidAbsRGB = half3(
                        (float3(solidAbsorb.rgb) * solidConc + float3(wetAbsorb.rgb) * concToMove * 0.8)
                        / newSolidConc
                    );
                } else {
                    newSolidAbsRGB = solidAbsorb.rgb;
                }
                wetAbsorb.a = half(clamp(wetConc - concToMove, 0.0, 1.0));
            }

            solidAbsorbTex.write(max(half4(newSolidAbsRGB, half(newSolidConc)), half4(0)), gid);
        }

        // Edge darkening at wet/dry boundaries — increase absorption at edges
        float wL = float(propsIn.read(uint2(clamp(int(gid.x) - 1, 0, w - 1), gid.y)).r);
        float wR = float(propsIn.read(uint2(clamp(int(gid.x) + 1, 0, w - 1), gid.y)).r);
        float wU = float(propsIn.read(uint2(gid.x, clamp(int(gid.y) - 1, 0, h - 1))).r);
        float wD = float(propsIn.read(uint2(gid.x, clamp(int(gid.y) + 1, 0, h - 1))).r);
        float wetGrad = length(float2(wR - wL, wD - wU)) * 0.5;

        half4 newWetAbsorb = wetAbsorb;
        if (wetGrad > 0.1 && wetness > 0.1) {
            float darken = clamp(params.edgeDarken * wetGrad * params.dt, 0.0, 0.08);
            // Scale edge darkening by existing absorption — white/light paint
            // has near-zero absorption, so additive darkening would create
            // artificial burns.  Multiplicative scaling preserves light colors.
            float absorbMag = length(float3(wetAbsorb.rgb));
            float darkenScale = smoothstep(0.05, 0.5, absorbMag);
            darken *= darkenScale;
            // Increase absorption at edges (darker = more absorption)
            newWetAbsorb.rgb += half3(darken * 0.3);
            newWetAbsorb.a = min(newWetAbsorb.a + half(darken * 0.1), half(1.0));
        }
        newWetAbsorb = max(newWetAbsorb, half4(0));

        wetAbsorbOut.write(newWetAbsorb, gid);

        // --- Height smoothing during drying ---
        // As paint dries, surface tension and gravity smooth out ridges.
        // Smoothing rate varies by media:
        //   watercolor: smooths a lot (surface tension of water)
        //   acrylic: slight leveling before skin forms, then locks
        //   pastel: smooths out sharp ridges as it sets
        //   oil: smooths only slightly (high viscosity retains impasto)
        float smoothRate = 0.0;
        if (mediaType == MEDIA_WATERCOLOR)  smoothRate = params.dt * 0.4;
        else if (mediaType == MEDIA_ACRYLIC) smoothRate = params.dt * 0.06;  // slight leveling before acrylic skins over
        else if (mediaType == MEDIA_PASTEL)  smoothRate = params.dt * 0.12;
        else if (mediaType == MEDIA_OIL)     smoothRate = params.dt * 0.03;

        // Only smooth when there's wet paint (once fully dry, height is locked)
        if (smoothRate > 0.0 && wetness > 0.01) {
            float centerH = heightTex.read(gid).r;
            float hL = heightTex.read(uint2(clamp(int(gid.x) - 1, 0, w - 1), gid.y)).r;
            float hR = heightTex.read(uint2(clamp(int(gid.x) + 1, 0, w - 1), gid.y)).r;
            float hU = heightTex.read(uint2(gid.x, clamp(int(gid.y) - 1, 0, h - 1))).r;
            float hD = heightTex.read(uint2(gid.x, clamp(int(gid.y) + 1, 0, h - 1))).r;
            float avgH = (hL + hR + hU + hD) * 0.25;
            // Blend toward neighbor average — wetness scales effect
            float blend = smoothRate * wetness;
            float smoothedH = mix(centerH, avgH, clamp(blend, 0.0, 0.5));
            heightTex.write(float4(smoothedH, 0, 0, 0), gid);
        }

        // --- Acrylic volume shrinkage during drying ---
        // Water-based media contracts ~25% as water evaporates.
        // Applied proportionally to drying progress each step so the
        // cumulative shrinkage over full drying ≈ 25%.
        // Oil cures by oxidation — zero volume loss, retains all impasto.
        if (mediaType == MEDIA_ACRYLIC && dryAmount > 0.001) {
            float currentH = heightTex.read(gid).r;
            if (currentH > 0.05) {  // only shrink paint, not bare canvas
                float shrinkFraction = dryAmount * 0.25;
                float newH = currentH * (1.0 - shrinkFraction);
                heightTex.write(float4(max(newH, 0.0), 0, 0, 0), gid);
            }
        }

        propsOut.write(half4(half(newWet), half(newHard), props.b, props.a), gid);
    }
    """
}
