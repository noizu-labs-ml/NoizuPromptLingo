extension ShaderSource {
    static let crossMediaHeader = """
// Cross-media rejection: row=incoming, col=existing (dried)
// WC=0, Oil=1, Acrylic=2, Charcoal=3, Pastel=4
constant float CROSS_MEDIA_MATRIX[5][5] = {
    {1.0, 0.0, 0.3, 1.0, 0.8},   // Watercolor over...
    {1.0, 1.0, 1.0, 1.0, 1.0},   // Oil over...
    {1.0, 0.0, 1.0, 1.0, 1.0},   // Acrylic over...
    {0.1, 0.9, 0.9, 1.0, 0.5},   // Charcoal over...
    {0.8, 0.1, 0.4, 1.0, 1.0}    // Pastel over...
};

float cross_media_adhesion(uint incoming_media, half existing_substance, half existing_hardness) {
    if (existing_hardness < 0.5) return 1.0;   // wet paint: always accept
    int existing = clamp(int(existing_substance), 0, 4);
    int incoming = clamp(int(incoming_media), 0, 4);
    return CROSS_MEDIA_MATRIX[incoming][existing];
}

// Procedural bristle texture: returns a [0,1] modulation factor based on brush shape
float brushTexture(float2 pos, float angle, uint shapeType) {
    // Rotate position by brush angle
    float ca = cos(angle);
    float sa = sin(angle);
    float2 rp = float2(pos.x * ca + pos.y * sa, -pos.x * sa + pos.y * ca);

    if (shapeType == 0) {
        // Round brush: radial bristle pattern
        float theta = atan2(rp.y, rp.x);
        float bristles = 0.7 + 0.3 * sin(theta * 12.0);  // 12 bristle ridges
        float grain = 0.85 + 0.15 * noise2d(rp * 3.0);   // fine grain noise
        return bristles * grain;
    } else if (shapeType == 1) {
        // Flat brush: parallel streaks
        float streaks = 0.6 + 0.4 * sin(rp.x * 8.0);     // parallel bristle lines
        float grain = 0.85 + 0.15 * noise2d(rp * 4.0);
        return streaks * grain;
    } else {
        // Fan brush: radiating streaks
        float theta = atan2(rp.y, rp.x);
        float fan = 0.5 + 0.5 * sin(theta * 20.0);
        float grain = 0.8 + 0.2 * noise2d(rp * 2.0);
        return fan * grain;
    }
}

"""

    static let deposit = header + brushHeader + crossMediaHeader + """
kernel void deposit(
    device VolumeLayer* layers [[buffer(0)]],
    device const BrushPoint* points [[buffer(1)]],
    constant BrushParams& brush [[buffer(2)]],
    constant DepositParams& params [[buffer(3)]],
    uint tid [[thread_position_in_grid]]
) {
    if (tid >= params.point_count) return;

    BrushPoint pt = points[tid];
    int cw = int(params.canvas_width);
    int ch = int(params.canvas_height);
    uint layerStride = uint(cw) * uint(ch);
    uint activeLayer = brush.active_layer;

    float effectiveRadius = pt.size;
    if (effectiveRadius < 0.5) return;

    int minX = max(0, int(pt.position_x - effectiveRadius));
    int maxX = min(cw - 1, int(pt.position_x + effectiveRadius));
    int minY = max(0, int(pt.position_y - effectiveRadius));
    int maxY = min(ch - 1, int(pt.position_y + effectiveRadius));

    float invRadius = 1.0 / effectiveRadius;

    for (int y = minY; y <= maxY; y++) {
        for (int x = minX; x <= maxX; x++) {
            float dx = float(x) - pt.position_x;
            float dy = float(y) - pt.position_y;
            float dist = sqrt(dx * dx + dy * dy);

            if (dist > effectiveRadius) continue;

            float normalized = dist * invRadius;
            float falloff = smoothstep(1.0, brush.hardness, normalized);

            float depositAmount = falloff * brush.opacity * brush.flow * pt.pressure;
            if (depositAmount < 0.001) continue;

            // Brush texture: modulate by procedural bristle pattern
            float2 localPos = float2(dx, dy) / effectiveRadius;
            float tex = brushTexture(localPos, brush.angle, brush.shape_type);
            depositAmount *= tex;

            // Canvas roughness: watercolor/charcoal/pastel settle more in paper valleys
            if (brush.media_type == 0 || brush.media_type == 3 || brush.media_type == 4) {
                float canvasGrain = 0.7 + 0.3 * noise2d(float2(float(x), float(y)) * 0.15);
                depositAmount *= canvasGrain;
            }

            if (depositAmount < 0.001) continue;

            uint pixelIndex = uint(y) * uint(cw) + uint(x);
            uint idx = pixelIndex + activeLayer * layerStride;

            // Eraser: clears pigment concentration and water height
            if (brush.is_eraser) {
                float color_r = float(layers[idx].color_r);
                float color_g = float(layers[idx].color_g);
                float color_b = float(layers[idx].color_b);
                float color_o = float(layers[idx].color_o);
                layers[idx].color_r = half(max(0.0, color_r - depositAmount * 0.5));
                layers[idx].color_g = half(max(0.0, color_g - depositAmount * 0.5));
                layers[idx].color_b = half(max(0.0, color_b - depositAmount * 0.5));
                layers[idx].color_o = half(max(0.0, color_o - depositAmount));  // remove water
                continue;
            }

            // Water-only tool: add water height and re-dissolve dried pigment
            if (brush.is_water_only) {
                float color_o = float(layers[idx].color_o);
                layers[idx].color_o = half(min(1.0, color_o + depositAmount));
                if (float(layers[idx].depth) > 0.001) {
                    float dissolve = min(float(layers[idx].depth), depositAmount * 0.3);
                    layers[idx].color_r += half(dissolve * 0.5);
                    layers[idx].color_g += half(dissolve * 0.3);
                    layers[idx].color_b += half(dissolve * 0.2);
                    layers[idx].depth -= half(dissolve);
                }
                continue;
            }

            // Cross-media adhesion check
            float adhesion = cross_media_adhesion(
                brush.media_type, layers[idx].substance_type, layers[idx].hardness);
            depositAmount *= adhesion;
            if (depositAmount < 0.001) continue;

            // Physically-based watercolor: pigment concentration + water height
            float existingWater = float(layers[idx].color_o);
            float addedWater = depositAmount * 0.8;          // brush delivers mostly water
            float addedPigment = depositAmount * float(brush.opacity);

            // ADDITIVE pigment: concentration accumulates (wet-on-wet or wet-on-dry)
            // More paint strokes = more pigment = darker (subtractive, like real watercolor)
            layers[idx].color_r += half(float(brush.color_r) * addedPigment);
            layers[idx].color_g += half(float(brush.color_g) * addedPigment);
            layers[idx].color_b += half(float(brush.color_b) * addedPigment);
            layers[idx].color_o = half(min(1.5, existingWater + addedWater));

            // Set velocity outward from brush center for flow simulation
            float len = max(dist, 0.001);
            layers[idx].velocity_x += half(dx / len * addedWater * 0.3);
            layers[idx].velocity_y += half(dy / len * addedWater * 0.3);

            // Gloss: wet paint is glossy
            layers[idx].gloss = half(max(float(layers[idx].gloss), float(layers[idx].color_o) * 0.6));

            layers[idx].substance_type = half(brush.media_type);
        }
    }
}
"""

    static let depositWithParticles = header + brushHeader + sphHeader + crossMediaHeader + """
kernel void depositWithParticles(
    device VolumeLayer* layers [[buffer(0)]],
    device const BrushPoint* points [[buffer(1)]],
    constant BrushParams& brush [[buffer(2)]],
    constant DepositParams& params [[buffer(3)]],
    device SPHParticle* particles [[buffer(4)]],
    device atomic_uint& particleCounter [[buffer(5)]],
    constant uint& maxParticles [[buffer(6)]],
    uint tid [[thread_position_in_grid]]
) {
    if (tid >= params.point_count) return;

    BrushPoint pt = points[tid];
    int cw = int(params.canvas_width);
    int ch = int(params.canvas_height);
    uint layerStride = uint(cw) * uint(ch);
    uint activeLayer = brush.active_layer;

    float effectiveRadius = pt.size;
    if (effectiveRadius < 0.5) return;

    bool isWetMedia = (brush.media_type == 0 || brush.media_type == 1 || brush.media_type == 2);

    int minX = max(0, int(pt.position_x - effectiveRadius));
    int maxX = min(cw - 1, int(pt.position_x + effectiveRadius));
    int minY = max(0, int(pt.position_y - effectiveRadius));
    int maxY = min(ch - 1, int(pt.position_y + effectiveRadius));

    float invRadius = 1.0 / effectiveRadius;

    for (int y = minY; y <= maxY; y++) {
        for (int x = minX; x <= maxX; x++) {
            float dx = float(x) - pt.position_x;
            float dy = float(y) - pt.position_y;
            float dist = sqrt(dx * dx + dy * dy);

            if (dist > effectiveRadius) continue;

            float normalized = dist * invRadius;
            float falloff = smoothstep(1.0, brush.hardness, normalized);

            float depositAmount = falloff * brush.opacity * brush.flow * pt.pressure;
            if (depositAmount < 0.001) continue;

            // Brush texture: modulate by procedural bristle pattern
            float2 localPos = float2(dx, dy) / effectiveRadius;
            float tex = brushTexture(localPos, brush.angle, brush.shape_type);
            depositAmount *= tex;

            // Canvas roughness: watercolor/charcoal/pastel settle more in paper valleys
            if (brush.media_type == 0 || brush.media_type == 3 || brush.media_type == 4) {
                float canvasGrain = 0.7 + 0.3 * noise2d(float2(float(x), float(y)) * 0.15);
                depositAmount *= canvasGrain;
            }

            if (depositAmount < 0.001) continue;

            uint pixelIndex = uint(y) * uint(cw) + uint(x);
            uint idx = pixelIndex + activeLayer * layerStride;

            // Eraser: clears pigment concentration and water height
            if (brush.is_eraser) {
                float color_r = float(layers[idx].color_r);
                float color_g = float(layers[idx].color_g);
                float color_b = float(layers[idx].color_b);
                float color_o = float(layers[idx].color_o);
                layers[idx].color_r = half(max(0.0, color_r - depositAmount * 0.5));
                layers[idx].color_g = half(max(0.0, color_g - depositAmount * 0.5));
                layers[idx].color_b = half(max(0.0, color_b - depositAmount * 0.5));
                layers[idx].color_o = half(max(0.0, color_o - depositAmount));  // remove water
                continue;
            }

            // Water-only tool: add water height and re-dissolve dried pigment
            if (brush.is_water_only) {
                float color_o = float(layers[idx].color_o);
                layers[idx].color_o = half(min(1.0, color_o + depositAmount));
                if (float(layers[idx].depth) > 0.001) {
                    float dissolve = min(float(layers[idx].depth), depositAmount * 0.3);
                    layers[idx].color_r += half(dissolve * 0.5);
                    layers[idx].color_g += half(dissolve * 0.3);
                    layers[idx].color_b += half(dissolve * 0.2);
                    layers[idx].depth -= half(dissolve);
                }
                continue;
            }

            // Cross-media adhesion check
            float adhesion = cross_media_adhesion(
                brush.media_type, layers[idx].substance_type, layers[idx].hardness);
            depositAmount *= adhesion;
            if (depositAmount < 0.001) continue;

            // Physically-based watercolor: pigment concentration + water height
            float existingWater = float(layers[idx].color_o);
            float addedWater = depositAmount * 0.8;          // brush delivers mostly water
            float addedPigment = depositAmount * float(brush.opacity);

            // ADDITIVE pigment: concentration accumulates (wet-on-wet or wet-on-dry)
            // More paint strokes = more pigment = darker (subtractive, like real watercolor)
            layers[idx].color_r += half(float(brush.color_r) * addedPigment);
            layers[idx].color_g += half(float(brush.color_g) * addedPigment);
            layers[idx].color_b += half(float(brush.color_b) * addedPigment);
            layers[idx].color_o = half(min(1.5, existingWater + addedWater));

            // Set velocity outward from brush center for flow simulation
            float len = max(dist, 0.001);
            layers[idx].velocity_x += half(dx / len * addedWater * 0.3);
            layers[idx].velocity_y += half(dy / len * addedWater * 0.3);

            // Gloss: wet paint is glossy
            layers[idx].gloss = half(max(float(layers[idx].gloss), float(layers[idx].color_o) * 0.6));

            layers[idx].substance_type = half(brush.media_type);
        }
    }

    // Spawn SPH particles at stamp edge for wet media
    if (isWetMedia && effectiveRadius > 2.0) {
        int numParticles = min(8, int(effectiveRadius * 0.5));
        for (int i = 0; i < numParticles; i++) {
            uint slot = atomic_fetch_add_explicit(&particleCounter, 1, memory_order_relaxed);
            if (slot >= maxParticles) break;

            float angle = float(i) * (2.0 * 3.14159265 / float(numParticles));
            float edgeDist = effectiveRadius * 0.8;

            SPHParticle sp;
            sp.position_x = pt.position_x + cos(angle) * edgeDist;
            sp.position_y = pt.position_y + sin(angle) * edgeDist;
            sp.velocity_x = cos(angle) * 2.0;
            sp.velocity_y = sin(angle) * 2.0;
            sp.color_r = brush.color_r;
            sp.color_g = brush.color_g;
            sp.color_b = brush.color_b;
            sp.color_a = half(pt.pressure);
            sp.radius = half(4.0);
            sp.mass = half(pt.pressure * 0.5);
            sp.local_density = 0.0h;
            sp.rest_density = half(1000.0);
            sp.viscosity = (brush.media_type == 0) ? half(0.005) :
                           (brush.media_type == 1) ? half(50.0) : half(1.0);
            sp.smoothing_length = half(8.0);
            sp.wetness = half(pt.pressure);
            sp.life = half(5.0);
            sp.layer_index = uint8_t(activeLayer);
            sp.flags = 0;
            sp._pad0 = 0;
            sp._pad1 = 0;

            particles[slot] = sp;
        }
    }
}
"""
}
