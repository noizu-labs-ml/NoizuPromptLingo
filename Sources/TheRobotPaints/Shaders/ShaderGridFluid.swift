extension ShaderSource {
    static let gridFluid = header + sphHeader + """
kernel void gridFluid(
    device VolumeLayer* layers [[buffer(0)]],
    constant FluidParams& params [[buffer(1)]],
    uint2 gid [[thread_position_in_grid]]
) {
    int cw = int(params.canvas_width);
    int ch = int(params.canvas_height);
    if (int(gid.x) >= cw || int(gid.y) >= ch) return;

    uint pixelIndex = gid.y * uint(cw) + gid.x;
    uint layerStride = uint(cw) * uint(ch);
    int layerCount = int(params.layer_count);
    float dt = params.dt;

    for (int layer = 0; layer < layerCount; layer++) {
        uint idx = pixelIndex + uint(layer) * layerStride;

        float water = float(layers[idx].color_o);  // water height stored in color_o
        if (water < 0.005) continue;

        // --- NEIGHBOR INDICES ---
        uint idxL = (int(gid.x) > 0)      ? (pixelIndex - 1)        + uint(layer) * layerStride : idx;
        uint idxR = (int(gid.x) < cw - 1) ? (pixelIndex + 1)        + uint(layer) * layerStride : idx;
        uint idxU = (int(gid.y) > 0)      ? (pixelIndex - uint(cw)) + uint(layer) * layerStride : idx;
        uint idxD = (int(gid.y) < ch - 1) ? (pixelIndex + uint(cw)) + uint(layer) * layerStride : idx;

        float wL = float(layers[idxL].color_o);
        float wR = float(layers[idxR].color_o);
        float wU = float(layers[idxU].color_o);
        float wD = float(layers[idxD].color_o);

        // --- PRESSURE-DRIVEN VELOCITY (shallow water) ---
        float gradX = (wR - wL) * 0.5;
        float gradY = (wD - wU) * 0.5;

        float vx = float(layers[idx].velocity_x);
        float vy = float(layers[idx].velocity_y);

        // Accelerate from pressure gradient
        vx -= gradX * dt * 50.0;
        vy -= gradY * dt * 50.0;

        // --- CURL NOISE VELOCITY PERTURBATION ---
        // Adds divergence-free turbulent swirling — simulates ink tendrils in water.
        // Spatial frequency kept low so structures are large-scale and wispy.
        // Velocity field itself offsets noise sampling, creating a feedback loop
        // where the noise pattern advects with the existing flow over time.
        float noiseScale = 0.03;
        float turbulenceStrength = water * 15.0;

        float noiseOffX = float(gid.x) * noiseScale + vx * 0.01;
        float noiseOffY = float(gid.y) * noiseScale + vy * 0.01;

        float n1 = noise2d(float2(noiseOffX + dt * 3.0, noiseOffY));
        float n2 = noise2d(float2(noiseOffX, noiseOffY + dt * 3.0));

        // Curl of noise field gives a divergence-free perturbation
        vx += (n1 - 0.5) * turbulenceStrength * dt;
        vy += (n2 - 0.5) * turbulenceStrength * dt;

        // --- VORTICITY CONFINEMENT ---
        // Re-amplifies existing rotational structures lost to numerical dissipation.
        // Keeps tendrils curling instead of smoothing out.
        float vxU = (int(gid.y) > 0)      ? float(layers[idxU].velocity_x) : vx;
        float vxD = (int(gid.y) < ch - 1) ? float(layers[idxD].velocity_x) : vx;
        float vyL = (int(gid.x) > 0)      ? float(layers[idxL].velocity_y) : vy;
        float vyR = (int(gid.x) < cw - 1) ? float(layers[idxR].velocity_y) : vy;

        // 2D vorticity scalar (curl of velocity field)
        float omega = (vyR - vyL) * 0.5 - (vxD - vxU) * 0.5;

        // Sample |omega| at neighbors to find gradient direction
        float omegaL_val = (int(gid.x) > 0)      ? abs(float(layers[idxL].velocity_y + layers[idxU].velocity_x)) : abs(omega);
        float omegaR_val = (int(gid.x) < cw - 1) ? abs(float(layers[idxR].velocity_y + layers[idxD].velocity_x)) : abs(omega);
        float omegaU_val = (int(gid.y) > 0)      ? abs(float(layers[idxU].velocity_x + layers[idxL].velocity_y)) : abs(omega);
        float omegaD_val = (int(gid.y) < ch - 1) ? abs(float(layers[idxD].velocity_x + layers[idxR].velocity_y)) : abs(omega);

        float2 N = normalize(float2(omegaR_val - omegaL_val, omegaD_val - omegaU_val) + 0.0001);

        // Confinement force perpendicular to vorticity gradient — water-scaled
        float epsilon = 5.0 * water;
        vx += epsilon * dt * N.y * omega;
        vy -= epsilon * dt * N.x * omega;

        // Paper friction (base; roughness from canvasProps not available in this kernel)
        float friction = 0.3;
        vx *= (1.0 - friction * dt);
        vy *= (1.0 - friction * dt);

        // Clamp velocity
        float maxVel = 20.0;
        vx = clamp(vx, -maxVel, maxVel);
        vy = clamp(vy, -maxVel, maxVel);

        layers[idx].velocity_x = half(vx);
        layers[idx].velocity_y = half(vy);

        // --- SEMI-LAGRANGIAN ADVECTION OF WATER + PIGMENT ---
        float srcX = clamp(float(gid.x) - vx * dt, 0.0, float(cw - 1));
        float srcY = clamp(float(gid.y) - vy * dt, 0.0, float(ch - 1));

        int x0 = int(floor(srcX));
        int y0 = int(floor(srcY));
        int x1 = min(x0 + 1, cw - 1);
        int y1 = min(y0 + 1, ch - 1);
        float fx = srcX - float(x0);
        float fy = srcY - float(y0);

        uint i00 = uint(y0) * uint(cw) + uint(x0) + uint(layer) * layerStride;
        uint i10 = uint(y0) * uint(cw) + uint(x1) + uint(layer) * layerStride;
        uint i01 = uint(y1) * uint(cw) + uint(x0) + uint(layer) * layerStride;
        uint i11 = uint(y1) * uint(cw) + uint(x1) + uint(layer) * layerStride;

        float w00 = (1.0 - fx) * (1.0 - fy);
        float w10 = fx * (1.0 - fy);
        float w01 = (1.0 - fx) * fy;
        float w11 = fx * fy;

        // Blend rate based on actual displacement magnitude
        float blendRate = clamp((abs(vx * dt) + abs(vy * dt)) * 0.5, 0.0, 0.8);

        // Advect water height
        float srcWater = float(layers[i00].color_o) * w00 +
                         float(layers[i10].color_o) * w10 +
                         float(layers[i01].color_o) * w01 +
                         float(layers[i11].color_o) * w11;
        layers[idx].color_o = half(mix(water, srcWater, blendRate));

        // Advect pigment (passive scalar riding with water)
        if (blendRate > 0.001) {
            float srcR = float(layers[i00].color_r) * w00 +
                         float(layers[i10].color_r) * w10 +
                         float(layers[i01].color_r) * w01 +
                         float(layers[i11].color_r) * w11;
            float srcG = float(layers[i00].color_g) * w00 +
                         float(layers[i10].color_g) * w10 +
                         float(layers[i01].color_g) * w01 +
                         float(layers[i11].color_g) * w11;
            float srcB = float(layers[i00].color_b) * w00 +
                         float(layers[i10].color_b) * w10 +
                         float(layers[i01].color_b) * w01 +
                         float(layers[i11].color_b) * w11;

            layers[idx].color_r = half(mix(float(layers[idx].color_r), srcR, blendRate));
            layers[idx].color_g = half(mix(float(layers[idx].color_g), srcG, blendRate));
            layers[idx].color_b = half(mix(float(layers[idx].color_b), srcB, blendRate));
        }

        // --- CAPILLARY DIFFUSION ---
        // Water spreads to drier neighbors; pigment diffuses slower
        float diffRate = params.viscosity * dt * 5.0;

        float avgWater = (wL + wR + wU + wD) * 0.25;
        float waterDiff = (avgWater - water) * diffRate;
        float newWater = clamp(float(layers[idx].color_o) + waterDiff, 0.0, 1.5);
        layers[idx].color_o = half(newWater);

        // Pigment diffusion when wet (pigment diffuses slower than water)
        if (water > 0.05 && diffRate > 0.0) {
            float pigDiffRate = diffRate * 0.3;

            float avgR = (float(layers[idxL].color_r) + float(layers[idxR].color_r) +
                          float(layers[idxU].color_r) + float(layers[idxD].color_r)) * 0.25;
            float avgG = (float(layers[idxL].color_g) + float(layers[idxR].color_g) +
                          float(layers[idxU].color_g) + float(layers[idxD].color_g)) * 0.25;
            float avgB = (float(layers[idxL].color_b) + float(layers[idxR].color_b) +
                          float(layers[idxU].color_b) + float(layers[idxD].color_b)) * 0.25;

            layers[idx].color_r = half(mix(float(layers[idx].color_r), avgR, pigDiffRate));
            layers[idx].color_g = half(mix(float(layers[idx].color_g), avgG, pigDiffRate));
            layers[idx].color_b = half(mix(float(layers[idx].color_b), avgB, pigDiffRate));
        }

        // --- FICK'S LAW: CONCENTRATION-GRADIENT DRIVEN DIFFUSION ---
        // Pigment spreads from high to low concentration independent of water flow.
        // This creates wispy tendrils even in relatively still water.
        // Applied after advection+capillary so it adds fine structure on top.
        if (water > 0.02) {
            float pigDiffCoeff = 0.15 * dt;

            float pigR = float(layers[idx].color_r);
            float pigG = float(layers[idx].color_g);
            float pigB = float(layers[idx].color_b);

            float nPigR_L = float(layers[idxL].color_r);
            float nPigR_R = float(layers[idxR].color_r);
            float nPigR_U = float(layers[idxU].color_r);
            float nPigR_D = float(layers[idxD].color_r);

            float nPigG_L = float(layers[idxL].color_g);
            float nPigG_R = float(layers[idxR].color_g);
            float nPigG_U = float(layers[idxU].color_g);
            float nPigG_D = float(layers[idxD].color_g);

            float nPigB_L = float(layers[idxL].color_b);
            float nPigB_R = float(layers[idxR].color_b);
            float nPigB_U = float(layers[idxU].color_b);
            float nPigB_D = float(layers[idxD].color_b);

            // Discrete Laplacian (5-point stencil) approximates ∇²C
            float laplacianR = (nPigR_L + nPigR_R + nPigR_U + nPigR_D) - 4.0 * pigR;
            float laplacianG = (nPigG_L + nPigG_R + nPigG_U + nPigG_D) - 4.0 * pigG;
            float laplacianB = (nPigB_L + nPigB_R + nPigB_U + nPigB_D) - 4.0 * pigB;

            // Scale diffusion by local water depth — no diffusion in dry areas
            float wetScale = clamp((water - 0.02) / 0.5, 0.0, 1.0);
            layers[idx].color_r = half(clamp(pigR + laplacianR * pigDiffCoeff * wetScale, 0.0, 2.0));
            layers[idx].color_g = half(clamp(pigG + laplacianG * pigDiffCoeff * wetScale, 0.0, 2.0));
            layers[idx].color_b = half(clamp(pigB + laplacianB * pigDiffCoeff * wetScale, 0.0, 2.0));
        }

        // Keep wetness field in sync with water height for downstream kernels
        layers[idx].wetness = half(clamp(newWater, 0.0, 1.0));
    }
}
"""
}
