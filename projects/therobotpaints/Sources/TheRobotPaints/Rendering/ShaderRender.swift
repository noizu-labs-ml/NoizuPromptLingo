extension ShaderSource {
    static let render = header + """
kernel void render(
    device const VolumeLayer* layers [[buffer(0)]],
    texture2d<half, access::read> canvasProps [[texture(0)]],
    texture2d<half, access::write> output [[texture(1)]],
    constant RenderParams& params [[buffer(1)]],
    constant LightParams& light [[buffer(2)]],
    constant ViewParams& view [[buffer(3)]],
    constant LayerState& layerState [[buffer(4)]],
    uint2 gid [[thread_position_in_grid]]
) {
    int dw = int(view.drawable_width);
    int dh = int(view.drawable_height);
    if (int(gid.x) >= dw || int(gid.y) >= dh) return;

    int cw = int(view.canvas_width);
    int ch = int(view.canvas_height);
    int layerCount = int(params.layer_count);

    float fitScale = min(float(dw) / float(cw), float(dh) / float(ch));
    float scale = fitScale * view.zoom_level;

    float baseX = float(cw) / 2.0 - float(dw) / (2.0 * scale);
    float baseY = float(ch) / 2.0 - float(dh) / (2.0 * scale);

    float canvasXf = float(gid.x) / scale + baseX + view.pan_offset_x;
    float canvasYf = float(gid.y) / scale + baseY + view.pan_offset_y;

    int cx = int(floor(canvasXf));
    int cy = int(floor(canvasYf));

    if (cx < 0 || cx >= cw || cy < 0 || cy >= ch) {
        int checker = ((int(gid.x) / 16) + (int(gid.y) / 16)) % 2;
        half gray = checker ? half(0.18) : half(0.22);
        output.write(half4(gray, gray, gray, 1.0), gid);
        return;
    }

    float3 lightDir = normalize(float3(light.light_dir_x, light.light_dir_y, light.light_dir_z));

    // --- Paper base color (warm white watercolor paper) ---
    float3 paperColor = float3(0.95, 0.93, 0.88);

    // Canvas texture: roughness-based brightness modulation
    uint2 canvasGid = uint2(cx, cy);
    half4 props = canvasProps.read(canvasGid);
    float roughness = float(props.g);
    paperColor *= mix(0.85, 1.0, 1.0 - roughness * 0.3);

    // Canvas surface normal from roughness gradient (paper tooth)
    float roughL = roughness, roughR = roughness;
    float roughU = roughness, roughD = roughness;
    if (cx > 0)      roughL = float(canvasProps.read(uint2(cx - 1, cy)).g);
    if (cx < cw - 1) roughR = float(canvasProps.read(uint2(cx + 1, cy)).g);
    if (cy > 0)      roughU = float(canvasProps.read(uint2(cx, cy - 1)).g);
    if (cy < ch - 1) roughD = float(canvasProps.read(uint2(cx, cy + 1)).g);

    float3 canvasNormal = normalize(float3(
        (roughL - roughR) * 4.0,
        (roughU - roughD) * 4.0,
        1.0
    ));
    float canvasDiffuse = 0.7 + 0.3 * max(dot(canvasNormal, lightDir), 0.0);
    paperColor *= canvasDiffuse;

    uint pixelIndex = uint(cy) * uint(cw) + uint(cx);
    uint layerStride = uint(cw) * uint(ch);

    uint visMask = layerState.visibility_mask;

    // --- Beer-Lambert compositing ---
    // Accumulate combined transmission across all layers (back to front).
    // Each pigment layer absorbs a fraction of the light passing through it.
    // Light travels: source → through all layers → paper → back through all layers → eye.
    // Round-trip means effective path length doubles, so exponent multiplier = 2.0.
    // Combined transmission starts at 1 (no absorption), then is multiplied layer by layer.
    float3 combinedTransmission = float3(1.0);

    // Track maximum wet-paint gloss for specular highlight
    float maxWaterHeight = 0.0;
    float maxGloss = 0.0;

    // Impasto: accumulate depth normal from all layers for subtle surface relief
    float totalDepthL = 0.0, totalDepthR = 0.0, totalDepthU = 0.0, totalDepthD = 0.0;

    for (int layer = layerCount - 1; layer >= 0; layer--) {
        if ((visMask & (1u << uint(layer))) == 0) continue;

        uint idx = pixelIndex + uint(layer) * layerStride;
        VolumeLayer v = layers[idx];

        // Pigment concentration per channel (floating in water + deposited on paper).
        // color_r/g/b = floating pigment concentration (can exceed 1.0).
        // depth = deposited dried pigment (grayscale), adds uniformly across channels.
        float pigR = float(v.color_r) + float(v.depth);
        float pigG = float(v.color_g) + float(v.depth);
        float pigB = float(v.color_b) + float(v.depth);

        // Skip layers with negligible pigment (no contribution)
        if (pigR < 0.001 && pigG < 0.001 && pigB < 0.001) continue;

        // Beer-Lambert per-channel transmission for this layer (round-trip path length = 2)
        float3 layerTransmission = float3(
            exp(-pigR * 2.0),
            exp(-pigG * 2.0),
            exp(-pigB * 2.0)
        );

        // Multiply into combined transmission (each layer further absorbs remaining light)
        combinedTransmission *= layerTransmission;

        // Opaque media (oil=1, acrylic=2): high pigment blocks layers below
        int mediaType = int(v.substance_type);
        if (mediaType == 1 || mediaType == 2) {
            float totalPig = pigR + pigG + pigB;
            float opacity = clamp(totalPig * 0.5, 0.0, 0.95);
            combinedTransmission *= (1.0 - opacity);
        }

        // Track wettest/glossiest layer for specular
        float waterHeight = float(v.color_o);
        if (waterHeight > maxWaterHeight) {
            maxWaterHeight = waterHeight;
            maxGloss = float(v.gloss);
        }

        // Accumulate depth for impasto normal (subtle for watercolor)
        float depthVal = float(v.depth);
        if (cx > 0)      totalDepthL += float(layers[pixelIndex - 1           + uint(layer) * layerStride].depth);
        if (cx < cw - 1) totalDepthR += float(layers[pixelIndex + 1           + uint(layer) * layerStride].depth);
        if (cy > 0)      totalDepthU += float(layers[pixelIndex - uint(cw)    + uint(layer) * layerStride].depth);
        if (cy < ch - 1) totalDepthD += float(layers[pixelIndex + uint(cw)    + uint(layer) * layerStride].depth);
        (void)depthVal;
    }

    // Final visible color: paper seen through all combined pigment absorption.
    // Where transmission=1 (no pigment), we see pure paper.
    // Where transmission=0 (dense pigment), we see the absorbed complement (paper * 0 = black).
    float3 litPaper = paperColor * combinedTransmission;

    // --- Impasto surface relief (subtle — watercolor deposits thin layers) ---
    float3 impastoNormal = normalize(float3(
        (totalDepthL - totalDepthR) * 0.5,
        (totalDepthU - totalDepthD) * 0.5,
        2.0
    ));
    float impastoNdotL = max(dot(impastoNormal, lightDir), 0.0);
    float impastoLighting = 0.92 + 0.08 * impastoNdotL;
    litPaper *= impastoLighting;

    // --- Wet paint specular gloss ---
    // Wet watercolor is glossy (water surface); dry is matte.
    float3 viewDir = float3(0.0, 0.0, 1.0);
    float3 halfVec = normalize(lightDir + viewDir);
    float NdotH = max(dot(impastoNormal, halfVec), 0.0);

    float specular = 0.0;
    if (maxWaterHeight > 0.01) {
        // Wet paint: sharp specular from water surface
        float wetGlossPow = 64.0 + maxWaterHeight * 192.0;
        specular = pow(NdotH, wetGlossPow) * maxWaterHeight * 0.4;
    } else if (maxGloss > 0.01) {
        // Dried paint with residual gloss (e.g., dried ink, acrylic medium)
        specular = pow(NdotH, maxGloss * 128.0 + 16.0) * maxGloss * 0.15;
    }
    litPaper += float3(specular);

    float4 result = float4(litPaper, 1.0);

    // --- Tone mapping: Reinhard + gamma ---
    result.rgb = result.rgb / (1.0 + result.rgb);
    result.rgb = pow(result.rgb, float3(1.0 / 2.2));

    // --- Pixel grid overlay at high zoom ---
    if (scale > 8.0) {
        float fracX = fract(canvasXf);
        float fracY = fract(canvasYf);
        float edge = 1.0 / scale;
        bool onGrid = (fracX < edge || fracX > 1.0 - edge ||
                       fracY < edge || fracY > 1.0 - edge);
        if (onGrid) {
            float gridAlpha = clamp((scale - 8.0) / 16.0, 0.0, 0.35);
            result.rgb = mix(result.rgb, float3(0.1, 0.1, 0.1), gridAlpha);
        }
    }

    output.write(half4(half(result.r), half(result.g), half(result.b), half(result.a)), gid);
}
"""
}
