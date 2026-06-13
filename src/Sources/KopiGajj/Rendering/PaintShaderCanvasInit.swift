/// Canvas initialization kernel — generates procedural canvas texture.
extension PaintShaderSource {

    // MARK: - Kernel 1: Canvas Init

    static let canvasInit = header + """

    kernel void canvasInit(
        texture2d<half, access::write>  wetAbsorbTex  [[ texture(0) ]],
        texture2d<half, access::write>  solidAbsorbTex[[ texture(1) ]],
        texture2d<half, access::write>  propsTex      [[ texture(2) ]],
        texture2d<float, access::write> heightTex     [[ texture(3) ]],
        texture2d<half, access::write>  canvasPropsTex[[ texture(4) ]],
        constant CanvasParams &params                 [[ buffer(0) ]],
        uint2 gid                                     [[ thread_position_in_grid ]]
    ) {
        if (int(gid.x) >= params.width || int(gid.y) >= params.height) return;

        float2 pos = float2(gid);
        float spacing = params.threadSpacing;
        float ridge = params.ridgeHeight;

        // Canvas weave heightmap
        float warpPhase = pos.y / spacing;
        float warpNoise = noise2d(pos * 0.02 + float2(float(params.seed) * 0.1, 0));
        float warp = smoothstep(0.4, 0.5, fract(warpPhase + warpNoise * 0.15))
                   * smoothstep(0.6, 0.5, fract(warpPhase + warpNoise * 0.15));
        warp *= ridge * (0.8 + warpNoise * 0.4);

        float weftPhase = pos.x / spacing;
        float weftNoise = noise2d(pos * 0.02 + float2(0, float(params.seed) * 0.1 + 100));
        float weft = smoothstep(0.4, 0.5, fract(weftPhase + weftNoise * 0.15))
                   * smoothstep(0.6, 0.5, fract(weftPhase + weftNoise * 0.15));
        weft *= ridge * (0.8 + weftNoise * 0.4);

        float interlace = step(0.5, fract((floor(warpPhase) + floor(weftPhase)) * 0.5));
        float h = mix(max(warp, weft), min(warp, weft) + ridge * 0.3, interlace);
        h += noise2d(pos * 0.005 + float2(params.seed)) * ridge * 0.5;

        heightTex.write(h, gid);

        // Canvas material properties (vary slightly with texture)
        float localRough = params.roughness * (0.8 + noise2d(pos * 0.1 + 50) * 0.4);
        canvasPropsTex.write(half4(
            half(params.absorbency),
            half(localRough),
            half(params.porosity),
            0
        ), gid);

        // Clear paint layers (zero absorption = transparent)
        wetAbsorbTex.write(half4(0), gid);
        solidAbsorbTex.write(half4(0), gid);
        // Props: wetness=0, hardness=1 (dry canvas), viscosity=0, media=0
        propsTex.write(half4(0, 1, 0, 0), gid);
    }
    """
}
