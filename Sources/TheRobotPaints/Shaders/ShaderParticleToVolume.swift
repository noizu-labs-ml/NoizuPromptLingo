extension ShaderSource {
    static let particleToVolume = header + sphHeader + """
kernel void particleToVolume(
    device const SPHParticle* particles [[buffer(0)]],
    device VolumeLayer* layers [[buffer(1)]],
    constant SPHConstants& sph [[buffer(2)]],
    uint tid [[thread_position_in_grid]]
) {
    if (tid >= sph.particle_count) return;

    SPHParticle p = particles[tid];
    if (p.life <= 0.0h || p.wetness <= 0.01h) return;

    int cw = int(sph.canvas_width);
    int ch = int(sph.canvas_height);
    uint layerStride = uint(cw) * uint(ch);
    uint activeLayer = uint(p.layer_index);

    float h = float(p.smoothing_length);
    float h2 = h * h;
    float2 pos = float2(p.position_x, p.position_y);

    int minX = max(0, int(pos.x - h));
    int maxX = min(cw - 1, int(pos.x + h));
    int minY = max(0, int(pos.y - h));
    int maxY = min(ch - 1, int(pos.y + h));

    float totalWeight = 0.0;
    for (int y = minY; y <= maxY; y++) {
        for (int x = minX; x <= maxX; x++) {
            float dx = float(x) - pos.x;
            float dy = float(y) - pos.y;
            float r2 = dx * dx + dy * dy;
            if (r2 >= h2) continue;

            float diff = h2 - r2;
            float weight = diff * diff * diff;
            totalWeight += weight;
        }
    }

    if (totalWeight < 0.0001) return;
    float invTotal = 1.0 / totalWeight;

    for (int y = minY; y <= maxY; y++) {
        for (int x = minX; x <= maxX; x++) {
            float dx = float(x) - pos.x;
            float dy = float(y) - pos.y;
            float r2 = dx * dx + dy * dy;
            if (r2 >= h2) continue;

            float diff = h2 - r2;
            float weight = diff * diff * diff * invTotal;

            float contribution = weight * float(p.mass) * float(p.wetness) * 0.01;
            if (contribution < 0.0001) continue;

            uint pixelIndex = uint(y) * uint(cw) + uint(x);
            uint idx = pixelIndex + activeLayer * layerStride;

            // Accumulate velocity from particles
            layers[idx].velocity_x = half(float(layers[idx].velocity_x) +
                                          p.velocity_x * half(weight * 0.1));
            layers[idx].velocity_y = half(float(layers[idx].velocity_y) +
                                          p.velocity_y * half(weight * 0.1));

            // Maintain wetness from particle influence
            layers[idx].wetness = max(layers[idx].wetness, half(contribution));
        }
    }
}
"""
}
