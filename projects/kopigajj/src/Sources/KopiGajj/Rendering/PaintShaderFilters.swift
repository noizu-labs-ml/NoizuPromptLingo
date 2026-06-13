/// Image filter shaders — artistic post-processing (Kuwahara, Pointillize, etc.).
extension PaintShaderSource {

    // MARK: - Paint Filter Shaders (used by CanvasMetalRenderer)

    /// Common header for paint filter compute kernels — hash functions + metal_stdlib.
    static let filterHeader = """
    #include <metal_stdlib>
    using namespace metal;

    // ── Hash functions for procedural noise ──
    float hash11(float p) {
        p = fract(p * 0.1031);
        p *= p + 33.33;
        p *= p + p;
        return fract(p);
    }
    float2 hash22(float2 p) {
        float3 p3 = fract(float3(p.xyx) * float3(0.1031, 0.1030, 0.0973));
        p3 += dot(p3, p3.yzx + 33.33);
        return fract((p3.xx + p3.yz) * p3.zy);
    }
    """

    /// Kuwahara filter kernel.
    static let kuwaharaKernel = """

    // ── 1. Kuwahara ──
    kernel void kuwaharaCompute(
        texture2d<half, access::read>  input  [[ texture(0) ]],
        texture2d<half, access::write> output [[ texture(1) ]],
        constant float &radius [[ buffer(0) ]],
        constant float &p1     [[ buffer(1) ]],
        constant float &p2     [[ buffer(2) ]],
        uint2 gid [[ thread_position_in_grid ]]
    ) {
        int w = int(input.get_width());
        int h = int(input.get_height());
        if (int(gid.x) >= w || int(gid.y) >= h) return;

        int r = int(radius);
        half3 mean[4] = {}; half3 sigma[4] = {}; half count[4] = {};

        for (int j = -r; j <= r; j++) {
            for (int i = -r; i <= r; i++) {
                int2 pos = clamp(int2(gid) + int2(i, j), int2(0), int2(w-1, h-1));
                half3 c = input.read(uint2(pos)).rgb;
                if (i<=0 && j<=0) { mean[0]+=c; sigma[0]+=c*c; count[0]+=1.0h; }
                if (i>=0 && j<=0) { mean[1]+=c; sigma[1]+=c*c; count[1]+=1.0h; }
                if (i<=0 && j>=0) { mean[2]+=c; sigma[2]+=c*c; count[2]+=1.0h; }
                if (i>=0 && j>=0) { mean[3]+=c; sigma[3]+=c*c; count[3]+=1.0h; }
            }
        }
        half minV = half(1e10); half3 result = half3(0);
        for (int q = 0; q < 4; q++) {
            mean[q] /= count[q];
            sigma[q] = sigma[q]/count[q] - mean[q]*mean[q];
            half v = sigma[q].r + sigma[q].g + sigma[q].b;
            if (v < minV) { minV = v; result = mean[q]; }
        }
        output.write(half4(result, input.read(gid).a), gid);
    }
    """

