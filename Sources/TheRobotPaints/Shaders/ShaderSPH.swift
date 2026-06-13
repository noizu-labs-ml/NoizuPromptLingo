extension ShaderSource {
    static let sphBuildHash = header + sphHeader + """
kernel void sphBuildHash(
    device SPHParticle* particles [[buffer(0)]],
    device atomic_uint* cellCounts [[buffer(1)]],
    constant SPHConstants& sph [[buffer(2)]],
    uint tid [[thread_position_in_grid]]
) {
    if (tid >= sph.particle_count) return;

    SPHParticle p = particles[tid];
    if (p.life <= 0.0h) return;

    int cx = clamp(int(p.position_x / sph.cell_size), 0, int(sph.grid_width) - 1);
    int cy = clamp(int(p.position_y / sph.cell_size), 0, int(sph.grid_height) - 1);
    uint cellIndex = uint(cy) * sph.grid_width + uint(cx);

    atomic_fetch_add_explicit(&cellCounts[cellIndex], 1, memory_order_relaxed);
}
"""

    static let sphComputeForces = header + sphHeader + """
// Poly6 kernel (2D): density estimation
float poly6_2d(float r2, float h) {
    float h2 = h * h;
    if (r2 >= h2) return 0.0;
    float diff = h2 - r2;
    return (4.0 / (3.14159265 * h * h * h * h * h * h * h * h)) * diff * diff * diff;
}

// Spiky gradient (2D): pressure force
float2 spiky_grad_2d(float2 rVec, float r, float h) {
    if (r >= h || r < 0.0001) return float2(0.0);
    float coeff = -10.0 / (3.14159265 * h * h * h * h * h);
    float diff = h - r;
    return coeff * diff * diff * (rVec / r);
}

// Viscosity Laplacian (2D)
float viscosity_lap_2d(float r, float h) {
    if (r >= h) return 0.0;
    return 40.0 / (3.14159265 * h * h * h * h * h) * (h - r);
}

kernel void sphComputeForces(
    device SPHParticle* particles [[buffer(0)]],
    device SPHParticle* particlesOut [[buffer(1)]],
    device const atomic_uint* cellCounts [[buffer(2)]],
    device const uint* sortedIndices [[buffer(3)]],
    device const SpatialHashCell* cells [[buffer(4)]],
    constant SPHConstants& sph [[buffer(5)]],
    uint tid [[thread_position_in_grid]]
) {
    if (tid >= sph.particle_count) return;

    SPHParticle p = particles[tid];
    if (p.life <= 0.0h) {
        particlesOut[tid] = p;
        return;
    }

    float h = sph.smoothing_length;
    float h2 = h * h;
    float2 pos = float2(p.position_x, p.position_y);

    // Compute density using Poly6
    float density = 0.0;
    int cx = clamp(int(pos.x / sph.cell_size), 0, int(sph.grid_width) - 1);
    int cy = clamp(int(pos.y / sph.cell_size), 0, int(sph.grid_height) - 1);

    for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
            int nx = cx + dx;
            int ny = cy + dy;
            if (nx < 0 || nx >= int(sph.grid_width) || ny < 0 || ny >= int(sph.grid_height)) continue;

            uint cellIdx = uint(ny) * sph.grid_width + uint(nx);
            SpatialHashCell cell = cells[cellIdx];

            for (uint i = cell.offset; i < cell.offset + cell.count; i++) {
                uint j = sortedIndices[i];
                if (j >= sph.particle_count) continue;

                SPHParticle pj = particles[j];
                if (pj.life <= 0.0h) continue;

                float2 r = pos - float2(pj.position_x, pj.position_y);
                float r2 = dot(r, r);
                if (r2 < h2) {
                    density += float(pj.mass) * poly6_2d(r2, h);
                }
            }
        }
    }

    density = max(density, 0.001);
    p.local_density = half(density);

    // Tait equation of state
    float rho0 = sph.rest_density;
    float B = sph.stiffness;
    float gamma = sph.gamma;
    float pressure = B * (pow(density / rho0, gamma) - 1.0);

    // Compute forces: pressure gradient + viscosity
    float2 fPressure = float2(0.0);
    float2 fViscosity = float2(0.0);
    float2 vel = float2(p.velocity_x, p.velocity_y);

    for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
            int nx = cx + dx;
            int ny = cy + dy;
            if (nx < 0 || nx >= int(sph.grid_width) || ny < 0 || ny >= int(sph.grid_height)) continue;

            uint cellIdx = uint(ny) * sph.grid_width + uint(nx);
            SpatialHashCell cell = cells[cellIdx];

            for (uint i = cell.offset; i < cell.offset + cell.count; i++) {
                uint j = sortedIndices[i];
                if (j == tid || j >= sph.particle_count) continue;

                SPHParticle pj = particles[j];
                if (pj.life <= 0.0h) continue;

                float2 r = pos - float2(pj.position_x, pj.position_y);
                float dist = length(r);
                if (dist >= h || dist < 0.0001) continue;

                float densityJ = max(float(pj.local_density), 0.001);
                float pressureJ = B * (pow(densityJ / rho0, gamma) - 1.0);

                // Pressure force (symmetric)
                float pAvg = (pressure + pressureJ) * 0.5;
                fPressure -= float(pj.mass) * (pAvg / densityJ) * spiky_grad_2d(r, dist, h);

                // Viscosity force
                float2 velJ = float2(pj.velocity_x, pj.velocity_y);
                fViscosity += float(pj.mass) * ((velJ - vel) / densityJ) * viscosity_lap_2d(dist, h);
            }
        }
    }

    fViscosity *= sph.viscosity_coeff;

    // Integration
    float2 acceleration = (fPressure + fViscosity) / max(density, 0.001);
    float dt = sph.dt;

    float2 newVel = vel + acceleration * dt;
    float2 newPos = pos + newVel * dt;

    // Boundary clamping
    newPos.x = clamp(newPos.x, 0.0, float(sph.canvas_width - 1));
    newPos.y = clamp(newPos.y, 0.0, float(sph.canvas_height - 1));

    if (newPos.x <= 0.0 || newPos.x >= float(sph.canvas_width - 1)) newVel.x *= -0.3;
    if (newPos.y <= 0.0 || newPos.y >= float(sph.canvas_height - 1)) newVel.y *= -0.3;

    // Velocity damping
    newVel *= 0.995;

    SPHParticle pOut = p;
    pOut.position_x = newPos.x;
    pOut.position_y = newPos.y;
    pOut.velocity_x = newVel.x;
    pOut.velocity_y = newVel.y;
    pOut.local_density = half(density);
    pOut.life = half(max(0.0, float(p.life) - dt));

    particlesOut[tid] = pOut;
}
"""
}
