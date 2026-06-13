/// Paint render kernel — composites wet/solid layers with lighting.
extension PaintShaderSource {

    // MARK: - Kernel 5: Render

    static let render = header + """

    kernel void paintRender(
        texture2d<half, access::read>   wetAbsorbTex  [[ texture(0) ]],
        texture2d<half, access::read>   solidAbsorbTex[[ texture(1) ]],
        texture2d<half, access::read>   propsTex      [[ texture(2) ]],
        texture2d<float, access::read>  heightTex     [[ texture(3) ]],
        texture2d<half, access::write>  outputTex     [[ texture(4) ]],
        constant RenderParams &params                 [[ buffer(0) ]],
        uint2 gid                                     [[ thread_position_in_grid ]]
    ) {
        int w = wetAbsorbTex.get_width();
        int h = wetAbsorbTex.get_height();
        if (int(gid.x) >= w || int(gid.y) >= h) return;

        half4 wetAbsorb = wetAbsorbTex.read(gid);
        half4 solidAbsorb = solidAbsorbTex.read(gid);
        half4 props = propsTex.read(gid);
        float centerH = heightTex.read(gid).r;

        // Normal from height
        float hL = heightTex.read(uint2(clamp(int(gid.x) - 1, 0, w - 1), gid.y)).r;
        float hR = heightTex.read(uint2(clamp(int(gid.x) + 1, 0, w - 1), gid.y)).r;
        float hU = heightTex.read(uint2(gid.x, clamp(int(gid.y) - 1, 0, h - 1))).r;
        float hD = heightTex.read(uint2(gid.x, clamp(int(gid.y) + 1, 0, h - 1))).r;
        float3 normal = normalize(float3(
            (hL - hR) * params.heightScale,
            (hU - hD) * params.heightScale, 1.0));

        float solidConc = float(solidAbsorb.a);
        float wetConc = float(wetAbsorb.a);

        // Debug render modes
        if (params.renderMode == 1) {
            float hVizScale = 1.0 / max(params.heightScale * 0.5, 0.1);
            float hNorm = clamp(log(1.0 + centerH * hVizScale * 20.0) * 0.4, 0.0, 1.0);
            outputTex.write(half4(half3(hNorm), 1.0), gid);
            return;
        }
        if (params.renderMode == 2) {
            float wetness = float(props.r);
            float hardness = float(props.g);
            outputTex.write(half4(half(hardness), half(solidConc), half(wetness), 1.0), gid);
            return;
        }
        if (params.renderMode == 3) {
            outputTex.write(half4(half3(normal * 0.5 + 0.5), 1.0), gid);
            return;
        }
        if (params.renderMode == 4) {
            // Solid layer only — show visible color: exp(-absorption * concentration)
            float3 visibleSolid = exp(-float3(solidAbsorb.rgb) * max(solidConc, 0.001));
            outputTex.write(half4(half3(visibleSolid), max(half(solidConc), half(0.1))), gid);
            return;
        }
        if (params.renderMode == 5) {
            // Wet layer only — show visible color: exp(-absorption * concentration)
            float3 visibleWet = exp(-float3(wetAbsorb.rgb) * max(wetConc, 0.001));
            outputTex.write(half4(half3(visibleWet), max(half(wetConc), half(0.1))), gid);
            return;
        }
        if (params.renderMode == 6) {
            // Media Map: diagnostic colors per medium type
            // Oil=warm orange, Watercolor=blue, Acrylic=magenta, Pastel=green
            float totalConc = solidConc + wetConc;
            if (totalConc < 0.01) {
                outputTex.write(half4(0.12, 0.12, 0.12, 1.0), gid);
                return;
            }
            int mediaType = int(props.a);
            float3 diagColor;
            if (mediaType == MEDIA_OIL)             diagColor = float3(1.0, 0.6, 0.2);
            else if (mediaType == MEDIA_WATERCOLOR) diagColor = float3(0.2, 0.5, 1.0);
            else if (mediaType == MEDIA_ACRYLIC)    diagColor = float3(0.9, 0.3, 0.7);
            else if (mediaType == MEDIA_PASTEL)      diagColor = float3(0.3, 0.9, 0.4);
            else if (mediaType == MEDIA_HIGHLIGHTER) diagColor = float3(1.0, 1.0, 0.2);
            else                                     diagColor = float3(0.5, 0.5, 0.5);
            float alpha = clamp(totalConc * 2.0, 0.0, 0.9);
            float3 bg = float3(0.12);
            float3 result = mix(bg, diagColor, alpha);
            outputTex.write(half4(half3(result), 1.0), gid);
            return;
        }

        // --- Mode 0: Full lit composite ---
        float3 lightDir = normalize(float3(params.lightDirX, params.lightDirY, params.lightDirZ));
        float NdotL = max(dot(normal, lightDir), 0.0);
        float diffuse = params.ambient + (1.0 - params.ambient) * NdotL;

        float wetness = float(props.r);
        float3 viewDir = float3(0, 0, 1);
        float3 halfVec = normalize(lightDir + viewDir);

        int mediaType = int(props.a);

        // Media-specific specular: each medium has different gloss characteristics
        float specExponent;
        float specIntensity;
        if (mediaType == MEDIA_ACRYLIC) {
            specExponent = 48.0;                    // tight, glossy highlights
            specIntensity = params.specular * 1.5;
        } else if (mediaType == MEDIA_OIL) {
            specExponent = 24.0;                    // softer, broader highlights
            specIntensity = params.specular * 0.8;
        } else {
            specExponent = 32.0;                    // watercolor / pastel default
            specIntensity = params.specular;
        }
        float spec = pow(max(dot(normal, halfVec), 0.0), specExponent) * specIntensity * wetness;

        // Canvas base color
        float3 baseColor = float3(params.canvasR, params.canvasG, params.canvasB);
        float3 result;

        // First compute the transparent base (watercolor-style absorption through canvas)
        // This serves as the "background" for opaque media, replacing raw canvas white
        float3 totalAbsorb = float3(solidAbsorb.rgb) * solidConc + float3(wetAbsorb.rgb) * wetConc;
        float totalConc = solidConc + wetConc;

        float3 transparentBase = baseColor * exp(-totalAbsorb) * diffuse;

        if (mediaType == MEDIA_HIGHLIGHTER) {
            // Highlighter: screen blend — bright translucent overlay like a real marker.
            // Convert absorption to reflectance for the ink color
            float3 inkRefl = exp(-totalAbsorb);
            float hlAlpha = clamp(totalConc * 0.6, 0.0, 0.7);
            float3 canvasLit = baseColor * diffuse;
            // Screen blend: result = 1 - (1 - base)(1 - overlay*alpha)
            result = 1.0 - (1.0 - canvasLit) * (1.0 - inkRefl * hlAlpha);
            result += spec * 0.2;
        } else if (mediaType == MEDIA_WATERCOLOR) {
            // Watercolor layering: if painting over significant dried opaque paint,
            // composite properly instead of pure Beer-Lambert (which stacks absorption → black)
            if (solidConc > 0.1) {
                // Render the solid layer as an opaque base
                float3 solidRefl = exp(-float3(solidAbsorb.rgb) * max(solidConc, 0.001));
                float solidCov = clamp(1.0 - exp(-solidConc * 2.0), 0.0, 1.0);
                float3 solidBase = solidRefl * diffuse * solidCov + baseColor * diffuse * (1.0 - solidCov);
                // Apply wet watercolor as a transparent glaze over the opaque base
                float3 wetGlaze = exp(-float3(wetAbsorb.rgb) * max(wetConc, 0.001));
                float wetAlpha = clamp(wetConc * 2.0, 0.0, 0.8);
                result = mix(solidBase, solidBase * wetGlaze, wetAlpha) + spec;
            } else {
                // Pure watercolor on bare/lightly-painted canvas: Beer-Lambert absorption
                result = transparentBase + spec;
            }
        } else {
            // Opaque/semi-opaque media: coverage-based compositing
            // Background is the transparent absorption result, NOT raw canvas white
            // This prevents white glow halos around opaque strokes over watercolor
            // Acrylic gets higher coverage multiplier for more opaque appearance
            float coverageMult = (mediaType == MEDIA_ACRYLIC) ? 10.0
                               : (mediaType == MEDIA_PASTEL) ? 8.0
                               : 2.0;

            float3 solidRefl = exp(-float3(solidAbsorb.rgb) * max(solidConc, 0.001));
            float solidCoverage = clamp(1.0 - exp(-solidConc * coverageMult), 0.0, 1.0);
            if (mediaType == MEDIA_OIL && solidConc > 0.05) {
                solidCoverage = max(solidCoverage, 0.7);
            }
            float3 solidLit = solidRefl * diffuse;

            // Acrylic stipple: at the very edge of a brush stroke, real bristles
            // either deposit paint or don't — creating splotchy rather than smooth
            // falloff.  Only applies to the thin edge band (coverage 0.02–0.35);
            // once multiple strokes build up moderate coverage, it stays solid.
            // Uses a floor of 0.03 instead of 0.0 to prevent black borders where
            // thin edges expose dark paint underneath.
            if (mediaType == MEDIA_ACRYLIC && solidCoverage > 0.02 && solidCoverage < 0.35) {
                float stipple = hash(float2(gid) * 0.73 + 31.7);
                solidCoverage = (solidCoverage > stipple * 0.3) ?
                                min(solidCoverage * 2.5, 1.0) : 0.03;
            }

            // Blend opaque layer over transparent base (not raw canvas)
            result = solidLit * solidCoverage + transparentBase * (1.0 - solidCoverage);

            // Wet layer: use a reduced coverage multiplier to prevent ghost white
            // halos.  The pixel's mediaType may be acrylic (high coverageMult) even
            // though the wet layer holds thin watercolor deposited on top.  Capping
            // the wet multiplier keeps thin foreign-media deposits transparent.
            float wetCovMult = min(coverageMult, 3.0);
            float3 wetRefl = exp(-float3(wetAbsorb.rgb) * max(wetConc, 0.001));
            float wetCoverage = clamp(1.0 - exp(-wetConc * wetCovMult), 0.0, 1.0);
            float3 wetLit = wetRefl * diffuse + spec;
            result = wetLit * wetCoverage + result * (1.0 - wetCoverage);
        }

        // Canvas texture through thin paint — opaque media blocks canvas sooner
        float coverageForCanvas = (mediaType == MEDIA_ACRYLIC || mediaType == MEDIA_PASTEL)
            ? clamp(1.0 - exp(-(solidConc + wetConc) * 8.0), 0.0, 1.0)
            : (mediaType == MEDIA_OIL)
                ? clamp(solidConc + wetConc * (1.0 - solidConc), 0.0, 1.0)
                : clamp(solidConc + wetConc * (1.0 - solidConc), 0.0, 1.0);
        if (mediaType == MEDIA_OIL) {
            coverageForCanvas = clamp(1.0 - exp(-(solidConc + wetConc) * 4.0), 0.0, 1.0);
        }
        float canvasShow = (1.0 - coverageForCanvas) * 0.3;
        result += canvasShow * (centerH * 2.0 - 0.5) * 0.1;

        outputTex.write(half4(half3(clamp(result, 0.0, 1.0)), 1.0), gid);
    }
    """
}
