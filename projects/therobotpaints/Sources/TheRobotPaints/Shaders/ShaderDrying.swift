extension ShaderSource {
    static let drying = header + sphHeader + """
constant float DRYING_RATE_WATERCOLOR = 0.3;
constant float DRYING_RATE_OIL = 0.05;
constant float DRYING_RATE_ACRYLIC = 8.0;
constant float DRYING_RATE_CHARCOAL = 1000.0;
constant float DRYING_RATE_PASTEL = 1000.0;

float media_drying_rate(half substance_type) {
    int media = int(substance_type);
    if (media == 1) return DRYING_RATE_OIL;
    if (media == 2) return DRYING_RATE_ACRYLIC;
    if (media == 3) return DRYING_RATE_CHARCOAL;
    if (media == 4) return DRYING_RATE_PASTEL;
    return DRYING_RATE_WATERCOLOR;
}

kernel void drying(
    device VolumeLayer* layers [[buffer(0)]],
    texture2d<half, access::read> canvasProps [[texture(0)]],
    constant DryingParams& params [[buffer(1)]],
    uint2 gid [[thread_position_in_grid]]
) {
    int cw = int(params.canvas_width);
    int ch = int(params.canvas_height);
    if (int(gid.x) >= cw || int(gid.y) >= ch) return;

    uint pixelIndex = gid.y * uint(cw) + gid.x;
    uint layerStride = uint(cw) * uint(ch);
    int layerCount = int(params.layer_count);

    half absorbency = canvasProps.read(gid).r;

    for (int layer = 0; layer < layerCount; layer++) {
        uint idx = pixelIndex + uint(layer) * layerStride;

        float water = float(layers[idx].color_o);  // water height stored in color_o
        if (water < 0.001) continue;

        float rate = media_drying_rate(layers[idx].substance_type);

        // --- EVAPORATION: water leaves, pigment stays ---
        // Absorbency modulates rate: more absorbent paper dries faster
        float evap = rate * (0.3 + float(absorbency) * 0.7) * params.dt;
        float newWater = max(0.0, water - evap);
        layers[idx].color_o = half(newWater);

        // --- PAPER ABSORPTION: water soaks into paper fibers ---
        // Repurpose hardness as paper saturation (0=dry paper, 1=saturated)
        float paperSat = float(layers[idx].hardness);
        float absorbAmount = float(absorbency) * params.dt * 0.2 * water;
        paperSat = min(1.0, paperSat + absorbAmount);
        layers[idx].hardness = half(paperSat);

        // --- PIGMENT SETTLING: deposits as water level drops ---
        // Pigment sediments onto paper fibers when nearly dry
        if (newWater < 0.15 && newWater < water) {
            float settleRate = (0.15 - newWater) * 5.0 * params.dt;
            float pigR = float(layers[idx].color_r);
            float pigG = float(layers[idx].color_g);
            float pigB = float(layers[idx].color_b);

            // Accumulate deposit amount into depth channel
            float pigMag = sqrt(pigR * pigR + pigG * pigG + pigB * pigB);
            layers[idx].depth += half(pigMag * settleRate);
        }

        // --- FULLY DRY ---
        if (newWater <= 0.0) {
            // Pigment remains in color_r/g/b as dried concentration
            layers[idx].color_o = 0.0h;
            layers[idx].gloss = 0.05h;     // dry watercolor is matte
            layers[idx].velocity_x = 0.0h;
            layers[idx].velocity_y = 0.0h;
            layers[idx].wetness = 0.0h;
        } else {
            // Wet paint is glossy; gloss scales with water height
            layers[idx].gloss = half(min(0.6, newWater * 0.8));
            // Keep wetness in sync for downstream kernels
            layers[idx].wetness = half(clamp(newWater, 0.0, 1.0));
        }
    }
}

kernel void instantDry(
    device VolumeLayer* layers [[buffer(0)]],
    constant DryingParams& params [[buffer(1)]],
    uint2 gid [[thread_position_in_grid]]
) {
    int cw = int(params.canvas_width);
    int ch = int(params.canvas_height);
    if (int(gid.x) >= cw || int(gid.y) >= ch) return;

    uint pixelIndex = gid.y * uint(cw) + gid.x;
    uint layerStride = uint(cw) * uint(ch);
    int layerCount = int(params.layer_count);

    for (int layer = 0; layer < layerCount; layer++) {
        uint idx = pixelIndex + uint(layer) * layerStride;
        // Drain water; pigment (color_r/g/b) stays deposited
        layers[idx].color_o = 0.0h;
        layers[idx].wetness = 0.0h;
        layers[idx].hardness = 1.0h;
        layers[idx].gloss = 0.05h;
        layers[idx].velocity_x = 0.0h;
        layers[idx].velocity_y = 0.0h;
    }
}
"""
}
