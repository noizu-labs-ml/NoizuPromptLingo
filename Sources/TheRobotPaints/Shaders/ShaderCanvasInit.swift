extension ShaderSource {
    static let canvasInit = header + """
kernel void canvasInit(
    texture2d<half, access::write> canvasProps [[texture(0)]],
    uint2 gid [[thread_position_in_grid]]
) {
    int w = canvasProps.get_width();
    int h = canvasProps.get_height();
    if (int(gid.x) >= w || int(gid.y) >= h) return;

    float x = float(gid.x);
    float y = float(gid.y);

    float warpX = sin(y * 0.4) * 0.3;
    float warpY = sin(x * 0.4) * 0.3;
    float weaveX = sin((x + warpX * 10.0) * 0.5) * 0.5 + 0.5;
    float weaveY = sin((y + warpY * 10.0) * 0.5) * 0.5 + 0.5;
    float weave = mix(weaveX, weaveY, 0.5);

    half absorbency = half(mix(0.6, 0.8, weave));
    half roughness  = half(mix(0.3, 0.7, noise2d(float2(x * 0.1, y * 0.1))));
    half porosity   = half(mix(0.4, 0.6, noise2d(float2(x * 0.05 + 100.0, y * 0.05 + 100.0))));
    half sizing     = half(mix(0.2, 0.5, noise2d(float2(x * 0.15 + 200.0, y * 0.15 + 200.0))));

    canvasProps.write(half4(absorbency, roughness, porosity, sizing), gid);
}
"""
}