    /// Anisotropic Kuwahara filter kernel.
    static let anisotropicKuwaharaKernel = """

    // ── 2. Anisotropic Kuwahara ──
    // Uses local gradient to orient the sampling sectors along edges.
    kernel void anisotropicKuwaharaCompute(
        texture2d<half, access::read>  input  [[ texture(0) ]],
        texture2d<half, access::write> output [[ texture(1) ]],
        constant float &radius    [[ buffer(0) ]],
        constant float &sharpness [[ buffer(1) ]],
        constant float &p2        [[ buffer(2) ]],
        uint2 gid [[ thread_position_in_grid ]]
    ) {
        int w = int(input.get_width());
        int h = int(input.get_height());
        if (int(gid.x) >= w || int(gid.y) >= h) return;

        // Compute gradient via Sobel
        half gx = 0, gy = 0;
        for (int j = -1; j <= 1; j++) {
            for (int i = -1; i <= 1; i++) {
                int2 pos = clamp(int2(gid) + int2(i, j), int2(0), int2(w-1, h-1));
                half lum = dot(input.read(uint2(pos)).rgb, half3(0.299h, 0.587h, 0.114h));
                half sx = half(i) * (j == 0 ? 2.0h : 1.0h);
                half sy = half(j) * (i == 0 ? 2.0h : 1.0h);
                gx += lum * sx;
                gy += lum * sy;
            }
        }
        float angle = atan2(float(gy), float(gx));
        float ca = cos(angle), sa = sin(angle);

        int r = int(radius);
        // 8 oriented sectors
        int N = 8;
        half3 mean[8] = {}; half3 sig[8] = {}; half cnt[8] = {};

        for (int j = -r; j <= r; j++) {
            for (int i = -r; i <= r; i++) {
                // Rotate sample position by -angle
                float ri = ca * float(i) + sa * float(j);
                float rj = -sa * float(i) + ca * float(j);

                int sector = int(floor((atan2(rj, ri) + 3.14159265) / 6.28318530 * float(N))) % N;

                int2 pos = clamp(int2(gid) + int2(i, j), int2(0), int2(w-1, h-1));
                half3 c = input.read(uint2(pos)).rgb;

                // Weight by distance (Gaussian-ish)
                float d = sqrt(float(i*i + j*j)) / float(r);
                half wt = half(exp(-d * d * (1.0 + sharpness * 4.0)));

                mean[sector] += c * wt;
                sig[sector] += c * c * wt;
                cnt[sector] += wt;
            }
        }

        half minV = half(1e10); half3 result = half3(0);
        for (int q = 0; q < N; q++) {
            if (cnt[q] < 0.001h) continue;
            half3 m = mean[q] / cnt[q];
            half3 s = sig[q] / cnt[q] - m * m;
            half v = s.r + s.g + s.b;
            if (v < minV) { minV = v; result = m; }
        }
        output.write(half4(result, input.read(gid).a), gid);
    }
    """

    /// Pointillize filter kernel.
    static let pointillizeKernel = """

    // ── 3. Pointillize ──
    kernel void pointillizeCompute(
        texture2d<half, access::read>  input  [[ texture(0) ]],
        texture2d<half, access::write> output [[ texture(1) ]],
        constant float &radius     [[ buffer(0) ]],
        constant float &randomness [[ buffer(1) ]],
        constant float &p2         [[ buffer(2) ]],
        uint2 gid [[ thread_position_in_grid ]]
    ) {
        int w = int(input.get_width());
        int h = int(input.get_height());
        if (int(gid.x) >= w || int(gid.y) >= h) return;

        float cellSize = max(2.0, radius * 3.0);
        float2 cell = float2(gid) / cellSize;
        int2 cellIdx = int2(floor(cell));

        // Find nearest dot center in 3x3 neighborhood
        float minDist = 1e10;
        float2 nearestCenter = float2(0);

        for (int j = -1; j <= 1; j++) {
            for (int i = -1; i <= 1; i++) {
                int2 neighbor = cellIdx + int2(i, j);
                float2 jitter = hash22(float2(neighbor)) * randomness;
                float2 center = (float2(neighbor) + 0.5 + jitter) * cellSize;
                float d = length(float2(gid) - center);
                if (d < minDist) {
                    minDist = d;
                    nearestCenter = center;
                }
            }
        }

        // Sample color at dot center
        uint2 samplePos = uint2(clamp(nearestCenter, float2(0), float2(w-1, h-1)));
        half4 color = input.read(samplePos);

        // Circle mask
        float dotRadius = cellSize * 0.45;
        float edge = smoothstep(dotRadius, dotRadius - 1.5, minDist);

        // Background: slightly darkened average
        half4 bg = input.read(gid) * 0.3h;
        output.write(mix(bg, color, half(edge)), gid);
    }
    """

