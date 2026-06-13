extension ShaderSource {
    static let debugWetness = header + """
kernel void debugWetness(
    device const VolumeLayer* layers [[buffer(0)]],
    texture2d<half, access::write> output [[texture(0)]],
    constant RenderParams& params [[buffer(1)]],
    constant ViewParams& view [[buffer(2)]],
    uint2 gid [[thread_position_in_grid]]
) {
    int dw = int(view.drawable_width);
    int dh = int(view.drawable_height);
    if (int(gid.x) >= dw || int(gid.y) >= dh) return;

    int cw = int(view.canvas_width);
    int ch = int(view.canvas_height);

    float fitScale = min(float(dw) / float(cw), float(dh) / float(ch));
    float scale = fitScale * view.zoom_level;
    float baseX = float(cw) / 2.0 - float(dw) / (2.0 * scale);
    float baseY = float(ch) / 2.0 - float(dh) / (2.0 * scale);
    int cx = int(floor(float(gid.x) / scale + baseX + view.pan_offset_x));
    int cy = int(floor(float(gid.y) / scale + baseY + view.pan_offset_y));

    if (cx < 0 || cx >= cw || cy < 0 || cy >= ch) {
        output.write(half4(0.1h, 0.1h, 0.1h, 1.0h), gid);
        return;
    }

    uint pixelIndex = uint(cy) * uint(cw) + uint(cx);
    uint layerStride = uint(cw) * uint(ch);
    int layerCount = int(params.layer_count);

    float maxWet = 0.0;
    for (int layer = 0; layer < layerCount; layer++) {
        uint idx = pixelIndex + uint(layer) * layerStride;
        maxWet = max(maxWet, float(layers[idx].wetness));
    }

    // Blue = wet, red = dry, black = empty
    half r = half(maxWet < 0.01 ? 0.0 : (1.0 - maxWet));
    half g = 0.0h;
    half b = half(maxWet);
    output.write(half4(r, g, b, 1.0h), gid);
}
"""

    static let debugDepth = header + """
kernel void debugDepth(
    device const VolumeLayer* layers [[buffer(0)]],
    texture2d<half, access::write> output [[texture(0)]],
    constant RenderParams& params [[buffer(1)]],
    constant ViewParams& view [[buffer(2)]],
    uint2 gid [[thread_position_in_grid]]
) {
    int dw = int(view.drawable_width);
    int dh = int(view.drawable_height);
    if (int(gid.x) >= dw || int(gid.y) >= dh) return;

    int cw = int(view.canvas_width);
    int ch = int(view.canvas_height);

    float fitScale = min(float(dw) / float(cw), float(dh) / float(ch));
    float scale = fitScale * view.zoom_level;
    float baseX = float(cw) / 2.0 - float(dw) / (2.0 * scale);
    float baseY = float(ch) / 2.0 - float(dh) / (2.0 * scale);
    int cx = int(floor(float(gid.x) / scale + baseX + view.pan_offset_x));
    int cy = int(floor(float(gid.y) / scale + baseY + view.pan_offset_y));

    if (cx < 0 || cx >= cw || cy < 0 || cy >= ch) {
        output.write(half4(0.1h, 0.1h, 0.1h, 1.0h), gid);
        return;
    }

    uint pixelIndex = uint(cy) * uint(cw) + uint(cx);
    uint layerStride = uint(cw) * uint(ch);
    int layerCount = int(params.layer_count);

    float maxDepth = 0.0;
    for (int layer = 0; layer < layerCount; layer++) {
        uint idx = pixelIndex + uint(layer) * layerStride;
        maxDepth = max(maxDepth, float(layers[idx].depth));
    }

    float v = clamp(maxDepth * 50.0, 0.0, 1.0);
    output.write(half4(half(v), half(v), half(v), 1.0h), gid);
}
"""
}