    /// Watercolor filter kernel.
    static let watercolorKernel = """

    // ── 4. Watercolor ──
    kernel void watercolorCompute(
        texture2d<half, access::read>  input  [[ texture(0) ]],
        texture2d<half, access::write> output [[ texture(1) ]],
        constant float &radius       [[ buffer(0) ]],
        constant float &edgeDarken   [[ buffer(1) ]],
        constant float &bleed        [[ buffer(2) ]],
        uint2 gid [[ thread_position_in_grid ]]
    ) {
        int w = int(input.get_width());
        int h = int(input.get_height());
        if (int(gid.x) >= w || int(gid.y) >= h) return;

        int r = max(1, int(radius));
        half4 center = input.read(gid);
        float sigmaS = float(r) * 0.5;
        float sigmaC = 0.1 + bleed * 0.4;

        // Bilateral filter (edge-preserving blur for watercolor softness)
        half3 sum = half3(0); half wSum = 0;
        for (int j = -r; j <= r; j++) {
            for (int i = -r; i <= r; i++) {
                int2 pos = clamp(int2(gid) + int2(i, j), int2(0), int2(w-1, h-1));
                half4 s = input.read(uint2(pos));
                float spatial = exp(-float(i*i + j*j) / (2.0*sigmaS*sigmaS));
                float colorDist = length(float3(s.rgb - center.rgb));
                float colorW = exp(-colorDist*colorDist / (2.0*sigmaC*sigmaC));
                half wt = half(spatial * colorW);
                sum += s.rgb * wt;
                wSum += wt;
            }
        }
        half3 smoothed = sum / max(wSum, 0.001h);

        // Edge detection (Sobel magnitude) for darkening
        half gx = 0, gy = 0;
        for (int j = -1; j <= 1; j++) {
            for (int i = -1; i <= 1; i++) {
                int2 pos = clamp(int2(gid) + int2(i, j), int2(0), int2(w-1, h-1));
                half lum = dot(input.read(uint2(pos)).rgb, half3(0.299h, 0.587h, 0.114h));
                gx += lum * half(i) * (j == 0 ? 2.0h : 1.0h);
                gy += lum * half(j) * (i == 0 ? 2.0h : 1.0h);
            }
        }
        half edgeMag = length(half2(gx, gy));
        half darken = 1.0h - edgeMag * half(edgeDarken) * 3.0h;
        darken = max(darken, 0.3h);

        // Slight desaturation at edges (watercolor characteristic)
        half lum = dot(smoothed, half3(0.299h, 0.587h, 0.114h));
        half3 result = mix(smoothed, half3(lum), edgeMag * 0.3h) * darken;

        output.write(half4(result, center.a), gid);
    }
    """

    /// Oil paint (Perona-Malik anisotropic diffusion) kernel.
    static let oilPaintKernel = """

    // ── 5. Oil Paint (Perona-Malik anisotropic diffusion, single pass) ──
    kernel void oilPaintCompute(
        texture2d<half, access::read>  input  [[ texture(0) ]],
        texture2d<half, access::write> output [[ texture(1) ]],
        constant float &radius      [[ buffer(0) ]],
        constant float &conductance [[ buffer(1) ]],
        constant float &p2          [[ buffer(2) ]],
        uint2 gid [[ thread_position_in_grid ]]
    ) {
        int w = int(input.get_width());
        int h = int(input.get_height());
        if (int(gid.x) >= w || int(gid.y) >= h) return;

        half3 c = input.read(gid).rgb;
        float k = max(conductance, 1.0);
        float dt = 0.15;

        // 4-neighbor differences
        int2 offsets[4] = { int2(1,0), int2(-1,0), int2(0,1), int2(0,-1) };
        half3 diffusion = half3(0);

        for (int n = 0; n < 4; n++) {
            int2 pos = clamp(int2(gid) + offsets[n], int2(0), int2(w-1, h-1));
            half3 neighbor = input.read(uint2(pos)).rgb;
            half3 diff = neighbor - c;
            float mag = length(float3(diff));
            float coeff = exp(-(mag * mag) / (k * k));
            diffusion += diff * half(coeff);
        }

        half3 result = c + diffusion * half(dt);
        result = clamp(result, half3(0), half3(1));
        output.write(half4(result, input.read(gid).a), gid);
    }
    """

    /// Posterize filter kernel.
    static let posterizeKernel = """

    // ── 6. Posterize ──
    kernel void posterizeCompute(
        texture2d<half, access::read>  input  [[ texture(0) ]],
        texture2d<half, access::write> output [[ texture(1) ]],
        constant float &radius    [[ buffer(0) ]],
        constant float &smoothing [[ buffer(1) ]],
        constant float &p2        [[ buffer(2) ]],
        uint2 gid [[ thread_position_in_grid ]]
    ) {
        int w = int(input.get_width());
        int h = int(input.get_height());
        if (int(gid.x) >= w || int(gid.y) >= h) return;

        half4 c = input.read(gid);
        half levels = half(max(2.0, radius));

        // Optional pre-smooth (bilateral, small radius)
        half3 color = c.rgb;
        if (smoothing > 0.01) {
            int r = int(smoothing * 3.0);
            half3 sum = half3(0); half wt = 0;
            for (int j = -r; j <= r; j++) {
                for (int i = -r; i <= r; i++) {
                    int2 pos = clamp(int2(gid) + int2(i, j), int2(0), int2(w-1, h-1));
                    half3 s = input.read(uint2(pos)).rgb;
                    half w2 = half(exp(-float(i*i + j*j) / (2.0 * smoothing * smoothing)));
                    sum += s * w2;
                    wt += w2;
                }
            }
            color = sum / max(wt, 0.001h);
        }

        // Quantize
        color = floor(color * levels + 0.5h) / levels;
        output.write(half4(color, c.a), gid);
    }
    """

    /// Bilateral filter kernel.
    static let bilateralKernel = """

    // ── 7. Bilateral filter ──
    kernel void bilateralCompute(
        texture2d<half, access::read>  input  [[ texture(0) ]],
        texture2d<half, access::write> output [[ texture(1) ]],
        constant float &radius     [[ buffer(0) ]],
        constant float &sigmaColor [[ buffer(1) ]],
        constant float &p2         [[ buffer(2) ]],
        uint2 gid [[ thread_position_in_grid ]]
    ) {
        int w = int(input.get_width());
        int h = int(input.get_height());
        if (int(gid.x) >= w || int(gid.y) >= h) return;

        int r = int(radius);
        half4 center = input.read(gid);
        float sigmaS = float(r) * 0.5;
        float sigmaC = max(0.01, sigmaColor);

        half3 sum = half3(0); half wSum = 0;
        for (int j = -r; j <= r; j++) {
            for (int i = -r; i <= r; i++) {
                int2 pos = clamp(int2(gid) + int2(i, j), int2(0), int2(w-1, h-1));
                half4 s = input.read(uint2(pos));
                float spatial = exp(-float(i*i + j*j) / (2.0*sigmaS*sigmaS));
                float cd = length(float3(s.rgb - center.rgb));
                float colorW = exp(-cd*cd / (2.0*sigmaC*sigmaC));
                half wt = half(spatial * colorW);
                sum += s.rgb * wt;
                wSum += wt;
            }
        }
        output.write(half4(sum / max(wSum, 0.001h), center.a), gid);
    }
    """

    /// Voronoi mosaic filter kernel.
    static let voronoiMosaicKernel = """

    // ── 8. Voronoi Mosaic ──
    kernel void voronoiMosaicCompute(
        texture2d<half, access::read>  input  [[ texture(0) ]],
        texture2d<half, access::write> output [[ texture(1) ]],
        constant float &radius      [[ buffer(0) ]],
        constant float &borderWidth [[ buffer(1) ]],
        constant float &jitter      [[ buffer(2) ]],
        uint2 gid [[ thread_position_in_grid ]]
    ) {
        int w = int(input.get_width());
        int h = int(input.get_height());
        if (int(gid.x) >= w || int(gid.y) >= h) return;

        float cellSize = max(3.0, radius * 4.0);
        float2 cell = float2(gid) / cellSize;
        int2 cellIdx = int2(floor(cell));

        float minDist = 1e10;
        float secondDist = 1e10;
        float2 nearestSeed = float2(0);

        for (int j = -1; j <= 1; j++) {
            for (int i = -1; i <= 1; i++) {
                int2 neighbor = cellIdx + int2(i, j);
                float2 seed = float2(neighbor) + 0.5 + (hash22(float2(neighbor)) - 0.5) * jitter;
                float d = length(cell - seed);
                if (d < minDist) {
                    secondDist = minDist;
                    minDist = d;
                    nearestSeed = seed;
                } else if (d < secondDist) {
                    secondDist = d;
                }
            }
        }

        // Sample color at cell seed position
        float2 samplePos = nearestSeed * cellSize;
        samplePos = clamp(samplePos, float2(0), float2(w-1, h-1));
        half4 color = input.read(uint2(samplePos));

        // Border detection (edge between Voronoi cells)
        float edgeDist = secondDist - minDist;
        float border = smoothstep(0.0, borderWidth * 0.15, edgeDist);
        color.rgb *= half(0.4 + 0.6 * border);

        output.write(color, gid);
    }
    """

    /// All filter shaders concatenated — compiled once by CanvasMetalRenderer.
    static let allFilterShaderSource: String = {
        filterHeader
        + kuwaharaKernel
        + anisotropicKuwaharaKernel
        + pointillizeKernel
        + watercolorKernel
        + oilPaintKernel
        + posterizeKernel
        + bilateralKernel
        + voronoiMosaicKernel
    }()
}
